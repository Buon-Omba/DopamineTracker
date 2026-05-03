import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dopamine_tracker/components/line_chart.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import '../services/health_service.dart';
import '../services/smoke_log_service.dart';
import '../services/daily_log_service.dart';

enum ChartRange { week, twoWeeks, month, sixMonths, year }

class _ChartEntry {
  final String label;
  final double triggerValue;
  final double moodValue;
  final double heartRateValue;
  final double stressValue;
  _ChartEntry({
    required this.label,
    required this.triggerValue,
    required this.moodValue,
    required this.heartRateValue,
    required this.stressValue,
  });
}

class CalendarScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const CalendarScreen({super.key, required this.setThemeMode});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Addiction> _addictions = [];
  Addiction? _selectedAddiction;

  Map<DateTime, int> _log = {};
  Map<DateTime, DailyLogEntry> _dailyEntries = {};
  Map<DateTime, double> _heartRateLog = {};
  Map<DateTime, double> _stressLog = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  ChartRange _selectedRange = ChartRange.week;
  int? _selectedDayScore;
  double? _todayHeartRate;
  double? _todayStress;

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
    await _loadLog();
    await _loadSelectedDayScore();
    await _loadHeartRate();
  }

  Future<void> _loadHeartRate() async {
    final healthService = HealthService();

    final cachedRate = await healthService.getSavedTodayHeartRate();
    final cachedStress = await healthService.getSavedTodayStress();

    if (mounted) {
      setState(() {
        _todayHeartRate = cachedRate;
        _todayStress = cachedStress;
      });
    }

    final currentRate = await healthService.updateAndSaveTodayHeartRate();
    final currentStress = await healthService.updateAndSaveTodayStress();
    if (mounted) {
      setState(() {
        if (currentRate != null) _todayHeartRate = currentRate;
        if (currentStress != null) _todayStress = currentStress;
      });
    }
  }

  Future<void> _loadLog() async {
    if (_selectedAddiction == null) return;
    
    final log = await DopamineLogService.loadCalendarLog(_selectedAddiction!.id);
    final dailyEntries = await DailyLogService.loadAllEntries();
    
    final healthService = HealthService();
    final hrLog = await healthService.fetchDailyAverageHeartRate(days: 365);
    final stressLog = await healthService.fetchDailyAverageStress(days: 365);

    if (!mounted) return;
    setState(() {
      _log = log;
      _dailyEntries = dailyEntries;
      _heartRateLog = hrLog;
      _stressLog = stressLog;
    });
  }

  Future<void> _loadSelectedDayScore() async {
    final entry = await DailyLogService.getEntry(_selectedDay);
    if (!mounted) return;
    setState(() {
      _selectedDayScore = entry?.totalScore;
    });
  }

  int _countForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _log[normalized] ?? 0;
  }

  int _scoreForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _dailyEntries[normalized]?.totalScore ?? 0;
  }

  double _heartRateForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _heartRateLog[normalized] ?? 0;
  }

  double _stressForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _stressLog[normalized] ?? 0;
  }

  DateTime get _firstDay {
    final now = DateTime.now();
    final baseline = DateTime(now.year - 1, now.month, 1);

    if (_log.isEmpty && _dailyEntries.isEmpty && _heartRateLog.isEmpty && _stressLog.isEmpty) {
      return baseline;
    }

    DateTime earliest = baseline;
    final allKeys = [
      ..._log.keys,
      ..._dailyEntries.keys,
      ..._heartRateLog.keys,
      ..._stressLog.keys
    ];
    if (allKeys.isNotEmpty) {
      final e = allKeys.reduce((a, b) => a.isBefore(b) ? a : b);
      if (e.isBefore(earliest)) earliest = e;
    }

    return earliest;
  }

  DateTime get _lastDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 365));
  }

  List<_ChartEntry> _buildRangeData(String localeString) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedRange) {
      case ChartRange.week:
        return _buildDailyEntries(today, 7, localeString);
      case ChartRange.twoWeeks:
        return _buildDailyEntries(today, 14, localeString);
      case ChartRange.month:
        return _buildDailyEntries(today, 30, localeString, monthMode: true);
      case ChartRange.sixMonths:
        return _buildMonthlyEntries(today, localeString, months: 6);
      case ChartRange.year:
        return _buildMonthlyEntries(today, localeString, months: 12);
    }
  }

  List<_ChartEntry> _buildDailyEntries(
    DateTime today,
    int days,
    String localeString, {
    bool monthMode = false,
  }) {
    return List.generate(days, (index) {
      final day = today.subtract(Duration(days: days - index - 1));
      String label;
      if (monthMode) {
        if ((index + 1) % 5 == 0) {
          label = DateFormat.d(localeString).format(day);
        } else {
          label = ''; 
        }
      } else {
        label = DateFormat.Md(localeString).format(day);
      }
      return _ChartEntry(
        label: label,
        triggerValue: _countForDay(day).toDouble(),
        moodValue: _scoreForDay(day).toDouble(),
        heartRateValue: _heartRateForDay(day),
        stressValue: _stressForDay(day),
      );
    });
  }

  List<_ChartEntry> _buildMonthlyEntries(
    DateTime today,
    String localeString, {
    int months = 12,
  }) {
    final format = DateFormat.MMM(localeString);
    return List.generate(months, (index) {
      final monthDate = DateTime(today.year, today.month - (months - 1 - index), 1);
      return _ChartEntry(
        label: format.format(monthDate),
        triggerValue: _countForMonth(monthDate).toDouble(),
        moodValue: _moodScoreForMonth(monthDate).toDouble(),
        heartRateValue: _avgHeartRateForMonth(monthDate),
        stressValue: _avgStressForMonth(monthDate),
      );
    });
  }

  int _countForMonth(DateTime monthStart) {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    int total = 0;
    for (final entry in _log.entries) {
      final day = entry.key;
      if (!day.isBefore(start) && day.isBefore(nextMonth)) {
        total += entry.value;
      }
    }
    return total;
  }

  int _moodScoreForMonth(DateTime monthStart) {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    int total = 0;
    for (final entry in _dailyEntries.entries) {
      final day = entry.key;
      if (!day.isBefore(start) && day.isBefore(nextMonth)) {
        total += entry.value.totalScore;
      }
    }
    return total;
  }

  double _avgHeartRateForMonth(DateTime monthStart) {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    double total = 0;
    int count = 0;
    for (final entry in _heartRateLog.entries) {
      final day = entry.key;
      if (!day.isBefore(start) && day.isBefore(nextMonth)) {
        total += entry.value;
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  double _avgStressForMonth(DateTime monthStart) {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    double total = 0;
    int count = 0;
    for (final entry in _stressLog.entries) {
      final day = entry.key;
      if (!day.isBefore(start) && day.isBefore(nextMonth)) {
        total += entry.value;
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _countForDay(_selectedDay);
    final localeString = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat.yMMMMd(localeString).format(_selectedDay);
    final todayCount = _countForDay(DateTime.now());
    final combinedEntries = _buildRangeData(localeString);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final addictionName = _selectedAddiction?.name ?? 'Dopamine';

    final bool isToday = isSameDay(_selectedDay, DateTime.now());
    final displayHR = isToday ? (_todayHeartRate ?? 0.0) : _heartRateForDay(_selectedDay);
    final displayStress = isToday ? (_todayStress ?? 0.0) : _stressForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: _addictions.isEmpty 
          ? Text(l10n.logScreenTitle(addictionName))
          : DropdownButton<Addiction>(
              value: _selectedAddiction,
              underline: const SizedBox(),
              items: _addictions.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (val) {
                setState(() => _selectedAddiction = val);
                _loadLog();
              },
            ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadLog();
          await _loadSelectedDayScore();
          await _loadHeartRate();
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.logScreenToday,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          todayCount.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          todayCount == 1 
                              ? l10n.logScreenCigaretteSingular(addictionName)
                              : l10n.logScreenCigarettePlural(addictionName),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  locale: localeString,
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableGestures: AvailableGestures.all,
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!mounted) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadSelectedDayScore();
                  },
                  onDayLongPressed: (selectedDay, focusedDay) {
                    if (!mounted) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadSelectedDayScore();
                    _showEditDialog(selectedDay);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final count = _countForDay(day);
                    if (count == 0) return const [];
                    return List.generate(count, (index) => index);
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final count = _countForDay(date);
                      if (count == 0) return null;

                      return Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<ChartRange>(
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            visualDensity:
                                VisualDensity(horizontal: -2, vertical: -2),
                          ),
                          segments: [
                            ButtonSegment(
                              value: ChartRange.week,
                              label: Text(l10n.logScreenRange7d),
                            ),
                            ButtonSegment(
                              value: ChartRange.twoWeeks,
                              label: Text(l10n.logScreenRange14d),
                            ),
                            ButtonSegment(
                              value: ChartRange.month,
                              label: Text(l10n.logScreenRange30d),
                            ),
                            ButtonSegment(
                              value: ChartRange.sixMonths,
                              label: Text(l10n.logScreenRange180d),
                            ),
                            ButtonSegment(
                              value: ChartRange.year,
                              label: Text(l10n.logScreenRange365d),
                            ),
                          ],
                          selected: {_selectedRange},
                          onSelectionChanged: (selection) {
                            if (!mounted) return;
                            setState(() {
                              _selectedRange = selection.first;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        datasets: [
                          LineChartData(
                            entries: combinedEntries
                                .map((e) => LineChartEntry(label: e.label, value: e.triggerValue))
                                .toList(),
                            color: colorScheme.primary,
                          ),
                          LineChartData(
                            entries: combinedEntries
                                .map((e) => LineChartEntry(label: e.label, value: e.moodValue))
                                .toList(),
                            color: Colors.red,
                            minValue: -30,
                            maxValue: 30,
                          ),
                          LineChartData(
                            entries: combinedEntries
                                .map((e) => LineChartEntry(label: e.label, value: e.heartRateValue))
                                .toList(),
                            color: Colors.orange,
                            minValue: 80,
                            maxValue: 130,
                          ),
                          LineChartData(
                            entries: combinedEntries
                                .map((e) => LineChartEntry(label: e.label, value: e.stressValue))
                                .toList(),
                            color: Colors.teal,
                            minValue: 0,
                            maxValue: 100,
                          ),
                        ],
                        emptyLabel: l10n.logScreenChartEmpty,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _LegendItem(color: colorScheme.primary, label: l10n.logScreenCigarettePlural(addictionName)),
                        _LegendItem(color: Colors.red, label: 'Mood'),
                        _LegendItem(color: Colors.orange, label: 'BPM'),
                        _LegendItem(color: Colors.teal, label: 'Stress (HRV)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.logScreenSelectedDayHeader,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 20,
                       // fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.logScreenSelectedDayText(
                                  selectedCount.toString(),
                                  formattedDate,
                                  addictionName,
                                ),
                            style: TextStyle(
                              fontSize: 16,
                              //color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_dailyEntries[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]?.moods.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sentiment_satisfied_alt, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dailyEntries[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]!
                                    .moods
                                    .map((m) => "${DailyLogService.moodEmojis[m]} ${_getMoodLabel(m, context)}")
                                    .join(", "),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.logTodayHR(displayHR.round().toString()),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.logTodayStress(displayStress.round().toString()),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_log.isEmpty && _dailyEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.logScreenEmptyHint(addictionName),
                //  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2, setThemeMode: widget.setThemeMode),
    );
  }

  Future<void> _showEditDialog(DateTime day) async {
    if (_selectedAddiction == null) return;
    
    final initial = _countForDay(day);
    final controller = TextEditingController(text: initial.toString());
    final l10n = AppLocalizations.of(context)!;
    final addictionName = _selectedAddiction!.name;

    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logEditTitle),
        content: TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.logEditCountLabel(
                    DateFormat.yMMMd(
                            Localizations.localeOf(context).toString())
                        .format(day),
                    addictionName),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (initial > 0)
            TextButton(
              onPressed: () => Navigator.pop(context, _EditResult.delete),
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, _EditResult.save),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == _EditResult.delete) {
      await DopamineLogService.removeDate(_selectedAddiction!.id, day);
    } else if (result == _EditResult.save) {
      final parsed = int.tryParse(controller.text.trim()) ?? 0;
      await DopamineLogService.setCountForDate(_selectedAddiction!.id, day, parsed);
    }

    if (!mounted) return;
    await _loadLog();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

enum _EditResult { save, delete }

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
