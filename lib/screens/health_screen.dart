import 'package:flutter/material.dart';
import '../components/health_goal_card.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';
import '../services/smoke_log_service.dart';

class HealthScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const HealthScreen({super.key, required this.setThemeMode});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<Addiction> _addictions = [];
  Addiction? _selectedAddiction;
  DateTime? lastTrigger;
  int durationSinceLastTrigger = 0;
  bool noTriggers = true; 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final list = await DopamineLogService.getAddictions();
    setState(() {
      _addictions = list;
      if (_addictions.isNotEmpty) {
        _selectedAddiction = _addictions.first;
      }
    });
    await _loadLastTrigger();
  }

  Future<void> _loadLastTrigger() async {
    if (_selectedAddiction == null) return;
    
    final last = await DopamineLogService.getLastTrigger(_selectedAddiction!.id);

    if (!mounted) return; 

    if (last != null) {
      setState(() {
        lastTrigger = last;
        durationSinceLastTrigger = DateTime.now().difference(lastTrigger!).inMinutes;
        noTriggers = false; 
      });
    } else {
      setState(() {
        noTriggers = true; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addictionName = _selectedAddiction?.name ?? 'Dopamine';

    List<Map<String, dynamic>> healthGoals = [
      {
        'title': l10n.health2DaysTitle(addictionName),
        'description': l10n.health2DaysText(addictionName),
        'time': 2 * 24 * 60,
      },
      {
        'title': l10n.health3DaysTitle(addictionName),
        'description': l10n.health3DaysText,
        'time': 3 * 24 * 60,
      },
      {
        'title': l10n.health7DaysTitle(addictionName),
        'description': l10n.health7DaysText,
        'time': 7 * 24 * 60,
      },
      {
        'title': l10n.health2WeeksTitle(addictionName),
        'description': l10n.health2WeeksText,
        'time': 2 * 7 * 24 * 60,
      },
      {
        'title': l10n.health1MonthTitle(addictionName),
        'description': l10n.health1MonthText,
        'time': 30 * 24 * 60,
      },
      {
        'title': l10n.health2MonthsTitle(addictionName),
        'description': l10n.health2MonthsText,
        'time': (2.5 * 30 * 24 * 60).toInt(),
      },
      {
        'title': l10n.health3MonthsTitle(addictionName),
        'description': l10n.health3MonthsText(addictionName),
        'time': 3 * 30 * 24 * 60,
      },
      {
        'title': l10n.health1YearTitle(addictionName),
        'description': l10n.health1YearText,
        'time': 365 * 24 * 60,
      },
      {
        'title': l10n.health5YearsTitle(addictionName),
        'description': l10n.health5YearsText,
        'time': 5 * 365 * 24 * 60,
      },
      {
        'title': l10n.health15YearsTitle(addictionName),
        'description': l10n.health15YearsText,
        'time': 15 * 365 * 24 * 60,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: _addictions.isEmpty 
          ? Text(l10n.navigationBarHealthGoals)
          : DropdownButton<Addiction>(
              value: _selectedAddiction,
              underline: const SizedBox(),
              items: _addictions.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (val) {
                setState(() => _selectedAddiction = val);
                _loadLastTrigger();
              },
            ),
      ),
      body: noTriggers 
        ? Center(child: Text(l10n.healthScreenNoCigarettesYetTitle(addictionName)))
        : CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: lastTrigger == null
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = healthGoals[index];
                          final progress = durationSinceLastTrigger / goal['time'];
                          final completed = progress >= 1.0;

                          return HealthGoalCard(
                            title: goal['title'],
                            description: goal['description'],
                            progress: progress,
                            completed: completed,
                            timeRemaining: goal['time'] - durationSinceLastTrigger,
                          );
                        },
                        childCount: healthGoals.length,
                      ),
                    ),
            ),
          ],
        ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1, setThemeMode: widget.setThemeMode),
    );
  }
}
