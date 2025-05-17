class Message {
  final String sender;
  final String receiver;
  final String content;
  final String timestamp;

  Message({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] ?? 'Unknown sender', // Default value or handle null
      receiver: json['receiver'] ?? 'Unknown receiver',
      content: json['content'] ?? 'No content', // Default value if content is null
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(), // Use current time if null
    );
  }
}
