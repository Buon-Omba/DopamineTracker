import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'config_screen.dart';
import 'about_screen.dart';
import '../services/smoke_log_service.dart';
//import '../widget_provider.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const MainScreen({super.key, required this.setThemeMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  List<Addiction> _addictions = [];
  Addiction? _selectedAddiction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAddictions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when returning from background (e.g. widget was used)
      DopamineLogService.notifyUpdate();
    }
  }

  Future<void> _loadAddictions() async {
    final list = await DopamineLogService.getAddictions();
    if (!mounted) return;
    setState(() {
      _addictions = list;
      if (_selectedAddiction == null && _addictions.isNotEmpty) {
        _selectedAddiction = _addictions.first;
      } else if (_selectedAddiction != null && !_addictions.contains(_selectedAddiction)) {
         _selectedAddiction = _addictions.isNotEmpty ? _addictions.first : null;
      }
    });
  }

  void _showAddAddictionDialog() {
    final controller = TextEditingController();
    String? errorText;

    String formatName(String input) {
      if (input.isEmpty) return "";
      return input[0].toUpperCase() + input.substring(1).toLowerCase();
    }

    bool isOnlyText(String input) {
      return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(input);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Aggiungi dipendenza"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Esempio: Social Media, Zucchero...",
              errorText: errorText,
            ),
            autofocus: true,
            onChanged: (_) => setDialogState(() => errorText = null),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
            TextButton(
              onPressed: () async {
                final input = controller.text.trim();
                if (input.isEmpty) {
                  setDialogState(() => errorText = "Inserisci un nome");
                  return;
                }
                if (!isOnlyText(input)) {
                  setDialogState(() => errorText = "Inserisci solo lettere");
                  return;
                }
                
                final formattedName = formatName(input);
                await DopamineLogService.addAddiction(formattedName);
                await _loadAddictions();
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Aggiungi"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Use Key to force reconstruction of pages when selection changes
    final List<Widget> pages = [
      HomeScreen(
        key: ValueKey('home_${_selectedAddiction?.id}'),
        setThemeMode: widget.setThemeMode, 
        selectedAddiction: _selectedAddiction
      ),
      CalendarScreen(
        key: ValueKey('calendar_${_selectedAddiction?.id}'),
        setThemeMode: widget.setThemeMode, 
        selectedAddiction: _selectedAddiction
      ),
      StatsScreen(
        key: ValueKey('stats_${_selectedAddiction?.id}'),
        setThemeMode: widget.setThemeMode, 
        selectedAddiction: _selectedAddiction
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Column(
          children: [
            const Text(
              'Dopamine Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_addictions.isNotEmpty)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<Addiction>(
                      value: _selectedAddiction,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _addictions
                          .map((a) => DropdownMenuItem(
                                value: a,
                                child: Text(a.name),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAddiction = val;
                        });
                      },
                    ),
                  )
                else
                  const SizedBox(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: _showAddAddictionDialog,
                      tooltip: "Aggiungi dipendenza",
                    ),
                    PopupMenuButton<String>(
                      iconSize: 20,
                      onSelected: (value) {
                        if (value == 'config') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfigScreen(
                                    setThemeMode: widget.setThemeMode)),
                          ).then((_) => _loadAddictions());
                        } else if (value == 'about') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'config',
                          child: Text(l10n.homeMenuConfig),
                        ),
                        PopupMenuItem(
                          value: 'about',
                          child: Text(l10n.homeMenuAbout),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navigationBarHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: l10n.navigationBarCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statsScreenTitle,
          ),
        ],
      ),
    );
  }
}
