class Friends {
  final int id;
  final String email;
  final String username;
  final String photoUrl;
  final String status;

  Friends({
    required this.id,
    required this.email,
    required this.username,
    required this.photoUrl,
    required this.status,
  });

  // Override the toString method to provide a readable output
  @override
  String toString() {
    return 'Friends(id: $id, username: $username, photoUrl: $photoUrl, status: $status)';
  }

  factory Friends.fromJson(Map<String, dynamic> json) {
    return Friends(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      photoUrl: json['photoUrl'],
      status: json['status'],
    );
  }
}
