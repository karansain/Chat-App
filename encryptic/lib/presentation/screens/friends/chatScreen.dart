import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../data/Models/Message.dart';
import '../home/home_page.dart';
import '../others/userProfile.dart';

// Bubble widget
class ChatBubble extends StatefulWidget {
  final String message;
  final bool isSentByMe;
  final String sender;
  final String timestamp;


  ChatBubble({
    required this.message,
    required this.isSentByMe,
    required this.sender,
    required this.timestamp,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  _ChatScreen ch = _ChatScreen();

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isSentByMe ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75, // 65% of the container width
            ),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSentByMe ? Theme.of(context).colorScheme.tertiaryContainer : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message,
                    style: TextStyle(color: widget.isSentByMe ? Colors.white : Colors.black87),
                    textAlign: widget.isSentByMe ? TextAlign.left : TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              ch.timeProvider(widget.timestamp),
              style: TextStyle(
                color: widget.isSentByMe ? Colors.white70 : Colors.white70,
                fontSize: 10,
              ),
              textAlign: widget.isSentByMe ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userName; // Sender
  final String friendsUserName; // Receiver
  final String imagePath; // Image path

  // Constructor with required parameters
  ChatScreen({
    required this.userName,
    required this.imagePath,
    required this.friendsUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  String timeProvider(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);

    // Extract Time
    String time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return time;
  }

  void _connectWebSocket() {
    //'ws://172.24.18.31:8080/ws' //Hostel wi-fi
    var urll = 'ws://localhost:8080/ws';

    _channel = WebSocketChannel.connect(Uri.parse(urll));

    // Listen for incoming messages
    _channel.stream.listen((response) {
      try {
        final decodedResponse = jsonDecode(response);

        if (decodedResponse is List) {
          List<Message> messages = decodedResponse.map((messageJson) {
            return Message.fromJson(messageJson as Map<String, dynamic>);
          }).toList();

          setState(() {
            _messages = messages;
          });
        } else if (decodedResponse is Map && decodedResponse['type'] == 'newMessage') {
          Message newMessage = Message.fromJson(decodedResponse['data']);
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom(); // Scroll to the bottom when a new message arrives
        }
      } catch (e) {
        print('Error processing WebSocket message: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
      _reconnectWebSocket();
    }, onDone: () {
      print('WebSocket closed');
      _reconnectWebSocket();
    });

    _fetchMessages();
  }

  void _reconnectWebSocket() {
    Future.delayed(Duration(seconds: 2), () {
      _connectWebSocket();
    });
  }

  void _fetchMessages() {
    _channel.sink.add(jsonEncode({
      'type': 'getMessages',
      'data': {
        'sender': widget.userName,
        'receiver': widget.friendsUserName,
      },
    }));
  }

  void _sendMessage() {
    final message = _messageController.text;
    final timestamp = DateTime.now().toIso8601String();

    if (message.isNotEmpty) {
      _channel.sink.add(jsonEncode({
        'type': 'sendMessage',
        'data': {
          'sender': widget.userName,
          'receiver': widget.friendsUserName,
          'content': message,
          'timestamp': timestamp,
        },
      }));

      setState(() {
        _messages.add(Message(
          sender: widget.userName,
          receiver: widget.friendsUserName,
          content: message,
          timestamp: timestamp,
        ));
        _messageController.clear();
      });
      _scrollToBottom(); // Scroll to the bottom when a message is sent
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 0,
      //   backgroundColor: Theme.of(context).colorScheme.secondary,
      // ),
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
                    Text(
                      widget.friendsUserName,
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
                        // color: Theme.of(context).colorScheme.secondaryContainer,
                        onSelected: (String value) {
                          print('Selected: $value');
                          switch (value) {
                            case 'Info':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => userProfilePage(
                                        userName: widget.friendsUserName,
                                        imagePath: widget.imagePath,
                                      )));
                              break;
                            case 'Clear Chat':
                              break;
                            case 'Report':
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
                              padding: const EdgeInsets.only(top: 10, bottom: 5),
                              child: Center(child: popItem('Info')),
                            ),
                          ),
                           PopupMenuItem<String>(
                            value: 'Clear Chat',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Center(child: popItem('Clear Chat')),
                            ),
                          ),
                           PopupMenuItem<String>(
                            value: 'Report',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              child: Center(child: popItem('Report')),
                            ),
                          ),
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
              ),

              // Middle Container
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  padding: EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20)),
                  child: ListView.builder(
                    controller: _scrollController, // Attach ScrollController
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(
                        message: message.content,
                        isSentByMe: message.sender == widget.userName,
                        sender: message.sender,
                        timestamp: message.timestamp,
                      );
                    },
                  ),
                ),
              ),

              // Bottom Container
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 65,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                        height: null, // Remove fixed height
                        constraints: BoxConstraints(
                          maxHeight: 100, // Optional: Set a max height
                        ),
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (value) => _sendMessage(),
                          maxLines: null, // Allow multiple lines
                          minLines: 1, // Minimum lines
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(color : Theme.of(context).colorScheme.tertiary),
                          decoration: InputDecoration(
                              fillColor: Theme.of(context).colorScheme.secondary,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 5),
                              hintText: 'Message',
                              hintStyle: TextStyle(color: Colors.grey),

                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      alignment: Alignment.centerRight,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(15)),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: Icon(
                          Icons.send_rounded,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget popItem(String option){
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(15),
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
      child: Center(
        child: Text(
          option,
          style: TextStyle(
            fontSize: 20,
            color:
            Theme.of(context).colorScheme.primary,
            fontFamily: 'Orbitron_black',
          ),
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

