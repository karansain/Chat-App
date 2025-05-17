import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';


class RefreshToken {
  String? userEmail;

  RefreshToken({required this.userEmail});

  final storage = FlutterSecureStorage();

  late WebSocketChannel? channel;

  // Method to establish WebSocket connection (reconnect if needed)
  void connectWebSocket() {
    if (channel == null || channel!.closeCode != null) {
      channel = WebSocketChannel.connect(Uri.parse('ws://172.24.18.31:8080/ws'));
    }
  }

  // Check if token is expired
  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  // Refresh token logic
  Future<void> refreshToken() async {
    connectWebSocket(); // Ensure WebSocket is connected

    String? refreshToken = await storage.read(key: 'refreshToken');

    if (refreshToken != null) {
      // Construct the refresh token request
      final refreshRequest = {
        "type": "refreshToken",
        "data": {"email": userEmail, "refreshToken": refreshToken}
      };

      // Send the refresh token request via WebSocket
      channel!.sink.add(jsonEncode(refreshRequest));

      // Listen for the response to update the token
      channel!.stream.listen((response) async {
        final decodedResponse = jsonDecode(response);

        if (decodedResponse['status'] == 'success') {
          String newToken = decodedResponse['accessToken'];
          // Save the new access token
          await storage.write(key: 'jwt', value: newToken);
        } else {
          // Handle error or force logout if refresh token is also invalid
          _handleExpiredRefreshToken();
        }
      }, onError: (error) {
        // Handle WebSocket errors
        print('WebSocket Error: $error');
        _handleExpiredRefreshToken();
      });
    } else {
      // Handle missing refresh token (e.g., force the user to log in again)
      _handleExpiredRefreshToken();
    }
  }

  // Handle an expired or missing refresh token
  void _handleExpiredRefreshToken() async {
    // Clear tokens and user data
    await logout();
    // Here, you'll need to redirect to the login page via the app's navigation system
    // e.g., use a callback or ensure the calling widget handles redirection
  }

  // Logout function to clear tokens and user data
  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'refreshToken');

    // Clear any other user-related data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear user preferences
  }

  // Ensure to close the WebSocket connection when no longer needed
  void dispose() {
    channel?.sink.close();
  }
}
