import 'dart:convert';

import 'package:encryptic/data/repositories/user_repository.dart';
import 'package:http/http.dart' as http;


class AuthRepository {
  final String baseUrl = 'http://192.168.29.123:8080/auth'; // Your API base URL

  // Method to log in
  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginRequest = {
      "email": email,
      "password": password,
    };

    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(loginRequest);

    try {
      final response = await http.post(url, headers: headers, body: body);
      // Print the response details for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final responseData = json.decode(response.body);
      print(responseData);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        print("All Set");
        // Save tokens using the user repository
        final userRepository = UserRepository();
        userRepository.saveTokens(responseData['key']);
        print("data saved");

        return {
          "userId": responseData['userId'],
          "username": responseData['username'],
          "imageUrl": responseData['imageUrl'],
        };
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

// Method to sign up
  Future<String> signup(
      String username, String email, String password, String imageUrl) async {
    final signupRequest = {
      "username": username,
      "email": email,
      "password": password,
      "photoUrl": imageUrl,
    };

    final url = Uri.parse('$baseUrl/signup');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(signupRequest);

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Print the response details for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("All Set");
        return 'User registered successfully';
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print(e);
      throw Exception('Signup failed: $e');
    }
  }
}
