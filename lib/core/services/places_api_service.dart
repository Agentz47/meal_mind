import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../models/restaurant_model.dart';

/// Google Places API Service for fetching REAL restaurants
/// Supports pagination to fetch up to 60 restaurants (3 pages × 20)
class PlacesApiService {
  /// Search for nearby restaurants using Google Places API
  /// Returns REAL restaurants from Google's database
  /// Fetches up to 60 results using pagination for better coverage
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusInMeters = 10000, // Default 10km (increased for Sri Lanka)
  }) async {
    try {
      List<RestaurantModel> allRestaurants = [];
      String? nextPageToken;
      int pageCount = 0;
      const maxPages = 3; // Fetch up to 60 results (3 pages × 20)

      // Fetch multiple pages of results
      do {
        // Build URL with optional pagetoken
        String urlString = '${ApiConstants.googlePlacesBaseUrl}/nearbysearch/json'
            '?location=$latitude,$longitude'
            '&radius=$radiusInMeters'
            '&type=restaurant'
            '&key=${ApiConstants.googlePlacesApiKey}';
        
        if (nextPageToken != null) {
          urlString += '&pagetoken=$nextPageToken';
        }
        
        final url = Uri.parse(urlString);
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['status'] == 'OK' && data['results'] != null) {
            final List results = data['results'];
            
            // Convert each place to RestaurantModel
            final pageRestaurants = results.map((place) {
              return RestaurantModel(
                id: place['place_id'] ?? '',
                name: place['name'] ?? 'Unknown Restaurant',
                latitude: place['geometry']?['location']?['lat'] ?? latitude,
                longitude: place['geometry']?['location']?['lng'] ?? longitude,
                address: place['vicinity'] ?? place['formatted_address'] ?? 'Address not available',
                rating: (place['rating'] ?? 0.0).toDouble(),
                distance: 0.0, // Will be calculated separately
                cuisine: _extractCuisineType(place['types']),
                phone: null, // Requires Place Details API call (extra quota)
                imageUrl: _getPhotoUrl(place['photos']),
              );
            }).toList();
            
            allRestaurants.addAll(pageRestaurants);
            
            // Get next page token if available
            nextPageToken = data['next_page_token'];
            pageCount++;
            
            // Google requires a short delay (2-3 seconds) before using next_page_token
            if (nextPageToken != null && pageCount < maxPages) {
              await Future.delayed(const Duration(seconds: 2));
            }
          } else if (data['status'] == 'ZERO_RESULTS') {
            break; // No more results
          } else if (data['status'] == 'INVALID_REQUEST' && nextPageToken != null) {
            // Page token not ready yet, wait and retry once
            await Future.delayed(const Duration(seconds: 2));
            continue;
          } else if (data['status'] == 'REQUEST_DENIED') {
            throw Exception('Google Places API key is invalid or not enabled');
          } else {
            throw Exception('Google Places API error: ${data['status']}');
          }
        } else {
          throw Exception('Failed to fetch restaurants: ${response.statusCode}');
        }
      } while (nextPageToken != null && pageCount < maxPages);
      
      if (allRestaurants.isEmpty) {
        throw Exception('No restaurants found in this area');
      }
      
      return allRestaurants;
    } catch (e) {
      throw Exception('Error fetching restaurants: $e');
    }
  }

  /// Get detailed information for a specific restaurant
  /// Returns phone number, opening hours, website, etc.
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.googlePlacesBaseUrl}/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_phone_number,international_phone_number,opening_hours,website,price_level,url'
        '&key=${ApiConstants.googlePlacesApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return data['result'];
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Extract cuisine type from place types
  String _extractCuisineType(List<dynamic>? types) {
    if (types == null || types.isEmpty) return 'Restaurant';

    // Map of Google Place types to cuisine categories
    const Map<String, String> cuisineMap = {
      'meal_delivery': 'Delivery',
      'meal_takeaway': 'Takeaway',
      'bakery': 'Bakery',
      'bar': 'Bar',
      'cafe': 'Café',
      'restaurant': 'Restaurant',
      'food': 'Food',
    };

    for (var type in types) {
      if (cuisineMap.containsKey(type)) {
        return cuisineMap[type]!;
      }
    }

    return 'Restaurant';
  }

  /// Get photo URL from place photos
  String? _getPhotoUrl(List<dynamic>? photos) {
    if (photos == null || photos.isEmpty) return null;

    try {
      final photoReference = photos[0]['photo_reference'];
      return '${ApiConstants.googlePlacesBaseUrl}/photo'
          '?maxwidth=400'
          '&photoreference=$photoReference'
          '&key=${ApiConstants.googlePlacesApiKey}';
    } catch (e) {
      return null;
    }
  }
}
