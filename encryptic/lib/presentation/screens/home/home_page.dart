import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/user_preferences.dart';
import '../../../bloc/home/clubs/clubs_bloc.dart';
import '../../../bloc/home/clubs/clubs_event.dart';
import '../../../bloc/home/friends/friends_bloc.dart';
import '../../../bloc/home/friends/friends_event.dart';
import '../../../bloc/home/friends/friends_state.dart';
import 'home_screen.dart';
import 'menu_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetching the username from UserPreferences
  Future<void> _loadUserData() async {
    final userPreferences = UserPreferences();
    final username = await userPreferences.getUsername();
    setState(() {
      _username = username ?? 'Guest'; // Default to 'Guest' if username is null
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null) {
      // While waiting for the username to load, show a loading indicator
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FriendsBloc(homeRepository: context.read())
              ..add(FetchFriends(_username!)), // Fetch friends on load
          ),
          BlocProvider(
            create: (context) => ClubsBloc(homeRepository: context.read())
              ..add(FetchClub()), // Fetch clubs on load
          ),
        ],
        child: Stack(
          children: [
            // Menu (sidebar) screen with animation
            MenuScreen(), // Menu screen

            // Home screen content
            BlocConsumer<FriendsBloc, FriendsState>(
              listener: (context, state) {
                if (state is FriendsError) { // Corrected to FriendsError
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                }
              },
              builder: (context, state) {
                if (state is FriendsLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is FriendsLoaded) {
                  final friends = state.friendsList;
                  return HomeScreen(username: _username!);
                } else if (state is FriendsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Center(child: Text("No friends found."));
              },
            ),
          ],
        ),
      ),
    );
  }
}
