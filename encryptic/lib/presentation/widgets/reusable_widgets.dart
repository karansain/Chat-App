import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClubChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String sender;
  final String timestamp;
  final String userImageUrl; // URL or asset for the user's image
  final Function(String) timeProvider; // Pass timeProvider function

  ClubChatBubble({
    required this.message,
    required this.isSentByMe,
    required this.sender,
    required this.timestamp,
    required this.userImageUrl,
    required this.timeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align image to top of bubble
      mainAxisAlignment:
      isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // User Image (Only for received messages)
        if (!isSentByMe)
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Spacing between image and bubble
            child: CircleAvatar(
              radius: 18, // Adjust the size as needed
              backgroundImage: CachedNetworkImageProvider(userImageUrl), // Network image
              backgroundColor: Colors.grey[300], // Fallback background color
            ),
          ),
        // Chat Bubble
        IntrinsicWidth(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7, // Max width cap
            ),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSentByMe ? 12 : 0),
                topRight: Radius.circular(isSentByMe ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Ensure the bubble wraps its content
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isSentByMe ? Colors.white : Theme.of(context).colorScheme.tertiary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeProvider(timestamp),
                    style: TextStyle(
                      color: isSentByMe ? Colors.white70 : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String sender;
  final String timestamp;
  final Function(String) timeProvider; // Pass timeProvider function

  ChatBubble({
    required this.message,
    required this.isSentByMe,
    required this.sender,
    required this.timestamp,
    required this.timeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Max width cap
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSentByMe
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isSentByMe ? 12 : 0),
              topRight: Radius.circular(isSentByMe ? 0 : 12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ensure the bubble wraps its content
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.white60,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  timeProvider(timestamp),
                  style: TextStyle(
                    color: isSentByMe ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
