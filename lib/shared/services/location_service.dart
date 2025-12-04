import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  /// Request location permission
  /// This method will show the system permission dialog on Android/iOS
  Future<bool> requestLocationPermission() async {
    try {
      // First, check current permission status
      PermissionStatus status = await Permission.location.status;

      // If permission is not granted, request it
      // This will show the system permission dialog
      if (!status.isGranted) {
        // Request permission - this will show the system permission dialog
        status = await Permission.location.request();

        // Check the result
        if (status.isDenied) {
          // User denied the permission
          debugPrint('Location permission denied by user');
          return false;
        }

        if (status.isPermanentlyDenied) {
          // Permission is permanently denied - user needs to enable in settings
          debugPrint('Location permission permanently denied');
          return false;
        }
      }

      // Check if location services are enabled (GPS/Location toggle)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled - permission dialog won't help
        debugPrint('Location services are disabled');
        return false;
      }

      // Also verify with Geolocator for consistency
      LocationPermission geolocatorPermission =
          await Geolocator.checkPermission();
      if (geolocatorPermission == LocationPermission.denied) {
        // Request permission via Geolocator as well (for Android compatibility)
        geolocatorPermission = await Geolocator.requestPermission();
        if (geolocatorPermission == LocationPermission.denied) {
          debugPrint('Geolocator permission denied');
          return false;
        }
      }

      if (geolocatorPermission == LocationPermission.deniedForever) {
        debugPrint('Geolocator permission denied forever');
        return false;
      }

      // Permission is granted
      return true;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Get current location and country code
  Future<String?> getCountryCode() async {
    try {
      // Request permission first
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy:
              LocationAccuracy.low, // Use low accuracy for faster response
        ),
      );

      // Get placemarks from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Return ISO country code (e.g., 'PK', 'US', 'IN')
        return placemark.isoCountryCode;
      }

      return null;
    } catch (e) {
      // Handle errors silently - return null if location cannot be determined
      debugPrint('Location error: $e');
      return null;
    }
  }
}
