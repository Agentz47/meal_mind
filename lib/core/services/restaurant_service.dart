import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/restaurant_model.dart';
import 'places_api_service.dart';

/// Service for managing restaurant data
/// Uses Google Places API for REAL restaurant data in Sri Lanka
class RestaurantService {
  FirebaseFirestore? _firestore;
  final PlacesApiService _placesApi = PlacesApiService();
  
  RestaurantService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      _firestore = null;
    }
  }
  
  bool get isAvailable => _firestore != null;
  
  /// Get nearby restaurants based on user's current location in Sri Lanka
  /// Uses Google Places API for REAL restaurant data ONLY
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double userLat,
    required double userLng,
    double radiusInMeters = 10000, // Default 10km (increased for more results)
  }) async {
    try {
      // Get REAL restaurants from Google Places API
      final restaurants = await _placesApi.getNearbyRestaurants(
        latitude: userLat,
        longitude: userLng,
        radiusInMeters: radiusInMeters,
      );
      
      // Calculate distances for each restaurant
      List<RestaurantModel> restaurantsWithDistance = [];
      
      for (var restaurant in restaurants) {
        double distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          restaurant.latitude,
          restaurant.longitude,
        ) / 1000; // Convert to km
        
        restaurantsWithDistance.add(
          RestaurantModel(
            id: restaurant.id,
            name: restaurant.name,
            address: restaurant.address,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            cuisine: restaurant.cuisine,
            rating: restaurant.rating,
            distance: distance,
            phone: restaurant.phone,
            imageUrl: restaurant.imageUrl,
          ),
        );
      }
      
      // Sort by distance (closest first)
      restaurantsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      
      return restaurantsWithDistance;
    } catch (e) {
      // If Google Places API fails, check Firebase for cached data
      return _getFromFirebase(userLat, userLng, radiusInMeters);
    }
  }
  
  /// Fallback: Try to get restaurants from Firebase cache
  Future<List<RestaurantModel>> _getFromFirebase(
    double userLat,
    double userLng,
    double radiusInMeters,
  ) async {
    if (_firestore == null) {
      throw Exception(
        'Unable to load restaurants.\n\n'
        'Possible reasons:\n'
        '1. Google Places API key may be invalid\n'
        '2. No internet connection\n'
        '3. Google Places API not enabled in Google Cloud Console\n\n'
        'Please check your API key and internet connection.'
      );
    }
    
    try {
      final snapshot = await _firestore!.collection('restaurants').get();
      
      if (snapshot.docs.isEmpty) {
        throw Exception(
          'No restaurants found.\n\n'
          'Google Places API returned no results.\n'
          'This could mean:\n'
          '1. API key is not enabled for Places API\n'
          '2. No restaurants exist within ${(radiusInMeters/1000).toStringAsFixed(1)}km\n'
          '3. API quota exceeded\n\n'
          'Try increasing the search radius or checking API status.'
        );
      }
      
      List<RestaurantModel> restaurants = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final restaurant = RestaurantModel.fromJson(data);
        
        double distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          restaurant.latitude,
          restaurant.longitude,
        );
        
        if (distance <= radiusInMeters) {
          restaurants.add(
            RestaurantModel(
              id: restaurant.id,
              name: restaurant.name,
              address: restaurant.address,
              latitude: restaurant.latitude,
              longitude: restaurant.longitude,
              cuisine: restaurant.cuisine,
              rating: restaurant.rating,
              distance: distance / 1000,
              phone: restaurant.phone,
              imageUrl: restaurant.imageUrl,
            ),
          );
        }
      }
      
      restaurants.sort((a, b) => a.distance.compareTo(b.distance));
      return restaurants;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Add a new restaurant to Firebase (for caching Google Places results)
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!
          .collection('restaurants')
          .doc(restaurant.id)
          .set(restaurant.toJson());
    } catch (e) {
      throw Exception('Error adding restaurant: $e');
    }
  }
  
  /// Update restaurant information
  Future<void> updateRestaurant(String restaurantId, Map<String, dynamic> updates) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!
          .collection('restaurants')
          .doc(restaurantId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating restaurant: $e');
    }
  }
  
  /// Delete a restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!
          .collection('restaurants')
          .doc(restaurantId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting restaurant: $e');
    }
  }
}
