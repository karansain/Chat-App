import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/home/clubs/clubs_bloc.dart';
import '../../../bloc/home/clubs/clubs_event.dart';
import '../../../bloc/home/clubs/clubs_state.dart';
import '../../../data/Models/ClubMembers.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/web_socket_service.dart';

class ClubInfo extends StatefulWidget {
  final String imageUrl;
  final int clubId;
  final String clubName;
  final String LoggedInUser;
  final int userId;

  const ClubInfo({
    super.key,
    required this.imageUrl,
    required this.clubId,
    required this.clubName,
    required this.LoggedInUser,
    required this.userId,
  });

  @override
  _ClubInfoState createState() => _ClubInfoState();
}

class _ClubInfoState extends State<ClubInfo> {
  final ScrollController _scrollController = ScrollController();
  double _topContainerHeight = 300;
  List<String> friendsUsernames = [];
  String url = "ws://192.168.67.26:8080/ws";



  String? username;
  String loggedInUserRole = '';

  void loadFriends() async {
    final userRepository = UserRepository();
    try {
      List<String> friends =
          await userRepository.fetchSavedUserFriends(); // Fetch the data
      friendsUsernames = friends;
    } catch (e) {
      print('Error fetching friends: $e'); // Handle errors
    }
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
    isLoggedInUserAdmin();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;

    // Update the height dynamically
    setState(() {
      _topContainerHeight = (300 - offset).clamp(65.0, 300.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.imageUrl;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Upper container (Club Info)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: AnimatedContainer(
                    alignment: Alignment.center,
                    width: double.infinity,
                    duration: const Duration(milliseconds: 300),
                    height: _topContainerHeight,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _topContainerHeight == 65
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _topContainerHeight > 65
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top row with icon buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.exit_to_app_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),

                              // Club Avatar with Hero
                              Flexible(
                                child: Hero(
                                  tag:
                                      'club_avatar_${imageUrl}', // Unique tag using imageUrl
                                  child: CircleAvatar(
                                    radius: (_topContainerHeight - 200) * 0.5 >
                                            30
                                        ? (_topContainerHeight - 200) * 0.5
                                        : 30, // Ensures minimum radius of 30
                                    backgroundImage:
                                        CachedNetworkImageProvider(imageUrl),
                                  ),
                                ),
                              ),

                              // Club Name
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Club Name',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon Buttons
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                ),
                              ),
                              // Club Avatar and Name in Row
                              Flexible(
                                child: Row(
                                  children: [
                                    Hero(
                                      tag:
                                          'club_avatar2_${imageUrl}', // Unique tag using imageUrl
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                imageUrl),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Club Name',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Exit Icon
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.exit_to_app_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // Lower Container (List of Members)
                Expanded(
                  child: BlocProvider(
                    create: (context) =>
                        ClubsBloc(homeRepository: context.read())
                          ..add(FetchMembersForClub(widget.clubId)),
                    child: BlocConsumer<ClubsBloc, ClubsState>(
                      builder: (context, state) {
                        if (state is ClubsMemberLoaded) {
                          print("Rebuilding UI with updated questions");
                          final MemberList = state.MemberList;

                          if (MemberList.isEmpty) {
                            return Center(child: Text("No Members Available"));
                          } else {
                            return MembersList(
                                _scrollController,
                                MemberList,
                                friendsUsernames,
                                widget.LoggedInUser,
                                loggedInUserRole);
                          }
                        } else if (state is ClubsMemberLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is ClubsMemberError) {
                          return Center(
                            child: InkWell(
                              child: Text(
                                "An error occurred. Tap to retry.",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                context
                                    .read<ClubsBloc>()
                                    .add(FetchQuestionsForClub(widget.clubId));
                              },
                            ),
                          );
                        } else {
                          return Center(child: Text("No data available."));
                        }
                      },
                      listener: (BuildContext context, ClubsState state) {},
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  void isLoggedInUserAdmin() async {
    try {
      // Ensure `webSocketService` and `homeRepository` are properly initialized
      final webSocketService = WebSocketService(url);
      final homeRepository = HomeRepository(webSocketService);

      // Call the async function and wait for the result
      final isAdmin = await homeRepository.IsUserAdmin(widget.clubId, widget.userId);

      // Update the state based on the result
      setState(() {
        loggedInUserRole = isAdmin ? "ADMIN" : "MEMBER";
      });
    } catch (e) {
      print("Error in isLoggedInUserAdmin: $e");
      setState(() {
        loggedInUserRole = "MEMBER"; // Default role in case of an error
      });
    }
  }
}

Widget MembersList(
    ScrollController _scrollController,
    List<ClubMembership> clubMembers,
    List<String> friendsUsernames,
    String loggedInUser,
    String loggedInUserRole) {
  // Add role of the logged-in user
  return ListView.builder(
    shrinkWrap: true,
    controller: _scrollController,
    itemCount: clubMembers.length,
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: InkWell(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: double.infinity,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        clubMembers[index].userImage),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    clubMembers[index].userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Orbitron_black',
                      color: Colors.white,
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: clubMembers[index].role == "ADMIN"
                            ? Colors.green
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        clubMembers[index].role,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: SizedBox()),

              // "ADD" Button or Message Icon
              !friendsUsernames.contains(clubMembers[index].userName)
                  ? Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
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
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'ADD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.tertiary,
                            fontFamily: 'Orbitron_black',
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.message_rounded,
                        size: 30,
                      ),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
              SizedBox(
                width: 10,
              ),

              // Conditionally render the "REMOVE" button if logged-in user is ADMIN
              loggedInUserRole == "ADMIN"
                  ? Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
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
                      child: ElevatedButton(
                        onPressed: () {
                          // Action to remove the member
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'REMOVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.tertiary,
                            fontFamily: 'Orbitron_black',
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(), // Hide the button if user is not ADMIN
            ],
          ),
        ),
        onTap: () {},
      ),
    ),
  );
}
