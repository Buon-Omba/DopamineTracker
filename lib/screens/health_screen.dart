import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/health_goal_card.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';

class HealthScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const HealthScreen({super.key, required this.setThemeMode});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  DateTime? lastTrigger;
  int durationSinceLastTrigger = 0;
  bool noTriggers = true; 

  @override
  void initState() {
    super.initState();
    _loadLastTrigger();
  }

  Future<void> _loadLastTrigger() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastTriggerString = prefs.getString('lastTrigger');

    if (!mounted) return; 

    if (lastTriggerString != null) {
      DateTime parsedDate = DateTime.parse(lastTriggerString);
      setState(() {
        lastTrigger = parsedDate;
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
    List<Map<String, dynamic>> healthGoals = [
      {
        'title': AppLocalizations.of(context)!.health2DaysTitle,
        'description': AppLocalizations.of(context)!.health2DaysText,
        'time': 2 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health3DaysTitle,
        'description': AppLocalizations.of(context)!.health3DaysText,
        'time': 3 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health7DaysTitle,
        'description': AppLocalizations.of(context)!.health7DaysText,
        'time': 7 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health2WeeksTitle,
        'description': AppLocalizations.of(context)!.health2WeeksText,
        'time': 2 * 7 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health1MonthTitle,
        'description': AppLocalizations.of(context)!.health1MonthText,
        'time': 30 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health2MonthsTitle,
        'description': AppLocalizations.of(context)!.health2MonthsText,
        'time': (2.5 * 30 * 24 * 60).toInt(),
      },
      {
        'title': AppLocalizations.of(context)!.health3MonthsTitle,
        'description': AppLocalizations.of(context)!.health3MonthsText,
        'time': 3 * 30 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health1YearTitle,
        'description': AppLocalizations.of(context)!.health1YearText,
        'time': 365 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health5YearsTitle,
        'description': AppLocalizations.of(context)!.health5YearsText,
        'time': 5 * 365 * 24 * 60,
      },
      {
        'title': AppLocalizations.of(context)!.health15YearsTitle,
        'description': AppLocalizations.of(context)!.health15YearsText,
        'time': 15 * 365 * 24 * 60,
      },
    ];

    if (noTriggers) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(AppLocalizations.of(context)?.healthScreenNoCigarettesYetTitle ?? 'Log your first trigger'),
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(currentIndex: 1, setThemeMode: widget.setThemeMode),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(AppLocalizations.of(context)!.navigationBarHealthGoals),
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
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
}
