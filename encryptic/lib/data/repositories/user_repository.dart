import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final _storage = FlutterSecureStorage();

  Future<void> saveUserData(String username, String imageUrl, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('imageUrl', imageUrl);
    await prefs.setString('userEmail', email);
  }

  Future<void> saveTokens(String key) async {
    await _storage.write(key: 'private key', value: key);
  }

  Future<void> saveUserFriends(List<String> friendsUsernames) async {
    try {
      final String encodedFriends = jsonEncode(friendsUsernames); // Convert List<String> to JSON
      await _storage.write(key: 'friends', value: encodedFriends); // Save to secure storage
      print('Friends usernames saved successfully.');
    } catch (e) {
      print('Error saving friends usernames: $e');
      throw Exception('Failed to save friends usernames.');
    }
  }

  Future<List<String>> fetchSavedUserFriends() async {
    try {
      final String? encodedFriends = await _storage.read(key: 'friends'); // Read from secure storage
      if (encodedFriends != null) {
        return List<String>.from(jsonDecode(encodedFriends)); // Decode JSON to List<String>
      }
      return []; // Return empty list if nothing is stored
    } catch (e) {
      print('Error fetching saved friends usernames: $e');
      throw Exception('Failed to fetch saved friends usernames.');
    }
  }

}
