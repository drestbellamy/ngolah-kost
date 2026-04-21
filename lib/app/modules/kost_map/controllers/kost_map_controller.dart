import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/utils/distance_calculator.dart' as utils;
import '../../../data/models/kost_with_status_model.dart';
import '../../../data/models/map_state_model.dart';
import '../../../../services/supabase_service.dart';
import '../../kost/models/kost_model.dart';
import '../../../routes/app_routes.dart';

class KostMapController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  // Reactive state
  final Rx<MapState> _mapState = const MapState().obs;
  final RxList<KostWithStatus> _allKostList = <KostWithStatus>[].obs;
  final RxList<KostWithStatus> _filteredKostList = <KostWithStatus>[].obs;
  final Rxn<KostWithStatus> _selectedKost = Rxn<KostWithStatus>();

  // Search debouncing
  Timer? _searchDebounceTimer;
  final _searchController = TextEditingController();

  // Getters
  MapState get mapState => _mapState.value;
  List<KostWithStatus> get allKostList => _allKostList;
  List<KostWithStatus> get filteredKostList => _filteredKostList;
  KostWithStatus? get selectedKost => _selectedKost.value;
  TextEditingController get searchController => _searchController;

  // Computed properties
  bool get isLoading => mapState.isLoading;
  bool get isLoadingLocation => mapState.isLoadingLocation;
  bool get hasLocationPermission => mapState.hasLocationPermission;
  bool get canUseLocationFeatures => mapState.canUseLocationFeatures;
  String get searchQuery => mapState.searchQuery;
  StatusFilter get statusFilter => mapState.statusFilter;
  MapViewMode get viewMode => mapState.viewMode;
  LatLng? get adminLocation => mapState.adminLocation;
  LatLng? get mapCenter => mapState.mapCenter;
  String? get errorMessage => mapState.errorMessage;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.onClose();
  }

  /// Initialize controller and load data
  Future<void> _initializeController() async {
    await _checkLocationPermission();
    // Try to get user location first before loading kost data
    await _tryGetInitialLocation();
    await loadKostData();
  }

  /// Try to get initial location without showing errors
  Future<void> _tryGetInitialLocation() async {
    try {
      final result = await LocationService.getCurrentLocation();

      if (result.isSuccess && result.location != null) {
        _updateMapState(
          _mapState.value.copyWith(
            adminLocation: result.location,
            mapCenter: result.location,
            mapZoom: 14.0, // Good zoom level to see nearby kost
            hasLocationPermission: true,
            isLocationServiceEnabled: true,
          ),
        );
      }
    } catch (e) {
      // Silently fail - will use kost center as fallback
    }
  }

  /// Load kost data with room availability status
  Future<void> loadKostData() async {
    try {
      _updateMapState(
        _mapState.value.copyWith(isLoading: true, clearError: true),
      );

      // Get kost list with status from Supabase
      final kostListWithStatus = await _supabaseService.getKostListWithStatus();

      print('🗺️ MAP DEBUG: Total kost from DB: ${kostListWithStatus.length}');

      // Convert to KostWithStatus models
      final kostList = kostListWithStatus
          .map((data) => KostWithStatus.fromMap(data))
          .where((kost) {
            final hasCoords = kost.hasValidCoordinates;
            if (!hasCoords) {
              print('⚠️ Kost "${kost.name}" tidak punya koordinat valid');
            }
            return hasCoords;
          }) // Only include kost with valid coordinates
          .toList();

      print('🗺️ MAP DEBUG: Kost dengan koordinat valid: ${kostList.length}');

      if (kostList.isNotEmpty) {
        print('🗺️ MAP DEBUG: Kost pertama: ${kostList.first.name}');
        print(
          '   Lat: ${kostList.first.latitude}, Lng: ${kostList.first.longitude}',
        );
      }

      _allKostList.assignAll(kostList);

      // Update distances if admin location is available
      if (adminLocation != null) {
        await _updateDistances();
      } else {
        _applyFilters();
      }

      // Set initial map center and zoom (only if not already set by location)
      if (kostList.isNotEmpty && mapCenter == null) {
        final locations = kostList
            .map((kost) => LatLng(kost.latitude!, kost.longitude!))
            .toList();
        final center = utils.DistanceCalculator.getCenterPoint(locations);
        if (center != null) {
          // Set appropriate zoom based on number of kost
          double zoom = 12.0; // Default zoom for multiple kost
          if (kostList.length == 1) {
            zoom = 15.0; // Zoom in more for single kost
          } else if (kostList.length <= 3) {
            zoom = 13.0; // Medium zoom for few kost
          }

          _updateMapState(
            _mapState.value.copyWith(mapCenter: center, mapZoom: zoom),
          );
        }
      }

      _updateMapState(_mapState.value.copyWith(isLoading: false));
    } catch (e) {
      _updateMapState(
        _mapState.value.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load kost data: ${e.toString()}',
        ),
      );
    }
  }

  /// Check and update location permission status
  Future<void> _checkLocationPermission() async {
    try {
      final status = await LocationService.checkPermissionStatus();
      final hasPermission = status == LocationStatus.granted;
      final isServiceEnabled = status != LocationStatus.serviceDisabled;

      _updateMapState(
        _mapState.value.copyWith(
          hasLocationPermission: hasPermission,
          isLocationServiceEnabled: isServiceEnabled,
        ),
      );
    } catch (e) {
      // Silently handle permission check errors
    }
  }

  /// Get current admin location
  Future<void> getCurrentLocation() async {
    try {
      _updateMapState(_mapState.value.copyWith(isLoadingLocation: true));

      final result = await LocationService.getCurrentLocation();

      if (result.isSuccess && result.location != null) {
        _updateMapState(
          _mapState.value.copyWith(
            adminLocation: result.location,
            mapCenter: result.location,
            hasLocationPermission: true,
            isLocationServiceEnabled: true,
            isLoadingLocation: false,
          ),
        );

        await _updateDistances();

        Get.snackbar(
          'Lokasi Ditemukan',
          'Lokasi Anda telah diperbarui',
          backgroundColor: const Color(0xFF10B981),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        _updateMapState(
          _mapState.value.copyWith(
            isLoadingLocation: false,
            hasLocationPermission: result.status == LocationStatus.granted,
            isLocationServiceEnabled:
                result.status != LocationStatus.serviceDisabled,
          ),
        );

        if (result.errorMessage != null) {
          LocationService.showLocationError(
            result.status,
            customMessage: result.errorMessage,
          );
        }
      }
    } catch (e) {
      _updateMapState(
        _mapState.value.copyWith(
          isLoadingLocation: false,
          errorMessage: 'Gagal mendapatkan lokasi: ${e.toString()}',
        ),
      );
    }
  }

  /// Update distances for all kost from admin location
  Future<void> _updateDistances() async {
    if (adminLocation == null) return;

    try {
      final updatedList = utils.DistanceCalculator.updateKostListWithDistances(
        adminLocation: adminLocation!,
        kostList: _allKostList,
        sortByDistance: viewMode == MapViewMode.list,
      );

      _allKostList.assignAll(updatedList);
      _applyFilters();
    } catch (e) {
      // Silently handle distance calculation errors
    }
  }

  /// Handle search input with debouncing
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateMapState(_mapState.value.copyWith(searchQuery: query.trim()));
      _applyFilters();
    });
  }

  /// Update status filter
  void updateStatusFilter(StatusFilter filter) {
    _updateMapState(_mapState.value.copyWith(statusFilter: filter));
    _applyFilters();
  }

  /// Toggle between map and list view
  void toggleViewMode() {
    final newMode = viewMode == MapViewMode.map
        ? MapViewMode.list
        : MapViewMode.map;
    _updateMapState(_mapState.value.copyWith(viewMode: newMode));

    // Sort by distance when switching to list view
    if (newMode == MapViewMode.list && adminLocation != null) {
      _updateDistances();
    }
  }

  /// Apply search and filter to kost list
  void _applyFilters() {
    var filtered = List<KostWithStatus>.from(_allKostList);

    // Apply search filter
    if (mapState.hasActiveSearch) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((kost) {
        return kost.name.toLowerCase().contains(query) ||
            kost.address.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    if (mapState.hasActiveFilter) {
      filtered = filtered.where((kost) {
        return mapState.matchesStatusFilter(kost.availabilityStatus);
      }).toList();
    }

    _filteredKostList.assignAll(filtered);
  }

  /// Select a kost (for bottom sheet display)
  void selectKost(KostWithStatus kost) {
    _selectedKost.value = kost;
  }

  /// Clear kost selection
  void clearSelection() {
    _selectedKost.value = null;
  }

  /// Navigate to kost detail page
  void navigateToKostDetail(KostWithStatus kost) {
    final kostModel = KostModel(
      id: kost.id,
      name: kost.name,
      address: kost.address,
      roomCount: kost.roomCount,
      latitude: kost.latitude,
      longitude: kost.longitude,
    );

    Get.toNamed(Routes.kamar, arguments: kostModel);
  }

  /// Open navigation to kost location
  Future<void> openNavigation(KostWithStatus kost) async {
    if (!kost.hasValidCoordinates) {
      Get.snackbar(
        'Kesalahan Navigasi',
        'Koordinat lokasi tidak tersedia untuk kost ini',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final destination = LatLng(kost.latitude!, kost.longitude!);

    final success = await NavigationService.openNavigation(
      destination: destination,
      origin: adminLocation,
      destinationName: kost.name,
    );

    if (success) {
      Get.snackbar(
        'Navigasi Dibuka',
        'Membuka navigasi ke ${kost.name}',
        backgroundColor: const Color(0xFF10B981),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refreshData() async {
    await loadKostData();
  }

  /// Clear search
  void clearSearch() {
    _searchController.clear();
    _updateMapState(_mapState.value.copyWith(searchQuery: ''));
    _applyFilters();
  }

  /// Clear all filters
  void clearAllFilters() {
    _searchController.clear();
    _updateMapState(
      _mapState.value.copyWith(searchQuery: '', statusFilter: StatusFilter.all),
    );
    _applyFilters();
  }

  /// Center map on specific kost
  void centerMapOnKost(KostWithStatus kost) {
    if (kost.hasValidCoordinates) {
      final location = LatLng(kost.latitude!, kost.longitude!);
      _updateMapState(
        _mapState.value.copyWith(
          mapCenter: location,
          mapZoom: 16.0, // Zoom in when centering on specific kost
        ),
      );
    }
  }

  /// Center map on admin location
  void centerMapOnAdmin() {
    if (adminLocation != null) {
      _updateMapState(
        _mapState.value.copyWith(mapCenter: adminLocation, mapZoom: 15.0),
      );
    } else {
      getCurrentLocation();
    }
  }

  /// Fit map to show all kost
  void fitMapToAllKost() {
    if (_filteredKostList.isEmpty) return;

    final locations = _filteredKostList
        .where((kost) => kost.hasValidCoordinates)
        .map((kost) => LatLng(kost.latitude!, kost.longitude!))
        .toList();

    if (locations.isNotEmpty) {
      final center = utils.DistanceCalculator.getCenterPoint(locations);
      if (center != null) {
        _updateMapState(
          _mapState.value.copyWith(
            mapCenter: center,
            mapZoom: 12.0, // Zoom out to show all
          ),
        );
      }
    }
  }

  /// Update map state
  void _updateMapState(MapState newState) {
    _mapState.value = newState;
  }
}
