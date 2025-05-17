import 'dart:async'; // Import for Timer
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'RefreshToken.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/auth/login_page.dart'; // Required for Navigator

class AuthTokenService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  Timer? _tokenCheckTimer;

  // This will be called from any screen where the token needs to be checked/handled
  Future<void> startTokenCheck(BuildContext context) async {
    await _checkAndRefreshToken(context); // Initial check
    _startTokenCheckTimer(context); // Start periodic checks
  }

  Future<void> _checkAndRefreshToken(BuildContext context) async {
    String? token = await storage.read(key: 'jwt');

    if (token == null) {
      _handleExpiredRefreshToken(context);
      return;
    }

    // Load the user email (you can pass it if needed or fetch it from storage)
    String? userEmail = await storage.read(key: 'username');
    if (userEmail == null) {
      print("User email not available");
      return;
    }

    final refreshToken = RefreshToken(userEmail: userEmail);
    bool isTokenExpired = refreshToken.isTokenExpired(token);

    if (isTokenExpired) {
      try {
        await refreshToken.refreshToken();
        print("Token refreshed successfully.");
      } catch (error) {
        print('Error refreshing token: $error');
        _handleExpiredRefreshToken(context);
      }
    } else {
      print("Token is still valid.");
    }
  }

  void _startTokenCheckTimer(BuildContext context) {
    _tokenCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      print("Checking token expiration...");
      _checkAndRefreshToken(context);
    });
  }

  void _stopTokenCheckTimer() {
    if (_tokenCheckTimer != null) {
      _tokenCheckTimer!.cancel();
      _tokenCheckTimer = null;
    }
  }

  void _handleExpiredRefreshToken(BuildContext context) {
    // Navigate to login page if the refresh fails or token is expired
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void dispose() {
    _stopTokenCheckTimer();
  }
}
