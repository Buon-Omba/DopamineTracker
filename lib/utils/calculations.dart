import 'dart:convert';
import 'package:dopamine_tracker/services/preferences_service.dart';

class Calculations {
  /// Calculate benefit score based on frequency and intensity
  static Future<double> calculateMoneySaved(DateTime lastTrigger) async {
    final prefs = await PreferencesService.instance;

    int weeklyOccurrences = prefs.getInt('packetsPerWeek') ?? 0;
    int dailyIntensity = prefs.getInt('cigarettesPerPacket') ?? 0;

    String? priceHistoryJson = prefs.getString('priceHistory');
    List<Map<String, dynamic>> history = priceHistoryJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(priceHistoryJson))
        : [];

    double totalScore = 0.0;
    DateTime startDate = lastTrigger;

    for (int i = 0; i < history.length; i++) {
      double intensity = history[i]['price']; // Reusing price as intensity factor
      DateTime endDate = (i + 1 < history.length)
          ? DateTime.parse(history[i + 1]['date'])
          : DateTime.now();

      if (startDate.isBefore(endDate)) {
        double minutes = endDate.difference(startDate).inMinutes.toDouble();
        double triggersPerMinute =
            ((weeklyOccurrences * dailyIntensity) / 7.0) / 1440.0;
        totalScore += (minutes * triggersPerMinute) * intensity;
        startDate = endDate;
      }
    }
    return totalScore;
  }

  /// Calculate triggers avoided based on duration and rate
  static Future<int> calculateCigarettesAvoided(
      DateTime lastTrigger, int weeklyOccurrences, int dailyIntensity) async {
    final duration = DateTime.now().difference(lastTrigger);
    double triggersPerMinute =
        ((weeklyOccurrences * dailyIntensity) / 7.0) / 1440.0;
    return (duration.inMinutes * triggersPerMinute).toInt();
  }
}
