import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/kost_with_status_model.dart';

class DistanceCalculator {
  /// Calculate distance between two points using Geolocator
  /// Returns distance in kilometers
  static double calculateDistance({required LatLng from, required LatLng to}) {
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );

      // Convert to kilometers
      return distanceInMeters / 1000.0;
    } catch (e) {
      // Return a large distance on error to put it at the end of sorted lists
      return double.maxFinite;
    }
  }

  /// Calculate distances from admin location to multiple kost
  /// Returns a map of kost ID to distance in kilometers
  static Map<String, double> calculateDistancesToKostList({
    required LatLng adminLocation,
    required List<KostWithStatus> kostList,
  }) {
    final Map<String, double> distances = {};

    for (final kost in kostList) {
      if (kost.hasValidCoordinates) {
        final kostLocation = LatLng(kost.latitude!, kost.longitude!);
        final distance = calculateDistance(
          from: adminLocation,
          to: kostLocation,
        );
        distances[kost.id] = distance;
      }
    }

    return distances;
  }

  /// Update kost list with distances from admin location
  /// Returns new list with updated distances, sorted by distance
  static List<KostWithStatus> updateKostListWithDistances({
    required LatLng adminLocation,
    required List<KostWithStatus> kostList,
    bool sortByDistance = true,
  }) {
    final updatedList = kostList.map((kost) {
      if (kost.hasValidCoordinates) {
        final kostLocation = LatLng(kost.latitude!, kost.longitude!);
        final distance = calculateDistance(
          from: adminLocation,
          to: kostLocation,
        );
        return kost.copyWithDistance(distance);
      } else {
        return kost.copyWithDistance(null);
      }
    }).toList();

    if (sortByDistance) {
      updatedList.sort((a, b) {
        // Put kost without coordinates at the end
        if (a.distanceFromAdmin == null && b.distanceFromAdmin == null) {
          return 0;
        }
        if (a.distanceFromAdmin == null) return 1;
        if (b.distanceFromAdmin == null) return -1;

        return a.distanceFromAdmin!.compareTo(b.distanceFromAdmin!);
      });
    }

    return updatedList;
  }

  /// Format distance for display
  /// Returns formatted string like "1.2 km" or "850 m"
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      final meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  /// Check if a location is within a certain radius from admin location
  static bool isWithinRadius({
    required LatLng adminLocation,
    required LatLng targetLocation,
    required double radiusInKm,
  }) {
    final distance = calculateDistance(from: adminLocation, to: targetLocation);
    return distance <= radiusInKm;
  }

  /// Get the center point of multiple locations
  /// Useful for centering map on multiple kost
  static LatLng? getCenterPoint(List<LatLng> locations) {
    if (locations.isEmpty) return null;
    if (locations.length == 1) return locations.first;

    double totalLat = 0;
    double totalLng = 0;

    for (final location in locations) {
      totalLat += location.latitude;
      totalLng += location.longitude;
    }

    return LatLng(totalLat / locations.length, totalLng / locations.length);
  }

  /// Get bounding box for multiple locations
  /// Returns [southwest, northeast] corners for map bounds
  static List<LatLng>? getBoundingBox(List<LatLng> locations) {
    if (locations.isEmpty) return null;
    if (locations.length == 1) {
      // Return a small bounding box around the single point
      final location = locations.first;
      const offset = 0.01; // ~1km offset
      return [
        LatLng(location.latitude - offset, location.longitude - offset),
        LatLng(location.latitude + offset, location.longitude + offset),
      ];
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    // Add some padding
    const padding = 0.005; // ~500m padding
    return [
      LatLng(minLat - padding, minLng - padding), // Southwest
      LatLng(maxLat + padding, maxLng + padding), // Northeast
    ];
  }

  /// Find nearest kost to admin location
  static KostWithStatus? findNearestKost({
    required LatLng adminLocation,
    required List<KostWithStatus> kostList,
  }) {
    if (kostList.isEmpty) return null;

    KostWithStatus? nearest;
    double nearestDistance = double.maxFinite;

    for (final kost in kostList) {
      if (kost.hasValidCoordinates) {
        final kostLocation = LatLng(kost.latitude!, kost.longitude!);
        final distance = calculateDistance(
          from: adminLocation,
          to: kostLocation,
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = kost.copyWithDistance(distance);
        }
      }
    }

    return nearest;
  }
}
