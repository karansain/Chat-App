import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/home/messaging/one_on_one/message_bloc.dart';
import '../../../bloc/home/messaging/one_on_one/message_event.dart';
import '../../../bloc/home/messaging/one_on_one/message_state.dart';
import '../../widgets/reusable_widgets.dart';
import '../others/userProfile.dart';

class FriendsChatScreen extends StatefulWidget {
  final String sender;
  final String receiver;
  final String imageUrl;

  FriendsChatScreen(
      {required this.sender, required this.receiver, required this.imageUrl});

  @override
  _FriendsChatScreenState createState() => _FriendsChatScreenState();
}

class _FriendsChatScreenState extends State<FriendsChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MessagingBloc>(context).add(FetchMessages(
      widget.sender,
      widget.receiver,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  String timeProvider(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 35,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          Text(
            widget.receiver,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Orbitron_black',
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildPopupMenuItem('Info'),
                _buildPopupMenuItem('Clear Chat'),
                _buildPopupMenuItem('Report'),
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
            builder: (context) => userProfilePage(
              userName: widget.receiver,
              imagePath: widget.imageUrl,
            ),
          ),
        );
        break;
      case 'Clear Chat':
      // Handle clear chat
        break;
      case 'Report':
      // Handle report
        break;
    }
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        padding: EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: BlocConsumer<MessagingBloc, MessagingState>(
          listener: (context, state) {
            if (state is MessagingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          builder: (context, state) {
            if (state is MessagingLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is MessagingLoaded) {
              // Scroll to the bottom when messages are loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });

              return ListView.builder(
                controller: _scrollController, // Set controller to ListView
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return ChatBubble(
                    message: message.content,
                    sender: message.sender,
                    isSentByMe: message.sender == widget.sender,
                    timestamp: message.timestamp,
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
    );
  }

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
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              minLines: 1,
              maxLines: null,
              cursorColor: Colors.white,
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
                  color: Colors.white,
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
            fontSize: MediaQuery.of(context).size.width > 375 ? 20 : 12,
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
      BlocProvider.of<MessagingBloc>(context).add(SendMessage(
        sender: widget.sender,
        receiver: widget.receiver,
        content: content,
      ));
      _messageController.clear();
    }
  }
}

