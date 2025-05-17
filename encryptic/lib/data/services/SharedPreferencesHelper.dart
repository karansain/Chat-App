import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Save membership status
  Future<void> joinClub(String userId, int clubId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'isJoined_${userId}_$clubId';
    await prefs.setBool(key, true);
  }

  // Check membership status
  Future<bool> checkIfUserHasJoined(String userId, int clubId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'isJoined_${userId}_$clubId';
    return prefs.getBool(key) ?? false;
  }
}
