import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chiavi SharedPreferences da includere nell'export/import.
const List<String> _exportKeys = [
  'smokeLog',
  'lastSmoked',
  'hasStarted',
  'packetsPerWeek',
  'cigarettesPerPacket',
  'priceHistory',
  'friendsData',
  'userId',
  'themeMode',
];

const String _exportVersionKey = 'exportVersion';
const int _currentExportVersion = 1;

class DataExportImportService {
  /// Esporta tutti i dati rilevanti in un unico JSON e condivide il file.
  /// Restituisce true se l'export e la condivisione sono andati a buon fine.
  static Future<bool> exportToJson() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      _exportVersionKey: _currentExportVersion,
    };

    for (final key in _exportKeys) {
      final value = prefs.get(key);
      if (value == null) continue;
      if (value is int) {
        data[key] = value;
      } else if (value is bool) {
        data[key] = value;
      } else if (value is String) {
        data[key] = value;
      } else {
        data[key] = value.toString();
      }
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final fileName = 'smoke_tracker_backup_${DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString, encoding: utf8);

    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Smoke Tracker backup',
        subject: 'Smoke Tracker data export',
      );
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Permette all'utente di scegliere un file JSON e importa i dati in SharedPreferences.
  /// Restituisce un messaggio di esito (successo o errore).
  static Future<String> importFromJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return 'cancelled';
    }

    final platformFile = result.files.first;
    String jsonString;
    if (platformFile.bytes != null) {
      jsonString = utf8.decode(platformFile.bytes!);
    } else if (platformFile.path != null) {
      jsonString = await File(platformFile.path!).readAsString(encoding: utf8);
    } else {
      return 'error_read';
    }

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data[_exportVersionKey] == null) {
        return 'error_invalid';
      }

      final prefs = await SharedPreferences.getInstance();

      for (final key in _exportKeys) {
        if (!data.containsKey(key)) continue;
        final value = data[key];
        if (value == null) continue;
        if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        }
      }

      return 'success';
    } catch (_) {
      return 'error_invalid';
    }
  }
}
