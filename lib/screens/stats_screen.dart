import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/navigation_bar.dart';
import '../components/line_chart.dart';
import '../services/health_service.dart';
import '../services/smoke_log_service.dart';
import '../services/daily_log_service.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const StatsScreen({super.key, required this.setThemeMode});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final HealthService _healthService = HealthService();
  
  List<Addiction> _addictions = [];
  Addiction? _selectedAddiction;

  Map<DateTime, double> _heartRateData = {};
  Map<DateTime, double> _stressData = {};
  Map<DateTime, int> _triggerLog = {};
  Map<DateTime, DailyLogEntry> _dailyEntries = {};
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _loadAddictionsAndCheckAuth();
  }

  Future<void> _loadAddictionsAndCheckAuth() async {
    final list = await DopamineLogService.getAddictions();
    setState(() {
      _addictions = list;
      if (_addictions.isNotEmpty && _selectedAddiction == null) {
        _selectedAddiction = _addictions.first;
      }
    });
    await _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    setState(() {
      _isLoading = true;
    });

    bool alreadyAuthorized = await _healthService.authorize();
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
    if (_selectedAddiction == null) return;
    final triggers = await DopamineLogService.loadCalendarLog(_selectedAddiction!.id);
    final dailyEntries = await DailyLogService.loadAllEntries();
    setState(() {
      _triggerLog = triggers;
      _dailyEntries = dailyEntries;
    });
  }

  Future<void> _fetchData() async {
    if (_selectedAddiction == null) {
       setState(() => _isLoading = false);
       return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final hr = await _healthService.fetchDailyAverageHeartRate(days: 7);
      final stress = await _healthService.fetchDailyAverageStress(days: 7);
      final triggers = await DopamineLogService.loadCalendarLog(_selectedAddiction!.id);
      final dailyEntries = await DailyLogService.loadAllEntries();

      setState(() {
        _heartRateData = hr;
        _stressData = stress;
        _triggerLog = triggers;
        _dailyEntries = dailyEntries;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.statsScreenTitle),
      ),
      bottomNavigationBar: CustomNavigationBar(
          currentIndex: 4,
          setThemeMode: widget.setThemeMode
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_addictions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButton<Addiction>(
                          value: _selectedAddiction,
                          isExpanded: true,
                          items: _addictions.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                          onChanged: (val) {
                            setState(() => _selectedAddiction = val);
                            _fetchData();
                          },
                        ),
                      ),

                    _buildSectionTitle("${_selectedAddiction?.name ?? 'Dopamine'} Triggers (7d)"),
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

                    _buildSectionTitle("Mood Score (7d)"),
                    _buildChartContainer(
                      LineChart(
                        datasets: [
                          LineChartData(
                            entries: _getLast7DaysEntries((date) => (_dailyEntries[date]?.totalScore ?? 0).toDouble()),
                            color: Colors.red,
                            minValue: -30,
                            maxValue: 30,
                          ),
                        ],
                        emptyLabel: localizations.logScreenChartEmpty,
                      ),
                    ),
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
}
