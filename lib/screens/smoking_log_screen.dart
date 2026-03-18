import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dopamine_tracker/components/line_chart.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

import '../services/smoke_log_service.dart';

enum ChartRange { week, twoWeeks, month, year }

class _BarEntry {
  final String label;
  final int value;

  _BarEntry({required this.label, required this.value});
}

class SmokingLogScreen extends StatefulWidget {
  const SmokingLogScreen({super.key});

  @override
  State<SmokingLogScreen> createState() => _SmokingLogScreenState();
}

class _SmokingLogScreenState extends State<SmokingLogScreen> {
  Map<DateTime, int> _log = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  ChartRange _selectedRange = ChartRange.week;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    final log = await DopamineLogService.loadCalendarLog();
    if (!mounted) return;
    setState(() {
      _log = log;
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

  @override
  Widget build(BuildContext context) {
    final selectedCount = _countForDay(_selectedDay);
    final localeString = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat.yMMMMd(localeString).format(_selectedDay);
    final chartEntries = _buildRangeData(localeString);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logScreenTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLog,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onDayLongPressed: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showEditDialog(selectedDay);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.indigo.shade400,
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
                            color: Colors.redAccent,
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
                              label: Text(AppLocalizations.of(context)!
                                  .logScreenRange7d),
                            ),
                            ButtonSegment(
                              value: ChartRange.twoWeeks,
                              label: Text(AppLocalizations.of(context)!
                                  .logScreenRange14d),
                            ),
                            ButtonSegment(
                              value: ChartRange.month,
                              label: Text(AppLocalizations.of(context)!
                                  .logScreenRange30d),
                            ),
                            ButtonSegment(
                              value: ChartRange.year,
                              label: Text(AppLocalizations.of(context)!
                                  .logScreenRange365d),
                            ),
                          ],
                          selected: {_selectedRange},
                          onSelectionChanged: (selection) {
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
                              .map((e) => LineChartEntry(
                                  label: e.label, value: e.value))
                              .toList(),
                          emptyLabel:
                              AppLocalizations.of(context)!.logScreenChartEmpty,
                          lineColor: Colors.indigo.shade400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.logScreenSelectedDayText(
                selectedCount.toString(),
                formattedDate,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_log.isEmpty)
              Text(
                AppLocalizations.of(context)!.logScreenEmptyHint,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  List<_BarEntry> _buildRangeData(String localeString) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedRange) {
      case ChartRange.week:
        return _buildDailyEntries(today, 7, localeString);
      case ChartRange.twoWeeks:
        return _buildDailyEntries(today, 14, localeString);
      case ChartRange.month:
        return _buildDailyEntries(today, 30, localeString, monthMode: true);
      case ChartRange.year:
        return _buildMonthlyEntries(today, localeString);
    }
  }

  List<_BarEntry> _buildDailyEntries(
    DateTime today,
    int days,
    String localeString, {
    bool monthMode = false,
  }) {
    final format = monthMode
        ? DateFormat.Md(localeString) // month and day label for 30 days
        : DateFormat.Md(localeString); // compact label

    return List.generate(days, (index) {
      final day = today.subtract(Duration(days: days - index - 1));
      return _BarEntry(
        label: format.format(day),
        value: _countForDay(day),
      );
    });
  }

  List<_BarEntry> _buildMonthlyEntries(
    DateTime today,
    String localeString,
  ) {
    final format = DateFormat.MMM(localeString);
    return List.generate(12, (index) {
      final monthDate = DateTime(today.year, today.month - (11 - index), 1);
      return _BarEntry(
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

  Future<void> _showEditDialog(DateTime day) async {
    final initial = _countForDay(day);
    final controller = TextEditingController(text: initial.toString());

    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logEditTitle),
        content: TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.logEditCountLabel(
                DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .format(day)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          if (initial > 0)
            TextButton(
              onPressed: () => Navigator.pop(context, _EditResult.delete),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, _EditResult.save),
            child: Text(AppLocalizations.of(context)!.save),
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

    await _loadLog();
  }
}

enum _EditResult { save, delete }

class _LineChart extends StatelessWidget {
  final List<_BarEntry> entries;
  final String emptyLabel;

  const _LineChart({required this.entries, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    // Deprecated local chart; delegate to shared LineChart component.
    return LineChart(
      entries: entries
          .map((e) => LineChartEntry(label: e.label, value: e.value))
          .toList(),
      emptyLabel: emptyLabel,
      lineColor: Colors.indigo.shade400,
    );
  }
}
