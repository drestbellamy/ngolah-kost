import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final MapController _mapController = MapController();
  LatLng _centerPosition = const LatLng(
    -6.200000,
    106.816666,
  ); // Default Jakarta
  bool _isLoading = true;
  String _currentAddress = 'Mengambil alamat...';

  @override
  void initState() {
    super.initState();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _centerPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_centerPosition, 16.0);
      _updateAddress(_centerPosition);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Info',
        'Menggunakan lokasi default (Gagal mengakses lokasi anda)',
        backgroundColor: const Color(0xFFE2E8F0),
      );
      setState(() => _isLoading = false);
      _updateAddress(_centerPosition);
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    if (!mounted) return;
    setState(() => _currentAddress = 'Mencari alamat...');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''} ${place.postalCode ?? ''}'
                  .replaceAll(RegExp(r', +,'), ', ')
                  .replaceAll(RegExp(r'^, '), '')
                  .trim();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _currentAddress = 'Alamat tidak ditemukan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B8E7F),
        title: const Text(
          'Pilih Lokasi Kost',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          if (!_isLoading)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centerPosition,
                initialZoom: 16.0,
                onPositionChanged: (MapCamera position, bool hasGesture) {
                  if (hasGesture) {
                    setState(() => _centerPosition = position.center);
                  }
                },
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveEnd) {
                    _updateAddress(_centerPosition);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.hummatech.ngolah_kost',
                ),
              ],
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B8E7F)),
            ),
          if (!_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40), // Adjust for pin tail
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: Color(0xFF6B8E7F),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _currentAddress == 'Mencari alamat...' ||
                                _currentAddress == 'Mengambil alamat...'
                            ? null
                            : () {
                                Get.back(result: _currentAddress);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B8E7F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pilih Titik Lokasi Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _getCurrentUserLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF6B8E7F)),
            ),
          ),
        ],
      ),
    );
  }
}
