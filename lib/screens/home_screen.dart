import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/time_formatter.dart';
import '../utils/calculations.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import '../services/smoke_log_service.dart';
import '../services/daily_log_service.dart';
import '../widget_provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  final Addiction? selectedAddiction;
  const HomeScreen({super.key, required this.setThemeMode, this.selectedAddiction});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime? lastTrigger;
  int weeklyOccurrences = 0;
  int dailyIntensity = 0;

  double benefitScore = 0.0;
  int triggersAvoided = 0;
  int triggersLoggedToday = 0;
  int hoursWithoutTriggers = 0;

  DailyLogEntry _currentDailyEntry = DailyLogEntry();

  List<String> _customMoods = [];
  List<String> _customActivities = [];
  List<String> _customOthers = [];
  Map<String, String> _customEmojis = {};

  late Timer timer;
  StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _generateAndSaveUserId();
    _initializeData();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCalculations());
    
    _updateSubscription = DopamineLogService.updates.listen((_) {
      _initializeData();
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddiction != oldWidget.selectedAddiction) {
      _loadSelectedAddictionData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
    _updateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeData();
    }
  }

  Future<void> _generateAndSaveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      var uuid = const Uuid();
      userId = uuid.v4();
      await prefs.setString('userId', userId);
    }
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!mounted) return;

    await _loadConfigData();
    await _loadTodayDailyLog();
    await _loadCustomItems();
    await _loadSelectedAddictionData();
    _updateCalculations();
  }

  Future<void> _loadCustomItems() async {
    final moods = await DailyLogService.getCustomItems('moods');
    final activities = await DailyLogService.getCustomItems('activities');
    final others = await DailyLogService.getCustomItems('others');
    final emojis = await DailyLogService.getCustomEmojis();
    if (!mounted) return;
    setState(() {
      _customMoods = moods;
      _customActivities = activities;
      _customOthers = others;
      _customEmojis = emojis;
    });
  }

  Future<void> _loadSelectedAddictionData() async {
    if (widget.selectedAddiction == null) return;
    
    final last = await DopamineLogService.getLastTrigger(widget.selectedAddiction!.id);
    final count = await DopamineLogService.countForDate(widget.selectedAddiction!.id, DateTime.now());
    
    if (!mounted) return;
    setState(() {
      lastTrigger = last;
      triggersLoggedToday = count;
    });
  }

  Future<void> _loadTodayDailyLog() async {
    final entry = await DailyLogService.getEntry(DateTime.now());
    if (!mounted) return;
    setState(() {
      _currentDailyEntry = entry ?? DailyLogEntry();
    });
  }

  Future<void> _toggleMood(String moodKey) async {
    List<String> moods = List.from(_currentDailyEntry.moods);
    if (moods.contains(moodKey)) {
      moods.remove(moodKey);
    } else {
      moods.add(moodKey);
    }
    
    final updatedEntry = _currentDailyEntry.copyWith(moods: moods);
    await DailyLogService.saveEntry(DateTime.now(), updatedEntry);
    
    if (!mounted) return;
    setState(() {
      _currentDailyEntry = updatedEntry;
    });
  }

  Future<void> _toggleItem(String category, String itemKey) async {
    List<String> newList;
    DailyLogEntry updatedEntry;

    switch (category) {
      case 'activities':
        newList = List.from(_currentDailyEntry.activities);
        if (newList.contains(itemKey)) {
          newList.remove(itemKey);
        } else {
          newList.add(itemKey);
        }
        updatedEntry = _currentDailyEntry.copyWith(activities: newList);
        break;
      case 'others':
        newList = List.from(_currentDailyEntry.others);
        if (newList.contains(itemKey)) {
          newList.remove(itemKey);
        } else {
          newList.add(itemKey);
        }
        updatedEntry = _currentDailyEntry.copyWith(others: newList);
        break;
      default:
        return;
    }

    await DailyLogService.saveEntry(DateTime.now(), updatedEntry);

    if (!mounted) return;
    setState(() {
      _currentDailyEntry = updatedEntry;
    });
  }

  Future<void> _loadConfigData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      weeklyOccurrences = prefs.getInt('packetsPerWeek') ?? 0;
      dailyIntensity = prefs.getInt('cigarettesPerPacket') ?? 0;
    });
  }

  Future<void> _updateCalculations() async {
    if (lastTrigger != null) {
      double saved = await Calculations.calculateMoneySaved(lastTrigger!);
      int avoided = await Calculations.calculateCigarettesAvoided(
        lastTrigger!,
        weeklyOccurrences,
        dailyIntensity,
      );
      
      final duration = DateTime.now().difference(lastTrigger!);
      final hours = duration.inHours;

      if (!mounted) return;
      setState(() {
        benefitScore = saved;
        triggersAvoided = avoided;
        hoursWithoutTriggers = hours;
      });
    } else {
      if (!mounted) return;
      setState(() {
        benefitScore = 0.0;
        triggersAvoided = 0;
        hoursWithoutTriggers = 0;
      });
    }
  }

  Future<void> _logTrigger() async {
    if (widget.selectedAddiction == null) {
       print("HomeScreen: Log trigger failed - selectedAddiction is null");
       return;
    }
    
    final now = DateTime.now();
    print("HomeScreen: Logging trigger for ${widget.selectedAddiction!.name}");
    await DopamineLogService.logTrigger(widget.selectedAddiction!.id, timestamp: now);
    
    if (!mounted) return;
    await _loadSelectedAddictionData();
    await _updateCalculations();
    await WidgetProvider.updateWidgets();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context)!.homeSnackBarCigaretteLogged(widget.selectedAddiction?.name ?? 'Dopamine'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = lastTrigger != null
        ? DateTime.now().difference(lastTrigger!)
        : const Duration();
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final addictionName = widget.selectedAddiction?.name ?? 'Dopamine';

    final timeComponents = {
      'days': duration.inDays,
      'hours': duration.inHours % 24,
      'minutes': duration.inMinutes % 60
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeSinceLastTitle(addictionName),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTime(timeComponents),
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatLastTrigger(locale, context),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = 2;
              final itemWidth =
                  (constraints.maxWidth - (12 * (columnCount - 1))) /
                      columnCount;

              final colorScheme = Theme.of(context).colorScheme;
              final items = [
                _buildStatCard(
                  icon: Icons.bolt,
                  color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                  text: l10n.homeSmokedTodayText(
                    triggersLoggedToday.toString(),
                    addictionName,
                  ),
                  availableWidth: itemWidth,
                ),
                _buildStatCard(
                  icon: Icons.access_time,
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  text: l10n.homeHoursWithoutSmokingText(
                    hoursWithoutTriggers.toString(),
                    addictionName,
                  ),
                  availableWidth: itemWidth,
                ),
              ];

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: items,
              );
            },
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mood e Activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: [
                      // Moods
                      ...DailyLogService.moodEmojis.keys
                        .where((k) => ![
                              'obsessive',
                              'mood_swings',
                              'guilt',
                              'confused',
                              'self_critical'
                            ].contains(k))
                        .map((moodKey) {
                          final isSelected = _currentDailyEntry.moods.contains(moodKey);
                          return FilterChip(
                            visualDensity: VisualDensity.compact,
                            avatar: Text(DailyLogService.moodEmojis[moodKey]!),
                            label: Text(_getMoodLabel(moodKey, context), style: const TextStyle(fontSize: 14)),
                            selected: isSelected,
                            onSelected: (_) => _toggleMood(moodKey),
                            selectedColor: Colors.orange.withValues(alpha: 0.3),
                            checkmarkColor: Colors.orange,
                          );
                        }),
                      ..._customMoods.map((moodKey) {
                          final isSelected = _currentDailyEntry.moods.contains(moodKey);
                          return GestureDetector(
                            onLongPress: () => _showEditCustomItemDialog('moods', moodKey),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              avatar: Text(_customEmojis[moodKey] ?? '✨'),
                              label: Text(moodKey, style: const TextStyle(fontSize: 14)),
                              selected: isSelected,
                              onSelected: (_) => _toggleMood(moodKey),
                              selectedColor: Colors.orange.withValues(alpha: 0.3),
                              checkmarkColor: Colors.orange,
                            ),
                          );
                        }),
                      // Activities
                      ...DailyLogService.activityEmojis.keys
                        .where((k) => ![
                              'yoga',
                              'aerobics',
                              'team_sports',
                              'walking',
                              'cycling'
                            ].contains(k))
                        .map((activityKey) {
                          final isSelected = _currentDailyEntry.activities.contains(activityKey);
                          return FilterChip(
                            visualDensity: VisualDensity.compact,
                            avatar: Text(DailyLogService.activityEmojis[activityKey]!),
                            label: Text(_getActivityLabel(activityKey, context), style: const TextStyle(fontSize: 14)),
                            selected: isSelected,
                            onSelected: (_) => _toggleItem('activities', activityKey),
                            selectedColor: Colors.green.withValues(alpha: 0.3),
                            checkmarkColor: Colors.green,
                          );
                        }),
                      ..._customActivities.map((activityKey) {
                          final isSelected = _currentDailyEntry.activities.contains(activityKey);
                          return GestureDetector(
                            onLongPress: () => _showEditCustomItemDialog('activities', activityKey),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              avatar: Text(_customEmojis[activityKey] ?? '✨'),
                              label: Text(activityKey, style: const TextStyle(fontSize: 14)),
                              selected: isSelected,
                              onSelected: (_) => _toggleItem('activities', activityKey),
                              selectedColor: Colors.green.withValues(alpha: 0.3),
                              checkmarkColor: Colors.green,
                            ),
                          );
                        }),
                      // Others
                      ...DailyLogService.otherEmojis.keys
                        .where((k) => ![
                              'meditation',
                              'journaling',
                              'alcohol',
                              'breathing',
                              'kegel'
                            ].contains(k))
                        .map((otherKey) {
                          final isSelected = _currentDailyEntry.others.contains(otherKey);
                          return FilterChip(
                            visualDensity: VisualDensity.compact,
                            avatar: Text(DailyLogService.otherEmojis[otherKey]!),
                            label: Text(_getOtherLabel(otherKey, context), style: const TextStyle(fontSize: 14)),
                            selected: isSelected,
                            onSelected: (_) => _toggleItem('others', otherKey),
                            selectedColor: Colors.blue.withValues(alpha: 0.3),
                            checkmarkColor: Colors.blue,
                          );
                        }),
                      ..._customOthers.map((otherKey) {
                          final isSelected = _currentDailyEntry.others.contains(otherKey);
                          return GestureDetector(
                            onLongPress: () => _showEditCustomItemDialog('others', otherKey),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              avatar: Text(_customEmojis[otherKey] ?? '✨'),
                              label: Text(otherKey, style: const TextStyle(fontSize: 14)),
                              selected: isSelected,
                              onSelected: (_) => _toggleItem('others', otherKey),
                              selectedColor: Colors.blue.withValues(alpha: 0.3),
                              checkmarkColor: Colors.blue,
                            ),
                          );
                        }),
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Text('➕'),
                        label: const Text(''),
                        onPressed: _showAddCustomItemDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          ElevatedButton.icon(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _logTrigger,
                          label: Text(
                            l10n.homeLogCigaretteButton(addictionName),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
                          ),
                        ),
                      const SizedBox(width: 12),
                    ],
                  ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _formatLastTrigger(String locale, BuildContext context) {
    if (lastTrigger == null) {
      return AppLocalizations.of(context)!.homeNotStartedYet;
    }
    return AppLocalizations.of(context)!.homeLastSmokedLabel(
      DateFormat.yMMMMd(locale).add_Hm().format(lastTrigger!.toLocal()),
    );
  }

  void _showAddCustomItemDialog() {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addCustomItemTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.addCustomItemNameLabel,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  // Default to 'others' category for custom items
                  await DailyLogService.addCustomItem('others', name);
                  if (!context.mounted) return;
                  await _loadCustomItems();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomItemDialog(String category, String name) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController emojiController = TextEditingController(text: _customEmojis[name] ?? '✨');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: "Emoji",
                hintText: "Inserisci un'emoji",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () async {
                // Nested confirmation for delete
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.delete),
                    content: Text("${l10n.configDeleteAddictionConfirmation(name)}?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), 
                        child: Text(l10n.delete, style: const TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await DailyLogService.removeCustomItem(category, name);
                  if (!context.mounted) return;
                  await _loadCustomItems();
                  
                  DailyLogEntry updatedEntry = _currentDailyEntry;
                  if (category == 'moods') {
                    List<String> newList = List.from(_currentDailyEntry.moods);
                    if (newList.remove(name)) {
                       updatedEntry = _currentDailyEntry.copyWith(moods: newList);
                    }
                  } else if (category == 'activities') {
                    List<String> newList = List.from(_currentDailyEntry.activities);
                    if (newList.remove(name)) {
                       updatedEntry = _currentDailyEntry.copyWith(activities: newList);
                    }
                  } else {
                    List<String> newList = List.from(_currentDailyEntry.others);
                    if (newList.remove(name)) {
                       updatedEntry = _currentDailyEntry.copyWith(others: newList);
                    }
                  }
                  
                  if (updatedEntry != _currentDailyEntry) {
                    await DailyLogService.saveEntry(DateTime.now(), updatedEntry);
                    if (mounted) setState(() => _currentDailyEntry = updatedEntry);
                  }

                  if (context.mounted) {
                    Navigator.pop(context); // Close edit dialog
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newEmoji = emojiController.text.trim();
              if (newEmoji.isNotEmpty) {
                await DailyLogService.setCustomEmoji(name, newEmoji);
                if (!context.mounted) return;
                await _loadCustomItems();
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String text,
    required double availableWidth,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: availableWidth,
      child: Card(
        color: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodLabel(String moodKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (moodKey) {
      case 'calm': return l10n.moodCalm;
      case 'happy': return l10n.moodHappy;
      case 'energetic': return l10n.moodEnergetic;
      case 'irritated': return l10n.moodIrritated;
      case 'sad': return l10n.moodSad;
      case 'anxious': return l10n.moodAnxious;
      case 'depressed': return l10n.moodDepressed;
      case 'low_energy': return l10n.moodLowEnergy;
      case 'apathetic': return l10n.moodApathetic;
      default: return moodKey;
    }
  }

  String _getActivityLabel(String activityKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (activityKey) {
      case 'none': return l10n.activityNone;
      case 'gym': return l10n.activityGym;
      case 'swimming': return l10n.activitySwimming;
      case 'running': return l10n.activityRunning;
      default: return activityKey;
    }
  }

  String _getOtherLabel(String otherKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (otherKey) {
      case 'travel': return l10n.otherTravel;
      case 'stress': return l10n.otherStress;
      case 'illness': return l10n.otherIllness;
      default: return otherKey;
    }
  }
}
