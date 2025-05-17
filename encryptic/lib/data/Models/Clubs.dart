class Club {
  final int id; // Use 'int' for the 'Long' type from Java backend
  final String name;
  final String description;
  final int currentMembers;
  final int capacity;
  final String imageUrl;
  final String status; // Assuming ClubStatus is sent as a string (verify this)

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.currentMembers,
    required this.capacity,
    required this.imageUrl,
    required this.status,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'], // Dart's 'int' can handle Java 'Long'
      name: json['name'],
      description: json['description'],
      currentMembers: json['currentMembers'],
      capacity: json['capacity'],
      imageUrl: json['imageUrl'],
      status: json['status'], // Assuming this is a string; adjust if needed
    );
  }

  @override
  String toString() {
    return 'Club(id: $id, name: $name, description: $description, currentMembers: $currentMembers, capacity: $capacity, imageUrl: $imageUrl, status: $status)';
  }
}
