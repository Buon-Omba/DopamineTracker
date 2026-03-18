import 'package:shared_preferences/shared_preferences.dart';

/// Lazy singleton for SharedPreferences to avoid repeated getInstance calls.
class PreferencesService {
  PreferencesService._();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
