import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/Models/user.dart';
import 'userProfile.dart';

class SearchAll extends StatefulWidget {


  @override
  State<SearchAll> createState() => _UserlistState();
}

class _UserlistState extends State<SearchAll> {
  late WebSocketChannel _channel;
  List<User> _allUsers = [];
  List<User> _foundUsers = [];

  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      // onChanged: (value) => _runFilter(value),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15),
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.white70),
                        suffixIcon: Icon(Icons.search,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
