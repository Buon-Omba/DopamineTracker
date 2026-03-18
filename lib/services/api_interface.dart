import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dopamine_tracker/utils/calculations.dart';
import 'package:dopamine_tracker/services/preferences_service.dart';

class ApiInterface {
  static const String baseUrl =
      'https://dopamine-tracker.retiolus.net/api'; 
  static const String apiKey = '10bcd742-fb08-47f9-bf06-6c7faf9e7988';
  static const int syncCooldownSeconds = 10;

  // Send sync request to the server
  static Future<Map<String, dynamic>?> syncData({
    required String deviceId,
    required String lastTrigger,
    required int triggersAvoided,
    required double benefitScore,
    required List<Map<String, dynamic>> friends,
  }) async {
    final url = Uri.parse('$baseUrl/sync');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode({
          'device_id': deviceId,
          'last_smoked': lastTrigger,
          'cig_avoided': triggersAvoided,
          'money_saved': benefitScore,
          'friends': friends,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Save friends data locally
  static Future<void> saveFriendsData(List<dynamic> friendsData) async {
    final prefs = await PreferencesService.instance;
    await prefs.setString('friendsData', jsonEncode(friendsData));
  }

  // Load friends data from local storage
  static Future<List<dynamic>> loadFriendsData() async {
    final prefs = await PreferencesService.instance;
    String? friendsDataJson = prefs.getString('friendsData');
    if (friendsDataJson != null) {
      return jsonDecode(friendsDataJson);
    }
    return [];
  }

  // Sync data with server and save friends' info
  static Future<void> performSync() async {
    final prefs = await PreferencesService.instance;

    // Check cooldown for sync
    int? lastSyncTimestamp = prefs.getInt('lastSyncTimestamp');
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (lastSyncTimestamp != null &&
        currentTimestamp - lastSyncTimestamp < syncCooldownSeconds) {
      return;
    }

    // Update the last sync time
    await prefs.setInt('lastSyncTimestamp', currentTimestamp);

    // Retrieve user data
    String? deviceId = prefs.getString('userId');
    String? lastTriggerStr = prefs.getString('lastTrigger');
    int weeklyOccurrences = prefs.getInt('packetsPerWeek') ?? 0;
    int dailyIntensity = prefs.getInt('cigarettesPerPacket') ?? 0;

    if (deviceId == null || lastTriggerStr == null) {
      return;
    }

    DateTime lastTrigger = DateTime.parse(lastTriggerStr);

    // Perform calculations
    double benefitScore = await Calculations.calculateMoneySaved(lastTrigger);
    int triggersAvoided = await Calculations.calculateCigarettesAvoided(
      lastTrigger,
      weeklyOccurrences,
      dailyIntensity,
    );

    // Load local friends data
    List<Map<String, dynamic>> localFriends = [];
    String? friendsJson = prefs.getString('friendsData');
    if (friendsJson != null) {
      localFriends = List<Map<String, dynamic>>.from(jsonDecode(friendsJson));
    }

    // Start syncing with the server
    final response = await syncData(
      deviceId: deviceId,
      lastTrigger: lastTrigger.toIso8601String(),
      triggersAvoided: triggersAvoided,
      benefitScore: benefitScore,
      friends: localFriends,
    );

    if (response == null) {
      return;
    }

    if (response['friends_data'] is List) {
      // Merge server response with local data
      List<Map<String, dynamic>> updatedFriends = mergeFriendsData(
        localFriends,
        List<Map<String, dynamic>>.from(response['friends_data']),
      );

      // Save the merged data locally
      await saveFriendsData(updatedFriends);
    }
  }

  // Merge server data with local data
  static List<Map<String, dynamic>> mergeFriendsData(
    List<Map<String, dynamic>> localFriends,
    List<Map<String, dynamic>> serverFriends,
  ) {
    Map<String, Map<String, dynamic>> friendsMap = {
      for (var friend in localFriends) friend['uid']: friend
    };

    for (var serverFriend in serverFriends) {
      String serverUid = serverFriend['device_id'];
      if (friendsMap.containsKey(serverUid)) {
        // Update local friend with server data
        friendsMap[serverUid]?.addAll(serverFriend);
      } else {
        // Add new friend from server
        friendsMap[serverUid] = serverFriend;
      }
    }

    return friendsMap.values.toList();
  }
}
