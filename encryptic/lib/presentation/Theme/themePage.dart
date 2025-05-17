import 'package:encryptic/presentation/Theme/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home/home_page.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchState();
  }

  Future<void> _loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitched = prefs.getBool('isSwitched') ?? false;
    });
  }

  Future<void> _saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitched', value);
  }

  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });
    _saveSwitchState(value);
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 10),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  size: 30,
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              alignment: Alignment.center,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Light Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Orbitron_black',
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: _toggleSwitch,
                    activeColor: isSwitched ? Color(0xff263A47) : Color(0xff9813F1),
                    inactiveThumbColor: Color(0xff9813F1),
                    inactiveTrackColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
