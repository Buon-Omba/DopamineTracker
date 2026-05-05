import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  final Health _health = Health();

  static const String _keyTodayHeartRate = 'today_avg_heart_rate';
  static const String _keyTodayStress = 'today_avg_stress';

  final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
  ];

  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _prepare() async {
    await _health.configure();
  }

  Future<bool> isAuthorized() async {
    await _prepare();
    return await _health.hasPermissions(_types, permissions: _permissions) ?? false;
  }

  Future<bool> authorize() async {
    await _prepare();

    bool? hasPermissions = await _health.hasPermissions(_types, permissions: _permissions);
    
    if (hasPermissions != true) {
      try {
        hasPermissions = await _health.requestAuthorization(_types, permissions: _permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
    
    return hasPermissions ?? false;
  }

  Future<Map<DateTime, double>> fetchDailyAverageHeartRate({int days = 7}) async {
    await _prepare();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: now,
    );

    return _calculateDailyAverages(data);
  }

  Future<Map<DateTime, double>> fetchDailyAverageStress({int days = 7}) async {
    await _prepare();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    // Using HRV (RMSSD) as a proxy for stress
    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
      startTime: start,
      endTime: now,
    );

    return _calculateDailyAverages(data);
  }

  Map<DateTime, double> _calculateDailyAverages(List<HealthDataPoint> data) {
    Map<DateTime, List<double>> dailyValues = {};

    for (var point in data) {
      final date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
      double value = 0;
      
      final pointValue = point.value;
      if (pointValue is NumericHealthValue) {
        value = pointValue.numericValue.toDouble();
      }

      if (!dailyValues.containsKey(date)) {
        dailyValues[date] = [];
      }
      dailyValues[date]!.add(value);
    }

    Map<DateTime, double> averages = {};
    dailyValues.forEach((date, values) {
      if (values.isNotEmpty) {
        averages[date] = values.reduce((a, b) => a + b) / values.length;
      }
    });

    return averages;
  }

  Future<double?> updateAndSaveTodayHeartRate() async {
    await _prepare();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.RESTING_HEART_RATE],
      startTime: startOfToday,
      endTime: now,
    );

    if (data.isEmpty) return null;

    double sum = 0;
    int count = 0;

    for (var point in data) {
      final pointValue = point.value;
      if (pointValue is NumericHealthValue) {
        sum += pointValue.numericValue.toDouble();
        count++;
      }
    }

    if (count == 0) return null;
    double average = sum / count;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTodayHeartRate, average);

    return average;
  }

  Future<double?> getSavedTodayHeartRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTodayHeartRate);
  }

  Future<double?> updateAndSaveTodayStress() async {
    await _prepare();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
      startTime: startOfToday,
      endTime: now,
    );

    if (data.isEmpty) return null;

    double sum = 0;
    int count = 0;
    for (var point in data) {
      final v = point.value;
      if (v is NumericHealthValue) {
        sum += v.numericValue.toDouble();
        count++;
      }
    }

    if (count == 0) return null;
    double average = sum / count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTodayStress, average);
    return average;
  }

  Future<double?> getSavedTodayStress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTodayStress);
  }
}
