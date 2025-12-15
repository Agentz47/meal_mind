import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/restaurant_service.dart';
import '../../../models/restaurant_model.dart';
import '../widgets/nearby_restaurant_card_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';

// Screen showing nearby restaurants based on user location
// Member 4 - Restaurants Feature
class NearbyRestaurantsScreen extends StatefulWidget {
  const NearbyRestaurantsScreen({super.key});

  @override
  State<NearbyRestaurantsScreen> createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  final LocationService _locationService = LocationService();
  final RestaurantService _restaurantService = RestaurantService();
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  double _radiusInKm = 5.0; // Default 5km radius

  @override
  void initState() {
    super.initState();
    _loadNearbyRestaurants();
  }

  Future<void> _loadNearbyRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _currentPosition = await _locationService.getCurrentLocation();

      // Get nearby restaurants from Firebase or sample data
      _restaurants = await _restaurantService.getNearbyRestaurants(
        userLat: _currentPosition!.latitude,
        userLng: _currentPosition!.longitude,
        radiusInMeters: _radiusInKm * 1000, // Convert km to meters
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _changeRadius() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Radius'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${_radiusInKm.toStringAsFixed(1)} km'),
            Slider(
              value: _radiusInKm,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${_radiusInKm.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() {
                  _radiusInKm = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _radiusInKm),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      _loadNearbyRestaurants();
    }
  }

  // DEPRECATED: Old sample generation method (kept for reference)
  // List<RestaurantModel> _generateSampleRestaurants_OLD(Position position) {
  //   final sampleRestaurants = [
  //     {
  //       'name': 'The Italian Kitchen',
  //       'latOffset': 0.01,
  //       'lonOffset': 0.01,
  //       'address': '123 Main Street',
  //       'rating': 4.5
  //     },
  //     {
  //       'name': 'Spice House',
  //       'latOffset': -0.02,
  //       'lonOffset': 0.015,
  //       'address': '456 Oak Avenue',
  //       'rating': 4.2
  //     },
  //     {
  //       'name': 'Burger Palace',
  //       'latOffset': 0.015,
  //       'lonOffset': -0.01,
  //       'address': '789 Pine Road',
  //       'rating': 4.0
  //     },
  //     {
  //       'name': 'Sushi Bar',
  //       'latOffset': -0.01,
  //       'lonOffset': -0.02,
  //       'address': '321 Elm Street',
  //       'rating': 4.7
  //     },
  //     {
  //       'name': 'Pasta Paradise',
  //       'latOffset': 0.02,
  //       'lonOffset': 0.02,
  //       'address': '654 Maple Drive',
  //       'rating': 4.3
  //     },
  //   ];

  //   return sampleRestaurants.map((data) {
  //     final lat = position.latitude + (data['latOffset'] as double);
  //     final lon = position.longitude + (data['lonOffset'] as double);
  //     final distance = _locationService.calculateDistance(
  //       position.latitude,
  //       position.longitude,
  //       lat,
  //       lon,
  //     );

  //     return RestaurantModel(
  //       id: data['name'].toString().toLowerCase().replaceAll(' ', '_'),
  //       name: data['name'] as String,
  //       latitude: lat,
  //       longitude: lon,
  //       address: data['address'] as String,
  //       rating: data['rating'] as double,
  //       distance: distance,
  //     );
  //   }).toList()
  //     ..sort((a, b) => a.distance.compareTo(b.distance));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Change Radius',
            onPressed: _changeRadius,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNearbyRestaurants,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off,
                            size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Location Error',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!.contains('permission')
                              ? 'Please enable location permission in settings'
                              : 'Could not get your location. Please try again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadNearbyRestaurants,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _restaurants.isEmpty
                  ? const EmptyStateWidget(
                      message: 'No restaurants found nearby',
                      icon: Icons.restaurant,
                    )
                  : Column(
                      children: [
                        // Location and radius info
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.green[50],
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.my_location, color: Colors.green[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Lat: ${_currentPosition?.latitude.toStringAsFixed(4)}, '
                                      'Lng: ${_currentPosition?.longitude.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Found ${_restaurants.length} restaurants within ${_radiusInKm.toStringAsFixed(1)} km',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _restaurants.length,
                            itemBuilder: (context, index) {
                              return NearbyRestaurantCardWidget(
                                restaurant: _restaurants[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
