// {
// "id": 1,
// "clubId": 1,
// "content": "Hello, club members!",
// "senderId": 7,
// "senderUsername": "0000",
// "sendersImage": "https://hzcswekjrpilxjplqdnw.supabase.co/storage/v1/object/public/female_profiles/03222216d68dcf6afbd6ce0e7ae5f968.jpg",
// "timestamp": "2024-12-13T11:08:40.035909"
// },

class ClubMessage {
  final int id;
  final int clubId;
  final String content;
  final int senderId;
  final String senderUsername;
  final String sendersImage;
  final DateTime timestamp;

  ClubMessage({
    required this.id,
    required this.clubId,
    required this.content,
    required this.senderId,
    required this.senderUsername,
    required this.sendersImage,
    required this.timestamp,
  });

  // Factory method to create an instance from JSON
  factory ClubMessage.fromJson(Map<String, dynamic> json) {
    return ClubMessage(
      id: json['id'],
      clubId: json['clubId'],
      content: json['content'],
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      sendersImage: json['sendersImage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'content': content,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'sendersImage': sendersImage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
