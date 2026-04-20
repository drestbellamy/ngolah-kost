import 'package:latlong2/latlong.dart';
import '../enums/room_availability_status.dart';

enum MapViewMode { map, list }

enum StatusFilter { all, hasEmptyRooms, full }

class MapState {
  final bool isLoading;
  final bool isLoadingLocation;
  final String searchQuery;
  final StatusFilter statusFilter;
  final MapViewMode viewMode;
  final LatLng? adminLocation;
  final LatLng? mapCenter;
  final double mapZoom;
  final String? errorMessage;
  final bool hasLocationPermission;
  final bool isLocationServiceEnabled;

  const MapState({
    this.isLoading = false,
    this.isLoadingLocation = false,
    this.searchQuery = '',
    this.statusFilter = StatusFilter.all,
    this.viewMode = MapViewMode.map,
    this.adminLocation,
    this.mapCenter,
    this.mapZoom = 13.0,
    this.errorMessage,
    this.hasLocationPermission = false,
    this.isLocationServiceEnabled = false,
  });

  MapState copyWith({
    bool? isLoading,
    bool? isLoadingLocation,
    String? searchQuery,
    StatusFilter? statusFilter,
    MapViewMode? viewMode,
    LatLng? adminLocation,
    LatLng? mapCenter,
    double? mapZoom,
    String? errorMessage,
    bool? hasLocationPermission,
    bool? isLocationServiceEnabled,
    bool clearError = false,
    bool clearAdminLocation = false,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      viewMode: viewMode ?? this.viewMode,
      adminLocation: clearAdminLocation
          ? null
          : (adminLocation ?? this.adminLocation),
      mapCenter: mapCenter ?? this.mapCenter,
      mapZoom: mapZoom ?? this.mapZoom,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }

  /// Check if search is active
  bool get hasActiveSearch => searchQuery.trim().isNotEmpty;

  /// Check if filter is active (not showing all)
  bool get hasActiveFilter => statusFilter != StatusFilter.all;

  /// Check if any filters are applied
  bool get hasActiveFilters => hasActiveSearch || hasActiveFilter;

  /// Check if location features are available
  bool get canUseLocationFeatures =>
      hasLocationPermission && isLocationServiceEnabled;

  /// Get filter display text
  String get filterDisplayText {
    switch (statusFilter) {
      case StatusFilter.all:
        return 'All';
      case StatusFilter.hasEmptyRooms:
        return 'Has Empty Rooms';
      case StatusFilter.full:
        return 'Full';
    }
  }

  /// Check if a status matches the current filter
  bool matchesStatusFilter(RoomAvailabilityStatus status) {
    switch (statusFilter) {
      case StatusFilter.all:
        return true;
      case StatusFilter.hasEmptyRooms:
        return status == RoomAvailabilityStatus.allAvailable ||
            status == RoomAvailabilityStatus.partiallyOccupied;
      case StatusFilter.full:
        return status == RoomAvailabilityStatus.allOccupied;
    }
  }

  @override
  String toString() {
    return 'MapState{isLoading: $isLoading, searchQuery: "$searchQuery", statusFilter: ${statusFilter.name}, viewMode: ${viewMode.name}, hasLocationPermission: $hasLocationPermission}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapState &&
        other.isLoading == isLoading &&
        other.isLoadingLocation == isLoadingLocation &&
        other.searchQuery == searchQuery &&
        other.statusFilter == statusFilter &&
        other.viewMode == viewMode &&
        other.adminLocation == adminLocation &&
        other.mapCenter == mapCenter &&
        other.mapZoom == mapZoom &&
        other.errorMessage == errorMessage &&
        other.hasLocationPermission == hasLocationPermission &&
        other.isLocationServiceEnabled == isLocationServiceEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isLoadingLocation,
      searchQuery,
      statusFilter,
      viewMode,
      adminLocation,
      mapCenter,
      mapZoom,
      errorMessage,
      hasLocationPermission,
      isLocationServiceEnabled,
    );
  }
}

extension StatusFilterExtension on StatusFilter {
  String get displayName {
    switch (this) {
      case StatusFilter.all:
        return 'All';
      case StatusFilter.hasEmptyRooms:
        return 'Has Empty Rooms';
      case StatusFilter.full:
        return 'Full';
    }
  }

  String get shortName {
    switch (this) {
      case StatusFilter.all:
        return 'All';
      case StatusFilter.hasEmptyRooms:
        return 'Available';
      case StatusFilter.full:
        return 'Full';
    }
  }
}
