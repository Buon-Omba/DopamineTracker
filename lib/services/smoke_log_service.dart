import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dopamine_tracker/main.dart'; 

class Addiction {
  final String id;
  final String name;

  Addiction({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Addiction.fromJson(Map<String, dynamic> json) => Addiction(id: json['id'], name: json['name']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Addiction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DopamineLogService {
  static const _addictionsKey = 'addictions';
  static const _logKeyPrefix = 'dopamineLog_';
  static const _lastTriggerKeyPrefix = 'lastTrigger_';
  static const _hasStartedKey = 'hasStarted';

  static String _formatName(String input) {
    if (input.trim().isEmpty) return "";
    final trimmed = input.trim();
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  static Future<List<Addiction>> getAddictions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_addictionsKey);
    if (stored == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(stored);
      return decoded.map((item) => Addiction.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addAddiction(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final addictions = await getAddictions();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final formattedName = _formatName(name);
    
    addictions.add(Addiction(id: id, name: formattedName));
    await prefs.setString(_addictionsKey, jsonEncode(addictions.map((e) => e.toJson()).toList()));
    await prefs.setBool(_hasStartedKey, true);
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  static Future<void> removeAddiction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final addictions = await getAddictions();
    addictions.removeWhere((a) => a.id == id);
    await prefs.setString(_addictionsKey, jsonEncode(addictions.map((e) => e.toJson()).toList()));
    await prefs.remove(_logKeyPrefix + id);
    await prefs.remove(_lastTriggerKeyPrefix + id);
    await DopamineTrackerApp.updateHomeWidgets();
  }

  static Future<void> logTrigger(String addictionId, {DateTime? timestamp}) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs, addictionId);
    final now = timestamp ?? DateTime.now();
    final dayKey = _formatDate(now);

    log[dayKey] = (log[dayKey] ?? 0) + 1;

    await prefs.setString(_logKeyPrefix + addictionId, jsonEncode(log));
    await prefs.setString(_lastTriggerKeyPrefix + addictionId, now.toIso8601String());
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  static Future<int> countForDate(String addictionId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs, addictionId);
    final dayKey = _formatDate(date);
    return log[dayKey] ?? 0;
  }

  static Future<void> setCountForDate(String addictionId, DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs, addictionId);
    final dayKey = _formatDate(date);

    if (count <= 0) {
      log.remove(dayKey);
    } else {
      log[dayKey] = count;
    }

    await prefs.setString(_logKeyPrefix + addictionId, jsonEncode(log));
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  static Future<void> removeDate(String addictionId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs, addictionId);
    final dayKey = _formatDate(date);
    log.remove(dayKey);
    await prefs.setString(_logKeyPrefix + addictionId, jsonEncode(log));
    await DopamineTrackerApp.updateHomeWidgets(); 
  }

  static Future<Map<DateTime, int>> loadCalendarLog(String addictionId) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _loadLog(prefs, addictionId);
    return log.map(
      (key, value) => MapEntry(_parseDate(key), value),
    );
  }

  static Future<DateTime?> getLastTrigger(String addictionId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_lastTriggerKeyPrefix + addictionId);
    if (stored == null) return null;
    return DateTime.parse(stored);
  }

  static Future<Map<String, int>> _loadLog(SharedPreferences prefs, String addictionId) async {
    final stored = prefs.getString(_logKeyPrefix + addictionId);
    if (stored == null) {
      if (addictionId == "legacy") {
         final oldStored = prefs.getString('dopamineLog');
         if (oldStored != null) {
           try {
             return (jsonDecode(oldStored) as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
           } catch (e) {
             return {};
           }
         }
      }
      return {};
    }

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (e) {
      return {};
    }
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime _parseDate(String value) {
    final parsed = DateTime.parse(value);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
