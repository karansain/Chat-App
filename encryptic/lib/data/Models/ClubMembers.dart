class ClubMembership {
  final int id;
  final int clubId;
  final String clubName;
  final int userId;
  final String userName;
  final String userImage;
  final String role;

  ClubMembership({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.role,
  });

  // Factory constructor to create a ClubMembership object from a JSON map
  factory ClubMembership.fromJson(Map<String, dynamic> json) {
    return ClubMembership(
      id: json['id'],
      clubId: json['clubId'],
      clubName: json['clubName'],
      userId: json['userId'],
      userName: json['userName'],
      userImage: json['userImage'],
      role: json['role'],
    );
  }

  @override
  String toString() {
    return 'ClubMembership(id: $id, clubId: $clubId, clubName: $clubName, userId: $userId, userName: $userName, role: $role, profile: $userImage)';
  }

}