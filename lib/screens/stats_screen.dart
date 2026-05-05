import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/line_chart.dart';
import '../services/health_service.dart';
import '../services/smoke_log_service.dart';
import '../services/daily_log_service.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  final Addiction? selectedAddiction;
  const StatsScreen({super.key, required this.setThemeMode, this.selectedAddiction});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final HealthService _healthService = HealthService();
  
  Map<DateTime, double> _heartRateData = {};
  Map<DateTime, double> _stressData = {};
  Map<DateTime, int> _triggerLog = {};
  Map<DateTime, DailyLogEntry> _dailyEntries = {};
  Map<String, String> _customEmojis = {};
  bool _isLoading = true;
  bool _isAuthorized = false;
  StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
    _updateSubscription = DopamineLogService.updates.listen((_) {
      _fetchData();
    });
  }

  @override
  void didUpdateWidget(StatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddiction != oldWidget.selectedAddiction) {
      _fetchData();
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthorization() async {
    setState(() {
      _isLoading = true;
    });

    bool alreadyAuthorized = await _healthService.isAuthorized();
    if (alreadyAuthorized) {
      await _fetchData();
    } else {
      await _fetchNonHealthData();
      setState(() {
        _isLoading = false;
        _isAuthorized = false;
      });
    }
  }

  Future<void> _fetchNonHealthData() async {
    if (widget.selectedAddiction == null) return;
    final triggers = await DopamineLogService.loadCalendarLog(widget.selectedAddiction!.id);
    final dailyEntries = await DailyLogService.loadAllEntries();
    final customEmojis = await DailyLogService.getCustomEmojis();
    setState(() {
      _triggerLog = triggers;
      _dailyEntries = dailyEntries;
      _customEmojis = customEmojis;
    });
  }

  Future<void> _fetchData() async {
    if (widget.selectedAddiction == null) {
       setState(() => _isLoading = false);
       return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final hr = await _healthService.fetchDailyAverageHeartRate(days: 7);
      final stress = await _healthService.fetchDailyAverageStress(days: 7);
      final triggers = await DopamineLogService.loadCalendarLog(widget.selectedAddiction!.id);
      final dailyEntries = await DailyLogService.loadAllEntries();
      final customEmojis = await DailyLogService.getCustomEmojis();

      setState(() {
        _heartRateData = hr;
        _stressData = stress;
        _triggerLog = triggers;
        _dailyEntries = dailyEntries;
        _customEmojis = customEmojis;
        _isAuthorized = true;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authorizeAndFetch() async {
    setState(() {
      _isLoading = true;
    });
    bool authorized = await _healthService.authorize();
    if (authorized) {
      await _fetchData();
    } else {
      await _fetchNonHealthData();
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("${widget.selectedAddiction?.name ?? 'Dopamine'} Triggers (7d)"),
                  _buildChartContainer(
                    LineChart(
                      datasets: [
                        LineChartData(
                          entries: _getLast7DaysEntries((date) => (_triggerLog[date] ?? 0).toDouble()),
                          color: colorScheme.primary,
                        ),
                      ],
                      emptyLabel: localizations.logScreenChartEmpty,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Recent Activity (7d)"),
                  _buildRecentActivitySection(localizations),
                  const SizedBox(height: 24),

                  if (!_isAuthorized)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _authorizeAndFetch,
                          child: Text(localizations.statsAuthorizeButton),
                        ),
                      ),
                    )
                  else ...[
                    _buildSectionTitle(localizations.statsHeartRateTitle),
                    _buildChartContainer(
                      LineChart(
                        datasets: [
                          LineChartData(
                            entries: _getLast7DaysEntries((date) => _heartRateData[date] ?? 0),
                            color: Colors.orange,
                            minValue: 80,
                            maxValue: 130,
                          ),
                        ],
                        emptyLabel: localizations.logScreenChartEmpty,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(localizations.statsStressTitle),
                    _buildChartContainer(
                      LineChart(
                        datasets: [
                          LineChartData(
                            entries: _getLast7DaysEntries((date) => _stressData[date] ?? 0),
                            color: Colors.teal,
                            minValue: 0,
                            maxValue: 100,
                          ),
                        ],
                        emptyLabel: localizations.logScreenChartEmpty,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChartContainer(Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(height: 200, child: chart),
      ),
    );
  }

  List<LineChartEntry> _getLast7DaysEntries(double Function(DateTime) getValue) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      return LineChartEntry(
        label: DateFormat('E').format(date),
        value: getValue(date),
      );
    });
  }

  Widget _buildRecentActivitySection(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (index) => today.subtract(Duration(days: index)));

    return Column(
      children: days.map((date) {
        final entry = _dailyEntries[date];
        if (entry == null || (entry.moods.isEmpty && entry.activities.isEmpty && entry.others.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                if (entry.moods.isNotEmpty)
                  _buildActivityRow(Icons.sentiment_satisfied, Colors.orange, 
                    entry.moods.map((m) => "${DailyLogService.moodEmojis[m] ?? _customEmojis[m] ?? '✨'} ${_getMoodLabel(m, context)}").join(", ")),
                if (entry.activities.isNotEmpty)
                  _buildActivityRow(Icons.directions_run, Colors.green, 
                    entry.activities.map((a) => "${DailyLogService.activityEmojis[a] ?? _customEmojis[a] ?? '✨'} ${_getActivityLabel(a, context)}").join(", ")),
                if (entry.others.isNotEmpty)
                  _buildActivityRow(Icons.more_horiz, Colors.blue, 
                    entry.others.map((o) => "${DailyLogService.otherEmojis[o] ?? _customEmojis[o] ?? '✨'} ${_getOtherLabel(o, context)}").join(", ")),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 17))),
        ],
      ),
    );
  }

  String _getMoodLabel(String moodKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (moodKey) {
      case 'calm': return l10n.moodCalm;
      case 'happy': return l10n.moodHappy;
      case 'energetic': return l10n.moodEnergetic;
      case 'lively': return l10n.moodLively;
      case 'mood_swings': return l10n.moodMoodSwings;
      case 'irritated': return l10n.moodIrritated;
      case 'sad': return l10n.moodSad;
      case 'anxious': return l10n.moodAnxious;
      case 'depressed': return l10n.moodDepressed;
      case 'guilt': return l10n.moodGuilt;
      case 'obsessive': return l10n.moodObsessiveThoughts;
      case 'low_energy': return l10n.moodLowEnergy;
      case 'apathetic': return l10n.moodApathetic;
      case 'confused': return l10n.moodConfused;
      case 'self_critical': return l10n.moodSelfCritical;
      default: return moodKey;
    }
  }

  String _getActivityLabel(String activityKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (activityKey) {
      case 'none': return l10n.activityNone;
      case 'yoga': return l10n.activityYoga;
      case 'gym': return l10n.activityGym;
      case 'aerobics': return l10n.activityAerobics;
      case 'swimming': return l10n.activitySwimming;
      case 'team_sports': return l10n.activityTeamSports;
      case 'running': return l10n.activityRunning;
      case 'cycling': return l10n.activityCycling;
      case 'walking': return l10n.activityWalking;
      default: return activityKey;
    }
  }

  String _getOtherLabel(String otherKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (otherKey) {
      case 'travel': return l10n.otherTravel;
      case 'stress': return l10n.otherStress;
      case 'meditation': return l10n.otherMeditation;
      case 'journaling': return l10n.otherJournaling;
      case 'kegel': return l10n.otherKegel;
      case 'breathing': return l10n.otherBreathing;
      case 'illness': return l10n.otherIllness;
      case 'alcohol': return l10n.otherAlcohol;
      default: return otherKey;
    }
  }
}
