class User {
  final String? id;
  final String email;
  final String username;
  final String? photoUrl;
  final String status;
  final List<int> blockedUserIds;

  User({
    this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.status,
    required this.blockedUserIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      email: json['email'] as String,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?,
      status: json['status'] as String,
      blockedUserIds: (json['blockedUserIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }
}
