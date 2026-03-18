import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<bool> authorize() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
    
    if (hasPermissions != true) {
      try {
        hasPermissions = await _health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
    
    return hasPermissions ?? false;
  }

  Future<Map<DateTime, double>> fetchDailyAverageHeartRate() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: now,
    );

    return _calculateDailyAverages(data);
  }

  Future<Map<DateTime, double>> fetchDailyAverageStress() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    // Using HRV as a proxy for stress if direct stress is not available
    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.RESTING_HEART_RATE],
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
}
