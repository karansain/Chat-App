// "id": 52,
// "content": "You can use the Spring Boot @EnableWebSocket annotation.",
// "createdAt": "2024-12-10 22:07:05",
// "authorId": 10,
// "authorName": "9999",
// "authorProfileImage": "https://hzcswekjrpilxjplqdnw.supabase.co/storage/v1/object/public/female_profiles/0ee8f1830258c59beb3ea3e905635b25.jpg",
// "questionId": 102,
// "verified": false

class Answer {
  final int id;
  final String content;
  final DateTime createdAt;
  final int authorId;
  final String authorName;
  final String authorProfileImage;
  final int questionId;
  final bool verified;

  // Constructor
  Answer({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    required this.authorProfileImage,
    required this.questionId,
    required this.verified,
  });

  // Factory constructor to create an Answer object from JSON
  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      questionId: json['questionId'],
      verified: json['verified'],
    );
  }

  @override
  String toString() {
    return 'Answer{id: $id, content: $content, createdAt: $createdAt, authorId: $authorId, authorName: $authorName, authorProfileImage: $authorProfileImage, questionId: $questionId, verified: $verified}';
  }
}

