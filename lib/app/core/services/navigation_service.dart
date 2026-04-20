import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

class NavigationService {
  /// Open navigation to a specific location using external apps
  /// Tries Google Maps first, then Waze as fallback
  static Future<bool> openNavigation({
    required LatLng destination,
    LatLng? origin,
    String? destinationName,
  }) async {
    try {
      // Try Google Maps first
      final googleMapsSuccess = await _openGoogleMaps(
        destination: destination,
        origin: origin,
        destinationName: destinationName,
      );

      if (googleMapsSuccess) {
        return true;
      }

      // Fallback to Waze
      final wazeSuccess = await _openWaze(
        destination: destination,
        origin: origin,
      );

      if (wazeSuccess) {
        return true;
      }

      // If both fail, show error
      _showNavigationError();
      return false;
    } catch (e) {
      _showNavigationError();
      return false;
    }
  }

  /// Open Google Maps with navigation
  static Future<bool> _openGoogleMaps({
    required LatLng destination,
    LatLng? origin,
    String? destinationName,
  }) async {
    try {
      String url;

      if (origin != null) {
        // Navigation from origin to destination
        url =
            'https://www.google.com/maps/dir/'
            '${origin.latitude},${origin.longitude}/'
            '${destination.latitude},${destination.longitude}';
      } else {
        // Just show destination location
        url =
            'https://www.google.com/maps/search/?api=1'
            '&query=${destination.latitude},${destination.longitude}';

        if (destinationName != null && destinationName.isNotEmpty) {
          final encodedName = Uri.encodeComponent(destinationName);
          url =
              'https://www.google.com/maps/search/?api=1'
              '&query=$encodedName'
              '&query_place_id=${destination.latitude},${destination.longitude}';
        }
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Open Waze with navigation
  static Future<bool> _openWaze({
    required LatLng destination,
    LatLng? origin,
  }) async {
    try {
      String url =
          'https://waze.com/ul?ll='
          '${destination.latitude},${destination.longitude}'
          '&navigate=yes';

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Show error message when no navigation apps are available
  static void _showNavigationError() {
    Get.snackbar(
      'Navigation Error',
      'No navigation app found. Please install Google Maps or Waze.',
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Check if any navigation apps are available
  static Future<bool> isNavigationAvailable() async {
    try {
      // Test Google Maps
      final googleMapsUri = Uri.parse('https://www.google.com/maps/');
      if (await canLaunchUrl(googleMapsUri)) {
        return true;
      }

      // Test Waze
      final wazeUri = Uri.parse('https://waze.com/');
      if (await canLaunchUrl(wazeUri)) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Open location in maps app without navigation (just show location)
  static Future<bool> openLocation({
    required LatLng location,
    String? locationName,
  }) async {
    try {
      String url =
          'https://www.google.com/maps/search/?api=1'
          '&query=${location.latitude},${location.longitude}';

      if (locationName != null && locationName.isNotEmpty) {
        final encodedName = Uri.encodeComponent(locationName);
        url = 'https://www.google.com/maps/search/?api=1&query=$encodedName';
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      _showNavigationError();
      return false;
    }
  }

  /// Get navigation URL for sharing or other purposes
  static String getNavigationUrl({
    required LatLng destination,
    LatLng? origin,
    String? destinationName,
  }) {
    if (origin != null) {
      return 'https://www.google.com/maps/dir/'
          '${origin.latitude},${origin.longitude}/'
          '${destination.latitude},${destination.longitude}';
    } else {
      return 'https://www.google.com/maps/search/?api=1'
          '&query=${destination.latitude},${destination.longitude}';
    }
  }
}
