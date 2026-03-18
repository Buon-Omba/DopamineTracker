import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class WidgetProvider {
  static const MethodChannel _channel =
      MethodChannel('it.buonomba.DopamineTracker/app_widgets');

  /// Requests the native side to refresh all home screen widgets.
  /// This reads the latest data from SharedPreferences and updates the widget UI.
  static Future<void> updateWidgets() async {
    try {
      await _channel.invokeMethod('updateHomeWidgets');
    } on PlatformException catch (e) {
      debugPrint("Failed to update home widgets: '${e.message}'.");
    } on MissingPluginException {
      // Not running on Android or channel not available – ignore silently.
      debugPrint("Widget update channel not available on this platform.");
    }
  }
}
