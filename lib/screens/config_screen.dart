import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  final _packetsPerWeekController = TextEditingController();
  final _cigarettesPerPacketController = TextEditingController();
  List<Map<String, dynamic>> _priceHistory = [];
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
      _packetsPerWeekController.text =
          prefs.getInt('packetsPerWeek')?.toString() ?? '';
      _cigarettesPerPacketController.text =
          prefs.getInt('cigarettesPerPacket')?.toString() ?? '';
      String? priceHistoryJson = prefs.getString('priceHistory');
      if (priceHistoryJson != null) {
        _priceHistory =
            List<Map<String, dynamic>>.from(jsonDecode(priceHistoryJson));
      }
      
      // Assicura che ci sia almeno un elemento se la lista è vuota
      if (_priceHistory.isEmpty) {
        _priceHistory.add({
          'price': '',
          'date': DateTime.now().toIso8601String(),
        });
      }

      String? startDate = prefs.getString('lastSmoked');
      if (startDate != null) {
        _counterStartDate = DateTime.parse(startDate);
      }
      if (_counterStartDate != null && _priceHistory.isNotEmpty) {
        _priceHistory[0]['date'] = _counterStartDate!.toIso8601String();
      }
      final themeModeString = prefs.getString('themeMode') ?? 'system';
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == 'ThemeMode.$themeModeString',
        orElse: () => ThemeMode.system,
      );
    });
  }

  Future<void> _saveConfig() async {
    if (_packetsPerWeekController.text.isEmpty ||
        _cigarettesPerPacketController.text.isEmpty ||
        _priceHistory.any((entry) =>
            entry['price'].toString().isEmpty ||
            double.tryParse(entry['price'].toString()) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.configSnackBarValidNumber)),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'packetsPerWeek', int.parse(_packetsPerWeekController.text));
    await prefs.setInt(
        'cigarettesPerPacket', int.parse(_cigarettesPerPacketController.text));

    List<Map<String, dynamic>> validatedPriceHistory =
        _priceHistory.map((entry) {
      return {
        'price': double.tryParse(entry['price'].toString()) ?? 0.0,
        'date': entry['date'],
      };
    }).toList();

    await prefs.setString('priceHistory', jsonEncode(validatedPriceHistory));
    if (_counterStartDate != null) {
      await prefs.setString('lastSmoked', _counterStartDate!.toIso8601String());
    }
    await prefs.setString('themeMode', _themeMode.toString().split('.').last);
    widget.setThemeMode(_themeMode);

    Navigator.pop(context, true);
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

  void _addPrice() {
    setState(() {
      _priceHistory.add({
        'price': '',
        'date': DateTime.now().toIso8601String(),
      });
    });
  }

  void _removePrice(int index) {
    setState(() {
      // Non rimuovere l'ultimo elemento se è l'unico rimasto
      if (_priceHistory.length > 1) {
        _priceHistory.removeAt(index);
      }
    });
  }

  void _updatePrice(int index, String value) {
    setState(() {
      _priceHistory[index]['price'] = value;
    });
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
              TextField(
                controller: _packetsPerWeekController,
                decoration: InputDecoration(
                    labelText: l10n.configOptionPacketsPerWeekText(_addictionName)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cigarettesPerPacketController,
                decoration: InputDecoration(
                    labelText: l10n.configOptionCigarettesPerPacketText(_addictionName)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Text(l10n.configOptionPriceHistoryText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _priceHistory.length,
                itemBuilder: (context, index) {
                  final priceEntry = _priceHistory[index];
                  final controller = TextEditingController(
                      text: priceEntry['price'].toString());
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length));
                  return ListTile(
                    title: TextField(
                      decoration: InputDecoration(
                          labelText: l10n.configOptionPriceHistoryPriceText),
                      keyboardType: TextInputType.number,
                      controller: controller,
                      onChanged: (value) => _updatePrice(index, value),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMMd(
                              Localizations.localeOf(context).toString())
                          .add_Hm()
                          .format(DateTime.parse(priceEntry['date']).toLocal()),
                    ),
                    trailing: index == 0
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removePrice(index),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<ThemeMode>(
                value: _themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _themeMode = newValue;
                      widget.setThemeMode(newValue);
                    });
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addPrice,
                      child: Text(l10n.configButtonAddPriceText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
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
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
