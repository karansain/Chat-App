// {
// "id": 1,
// "content": "What is the best way to implement WebSockets in Spring Boot?",
// "createdAt": "2024-12-09 12:11:33",
// "updatedAt": null,
// "tags": [],
// "clubId": 1,
// "authorId": 10,
// "authorName": "9999",
// "authorImage": "https://hzcswekjrpilxjplqdnw.supabase.co/storage/v1/object/public/female_profiles/0ee8f1830258c59beb3ea3e905635b25.jpg"
// },

class Question {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final int clubId;
  final int authorId;
  final String authorName;
  final String authorImage;

  Question({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.tags,
    required this.clubId,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
  });

  // Factory method to create a Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']), //createdAt
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,  // Handle null for updatedAt
      tags: List<String>.from(json['tags'] ?? []),  // Ensure tags is a list
      clubId: json['clubId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorImage: json['authorImage'],
    );
  }

  // Overridden toString method for custom string representation
  @override
  String toString() {
    return 'Question{id: $id, content: "$content", createdAt: $createdAt, updatedAt: $updatedAt, tags: ${tags.join(', ')}, clubId: $clubId, authorId: $authorId, authorName: "$authorName", authorImage: "$authorImage"}';
  }
}


