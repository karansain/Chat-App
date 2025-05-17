import 'package:cached_network_image/cached_network_image.dart';
import 'package:encryptic/presentation/screens/clubs/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../../../bloc/home/messaging/club/club_message_bloc.dart';
import '../../../bloc/home/messaging/club/club_message_event.dart';
import '../../../bloc/home/messaging/club/club_message_state.dart';
import '../../widgets/reusable_widgets.dart';
import '../home/home_page.dart';
import 'clubinfo.dart';

class ClubChatScreen extends StatefulWidget {
  final String clubName;
  final String imagePath;
  final int clubId;
  final int userId;
  final String userName;

  ClubChatScreen({
    required this.clubName,
    required this.imagePath,
    required this.clubId,
    required this.userId,
    required this.userName,
  });

  @override
  State<ClubChatScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubChatScreen> {
  bool _isFabVisible = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ClubMessagingBloc>(context)
        .add(FetchClubMessages(widget.clubId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String timeProvider(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAppBar(context),
            _buildMessageList(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width > 375 ? 65 : 55,
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
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 35,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          Hero(
            tag: 'club_${widget.clubName}',
            child: Material(
              color: Colors.transparent,
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
              onSelected: (String value) => _handleMenuSelection(value),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildPopupMenuItem('Info'),
              ],
              child: Icon(
                Icons.more_vert_rounded,
                size: 35,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BlocConsumer<ClubMessagingBloc, ClubMessagingState>(
              listener: (context, state) {
                if (state is MessagingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage)),
                  );
                } else if (state is MessagingLoaded) {
                  // Scroll to the bottom after messages are loaded
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is MessagingLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MessagingLoaded) {
                  return ListView.builder(
                    controller: _scrollController, // Attach ScrollController
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ClubChatBubble(
                        message: message.content,
                        sender: message.senderUsername,
                        userImageUrl: message.sendersImage,
                        isSentByMe: message.senderUsername == widget.userName,
                        timestamp: message.timestamp.toString(),
                        timeProvider: timeProvider,
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No messages found.'));
                }
              },
            ),
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
            children: _buildFabChildren(context),
          ),
        ],
      ),
    );
  }

  //onSubmitted: (_) => _sendMessage(),

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10, right: 10,),
            height: MediaQuery.of(context).size.width > 375 ? 65 : 50,
            margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              minLines: 1,
              maxLines: null,
              cursorColor: Theme.of(context).colorScheme.tertiary,
              controller: _messageController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: 'Message',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 17,
                  overflow: TextOverflow.fade),
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width > 375 ? 60 : 50,
          width: MediaQuery.of(context).size.width > 375 ? 60 : 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 10, right: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: MediaQuery.of(context).size.width > 375 ? 35 : 30,
              ),
              onPressed: () {
                _sendMessage();
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFabChildren(BuildContext context) {
    return [
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Questions(
                clubName: widget.clubName,
                clubId: widget.clubId,
                userId: widget.userId,
              ),
            ),
          );
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
    ];
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Center(child: popItem(value)),
      ),
    );
  }

  void _handleMenuSelection(String value) {
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
            ),
          ),
        );
        break;
      default:
        break;
    }
  }

  Widget popItem(String option) {
    return Container(
      height: MediaQuery.of(context).size.width > 375 ? 50 : 40,
      width: MediaQuery.of(context).size.width > 375 ? 150 : 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Center(
        child: Text(
          option,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 375 ? 20 : 15,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Orbitron_black',
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<ClubMessagingBloc>(context).add(SendMessage(
          sender: widget.userName, receiver: widget.clubId, content: content));
      _messageController.clear();
    }
  }
}
