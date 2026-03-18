import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DailyLogEntry {
  final List<String> moods;
  final List<String> symptoms;
  final List<String> activities;
  final List<String> others;
  final String? contraceptive; // 'taken', 'missed', or null
  final int totalScore;

  DailyLogEntry({
    this.moods = const [],
    this.symptoms = const [],
    this.activities = const [],
    this.others = const [],
    this.contraceptive,
    this.totalScore = 0,
  });

  Map<String, dynamic> toJson() => {
    'moods': moods,
    'symptoms': symptoms,
    'activities': activities,
    'others': others,
    'contraceptive': contraceptive,
    'totalScore': totalScore,
  };

  factory DailyLogEntry.fromJson(Map<String, dynamic> json) {
    return DailyLogEntry(
      moods: List<String>.from(json['moods'] ?? []),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      others: List<String>.from(json['others'] ?? []),
      contraceptive: json['contraceptive'],
      totalScore: json['totalScore'] ?? 0,
    );
  }

  DailyLogEntry copyWith({
    List<String>? moods,
    List<String>? symptoms,
    List<String>? activities,
    List<String>? others,
    String? contraceptive,
    int? totalScore,
  }) {
    return DailyLogEntry(
      moods: moods ?? this.moods,
      symptoms: symptoms ?? this.symptoms,
      activities: activities ?? this.activities,
      others: others ?? this.others,
      contraceptive: contraceptive ?? this.contraceptive,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}

class DailyLogService {
  static const _logKeyPrefix = 'dailyLog_';

  static final Map<String, int> moodScores = {
    'calm': 3, 'happy': 5, 'energetic': 4, 'lively': 4, 'mood_swings': -3,
    'irritated': -4, 'sad': -3, 'anxious': -4, 'depressed': -5, 'guilt': -4,
    'obsessive': -4, 'low_energy': -2, 'apathetic': -3, 'confused': -2, 'self_critical': -4,
  };

  static final Map<String, String> moodEmojis = {
    'calm': '😌', 'happy': '😊', 'energetic': '⚡', 'lively': '🤪', 'mood_swings': '🎢',
    'irritated': '😠', 'sad': '😔', 'anxious': '😰', 'depressed': '😞', 'guilt': '😔',
    'obsessive': '🤯', 'low_energy': '😫', 'apathetic': '😐', 'confused': '😕', 'self_critical': '😟',
  };

  static final Map<String, int> symptomScores = {
    'fine': 5, 'cramps': -4, 'breast_tension': -2, 'headache': -3, 'acne': -1,
    'back_pain': -3, 'fatigue': -2, 'cravings': -2, 'insomnia': -4,
  };

  static final Map<String, String> symptomEmojis = {
    'fine': '👍', 'cramps': '😫', 'breast_tension': '🍈', 'headache': '🤕', 'acne': '💆',
    'back_pain': '🚶', 'fatigue': '🔋', 'cravings': '🍩', 'insomnia': '🌚',
  };

  static final Map<String, int> activityScores = {
    'none': 0, 'yoga': 4, 'gym': 5, 'aerobics': 5, 'swimming': 5,
    'team_sports': 5, 'running': 5, 'cycling': 4, 'walking': 3,
  };

  static final Map<String, String> activityEmojis = {
    'none': '🛋️', 'yoga': '🧘', 'gym': '🏋️', 'aerobics': '💃', 'swimming': '🏊',
    'team_sports': '🏀', 'running': '🏃', 'cycling': '🚴', 'walking': '🚶',
  };

  static final Map<String, int> otherScores = {
    'travel': 4, 'stress': -4, 'meditation': 4, 'journaling': 3,
    'kegel': 2, 'breathing': 3, 'illness': -5, 'alcohol': -2,
  };

  static final Map<String, String> otherEmojis = {
    'travel': '✈️', 'stress': '⚡', 'meditation': '🧘', 'journaling': '📓',
    'kegel': '💪', 'breathing': '🫁', 'illness': '🤒', 'alcohol': '🍷',
  };

  static final Map<String, int> contraceptiveScores = {
    'taken': 1, 'missed': -2,
  };

  static final Map<String, String> contraceptiveEmojis = {
    'taken': '✅', 'missed': '❌',
  };

  static int calculateTotalScore(DailyLogEntry entry) {
    int score = 0;
    for (var m in entry.moods) { score += moodScores[m] ?? 0; }
    for (var s in entry.symptoms) { score += symptomScores[s] ?? 0; }
    for (var a in entry.activities) { score += activityScores[a] ?? 0; }
    for (var o in entry.others) { score += otherScores[o] ?? 0; }
    if (entry.contraceptive != null) {
      score += contraceptiveScores[entry.contraceptive] ?? 0;
    }
    return score;
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static Future<void> saveEntry(DateTime date, DailyLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _logKeyPrefix + _formatDate(date);
    
    // Ricalcola il punteggio prima di salvare
    final updatedEntry = entry.copyWith(totalScore: calculateTotalScore(entry));
    
    await prefs.setString(key, jsonEncode(updatedEntry.toJson()));
  }

  static Future<DailyLogEntry?> getEntry(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _logKeyPrefix + _formatDate(date);
    final stored = prefs.getString(key);
    if (stored == null) return null;
    return DailyLogEntry.fromJson(jsonDecode(stored));
  }
}
