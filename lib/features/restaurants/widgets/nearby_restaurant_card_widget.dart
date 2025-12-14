import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/restaurant_model.dart';
import '../../../core/services/places_api_service.dart';

// Custom widget to display nearby restaurant card
// Member 4 - Custom Component
class NearbyRestaurantCardWidget extends StatefulWidget {
  final RestaurantModel restaurant;

  const NearbyRestaurantCardWidget({
    super.key,
    required this.restaurant,
  });

  @override
  State<NearbyRestaurantCardWidget> createState() => _NearbyRestaurantCardWidgetState();
}

class _NearbyRestaurantCardWidgetState extends State<NearbyRestaurantCardWidget> {
  final PlacesApiService _placesApi = PlacesApiService();
  String? _phoneNumber;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    if (widget.restaurant.phone != null) {
      setState(() {
        _phoneNumber = widget.restaurant.phone;
      });
      return;
    }

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final details = await _placesApi.getPlaceDetails(widget.restaurant.id);
      if (details.isNotEmpty) {
        setState(() {
          _phoneNumber = details['formatted_phone_number'] ?? 
                        details['international_phone_number'];
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _openInMaps() async {
    final Uri url = Uri.parse(widget.restaurant.mapsUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant name and rating
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.restaurant.rating > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.restaurant.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Cuisine type (if available)
            if (widget.restaurant.cuisine != null) ...[
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    widget.restaurant.cuisine!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Address
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.restaurant.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Distance and buttons row
            Row(
              children: [
                Icon(Icons.directions_walk, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.restaurant.formattedDistance,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                // Call button (if phone available)
                if (_isLoadingDetails)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_phoneNumber != null) ...[
                  IconButton(
                    onPressed: () async {
                      final Uri url = Uri.parse('tel:$_phoneNumber');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.phone, size: 20),
                    tooltip: 'Call',
                    color: Colors.green,
                  ),
                ],
                // Navigate button
                ElevatedButton.icon(
                  onPressed: _openInMaps,
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
