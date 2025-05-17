import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/home_repository.dart';
import '../../../data/services/web_socket_service.dart';
import 'clubScreen.dart';

class JoinedOrNot extends StatelessWidget {
  final int clubId;
  final int userId;
  final String clubName;
  final String imagePath;
  final String username;

  JoinedOrNot({
    required this.clubId,
    required this.userId,
    required this.clubName,
    required this.imagePath,
    required this.username, // Initialize username
  });

  // Function to save the membership status in SharedPreferences
  Future<void> _joinClub(BuildContext context) async {
    String url = "ws://192.168.29.123:8080/ws";
    final webSocketService = WebSocketService(url);

    HomeRepository homeRepository = HomeRepository(webSocketService);

    // Await the result of JoinClub since it's a Future
    String result = await homeRepository.JoinClub(userId, clubId); // Use await here

    if (result == "Success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Use a key that includes both username and clubId
      await prefs.setBool('isJoined_${username}_$clubId', true);

      // After joining, navigate to the chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => clubScreen(
            clubName: clubName,
            imagePath: imagePath,
            clubId: clubId,
            userId: userId,
            userName: username,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed To Join Club"))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Join $clubName',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          content: Text(
            'Do you want to join the club?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel the action
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Join the club and update the SharedPreferences
                _joinClub(context);
              },
              child: Text(
                'Join',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
