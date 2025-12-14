import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Service for handling location operations
class LocationService {
  // Check if location permission is granted
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
  
  // Request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  // Get current user location
  Future<Position> getCurrentLocation() async {
    bool hasPermission = await checkPermission();
    
    if (!hasPermission) {
      hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
    }
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  // Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLong,
    double endLat,
    double endLong,
  ) {
    return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
  }
}
