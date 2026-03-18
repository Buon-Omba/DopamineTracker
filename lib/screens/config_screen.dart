import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/services/data_export_import_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadConfig();
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
      _priceHistory.removeAt(index);
    });
  }

  void _updatePrice(int index, String value) {
    setState(() {
      _priceHistory[index]['price'] = value;
    });
  }

  Future<void> _selectCounterStartDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _counterStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_counterStartDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _counterStartDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
          if (_priceHistory.isNotEmpty) {
            _priceHistory[0]['date'] = _counterStartDate!.toIso8601String();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.configScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _packetsPerWeekController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .configOptionPacketsPerWeekText),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cigarettesPerPacketController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .configOptionCigarettesPerPacketText),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.configOptionCounterStartDateText,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _counterStartDate != null
                          ? DateFormat.yMMMMd(
                                  Localizations.localeOf(context).toString())
                              .add_Hm()
                              .format(_counterStartDate!.toLocal())
                          : AppLocalizations.of(context)!
                              .configOptionCounterStartDateSelectText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectCounterStartDateTime(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.configOptionPriceHistoryText,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          labelText: AppLocalizations.of(context)!
                              .configOptionPriceHistoryPriceText),
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
              const SizedBox(height: 20),
              DropdownButtonFormField<ThemeMode>(
                initialValue: _themeMode,
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
                    child: Text(AppLocalizations.of(context)!.configOptionThemeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(AppLocalizations.of(context)!.configOptionThemeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(AppLocalizations.of(context)!.configOptionThemeDark),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.configOptionThemeTitle,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addPrice,
                      child: Text(AppLocalizations.of(context)!.configButtonAddPriceText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                  AppLocalizations.of(context)!.configDataBackupTitle,
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
                                ? (AppLocalizations.of(context)!
                                    .configExportSuccessMessage)
                                : (AppLocalizations.of(context)!
                                    .configExportErrorMessage)),
                          ),
                        );
                      },
                      label: Text(AppLocalizations.of(context)!
                          .configExportDataButton),
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
                          message = AppLocalizations.of(context)!
                              .configImportSuccessMessage;
                          _loadConfig();
                        } else if (result == 'cancelled') {
                          message =
                              AppLocalizations.of(context)!.configImportCancelled;
                        } else {
                          message =
                              AppLocalizations.of(context)!.configImportErrorMessage;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      label: Text(AppLocalizations.of(context)!
                          .configImportDataButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
