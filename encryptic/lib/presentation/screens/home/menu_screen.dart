import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Theme/themePage.dart';
import '../others/settingPage.dart';
import '../others/splash_screen.dart';
import '../../../data/services/user_preferences.dart';
import '../auth/login_page.dart';


class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenueScreenState();
}

class _MenueScreenState extends State<MenuScreen> {
  bool _isSwitched = false;
  String _username = "User Name"; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserPreferences userPreferences = UserPreferences();

    // Retrieve user data asynchronously
    String? username = await userPreferences.getUsername();

    // Update state asynchronously
    setState(() {
      // Update your state variables with retrieved data
      this._username = username ?? ''; // Provide default value if null
    });

  }

  void _logout() async {
    UserPreferences userPreferences = UserPreferences();
    // await userPreferences.clearUserData();
  }

  void _toggleSwitch(bool value) {
    setState(() {
      _isSwitched = value;
    });
  }

  final List<String> menuItem = [
    'New Club',
    'Settings',
    'Theme',
    'Invite',
    'Help',
    'Log Out'
  ];

  final List<IconData> icns = [
    Icons.add_comment_rounded,
    Icons.settings,
    Icons.light_mode_rounded,
    Icons.add,
    Icons.help,
    Icons.logout_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 50.0),
      margin: EdgeInsets.only(top: 5),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _username, // Display the loaded username here
                  style: TextStyle(
                      fontFamily: 'Orbitron_black',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.tertiary),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () async {
                      switch (index) {
                        case 0:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Coming Soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          break;
                        case 1:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => settingPage()));
                          break;
                        case 2:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThemePage()));
                          break;
                        case 3:
                        // Perform operation for 'Invite' item
                          break;
                        case 4:
                        // Perform operation for 'Help and Support' item
                          break;
                        case 5:
                          var srPf = await SharedPreferences.getInstance();

                          // _logout();
                          srPf.setBool(SplashScreenState.KEY, false);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                                (Route<dynamic> route) => false, // Remove all routes
                          );
                          break;
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 2),
                      trailing: Icon(
                        icns[index],
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      title: Text(
                        menuItem[index],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Orbitron_black',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ));
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 10); // Space between items
              },
              itemCount: menuItem.length,
            ),
          ),
        ],
      ),
    );
  }
}
