import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/services/data_export_import_service.dart';
import '../services/smoke_log_service.dart';

class ConfigScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const ConfigScreen({super.key, required this.setThemeMode});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  DateTime? _counterStartDate;
  ThemeMode _themeMode = ThemeMode.system;
  String _addictionName = 'Dopamine';
  List<Addiction> _addictions = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _loadAddictions();
  }

  Future<void> _loadAddictions() async {
    final list = await DopamineLogService.getAddictions();
    setState(() {
      _addictions = list;
      if (_addictions.isNotEmpty) {
        _addictionName = _addictions.first.name;
      } else {
        _addictionName = 'Dopamine';
      }
    });
  }

  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String? startDate = prefs.getString('lastSmoked');
      if (startDate != null) {
        _counterStartDate = DateTime.parse(startDate);
      }
      final themeModeString = prefs.getString('themeMode') ?? 'system';
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == 'ThemeMode.$themeModeString',
        orElse: () => ThemeMode.system,
      );
    });
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
      widget.setThemeMode(mode);
    });
  }

  Future<void> _confirmDeleteAddiction(Addiction addiction) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.configDeleteAddictionTitle),
        content: Text(l10n.configDeleteAddictionConfirmation(addiction.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DopamineLogService.removeAddiction(addiction.id);
      await _loadAddictions();
      if (_addictions.isEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('packetsPerWeek');
        await prefs.remove('cigarettesPerPacket');
        await prefs.remove('priceHistory');
        await prefs.remove('lastSmoked');
        _loadConfig();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.configDeleteAddictionSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar:
          AppBar(title: Text(l10n.configScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              DropdownButtonFormField<ThemeMode>(
                value: _themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    _updateTheme(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(l10n.configOptionThemeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(l10n.configOptionThemeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(l10n.configOptionThemeDark),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: l10n.configOptionThemeTitle,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                  l10n.configDataBackupTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () async {
                        final ok = await DataExportImportService.exportToJson();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? (l10n.configExportSuccessMessage)
                                : (l10n.configExportErrorMessage)),
                          ),
                        );
                      },
                      label: Text(l10n.configExportDataButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      onPressed: () async {
                        final result =
                            await DataExportImportService.importFromJson();
                        if (!context.mounted) return;
                        String message;
                        if (result == 'success') {
                          message = l10n.configImportSuccessMessage;
                          _loadConfig();
                          _loadAddictions();
                        } else if (result == 'cancelled') {
                          message =
                              l10n.configImportCancelled;
                        } else {
                          message =
                              l10n.configImportErrorMessage(_addictionName);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      label: Text(l10n.configImportDataButton),
                    ),
                  ),
                ],
              ),
              if (_addictions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                    l10n.configDeleteAddictionTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ..._addictions.map((addiction) => Card(
                  child: ListTile(
                    title: Text(addiction.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteAddiction(addiction),
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
