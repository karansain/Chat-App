import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_page.dart';
import '../home/home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String KEY = "Login";
  String? username;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start animation and determine navigation flow
    _startSplash();
  }

  @override
  void dispose() {
    // Dispose of the animation controller and WebSocket channel
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: _animation != null
              ? LayoutBuilder(
            builder: (context, constraints) {
              return Opacity(
                opacity: _animation.value,
                child: Text(
                  'Encryptic',
                  style: TextStyle(
                    fontFamily: 'Orbitron_black',
                    fontSize: constraints.maxWidth * 0.1, // Responsive font size
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              );
            },
          )
              : CircularProgressIndicator(), // Show loading indicator if animation is not initialized
        ),
      ),
    );
  }

  void _startSplash() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool isLogin = sharedPref.getBool(KEY) ?? false;

    _controller.forward();
    _controller.addListener(() {
      setState(() {}); // Update the state on each animation frame
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isLogin) {
          // Navigate to home page if logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Navigate to login page if not logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    });
  }
}
