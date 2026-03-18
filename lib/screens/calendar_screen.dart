import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dopamine_tracker/components/line_chart.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import '../services/smoke_log_service.dart';
import '../services/daily_log_service.dart';

enum ChartRange { week, twoWeeks, month, sixMonths, year }

class _ChartEntry {
  final String label;
  final int value;
  _ChartEntry({required this.label, required this.value});
}

class CalendarScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const CalendarScreen({super.key, required this.setThemeMode});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, int> _log = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  ChartRange _selectedRange = ChartRange.week;
  int? _selectedDayScore;

  @override
  void initState() {
    super.initState();
    _loadLog();
    _loadSelectedDayScore();
  }

  Future<void> _loadLog() async {
    final log = await DopamineLogService.loadCalendarLog();
    if (!mounted) return;
    setState(() {
      _log = log;
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

  DateTime get _firstDay {
    final now = DateTime.now();
    final baseline = DateTime(now.year - 1, now.month, 1);

    if (_log.isEmpty) {
      return baseline;
    }

    final earliest = _log.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    return earliest.isBefore(baseline) ? earliest : baseline;
  }

  DateTime get _lastDay {
    final now = DateTime.now();
    final baseline =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 365));

    if (_log.isEmpty) {
      return baseline;
    }

    final latest = _log.keys
        .reduce((a, b) => a.isAfter(b) ? a : b)
        .add(const Duration(days: 365));
    return latest.isAfter(baseline) ? latest : baseline;
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
        value: _countForDay(day),
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
        value: _countForMonth(monthDate),
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

  @override
  Widget build(BuildContext context) {
    final selectedCount = _countForDay(_selectedDay);
    final localeString = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat.yMMMMd(localeString).format(_selectedDay);
    final todayCount = _countForDay(DateTime.now());
    final chartEntries = _buildRangeData(localeString);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.logScreenTitle ?? 'Dopamine Log'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadLog();
          await _loadSelectedDayScore();
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
                      l10n?.logScreenToday ?? 'Today',
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
                              ? (l10n?.logScreenCigaretteSingular ?? 'trigger')
                              : (l10n?.logScreenCigarettePlural ?? 'triggers'),
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
                              label: Text(l10n?.logScreenRange7d ?? '7 days'),
                            ),
                            ButtonSegment(
                              value: ChartRange.twoWeeks,
                              label: Text(l10n?.logScreenRange14d ?? '14 days'),
                            ),
                            ButtonSegment(
                              value: ChartRange.month,
                              label: Text(l10n?.logScreenRange30d ?? '1 month'),
                            ),
                            ButtonSegment(
                              value: ChartRange.sixMonths,
                              label: Text(l10n?.logScreenRange180d ?? '6 months'),
                            ),
                            ButtonSegment(
                              value: ChartRange.year,
                              label: Text(l10n?.logScreenRange365d ?? '1 year'),
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
                        entries: chartEntries
                            .map((e) =>
                                LineChartEntry(label: e.label, value: e.value))
                            .toList(),
                        emptyLabel: l10n?.logScreenChartEmpty ?? 'No data in this range yet.',
                        lineColor: colorScheme.primary,
                      ),
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
                      l10n?.logScreenSelectedDayHeader ?? 'Selected Day',
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.logScreenSelectedDayText(
                            selectedCount.toString(),
                            formattedDate,
                          ) ??
                          '$selectedCount ${selectedCount == 1 ? (l10n?.logScreenCigaretteSingular ?? "trigger") : (l10n?.logScreenCigarettePlural ?? "triggers")} on $formattedDate',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (_selectedDayScore != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _selectedDayScore! >= 0 ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied,
                            color: _selectedDayScore! >= 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                             // l10n?.logDailyScore(_selectedDayScore.toString()) ??
                                  'Wellness Score: $_selectedDayScore',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedDayScore! >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_log.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n?.logScreenEmptyHint ??
                      'No data recorded yet. Tap and hold on a day to add entries.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    final initial = _countForDay(day);
    final controller = TextEditingController(text: initial.toString());
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.logEditTitle ?? 'Edit Day'),
        content: TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n?.logEditCountLabel(
                    DateFormat.yMMMd(
                            Localizations.localeOf(context).toString())
                        .format(day)) ??
                    'Triggers on ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(day)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          if (initial > 0)
            TextButton(
              onPressed: () => Navigator.pop(context, _EditResult.delete),
              child: Text(
                l10n?.delete ?? 'Delete',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, _EditResult.save),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == _EditResult.delete) {
      await DopamineLogService.removeDate(day);
    } else if (result == _EditResult.save) {
      final parsed = int.tryParse(controller.text.trim()) ?? 0;
      await DopamineLogService.setCountForDate(day, parsed);
    }

    if (!mounted) return;
    await _loadLog();
  }
}

enum _EditResult { save, delete }
