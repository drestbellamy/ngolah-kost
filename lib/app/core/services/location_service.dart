import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

enum LocationStatus { unknown, granted, denied, deniedForever, serviceDisabled }

class LocationResult {
  final LocationStatus status;
  final LatLng? location;
  final String? errorMessage;

  const LocationResult({
    required this.status,
    this.location,
    this.errorMessage,
  });

  bool get isSuccess => status == LocationStatus.granted && location != null;
  bool get canRetry =>
      status == LocationStatus.denied ||
      status == LocationStatus.serviceDisabled;
}

class LocationService {
  /// Get current location with proper permission handling
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          status: LocationStatus.serviceDisabled,
          errorMessage:
              'Location services are disabled. Please enable them in settings.',
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            status: LocationStatus.denied,
            errorMessage:
                'Location permission denied. Enable in settings to see distances and use My Location.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationStatus.deniedForever,
          errorMessage:
              'Location permission permanently denied. Please enable in app settings.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult(
        status: LocationStatus.granted,
        location: LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      return LocationResult(
        status: LocationStatus.unknown,
        errorMessage: 'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Check location permission status without requesting
  static Future<LocationStatus> checkPermissionStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationStatus.granted;
        case LocationPermission.denied:
          return LocationStatus.denied;
        case LocationPermission.deniedForever:
          return LocationStatus.deniedForever;
        case LocationPermission.unableToDetermine:
          return LocationStatus.unknown;
      }
    } catch (e) {
      return LocationStatus.unknown;
    }
  }

  /// Request location permission
  static Future<LocationStatus> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.serviceDisabled;
      }

      final permission = await Geolocator.requestPermission();

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationStatus.granted;
        case LocationPermission.denied:
          return LocationStatus.denied;
        case LocationPermission.deniedForever:
          return LocationStatus.deniedForever;
        case LocationPermission.unableToDetermine:
          return LocationStatus.unknown;
      }
    } catch (e) {
      return LocationStatus.unknown;
    }
  }

  /// Open app settings for location permission
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  /// Show appropriate error message based on location status
  static void showLocationError(
    LocationStatus status, {
    String? customMessage,
  }) {
    String title = 'Location Error';
    String message = customMessage ?? _getDefaultErrorMessage(status);

    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: _getErrorAction(status),
    );
  }

  /// Get default error message for location status
  static String _getDefaultErrorMessage(LocationStatus status) {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Location services are disabled. Enable them to see distances and use My Location.';
      case LocationStatus.denied:
        return 'Location permission denied. Enable in settings to see distances and use My Location.';
      case LocationStatus.deniedForever:
        return 'Location permission permanently denied. Please enable in app settings.';
      case LocationStatus.unknown:
        return 'Unable to determine location. Please check your device settings.';
      case LocationStatus.granted:
        return 'Location access granted.';
    }
  }

  /// Get action button for error snackbar
  static TextButton? _getErrorAction(LocationStatus status) {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return TextButton(
          onPressed: () {
            Get.closeAllSnackbars();
            openLocationSettings();
          },
          child: const Text(
            'Settings',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
        );
      case LocationStatus.deniedForever:
        return TextButton(
          onPressed: () {
            Get.closeAllSnackbars();
            openAppSettings();
          },
          child: const Text(
            'Settings',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
        );
      default:
        return null;
    }
  }

  /// Check if location features can be used
  static Future<bool> canUseLocationFeatures() async {
    final status = await checkPermissionStatus();
    return status == LocationStatus.granted;
  }

  /// Get location with user-friendly error handling
  static Future<LatLng?> getLocationWithErrorHandling() async {
    final result = await getCurrentLocation();

    if (result.isSuccess) {
      return result.location;
    } else {
      showLocationError(result.status, customMessage: result.errorMessage);
      return null;
    }
  }

  /// Listen to location changes (for real-time updates)
  static Stream<LatLng> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map((position) => LatLng(position.latitude, position.longitude));
  }
}
