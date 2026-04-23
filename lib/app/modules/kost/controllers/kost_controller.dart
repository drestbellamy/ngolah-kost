import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kost_repository.dart';
import '../models/kost_model.dart';
import '../views/map_picker_view.dart';

import '../../../routes/app_routes.dart';

class KostController extends GetxController {
  final KostRepository _kostRepo;

  KostController({KostRepository? kostRepository})
    : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository;
  final RxList<KostModel> kostList = <KostModel>[].obs;
  late final Future<List<KostModel>> kostFuture;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final roomCountController = TextEditingController();
  final RxBool isLoadingLocation = false.obs;
  String? editKostId;

  Rx<double?> latitude = Rx<double?>(null);
  Rx<double?> longitude = Rx<double?>(null);

  @override
  void onInit() {
    super.onInit();
    kostFuture = fetchKostData();
  }

  Future<List<KostModel>> fetchKostData() async {
    final data = await _kostRepo.getKostList();
    kostList.assignAll(data);
    return data;
  }

  void editKost(String id) {
    editKostId = id;
    final kost = kostList.firstWhere((k) => k.id == id);
    nameController.text = kost.name;
    addressController.text = kost.address;
    roomCountController.text = kost.roomCount.toString();
    latitude.value = kost.latitude;
    longitude.value = kost.longitude;

    Get.toNamed(Routes.editKost);
  }

  Future<void> updateKost() async {
    // Tutup keyboard sebelum proses
    FocusManager.instance.primaryFocus?.unfocus();

    if (editKostId == null) return;

    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        roomCountController.text.isEmpty) {
      ToastHelper.showError('Semua field harus diisi');
      return;
    }

    try {
      await _kostRepo.updateKost(
        id: editKostId!,
        namaKost: nameController.text,
        alamat: addressController.text,
        totalKamar: int.tryParse(roomCountController.text) ?? 0,
        latitude: latitude.value,
        longitude: longitude.value,
      );

      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.until((route) => route.isFirst || route.settings.name == Routes.kost);

      ToastHelper.showSuccess(
        'Data kost berhasil diperbarui',
        icon: Icons.home_work,
      );

      fetchKostData(); // Update secara background tanpa await agar cepat
    } catch (e) {
      ToastHelper.showError('Gagal memperbarui data kost: $e');
    }
  }

  void deleteKost(String id) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFFF0F4F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hapus Unit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF718096)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7FAFC),
                        foregroundColor: const Color(0xFF718096),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Future<void> _confirmDelete(String id) async {
    try {
      await _kostRepo.deleteKost(id);
      await fetchKostData();
      Get.back();

      ToastHelper.showSuccess(
        'Kost berhasil dihapus',
        icon: Icons.delete_outline,
      );
    } catch (e) {
      ToastHelper.showError('Gagal menghapus kost: $e');
    }
  }

  void addKost() {
    nameController.clear();
    addressController.clear();
    roomCountController.clear();
    latitude.value = null;
    longitude.value = null;
    Get.toNamed(Routes.addKost);
  }

  Future<void> saveNewKost() async {
    // Tutup keyboard sebelum proses
    FocusManager.instance.primaryFocus?.unfocus();

    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        roomCountController.text.isEmpty) {
      ToastHelper.showError('Semua field harus diisi');
      return;
    }

    try {
      await _kostRepo.createKost(
        namaKost: nameController.text,
        alamat: addressController.text,
        totalKamar: int.tryParse(roomCountController.text) ?? 0,
        latitude: latitude.value,
        longitude: longitude.value,
      );

      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.until((route) => route.isFirst || route.settings.name == Routes.kost);

      ToastHelper.showSuccess(
        'Kost baru berhasil ditambahkan',
        icon: Icons.home_work,
      );

      fetchKostData(); // Update secara background
    } catch (e) {
      ToastHelper.showError('Gagal menambahkan kost: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    roomCountController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ToastHelper.showError(
          'Layanan lokasi tidak aktif',
          icon: Icons.location_off,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ToastHelper.showError(
            'Izin lokasi ditolak',
            icon: Icons.location_off,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ToastHelper.showError(
          'Izin lokasi ditolak permanen',
          icon: Icons.location_off,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country} ${place.postalCode}';

        if (addressController.text != address) {
          addressController.text = address;
          ToastHelper.showSuccess(
            'Lokasi berhasil didapatkan',
            icon: Icons.location_on,
          );
        }
      }
    } catch (e) {
      ToastHelper.showError(
        'Gagal mendapatkan lokasi: $e',
        icon: Icons.location_off,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> openMapPicker() async {
    final result = await Get.to(
      () => MapPickerView(
        initialLatitude: latitude.value,
        initialLongitude: longitude.value,
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      final newAddress = result['address'] as String;
      latitude.value = result['latitude'] as double;
      longitude.value = result['longitude'] as double;

      if (addressController.text != newAddress) {
        addressController.text = newAddress;
        ToastHelper.showSuccess(
          'Titik lokasi berhasil dipilih',
          icon: Icons.location_on,
        );
      }
    }
  }
}
