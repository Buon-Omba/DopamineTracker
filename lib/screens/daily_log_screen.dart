import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/services/daily_log_service.dart';

class DailyLogScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const DailyLogScreen({super.key, required this.setThemeMode});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();
  DailyLogEntry _currentEntry = DailyLogEntry();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);
    final entry = await DailyLogService.getEntry(_selectedDate);
    if (mounted) {
      setState(() {
        _currentEntry = entry ?? DailyLogEntry();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    await DailyLogService.saveEntry(_selectedDate, _currentEntry);
  }

  void _toggleItem(String category, String item) {
    setState(() {
      switch (category) {
        case 'moods':
          List<String> newList = List.from(_currentEntry.moods);
          if (newList.contains(item)) {
            newList.remove(item);
          } else {
            newList.add(item);
          }
          _currentEntry = _currentEntry.copyWith(moods: newList);
          break;
        case 'symptoms':
          List<String> newList = List.from(_currentEntry.symptoms);
          if (newList.contains(item)) {
            newList.remove(item);
          } else {
            newList.add(item);
          }
          _currentEntry = _currentEntry.copyWith(symptoms: newList);
          break;
        case 'activities':
          List<String> newList = List.from(_currentEntry.activities);
          if (newList.contains(item)) {
            newList.remove(item);
          } else {
            newList.add(item);
          }
          _currentEntry = _currentEntry.copyWith(activities: newList);
          break;
        case 'others':
          List<String> newList = List.from(_currentEntry.others);
          if (newList.contains(item)) {
            newList.remove(item);
          } else {
            newList.add(item);
          }
          _currentEntry = _currentEntry.copyWith(others: newList);
          break;
      }
    });
    _saveEntry();
  }

  void _setContraceptive(String? value) {
    setState(() {
      _currentEntry = _currentEntry.copyWith(contraceptive: value);
    });
    _saveEntry();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat.MMMMd(locale).format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigationBarDailyLog),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                    _loadEntry();
                  },
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                    _loadEntry();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryMood,
                        [
                          _LogItem(l10n.moodCalm, 'moods', 'calm'),
                          _LogItem(l10n.moodHappy, 'moods', 'happy'),
                          _LogItem(l10n.moodEnergetic, 'moods', 'energetic'),
                          _LogItem(l10n.moodLively, 'moods', 'lively'),
                          _LogItem(l10n.moodMoodSwings, 'moods', 'mood_swings'),
                          _LogItem(l10n.moodIrritated, 'moods', 'irritated'),
                          _LogItem(l10n.moodSad, 'moods', 'sad'),
                          _LogItem(l10n.moodAnxious, 'moods', 'anxious'),
                          _LogItem(l10n.moodDepressed, 'moods', 'depressed'),
                          _LogItem(l10n.moodGuilt, 'moods', 'guilt'),
                          _LogItem(l10n.moodObsessiveThoughts, 'moods', 'obsessive'),
                          _LogItem(l10n.moodLowEnergy, 'moods', 'low_energy'),
                          _LogItem(l10n.moodApathetic, 'moods', 'apathetic'),
                          _LogItem(l10n.moodConfused, 'moods', 'confused'),
                          _LogItem(l10n.moodSelfCritical, 'moods', 'self_critical'),
                        ],
                        _currentEntry.moods,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategorySymptoms,
                        [
                          _LogItem(l10n.symptomFine, 'symptoms', 'fine'),
                          _LogItem(l10n.symptomCramps, 'symptoms', 'cramps'),
                          _LogItem(l10n.symptomBreastTension, 'symptoms', 'breast_tension'),
                          _LogItem(l10n.symptomHeadache, 'symptoms', 'headache'),
                          _LogItem(l10n.symptomAcne, 'symptoms', 'acne'),
                          _LogItem(l10n.symptomBackPain, 'symptoms', 'back_pain'),
                          _LogItem(l10n.symptomFatigue, 'symptoms', 'fatigue'),
                          _LogItem(l10n.symptomCravings, 'symptoms', 'cravings'),
                          _LogItem(l10n.symptomInsomnia, 'symptoms', 'insomnia'),
                        ],
                        _currentEntry.symptoms,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryActivity,
                        [
                          _LogItem(l10n.activityNone, 'activities', 'none'),
                          _LogItem(l10n.activityYoga, 'activities', 'yoga'),
                          _LogItem(l10n.activityGym, 'activities', 'gym'),
                          _LogItem(l10n.activityAerobics, 'activities', 'aerobics'),
                          _LogItem(l10n.activitySwimming, 'activities', 'swimming'),
                          _LogItem(l10n.activityTeamSports, 'activities', 'team_sports'),
                          _LogItem(l10n.activityRunning, 'activities', 'running'),
                          _LogItem(l10n.activityCycling, 'activities', 'cycling'),
                          _LogItem(l10n.activityWalking, 'activities', 'walking'),
                        ],
                        _currentEntry.activities,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryOther,
                        [
                          _LogItem(l10n.otherTravel, 'others', 'travel'),
                          _LogItem(l10n.otherStress, 'others', 'stress'),
                          _LogItem(l10n.otherMeditation, 'others', 'meditation'),
                          _LogItem(l10n.otherJournaling, 'others', 'journaling'),
                          _LogItem(l10n.otherKegel, 'others', 'kegel'),
                          _LogItem(l10n.otherBreathing, 'others', 'breathing'),
                          _LogItem(l10n.otherIllness, 'others', 'illness'),
                          _LogItem(l10n.otherAlcohol, 'others', 'alcohol'),
                        ],
                        _currentEntry.others,
                      ),
                      _buildContraceptiveSection(l10n),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3, setThemeMode: widget.setThemeMode),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<_LogItem> items, List<String> selectedItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item.key);
            return FilterChip(
              label: Text(item.label),
              selected: isSelected,
              onSelected: (_) => _toggleItem(item.category, item.key),
              selectedColor: _getCategoryColor(item.category).withOpacity(0.3),
              checkmarkColor: _getCategoryColor(item.category),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContraceptiveSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            l10n.dailyLogCategoryContraceptives,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            ChoiceChip(
              label: Text(l10n.contraceptiveTaken),
              selected: _currentEntry.contraceptive == 'taken',
              onSelected: (selected) {
                _setContraceptive(selected ? 'taken' : null);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l10n.contraceptiveMissed),
              selected: _currentEntry.contraceptive == 'missed',
              onSelected: (selected) {
                _setContraceptive(selected ? 'missed' : null);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'moods':
        return Colors.orange;
      case 'symptoms':
        return Colors.purple;
      case 'activities':
        return Colors.green;
      case 'others':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _LogItem {
  final String label;
  final String category;
  final String key;

  _LogItem(this.label, this.category, this.key);
}
