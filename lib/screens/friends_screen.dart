import 'dart:async';
import 'dart:convert';

import 'package:dopamine_tracker/components/navigation_bar.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:dopamine_tracker/services/api_interface.dart';
import 'package:dopamine_tracker/services/preferences_service.dart';
import 'package:dopamine_tracker/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  const FriendsScreen({super.key, required this.setThemeMode});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String? userId; // Stores the user's unique ID
  bool isLoading = false; // Tracks loading state
  List<Map<String, dynamic>> friends = []; // List of friends
  int weeklyOccurrences = 0;
  int dailyIntensity = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID on startup
    _loadConfig().then((_) => _loadFriends()); // Load config then friends
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateFriendDerivedStats(),
    );
  }

  // Load the user ID from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _loadConfig() async {
    final prefs = await PreferencesService.instance;
    setState(() {
      weeklyOccurrences = prefs.getInt('packetsPerWeek') ?? 0;
      dailyIntensity = prefs.getInt('cigarettesPerPacket') ?? 0;
    });
  }

  // Load friends from SharedPreferences
  Future<void> _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? friendsJson = prefs.getString('friendsData');
    if (friendsJson != null) {
      setState(() {
        friends = List<Map<String, dynamic>>.from(
          jsonDecode(friendsJson),
        );
      });
      await _updateFriendDerivedStats();
    }
  }

  // Save friends to SharedPreferences
  Future<void> _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('friendsData', jsonEncode(friends));
  }

  // Show a QR code of the user's ID and allow copying UID
  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.friendsDialogUIDYourQRText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            userId != null && userId!.isNotEmpty
                ? SizedBox(
                    // QR Code display
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      data: userId!,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.friendsDialogUIDNotAvailable),
            const SizedBox(height: 10),
            SelectableText(
              userId ?? AppLocalizations.of(context)!.friendsDialogUIDNoUserUID,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userId ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .friendsDialogUIDCopiedToClipboard)),
                );
              },
              child:
                  Text(AppLocalizations.of(context)!.friendsDialogUIDCopyUID),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  // Manually enter a friend's UID and name
  void _enterManualUid() {
    TextEditingController uidController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.friendsDialogAddFriendTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .friendsDialogAddFriendNameText),
            ),
            TextField(
              controller: uidController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .friendsDialogAddFriendUIDText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (uidController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                setState(() {
                  friends.add({
                    'name': nameController.text,
                    'uid': uidController.text,
                  });
                });
                _saveFriends();
                Navigator.of(context).pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  // Reload data from the API
  Future<void> _reloadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await ApiInterface.performSync();
      await _loadFriends(); // Reload friends from local storage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.friendsSnackBarSyncSuccessfull)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.friendsSnackBarSyncFailed)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.friendsScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _reloadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: friends.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.friendsNoFriendsText,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Card(
                        elevation: 4,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => _editFriendName(index),
                                    child: Text(
                                      friend['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.delete, color: Colors.black),
                                    onPressed: () {
                                      setState(() {
                                        friends.removeAt(index);
                                      });
                                      _saveFriends();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.bolt, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .friendsLastSmokedText(
                                      friend['last_smoked'] != null
                                          ? DateFormat.yMMMMd(
                                                  Localizations.localeOf(
                                                          context)
                                                      .toString())
                                              .add_Hm()
                                              .format(DateTime.parse(
                                                  friend['last_smoked']))
                                          : AppLocalizations.of(context)!.n_a,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .friendsCigarettesAvoidedText(
                                      _formatNumber(
                                        friend['derived_cig_avoided'] ??
                                            friend['cig_avoided'] ??
                                            0,
                                        decimals: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .friendsMoneySavedText(
                                      _formatNumber(
                                        friend['derived_money_saved'] ??
                                            friend['money_saved'] ??
                                            0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .friendsLastAnnouncedText(
                                      friend['last_announced'] != null
                                          ? DateFormat.yMMMMd(
                                                  Localizations.localeOf(
                                                          context)
                                                      .toString())
                                              .add_Hm()
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      friend['last_announced'] *
                                                          1000))
                                          : AppLocalizations.of(context)!.n_a,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  onPressed: _showQrCodeDialog,
                  label:
                      Text(AppLocalizations.of(context)!.friendsButtonShowUID),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: Text(AppLocalizations.of(context)!
                                  .friendsButtonShowUIDEnterUIDText),
                              onTap: () {
                                Navigator.pop(context);
                                _enterManualUid();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  label: Text(
                      AppLocalizations.of(context)!.friendsButtonAddFriend),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2, setThemeMode: widget.setThemeMode),
    );
  }

  // Method to edit a friend's name
  void _editFriendName(int index) {
    TextEditingController nameController =
        TextEditingController(text: friends[index]['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalizations.of(context)!.friendsDialogEditFriendsNameTitle),
        content: TextField(
          controller: nameController,
          decoration:
              InputDecoration(labelText: AppLocalizations.of(context)!.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                friends[index]['name'] = nameController.text;
              });
              _saveFriends();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFriendDerivedStats() async {
    if (friends.isEmpty) return;
    final updated = <Map<String, dynamic>>[];

    for (final friend in friends) {
      final updatedFriend = Map<String, dynamic>.from(friend);
      final lastTriggerStr = friend['last_smoked'];
      if (lastTriggerStr != null) {
        final lastTrigger = DateTime.tryParse(lastTriggerStr);
        if (lastTrigger != null) {
          updatedFriend['derived_cig_avoided'] =
              await Calculations.calculateCigarettesAvoided(
            lastTrigger,
            weeklyOccurrences,
            dailyIntensity,
          );
          updatedFriend['derived_money_saved'] =
              await Calculations.calculateMoneySaved(lastTrigger);
        }
      }
      updated.add(updatedFriend);
    }

    if (mounted) {
      setState(() {
        friends = updated;
      });
    }
  }

  String _formatNumber(dynamic value, {int decimals = 2}) {
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(decimals);
    if (value is num) return value.toStringAsFixed(decimals);
    return '0';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
