class Gym {
  final String id;
  final String title;
  final String? description;
  final String? phone;
  final double latitude;
  final double longitude;
  final double price;
  final double distance; // This will be calculated on the client side

  Gym({
    required this.id,
    required this.title,
    this.description,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.distance,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      phone: json['phone'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      price: json['price'].toDouble(),
      distance: 0, // This will be calculated later
    );
  }
}