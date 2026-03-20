import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/time_formatter.dart';
import '../utils/calculations.dart';
import 'config_screen.dart';
import 'about_screen.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import '../components/navigation_bar.dart';
import '../services/smoke_log_service.dart';
import '../widget_provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const HomeScreen({super.key, required this.setThemeMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Addiction> addictions = [];
  Addiction? selectedAddiction;
  
  DateTime? lastTrigger;
  bool isFirstTime = true;
  bool _friendsEnabled = true;

  int weeklyOccurrences = 0;
  int dailyIntensity = 0;

  double benefitScore = 0.0;
  int triggersAvoided = 0;
  int triggersLoggedToday = 0;
  int hoursWithoutTriggers = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _generateAndSaveUserId();
    _initializeData();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCalculations());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeData();
    }
  }

  Future<void> _generateAndSaveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      var uuid = const Uuid();
      userId = uuid.v4();
      await prefs.setString('userId', userId);
    }
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!mounted) return;

    await _loadAddictions();
    await _loadConfigData();
    await _loadSelectedAddictionData();
    _updateCalculations();
  }

  Future<void> _loadAddictions() async {
    final list = await DopamineLogService.getAddictions();
    if (!mounted) return;
    setState(() {
      addictions = list;
      if (selectedAddiction == null && addictions.isNotEmpty) {
        selectedAddiction = addictions.first;
      }
    });
  }

  Future<void> _loadSelectedAddictionData() async {
    if (selectedAddiction == null) return;
    
    final last = await DopamineLogService.getLastTrigger(selectedAddiction!.id);
    final count = await DopamineLogService.countForDate(selectedAddiction!.id, DateTime.now());
    
    if (!mounted) return;
    setState(() {
      lastTrigger = last;
      triggersLoggedToday = count;
      isFirstTime = last == null;
    });
  }

  Future<void> _loadConfigData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      weeklyOccurrences = prefs.getInt('packetsPerWeek') ?? 0;
      dailyIntensity = prefs.getInt('cigarettesPerPacket') ?? 0;
      _friendsEnabled = prefs.getBool('friendsEnabled') ?? true;
    });
  }

  Future<void> _updateCalculations() async {
    if (lastTrigger != null) {
      double saved = await Calculations.calculateMoneySaved(lastTrigger!);
      int avoided = await Calculations.calculateCigarettesAvoided(
        lastTrigger!,
        weeklyOccurrences,
        dailyIntensity,
      );
      
      final duration = DateTime.now().difference(lastTrigger!);
      final hours = duration.inHours;

      if (!mounted) return;
      setState(() {
        benefitScore = saved;
        triggersAvoided = avoided;
        hoursWithoutTriggers = hours;
      });
    } else {
      if (!mounted) return;
      setState(() {
        benefitScore = 0.0;
        triggersAvoided = 0;
        hoursWithoutTriggers = 0;
      });
    }
  }

  Future<void> _logTrigger() async {
    if (selectedAddiction == null) return;
    
    final now = DateTime.now();
    await DopamineLogService.logTrigger(selectedAddiction!.id, timestamp: now);
    
    if (!mounted) return;
    await _loadSelectedAddictionData();
    await _updateCalculations();
    await WidgetProvider.updateWidgets();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context)!.homeSnackBarCigaretteLogged(selectedAddiction?.name ?? 'Dopamine'))),
    );
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
    final duration = lastTrigger != null
        ? DateTime.now().difference(lastTrigger!)
        : const Duration();
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final addictionName = selectedAddiction?.name ?? 'Dopamine';

    final timeComponents = {
      'days': duration.inDays,
      'hours': duration.inHours % 24,
      'minutes': duration.inMinutes % 60
    };

    return Scaffold(
      appBar: AppBar(
        title: addictions.isEmpty 
          ? const Text('')
          : DropdownButton<Addiction>(
              value: selectedAddiction,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: addictions.map((a) => DropdownMenuItem(
                value: a,
                child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedAddiction = val;
                });
                _loadSelectedAddictionData();
              },
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAddictionDialog,
            tooltip: "Aggiungi dipendenza",
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'config') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfigScreen(setThemeMode: widget.setThemeMode)),
                ).then((_) => _initializeData());
              } else if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dopamine Tracker',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              selectedAddiction != null 
                ? "Stai tracciando: ${selectedAddiction!.name}"
                : l10n.homeTagline,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeSinceLastTitle(addictionName),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatTime(timeComponents),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatLastTrigger(locale, context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final columnCount = isWide ? 3 : 2;
                final itemWidth =
                    (constraints.maxWidth - (12 * (columnCount - 1))) /
                        columnCount;

                final colorScheme = Theme.of(context).colorScheme;
                final items = [
                  _buildStatCard(
                    icon: Icons.check_circle,
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    text:
                        l10n.homeCigarettesAvoidedText(
                      triggersAvoided.toString(),
                      addictionName,
                    ),
                    availableWidth: itemWidth,
                  ),
                  _buildStatCard(
                    icon: Icons.star,
                    color: colorScheme.secondaryContainer.withOpacity(0.5),
                    text: l10n.homeMoneySavedText(
                      benefitScore.toStringAsFixed(1),
                    ),
                    availableWidth: itemWidth,
                  ),
                  _buildStatCard(
                    icon: Icons.bolt,
                    color: colorScheme.tertiaryContainer.withOpacity(0.5),
                    text: l10n.homeSmokedTodayText(
                      triggersLoggedToday.toString(),
                      addictionName,
                    ),
                    availableWidth: itemWidth,
                  ),
                  _buildStatCard(
                    icon: Icons.access_time,
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    text: l10n.homeHoursWithoutSmokingText(
                      hoursWithoutTriggers.toString(),
                      addictionName,
                    ),
                    availableWidth: itemWidth,
                  ),
                ];

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items,
                );
              },
            ),
            const SizedBox(height: 16),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            ElevatedButton.icon(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _logTrigger,
                            label: Text(
                              l10n.homeLogCigaretteButton(addictionName),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                            ),
                          ),
                        const SizedBox(width: 12),
                      ],
                    ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0, setThemeMode: widget.setThemeMode),
    );
  }

  String _formatLastTrigger(String locale, BuildContext context) {
    if (lastTrigger == null) {
      return AppLocalizations.of(context)!.homeNotStartedYet;
    }
    return AppLocalizations.of(context)!.homeLastSmokedLabel(
      DateFormat.yMMMMd(locale).add_Hm().format(lastTrigger!.toLocal()),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String text,
    required double availableWidth,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: availableWidth,
      child: Card(
        color: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
