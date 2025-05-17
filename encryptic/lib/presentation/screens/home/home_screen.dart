import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bloc/home/clubs/clubs_bloc.dart';
import '../../../bloc/home/clubs/clubs_event.dart';
import '../../../bloc/home/clubs/clubs_state.dart';
import '../../../bloc/home/friends/friends_bloc.dart';
import '../../../bloc/home/friends/friends_event.dart';
import '../../../bloc/home/friends/friends_state.dart';
import '../../../data/Models/Clubs.dart';
import '../../../data/Models/Friends.dart';
import '../../../data/services/SharedPreferencesHelper.dart';
import '../clubs/club_screen.dart';
import '../clubs/joind_or_not.dart';
import '../friends/chat_screen.dart';
import '../others/profilePage.dart';
import '../../../data/services/user_preferences.dart';
import '../others/userLIst.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  List<String> _titles = ["Chats", "Clubs"];
  int? userId;
  String? username;
  String? photoUrl;
  String? email;

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  List<Friends> _foundUsers = [];
  List<String> _friendsUsernames = [];
  List<Friends> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  PageController _pageController = PageController();

  Future<void> _loadUserData() async {
    UserPreferences userPreferences = UserPreferences();
    userId = await userPreferences.getUderId();
    String? username = await userPreferences.getUsername();
    String? photoUrl = await userPreferences.getPhoto();
    String? email = await userPreferences.getEmail();
print(userId);
    setState(() {
      this.userId = userId;
      this.username = username ?? '';
      this.photoUrl = photoUrl ?? '';
      this.email = email ?? '';
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Friends> results = [];
    if (enteredKeyword.isEmpty) {
      results = _friendsList;
    } else {
      results = _friendsList
          .where((user) => user.username
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        color: Theme.of(context).colorScheme.primary,
        margin: EdgeInsets.only(top: 5),
        transform: Matrix4.translationValues(xOffset, yOffset, 0)
          ..scale(scaleFactor),
        duration: Duration(milliseconds: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 65,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      height: 50,
                      width: 50,
                      margin: EdgeInsets.only(left: 5.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: photoUrl != null
                              ? CachedNetworkImageProvider(photoUrl!)
                              : AssetImage('assets/images/Encryptic.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => profilePage(imgUrl: photoUrl),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    child: TextField(
                      // onChanged: (value) {
                      //   // Trigger search only if the list of friends is loaded
                      //   if (context.read<HomeBloc>().state is FriendsLoaded) {
                      //     context.read<HomeBloc>().add(SearchFriend(value));
                      //   }
                      // },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 7.5),
                        hintText: 'Search',
                        hintStyle: TextStyle(fontFamily: 'Orbitron_black'),
                        // Placeholder text
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black38, width: 1.0),
                    ),
                  ),
                  isDrawerOpen
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              xOffset = 0;
                              isDrawerOpen = false;
                            });
                          },
                          icon: Icon(Icons.arrow_forward_ios),
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              xOffset = -240;
                              isDrawerOpen = true;
                            });
                          },
                          icon: Icon(Icons.menu_rounded, size: 30),
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _titles[_currentPage],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Orbitron_black',
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Userlist(loggedInUser: widget.username)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'ADD FRIENDS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontFamily: 'Orbitron_black',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        FriendsBloc(homeRepository: context.read())
                          ..add(FetchFriends(widget.username)),
                  ),
                  BlocProvider(
                    create: (context) =>
                        ClubsBloc(homeRepository: context.read())
                          ..add(FetchClub()),
                  ),
                ],
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  children: [
                    // Friends List Section
                    RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<FriendsBloc>()
                            .add(FetchFriends(widget.username));
                      },
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: BlocConsumer<FriendsBloc, FriendsState>(
                        listener: (context, state) {
                          if (state is FriendsError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)));
                          }
                        },
                        builder: (context, state) {
                          if (state is FriendsLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is FriendsLoaded ||
                              state is SearchResult) {
                            final friends = state is FriendsLoaded
                                ? state.friendsList
                                : (state as SearchResult).searchResults;
                            return friends.isEmpty
                                ? Center(
                                    child: InkWell(
                                      child: Text(
                                        "No friends added yet! Tap to Refresh",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        context
                                            .read<FriendsBloc>()
                                            .add(FetchFriends(widget.username));
                                      },
                                    ),
                                  )
                                : buildFriendsGrid(
                                    friends, widget.username, context);
                          } else {
                            return Center(
                              child: InkWell(
                                child: Text(
                                  "No data available.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  context
                                      .read<FriendsBloc>()
                                      .add(FetchFriends(widget.username));
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    // Clubs List Section
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<ClubsBloc>().add(FetchClub());
                      },
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: BlocConsumer<ClubsBloc, ClubsState>(
                        listener: (context, state) {
                          if (state is ClubsError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)));
                          }
                        },
                        builder: (context, state) {
                          if (state is ClubsLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is ClubsLoaded) {
                            final clubs = state.clubsList;
                            return clubs.isEmpty
                                ? Center(child: Text("No clubs available"))
                                : clubsListBuilder(clubs);
                          } else {
                            return Center(
                              child: InkWell(
                                child: Text(
                                  "No data available.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  context.read<ClubsBloc>().add(FetchClub());
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildFriendsGrid(
    List<Friends> friends,
    String? username,
    BuildContext context,
  ) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: calculateCrossAxisCount(context),
        childAspectRatio: 0.6,
      ),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Check if the photoUrl is valid, otherwise use a placeholder
                      Hero(
                        tag:
                            'friend-${friends[index].username}', // Unique tag per friend
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 2, top: 130),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: friends[index].photoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      friends[index].photoUrl)
                                  : AssetImage('assets/images/Encryptic.png')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 2, top: 130),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            friends[index].username,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Orbitron_black'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildStatusText(friends[index].status),
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        '3',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendsChatScreen(
                  sender : username!,
                  imageUrl: friends[index].photoUrl,
                  receiver: friends[index].username,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget clubsListBuilder(List<Club> clubs) {
    return ListView.builder(
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final String heroTag = 'club-${clubs[index].id}';

        String imageUrl = clubs[index].imageUrl.isNotEmpty
            ? clubs[index].imageUrl
            : 'https://via.placeholder.com/150';

        return Stack(
          children: [
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(top: 40, left: 50, right: 10),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 100),
                      child: Column(
                        children: [
                          // Club name
                          Text(
                            clubs[index].name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Orbitron_black',
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 375
                                  ? 18
                                  : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Club details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Capacity: ${clubs[index].capacity}',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron_black',
                                    color: Colors.white,
                                    fontSize:
                                    MediaQuery.of(context).size.width > 375
                                        ? 15
                                        : 12,
                                  ),
                                ),
                                Text(
                                  'Current Members: ${clubs[index].currentMembers}',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron_black',
                                    color: Colors.white,
                                    fontSize:
                                    MediaQuery.of(context).size.width > 375
                                        ? 15
                                        : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        height: 60,
                        margin:
                        const EdgeInsets.only(right: 10, left: 10, top: 20),
                        child: Text(
                          'Description: ${clubs[index].description}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron_black',
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 375
                                ? 14
                                : 12,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

                // Check if the user has already joined the club
                bool isJoined = await _prefsHelper.checkIfUserHasJoined(
                  widget.username,
                  clubs[index].id,
                );

                if (isJoined) {
                  // Navigate directly to the chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubChatScreen(
                        clubName: clubs[index].name,
                        imagePath: clubs[index].imageUrl,
                        clubId: clubs[index].id,
                        userId: userId!,
                        userName: widget.username,
                      ),
                    ),
                  );
                } else {
                  // Navigate to the join club screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinedOrNot(
                        clubId: clubs[index].id,
                        clubName: clubs[index].name,
                        imagePath: clubs[index].imageUrl,
                        username: widget.username,
                        userId: userId!,
                      ),
                    ),
                  );
                }
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 10),
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Hero(
                tag: heroTag,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = (screenWidth / 120).floor();
    return columns > 3 ? columns : 3;
  }

  Widget buildStatusText(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: status == 'ACTIVE' ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

Future<bool> _checkIfUserHasJoined(int clubId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isJoined_$clubId') ??
      false; // Returns false if not found
}
