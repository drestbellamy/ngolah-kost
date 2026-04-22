import '../enums/room_availability_status.dart';
import '../../modules/kost/models/kost_model.dart';

class KostWithStatus extends KostModel {
  final RoomAvailabilityStatus availabilityStatus;
  final int availableRooms;
  final int occupiedRooms;
  final double? distanceFromAdmin; // Distance in kilometers

  KostWithStatus({
    required super.id,
    required super.name,
    required super.address,
    required super.roomCount,
    super.latitude,
    super.longitude,
    required this.availabilityStatus,
    required this.availableRooms,
    required this.occupiedRooms,
    this.distanceFromAdmin,
  });

  /// Create KostWithStatus from KostModel and room data
  factory KostWithStatus.fromKostModel({
    required KostModel kost,
    required int availableRooms,
    required int occupiedRooms,
    double? distanceFromAdmin,
  }) {
    final totalRooms = kost.roomCount;
    RoomAvailabilityStatus status;

    // Handle case when no rooms exist yet
    if (totalRooms == 0) {
      status =
          RoomAvailabilityStatus.allAvailable; // No rooms = available for setup
    } else if (availableRooms == totalRooms) {
      status = RoomAvailabilityStatus.allAvailable;
    } else if (availableRooms == 0) {
      status = RoomAvailabilityStatus.allOccupied;
    } else {
      status = RoomAvailabilityStatus.partiallyOccupied;
    }

    return KostWithStatus(
      id: kost.id,
      name: kost.name,
      address: kost.address,
      roomCount: kost.roomCount,
      latitude: kost.latitude,
      longitude: kost.longitude,
      availabilityStatus: status,
      availableRooms: availableRooms,
      occupiedRooms: occupiedRooms,
      distanceFromAdmin: distanceFromAdmin,
    );
  }

  /// Create from map data (for database queries)
  factory KostWithStatus.fromMap(Map<String, dynamic> map) {
    final kost = KostModel.fromMap(map);
    final availableRooms = map['available_rooms'] is int
        ? map['available_rooms'] as int
        : int.tryParse(map['available_rooms']?.toString() ?? '0') ?? 0;
    final occupiedRooms = map['occupied_rooms'] is int
        ? map['occupied_rooms'] as int
        : int.tryParse(map['occupied_rooms']?.toString() ?? '0') ?? 0;

    final distanceFromAdmin = map['distance_from_admin'] != null
        ? double.tryParse(map['distance_from_admin'].toString())
        : null;

    // Parse availability status from string
    RoomAvailabilityStatus status;
    final statusString = map['availability_status']?.toString() ?? 'available';

    switch (statusString) {
      case 'full':
        status = RoomAvailabilityStatus.allOccupied;
        break;
      case 'limited':
        status = RoomAvailabilityStatus.partiallyOccupied;
        break;
      case 'unavailable':
        status = RoomAvailabilityStatus.allOccupied;
        break;
      case 'available':
      default:
        status = RoomAvailabilityStatus.allAvailable;
        break;
    }

    return KostWithStatus(
      id: kost.id,
      name: kost.name,
      address: kost.address,
      roomCount: kost.roomCount,
      latitude: kost.latitude,
      longitude: kost.longitude,
      availabilityStatus: status,
      availableRooms: availableRooms,
      occupiedRooms: occupiedRooms,
      distanceFromAdmin: distanceFromAdmin,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nama_kost': name,
      'alamat': address,
      'total_kamar': roomCount,
      'latitude': latitude,
      'longitude': longitude,
      'available_rooms': availableRooms,
      'occupied_rooms': occupiedRooms,
      'availability_status': availabilityStatus.name,
    };

    if (distanceFromAdmin != null) {
      map['distance_from_admin'] = distanceFromAdmin;
    }

    return map;
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceFromAdmin == null) return '';

    if (distanceFromAdmin! < 1.0) {
      final meters = (distanceFromAdmin! * 1000).round();
      return '${meters}m';
    } else {
      return '${distanceFromAdmin!.toStringAsFixed(1)}km';
    }
  }

  /// Check if kost has valid coordinates for map display
  bool get hasValidCoordinates {
    return latitude != null &&
        longitude != null &&
        latitude!.isFinite &&
        longitude!.isFinite;
  }

  /// Create a copy with updated distance
  KostWithStatus copyWithDistance(double? newDistance) {
    return KostWithStatus(
      id: id,
      name: name,
      address: address,
      roomCount: roomCount,
      latitude: latitude,
      longitude: longitude,
      availabilityStatus: availabilityStatus,
      availableRooms: availableRooms,
      occupiedRooms: occupiedRooms,
      distanceFromAdmin: newDistance,
    );
  }

  @override
  String toString() {
    return 'KostWithStatus{id: $id, name: $name, status: ${availabilityStatus.name}, available: $availableRooms, occupied: $occupiedRooms, distance: $formattedDistance}';
  }
}
