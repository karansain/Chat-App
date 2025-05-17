import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class settingPage extends StatefulWidget {
  @override
  State<settingPage> createState() => _settingPage();
}

class _settingPage extends State<settingPage> {

  // final String? previousPage;
  //
  // _settingPage(this.previousPage);
  //
  //
  // void _navigateBack(BuildContext context) {
  //   // Navigate back to the appropriate page based on the previousPage value
  //   if (previousPage == 'menueScreen') {
  //     Navigator.popUntil(context, ModalRoute.withName('/'));
  //   } else if (previousPage == 'profilePage') {
  //     Navigator.pop(context);
  //   }
  // }

  final List<String> sName = [
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1',
    'setting 1'
  ];

  final List<IconData> icn = [
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings,
    Icons.settings
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) => settingPage()));
                  },
                  icon: Icon(Icons.arrow_back_ios),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    fontSize: 20,
                    decoration: TextDecoration.none,
                    // fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron_black',
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                ),
                itemCount: 11,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(icn[index], size: 50, color: Theme.of(context).colorScheme.tertiaryContainer,),
                        // SizedBox(height: 10),
                        Text(
                          sName[index],
                          style: TextStyle(fontFamily: 'Orbitron_black', color: Colors.white, fontSize: 10, decoration: TextDecoration.none),
                        ),
                        // SizedBox(height: 5),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.all(5),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
