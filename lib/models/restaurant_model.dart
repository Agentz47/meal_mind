// Model class representing a restaurant
class RestaurantModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final double distance; // in kilometers
  final String? cuisine;
  final String? phone;
  final String? imageUrl;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.rating = 0.0,
    this.distance = 0.0,
    this.cuisine,
    this.phone,
    this.imageUrl,
  });

  // Create RestaurantModel from JSON
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      cuisine: json['cuisine'],
      phone: json['phone'],
      imageUrl: json['imageUrl'],
    );
  }

  // Convert RestaurantModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'distance': distance,
      'cuisine': cuisine,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }

  // Get formatted distance string
  String get formattedDistance {
    // Distance is stored in kilometers
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  // Get Google Maps URL - uses place_id for accurate navigation
  String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}&query_place_id=$id';
}
