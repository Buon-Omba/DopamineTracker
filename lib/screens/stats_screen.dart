import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../components/navigation_bar.dart';
import '../services/health_service.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const StatsScreen({super.key, required this.setThemeMode});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final HealthService _healthService = HealthService();
  Map<DateTime, double> _heartRateData = {};
  Map<DateTime, double> _stressData = {};
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    setState(() {
      _isLoading = true;
    });

    bool alreadyAuthorized = await _healthService.authorize();
    if (alreadyAuthorized) {
      await _fetchHealthData();
    } else {
      setState(() {
        _isLoading = false;
        _isAuthorized = false;
      });
    }
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final hr = await _healthService.fetchDailyAverageHeartRate();
      final stress = await _healthService.fetchDailyAverageStress();
      setState(() {
        _heartRateData = hr;
        _stressData = stress;
        _isAuthorized = true;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching health data: $e");
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
      await _fetchHealthData();
    } else {
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
          : !_isAuthorized
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.statsNoData),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authorizeAndFetch,
              child: Text(localizations.statsAuthorizeButton),
            ),
          ],
        ),
      )
          : RefreshIndicator(
              onRefresh: _fetchHealthData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.statsHeartRateTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 250, child: _buildChart(_heartRateData, Colors.red)),
                    const SizedBox(height: 30),
                    Text(
                      localizations.statsStressTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 250, child: _buildChart(_stressData, Colors.blue)),
                  ],
                ),
              ),
          ),
    );
  }

  Widget _buildChart(Map<DateTime, double> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text("No data for the last 7 days"));
    }

    final sortedKeys = data.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), data[e.value]!);
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sortedKeys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('E').format(sortedKeys[index]),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
