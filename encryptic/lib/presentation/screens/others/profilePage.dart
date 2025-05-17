import 'package:cached_network_image/cached_network_image.dart';
import 'package:encryptic/presentation/screens/others/settingPage.dart';
import 'package:flutter/material.dart';

import '../../../data/services/user_preferences.dart';
// import 'package:flutter1/Other/settingPage.dart';

class profilePage extends StatefulWidget {
  String? imgUrl;
  profilePage({required this.imgUrl});
  @override
  State<profilePage> createState() => _profilePage();
}

class _profilePage extends State<profilePage> {

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
      this._username = username ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Stack(
            children: [
          //Back Pic
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.imgUrl ?? ''),
                    fit: BoxFit.cover)),
          ),

          // Overlay Container

          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Buttons
          SafeArea(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(50)),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => settingPage()));
                            },
                            icon: Icon(Icons.arrow_back_ios),
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              fontFamily: 'Orbitron_black',
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(50)),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => settingPage()));
                            },
                            icon: Icon(Icons.settings),
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.tertiaryContainer,),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.edit,
                            size: 40,
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.logout_rounded,
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Main Pic
          Center(
            child: Stack(children: [
              Container(
                height: 350,
                width: 250,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.imgUrl ?? ''),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(30)),
              ),

              Container(
                height: 350,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30)),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
                height: 350,
                width: 250,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        fontFamily: 'Orbitron_black',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(50)),
                            child: Text('Something', style: TextStyle(
                              color: Colors.black
                            ),),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(50)),
                            child: Text('Something', style: TextStyle(
                                color: Colors.black
                            ),),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(50)),
                            child: Text('Something', style: TextStyle(
                                color: Colors.black
                            ),),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ]));
  }
}
