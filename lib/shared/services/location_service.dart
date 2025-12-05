import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'currency_service.dart';
import 'secure_storage_service.dart';

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
        final countryCode = placemark.isoCountryCode;

        // Store country code
        if (countryCode != null) {
          await SecureStorageService.instance.setCountryCode(countryCode);

          // Get and store currency symbol based on country
          final currencySymbol = CurrencyService.instance.getCurrencySymbol(
            countryCode,
          );
          await SecureStorageService.instance.setCurrencySymbol(currencySymbol);

          debugPrint(
            'Country detected: $countryCode, Currency: $currencySymbol',
          );
        }

        // Return ISO country code (e.g., 'PK', 'US', 'IN')
        return countryCode;
      }

      return null;
    } catch (e) {
      // Handle errors silently - return null if location cannot be determined
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Get currency symbol for current location
  /// This uses the stored country code from previous location detection
  /// If currency symbol is not stored, it will be calculated and stored
  Future<String> getCurrencySymbol() async {
    try {
      // First check if currency symbol is already stored
      final cachedSymbol = await SecureStorageService.instance
          .getCurrencySymbol();
      if (cachedSymbol != null && cachedSymbol.isNotEmpty) {
        return cachedSymbol;
      }

      // If not cached, get from country code and store it
      final countryCode = await SecureStorageService.instance.getCountryCode();
      final symbol = CurrencyService.instance.getCurrencySymbol(countryCode);

      // Store the currency symbol for future use
      await SecureStorageService.instance.setCurrencySymbol(symbol);

      debugPrint(
        'Currency symbol retrieved and stored: $symbol (Country: $countryCode)',
      );
      return symbol;
    } catch (e) {
      debugPrint('Currency symbol error: $e');
      return '\$'; // Default to USD
    }
  }

  /// Ensure currency symbol is set based on stored country code
  /// Call this method to update currency if country code exists but currency doesn't
  Future<void> ensureCurrencySymbol() async {
    try {
      final countryCode = await SecureStorageService.instance.getCountryCode();
      if (countryCode != null && countryCode.isNotEmpty) {
        final cachedSymbol = await SecureStorageService.instance
            .getCurrencySymbol();
        if (cachedSymbol == null || cachedSymbol.isEmpty) {
          // Currency not set, calculate and store it
          final currencySymbol = CurrencyService.instance.getCurrencySymbol(
            countryCode,
          );
          await SecureStorageService.instance.setCurrencySymbol(currencySymbol);
          debugPrint(
            'Currency symbol ensured: $currencySymbol (Country: $countryCode)',
          );
        }
      }
    } catch (e) {
      debugPrint('Error ensuring currency symbol: $e');
    }
  }
}
