import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dopamine_tracker/main.dart'; 

class DopamineLogService {
  static const _logKey = 'dopamineLog'; // Changed key will reset data, but matches request
  static const _lastTriggerKey = 'lastTrigger';
  static const _hasStartedKey = 'hasStarted';

  /// Record a trigger at the given [timestamp] (defaults to now).
  static Future<void> logTrigger({DateTime? timestamp}) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs);
    final now = timestamp ?? DateTime.now();
    final dayKey = _formatDate(now);

    log[dayKey] = (log[dayKey] ?? 0) + 1;

    await prefs.setString(_logKey, jsonEncode(log));
    await prefs.setString(_lastTriggerKey, now.toIso8601String());
    await prefs.setBool(_hasStartedKey, true);
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  /// Returns the number of triggers on [date].
  static Future<int> countForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs);
    final dayKey = _formatDate(date);
    return log[dayKey] ?? 0;
  }

  /// Set an explicit count for [date]. If [count] is 0, removes the entry.
  static Future<void> setCountForDate(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs);
    final dayKey = _formatDate(date);

    if (count <= 0) {
      log.remove(dayKey);
    } else {
      log[dayKey] = count;
    }

    await prefs.setString(_logKey, jsonEncode(log));
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  /// Remove a day's entry completely.
  static Future<void> removeDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs);
    final dayKey = _formatDate(date);
    log.remove(dayKey);
    await prefs.setString(_logKey, jsonEncode(log));
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  /// Returns the whole log as a map keyed by DateTime midnight (local).
  static Future<Map<DateTime, int>> loadCalendarLog() async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs);
    return log.map(
      (key, value) => MapEntry(_parseDate(key), value),
    );
  }

  static Future<Map<String, int>> _loadLog(SharedPreferences prefs) async {
    final stored = prefs.getString(_logKey);
    if (stored == null) return {};

    final decoded = jsonDecode(stored) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime _parseDate(String value) {
    final parsed = DateTime.parse(value);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
