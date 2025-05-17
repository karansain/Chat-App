import 'package:encryptic/presentation/screens/clubs/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../home/home_page.dart';
import 'clubinfo.dart';

class clubScreen extends StatefulWidget {
  final String clubName;
  final String imagePath;
  final int clubId;
  final int userId;
  final String userName;

  clubScreen(
      {required this.clubName,
      required this.imagePath,
      required this.clubId,
      required this.userId,
      required this.userName});

  @override
  State<clubScreen> createState() => _chatScreen();
}

class _chatScreen extends State<clubScreen> {

  @override
  Widget build(BuildContext context) {
    bool _isFabVisible = true;

    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        bottom: false,
        child: Container(
          height: double.infinity,
          padding: EdgeInsets.only(bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Container

              Container(
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
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
                        size: 35,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                    // Hero widget wrapped around clubName for smooth transition
                    Hero(
                      tag:
                          'club_${widget.clubName}', // Unique tag for hero transition
                      child: Material(
                        color: Colors
                            .transparent, // Transparent material to avoid any background color
                        child: Text(
                          widget.clubName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Orbitron_black',
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: PopupMenuButton<String>(
                        onSelected: (String value) {
                          print('Selected: $value');
                          switch (value) {
                            case 'Info':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ClubInfo(
                                            imageUrl: widget.imagePath,
                                            clubId: widget.clubId,
                                            clubName: widget.clubName,
                                            LoggedInUser: widget.userName,
                                        userId: widget.userId,
                                          )));
                              break;
                            default:
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Info',
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: Center(child: popItem('Info'))),
                          ),
                          PopupMenuItem<String>(
                            value: 'Info',
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: Center(child: popItem('Info'))),
                          ),
                        ],
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 35,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Middle Container

              Expanded(
                child: Stack(children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  ExpandableFab(
                    type: ExpandableFabType.fan,
                    openButtonBuilder: DefaultFloatingActionButtonBuilder(
                      fabSize: ExpandableFabSize.regular,
                      child: Icon(Icons.menu),
                    ),
                    closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                      fabSize: ExpandableFabSize.regular,
                      child: Icon(Icons.close),
                    ),
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Questions(
                                        clubName: widget.clubName,
                                        clubId: widget.clubId,
                                        userId: widget.userId,
                                      )));
                        },
                        child: Icon(Icons.question_answer_outlined),
                      ),
                      FloatingActionButton(
                        onPressed: () {},
                        child: Icon(Icons.close),
                      ),
                      FloatingActionButton(
                        onPressed: () {},
                        child: Icon(Icons.close),
                      ),
                    ],
                  )
                ]),
              ),

              // Bottom Container

              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 65,
                margin: EdgeInsets.only(left: 5.0, right: 5.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50)),
                        child: TextField(
                          decoration: InputDecoration(
                              fillColor:
                                  Theme.of(context).colorScheme.secondary,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              hintText: 'Message',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(15)),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.send_rounded,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget popItem(String option) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          option,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Orbitron_black',
          ),
        ),
      ),
    );
  }
}

