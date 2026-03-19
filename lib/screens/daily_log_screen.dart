import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dopamine_tracker/components/navigation_bar.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/services/daily_log_service.dart';
import 'package:dopamine_tracker/services/smoke_log_service.dart';

class DailyLogScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const DailyLogScreen({super.key, required this.setThemeMode});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();
  DailyLogEntry _currentEntry = DailyLogEntry();
  List<Addiction> _addictions = [];
  Map<String, int> _triggerCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final entry = await DailyLogService.getEntry(_selectedDate);
    final addictions = await DopamineLogService.getAddictions();
    
    Map<String, int> counts = {};
    for (var addiction in addictions) {
      final count = await DopamineLogService.countForDate(addiction.id, _selectedDate);
      counts[addiction.id] = count;
    }

    if (mounted) {
      setState(() {
        _currentEntry = entry ?? DailyLogEntry();
        _addictions = addictions;
        _triggerCounts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    await DailyLogService.saveEntry(_selectedDate, _currentEntry);
  }

  Future<void> _updateTriggerCount(String addictionId, int delta) async {
    final newCount = (_triggerCounts[addictionId] ?? 0) + delta;
    if (newCount < 0) return;

    await DopamineLogService.setCountForDate(addictionId, _selectedDate, newCount);
    setState(() {
      _triggerCounts[addictionId] = newCount;
    });
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
                    _loadAllData();
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
                    _loadAllData();
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
                      if (_addictions.isNotEmpty) ...[
                        _buildTriggersSection(l10n),
                        const Divider(height: 32),
                      ],
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryMood,
                        [
                          _LogItem(l10n.moodCalm, 'moods', 'calm', DailyLogService.moodEmojis['calm']!),
                          _LogItem(l10n.moodHappy, 'moods', 'happy', DailyLogService.moodEmojis['happy']!),
                          _LogItem(l10n.moodEnergetic, 'moods', 'energetic', DailyLogService.moodEmojis['energetic']!),
                          _LogItem(l10n.moodLively, 'moods', 'lively', DailyLogService.moodEmojis['lively']!),
                          _LogItem(l10n.moodMoodSwings, 'moods', 'mood_swings', DailyLogService.moodEmojis['mood_swings']!),
                          _LogItem(l10n.moodIrritated, 'moods', 'irritated', DailyLogService.moodEmojis['irritated']!),
                          _LogItem(l10n.moodSad, 'moods', 'sad', DailyLogService.moodEmojis['sad']!),
                          _LogItem(l10n.moodAnxious, 'moods', 'anxious', DailyLogService.moodEmojis['anxious']!),
                          _LogItem(l10n.moodDepressed, 'moods', 'depressed', DailyLogService.moodEmojis['depressed']!),
                          _LogItem(l10n.moodGuilt, 'moods', 'guilt', DailyLogService.moodEmojis['guilt']!),
                          _LogItem(l10n.moodObsessiveThoughts, 'moods', 'obsessive', DailyLogService.moodEmojis['obsessive']!),
                          _LogItem(l10n.moodLowEnergy, 'moods', 'low_energy', DailyLogService.moodEmojis['low_energy']!),
                          _LogItem(l10n.moodApathetic, 'moods', 'apathetic', DailyLogService.moodEmojis['apathetic']!),
                          _LogItem(l10n.moodConfused, 'moods', 'confused', DailyLogService.moodEmojis['confused']!),
                          _LogItem(l10n.moodSelfCritical, 'moods', 'self_critical', DailyLogService.moodEmojis['self_critical']!),
                        ],
                        _currentEntry.moods,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategorySymptoms,
                        [
                          _LogItem(l10n.symptomFine, 'symptoms', 'fine', DailyLogService.symptomEmojis['fine']!),
                          _LogItem(l10n.symptomCramps, 'symptoms', 'cramps', DailyLogService.symptomEmojis['cramps']!),
                          _LogItem(l10n.symptomBreastTension, 'symptoms', 'breast_tension', DailyLogService.symptomEmojis['breast_tension']!),
                          _LogItem(l10n.symptomHeadache, 'symptoms', 'headache', DailyLogService.symptomEmojis['headache']!),
                          _LogItem(l10n.symptomAcne, 'symptoms', 'acne', DailyLogService.symptomEmojis['acne']!),
                          _LogItem(l10n.symptomBackPain, 'symptoms', 'back_pain', DailyLogService.symptomEmojis['back_pain']!),
                          _LogItem(l10n.symptomFatigue, 'symptoms', 'fatigue', DailyLogService.symptomEmojis['fatigue']!),
                          _LogItem(l10n.symptomCravings, 'symptoms', 'cravings', DailyLogService.symptomEmojis['cravings']!),
                          _LogItem(l10n.symptomInsomnia, 'symptoms', 'insomnia', DailyLogService.symptomEmojis['insomnia']!),
                        ],
                        _currentEntry.symptoms,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryActivity,
                        [
                          _LogItem(l10n.activityNone, 'activities', 'none', DailyLogService.activityEmojis['none']!),
                          _LogItem(l10n.activityYoga, 'activities', 'yoga', DailyLogService.activityEmojis['yoga']!),
                          _LogItem(l10n.activityGym, 'activities', 'gym', DailyLogService.activityEmojis['gym']!),
                          _LogItem(l10n.activityAerobics, 'activities', 'aerobics', DailyLogService.activityEmojis['aerobics']!),
                          _LogItem(l10n.activitySwimming, 'activities', 'swimming', DailyLogService.activityEmojis['swimming']!),
                          _LogItem(l10n.activityTeamSports, 'activities', 'team_sports', DailyLogService.activityEmojis['team_sports']!),
                          _LogItem(l10n.activityRunning, 'activities', 'running', DailyLogService.activityEmojis['running']!),
                          _LogItem(l10n.activityCycling, 'activities', 'cycling', DailyLogService.activityEmojis['cycling']!),
                          _LogItem(l10n.activityWalking, 'activities', 'walking', DailyLogService.activityEmojis['walking']!),
                        ],
                        _currentEntry.activities,
                      ),
                      _buildCategory(
                        context,
                        l10n.dailyLogCategoryOther,
                        [
                          _LogItem(l10n.otherTravel, 'others', 'travel', DailyLogService.otherEmojis['travel']!),
                          _LogItem(l10n.otherStress, 'others', 'stress', DailyLogService.otherEmojis['stress']!),
                          _LogItem(l10n.otherMeditation, 'others', 'meditation', DailyLogService.otherEmojis['meditation']!),
                          _LogItem(l10n.otherJournaling, 'others', 'journaling', DailyLogService.otherEmojis['journaling']!),
                          _LogItem(l10n.otherKegel, 'others', 'kegel', DailyLogService.otherEmojis['kegel']!),
                          _LogItem(l10n.otherBreathing, 'others', 'breathing', DailyLogService.otherEmojis['breathing']!),
                          _LogItem(l10n.otherIllness, 'others', 'illness', DailyLogService.otherEmojis['illness']!),
                          _LogItem(l10n.otherAlcohol, 'others', 'alcohol', DailyLogService.otherEmojis['alcohol']!),
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

  Widget _buildTriggersSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            l10n.logScreenChartTitle, // Or a more generic "Trackers"
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ..._addictions.map((addiction) {
          final count = _triggerCounts[addiction.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              child: ListTile(
                title: Text(addiction.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _updateTriggerCount(addiction.id, -1),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _updateTriggerCount(addiction.id, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
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
              avatar: Text(item.emoji),
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
              avatar: Text(DailyLogService.contraceptiveEmojis['taken']!),
              label: Text(l10n.contraceptiveTaken),
              selected: _currentEntry.contraceptive == 'taken',
              onSelected: (selected) {
                _setContraceptive(selected ? 'taken' : null);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: Text(DailyLogService.contraceptiveEmojis['missed']!),
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
  final String emoji;

  _LogItem(this.label, this.category, this.key, this.emoji);
}
