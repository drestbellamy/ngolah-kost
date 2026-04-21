import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/kost_map_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../data/models/map_state_model.dart';
import '../../../data/models/kost_with_status_model.dart';
import '../../../data/enums/room_availability_status.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chips_widget.dart';
import 'widgets/kost_detail_bottom_sheet.dart';
import 'widgets/map_floating_buttons.dart';

class KostMapView extends GetView<KostMapController> {
  const KostMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            const CustomHeader(
              title: 'Peta Lokasi Kost',
              subtitle: 'Lihat semua lokasi kost di peta',
              showBackButton: true,
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.viewMode == MapViewMode.map) {
                  return _buildMapView();
                } else {
                  return _buildListView();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map
        Obx(() => _buildFlutterMap()),

        // Search and Filter UI
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              // Search Bar
              SearchBarWidget(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),

              const SizedBox(height: 12),

              // Filter Chips
              FilterChipsWidget(
                selectedFilter: controller.statusFilter,
                onFilterChanged: controller.updateStatusFilter,
                onClearAll: controller.clearAllFilters,
                hasActiveFilters: controller.mapState.hasActiveFilters,
              ),
            ],
          ),
        ),

        // Floating Action Buttons
        Positioned(
          bottom: 16,
          right: 16,
          child: MapFloatingButtons(
            onMyLocationPressed: controller.getCurrentLocation,
            onToggleViewPressed: controller.toggleViewMode,
            onFitAllPressed: controller.fitMapToAllKost,
            isLoadingLocation: controller.isLoadingLocation,
            viewMode: controller.viewMode,
          ),
        ),

        // Loading Overlay
        Obx(() {
          if (controller.isLoading) {
            return Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8E7F)),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // No Data Message
        Obx(() {
          if (!controller.isLoading &&
              controller.filteredKostList.isEmpty &&
              controller.errorMessage == null) {
            return Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with background
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F0ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          size: 56,
                          color: Color(0xFF6B8E7F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tidak Ada Data Kost',
                        style: AppTextStyles.header20,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada kost dengan koordinat lokasi yang valid.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.copyWith(fontSize: 15).colored(const Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan latitude & longitude pada data kost Anda.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.getCurrentLocation,
                              icon: const Icon(Icons.my_location, size: 20),
                              label: const Text('Coba Lokasi Saya'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B8E7F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.refreshData,
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text('Refresh Data'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6B8E7F),
                                side: const BorderSide(
                                  color: Color(0xFF6B8E7F),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Error Message
        Obx(() {
          if (controller.errorMessage != null) {
            return Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.errorMessage!,
                        style: AppTextStyles.body14.colored(const Color(0xFFEF4444)),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.refreshData,
                      icon: const Icon(Icons.refresh, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildFlutterMap() {
    // Determine initial center
    LatLng initialCenter;
    double initialZoom = 5.0;

    if (controller.mapCenter != null) {
      // Use controller's map center (from location or kost data)
      initialCenter = controller.mapCenter!;
      initialZoom = controller.mapState.mapZoom;
    } else if (controller.filteredKostList.isNotEmpty) {
      // Use first kost location if available
      final firstKost = controller.filteredKostList.first;
      if (firstKost.hasValidCoordinates) {
        initialCenter = LatLng(firstKost.latitude!, firstKost.longitude!);
        initialZoom = 13.0;
      } else {
        // No valid coordinates, show Indonesia with message
        initialCenter = const LatLng(-2.5489, 118.0149);
        initialZoom = 5.0;
      }
    } else {
      // No kost data yet, show Indonesia
      initialCenter = const LatLng(-2.5489, 118.0149);
      initialZoom = 5.0;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          // Clear selection when tapping on empty area
          controller.clearSelection();
        },
      ),
      children: [
        // Map Tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hummatech_kost',
          maxZoom: 18,
        ),

        // Admin Location Marker
        if (controller.adminLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: controller.adminLocation!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

        // Kost Markers with Clustering
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            markers: controller.filteredKostList
                .where((kost) => kost.hasValidCoordinates)
                .map((kost) => _buildKostMarker(kost))
                .toList(),
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: AppTextStyles.body12.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Marker _buildKostMarker(KostWithStatus kost) {
    return Marker(
      point: LatLng(kost.latitude!, kost.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          controller.selectKost(kost);
          _showKostBottomSheet(kost);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(kost.availabilityStatus.markerColor),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.apartment, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Search and Filter (same as map view)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchBarWidget(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),

              const SizedBox(height: 12),

              FilterChipsWidget(
                selectedFilter: controller.statusFilter,
                onFilterChanged: controller.updateStatusFilter,
                onClearAll: controller.clearAllFilters,
                hasActiveFilters: controller.mapState.hasActiveFilters,
              ),
            ],
          ),
        ),

        // List Content
        Expanded(
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8E7F)),
                ),
              );
            }

            if (controller.filteredKostList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      controller.mapState.hasActiveFilters
                          ? 'No kost found matching your filters'
                          : 'No kost data available',
                      style: AppTextStyles.body16.colored(Colors.grey[600]!),
                    ),
                    if (controller.mapState.hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: controller.clearAllFilters,
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredKostList.length,
                itemBuilder: (context, index) {
                  final kost = controller.filteredKostList[index];
                  return _buildKostListItem(kost);
                },
              ),
            );
          }),
        ),

        // Toggle to Map View Button
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.toggleViewMode,
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKostListItem(KostWithStatus kost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(kost.availabilityStatus.markerColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Kost Name
              Expanded(
                child: Text(
                  kost.name,
                  style: AppTextStyles.subtitle16.colored(const Color(0xFF2D3748)),
                ),
              ),

              // Distance
              if (kost.distanceFromAdmin != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0ED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    kost.formattedDistance,
                    style: AppTextStyles.body12.copyWith(
                      color: const Color(0xFF6B8E7F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF718096)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  kost.address,
                  style: AppTextStyles.body12.colored(const Color(0xFF718096)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status and Room Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(kost.availabilityStatus.badgeBackgroundColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  kost.availabilityStatus.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(kost.availabilityStatus.badgeTextColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '${kost.availableRooms}/${kost.roomCount} tersedia',
                style: AppTextStyles.body12.colored(const Color(0xFF718096)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.openNavigation(kost),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Route'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B8E7F),
                    side: const BorderSide(color: Color(0xFF6B8E7F)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.navigateToKostDetail(kost),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showKostBottomSheet(KostWithStatus kost) {
    Get.bottomSheet(
      KostDetailBottomSheet(
        kost: kost,
        onRoutePressed: () => controller.openNavigation(kost),
        onDetailPressed: () => controller.navigateToKostDetail(kost),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
