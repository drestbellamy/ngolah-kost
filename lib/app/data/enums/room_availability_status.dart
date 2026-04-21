enum RoomAvailabilityStatus { allAvailable, partiallyOccupied, allOccupied }

extension RoomAvailabilityStatusExtension on RoomAvailabilityStatus {
  String get displayName {
    switch (this) {
      case RoomAvailabilityStatus.allAvailable:
        return 'All Available';
      case RoomAvailabilityStatus.partiallyOccupied:
        return 'Partially Occupied';
      case RoomAvailabilityStatus.allOccupied:
        return 'All Occupied';
    }
  }

  String get statusText {
    switch (this) {
      case RoomAvailabilityStatus.allAvailable:
        return 'Available';
      case RoomAvailabilityStatus.partiallyOccupied:
        return 'Partial';
      case RoomAvailabilityStatus.allOccupied:
        return 'Full';
    }
  }

  /// Color for marker display
  /// Green for available, Yellow for partial, Red for full
  int get markerColor {
    switch (this) {
      case RoomAvailabilityStatus.allAvailable:
        return 0xFF4CAF50; // Green
      case RoomAvailabilityStatus.partiallyOccupied:
        return 0xFFFFC107; // Yellow/Amber
      case RoomAvailabilityStatus.allOccupied:
        return 0xFFF44336; // Red
    }
  }

  /// Background color for status badge
  int get badgeBackgroundColor {
    switch (this) {
      case RoomAvailabilityStatus.allAvailable:
        return 0xFFE8F5E9; // Light green
      case RoomAvailabilityStatus.partiallyOccupied:
        return 0xFFFFF8E1; // Light yellow
      case RoomAvailabilityStatus.allOccupied:
        return 0xFFFFEBEE; // Light red
    }
  }

  /// Text color for status badge
  int get badgeTextColor {
    switch (this) {
      case RoomAvailabilityStatus.allAvailable:
        return 0xFF2E7D32; // Dark green
      case RoomAvailabilityStatus.partiallyOccupied:
        return 0xFFF57F17; // Dark yellow
      case RoomAvailabilityStatus.allOccupied:
        return 0xFFC62828; // Dark red
    }
  }
}
