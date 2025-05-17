import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<void> saveUserData(String userId, String username, String photo, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('photo', photo);
    await prefs.setString('email', email);
  }

  Future<int?> getUderId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');
    return userIdString != null ? int.tryParse(userIdString) : null; // Safely convert to int
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('photo');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}
