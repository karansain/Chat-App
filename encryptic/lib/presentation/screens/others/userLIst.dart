import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/Models/user.dart';
import '../../../data/repositories/user_repository.dart';
import 'SearchAll.dart';
import 'userProfile.dart';

class Userlist extends StatefulWidget {
  final String loggedInUser;

  Userlist({required this.loggedInUser});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {
  late WebSocketChannel _channel;
  List<User> _allUsers = [];
  List<User> _foundUsers = [];
  var urll = 'ws://192.168.29.123:8080/ws';

  List<String> friendsUsernames = [];

  final userRepository = UserRepository();

  void loadFriends() async {
    final userRepository =
        UserRepository(); // Create an instance of UserRepository

    try {
      List<String> friends =
          await userRepository.fetchSavedUserFriends(); // Fetch the data
      print('Saved friends: $friends'); // Display the fetched usernames
      friendsUsernames = friends;
    } catch (e) {
      print('Error fetching friends: $e'); // Handle errors
    }
  }

  //'ws://172.24.18.31:8080/ws'

  @override
  void initState() {
    super.initState();
    loadFriends();
    print("Printing User's Friends.");
    print(friendsUsernames);
    _channel = WebSocketChannel.connect(Uri.parse(urll)
// Uri.parse('ws://192.168.62.26:8080/ws')
        );

    _fetchUsers();
  }

  void _fetchUsers() {
    _channel.sink.add('{"type": "getAllUsers", "data": {}}');

    _channel.stream.listen((response) {
      print("Raw response: $response");

      try {
        List<dynamic> jsonResponse =
            response is String ? jsonDecode(response) : [];
        List<User> users =
            jsonResponse.map((data) => User.fromJson(data)).toList();
        // Filter out the logged-in user
        friendsUsernames.add(widget.loggedInUser);
        final filteredUsers = users
            .where((user) => !friendsUsernames.contains(user.username))
            .toList();

        setState(() {
          _allUsers = filteredUsers;
          _foundUsers = _allUsers; // Initially show filtered users
        });
      } catch (e) {
        print("Error parsing response: $e");
      }
    }).onError((error) {
      print("Error: $error");
    });
  }

  void _runFilter(String enteredKeyword) {
    List<User> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers.where((user) {
        return user.username
            .toLowerCase()
            .contains(enteredKeyword.toLowerCase());
      }).toList();
    }
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      floatingActionButton: allSearch(),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
                      onChanged: (value) => _runFilter(value),
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
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => InkWell(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: double.infinity,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          _foundUsers[index].photoUrl ?? ' '),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,)),
                              ),
                              Text(
                                _foundUsers[index].username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  fontFamily: 'Orbitron_black',
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    ],
                                    end: Alignment.topCenter,
                                    begin: Alignment.bottomCenter,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final WebSocketChannel channel =
                                        WebSocketChannel.connect(
                                            // Uri.parse('ws://192.168.62.26:8080/ws')
                                            Uri.parse(urll) //172.24.18.31
                                            );
                                    // Send the addFriend request to the server
                                    channel.sink.add(jsonEncode({
                                      "type": "addFriend",
                                      "data": {
                                        "username": widget.loggedInUser,
                                        "friendUsername":
                                            _foundUsers[index].username,
                                      },
                                    }));
                                    // Listen for the WebSocket stream
                                    StreamSubscription subscription =
                                        channel.stream.listen((response) {
                                      // Assuming response is a plain text message
                                      if (response.contains(
                                          'Friend added successfully')) {
                                        print('Success');

                                        // Show a success SnackBar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Friend added successfully"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // Optionally: Update state or UI if needed, e.g., remove the user from the list
                                        setState(() {
                                          _foundUsers.removeAt(index);
                                        });
                                      } else {
                                        // Show a failure SnackBar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Friend addition failed: $response"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }, onError: (error) {
                                      // Handle any errors here
                                      print('Error: $error');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'An error occurred: $error'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }, onDone: () {
                                      // Close the WebSocket connection after the operation is complete
                                      channel.sink.close();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    'ADD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontFamily: 'Orbitron_black',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => userProfilePage(
                                userName: _foundUsers[index].username,
                                imagePath: _foundUsers[index].photoUrl ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: const Text(
                        'No results found',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
            ),
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

  Widget allSearch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        shape: BoxShape.rectangle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
      ),
      child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchAll()));
          },
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.person_search,
            color: Theme.of(context).colorScheme.tertiary,
          )),
    );
  }
}
