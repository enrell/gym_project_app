class Gym {
  final String id;
  final String title;
  final String? description;
  final String? phone;
  final double latitude;
  final double longitude;
  final String? imageUrl; // Add this line
  final String ownerId;

  Gym({
    required this.id,
    required this.title,
    this.description,
    this.phone,
    required this.latitude,
    required this.longitude,
    this.imageUrl, // Add this line
    required this.ownerId,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      phone: json['phone'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      imageUrl: json['image_url'], // Add this line
      ownerId: json['ownerId'],
    );
  }
}