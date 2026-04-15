import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';
import '../models/kost_model.dart';

import '../../../routes/app_routes.dart';

class KostController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final RxList<KostModel> kostList = <KostModel>[].obs;
  late final Future<List<KostModel>> kostFuture;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final roomCountController = TextEditingController();
  String? editKostId;

  @override
  void onInit() {
    super.onInit();
    kostFuture = fetchKostData();
  }

  Future<List<KostModel>> fetchKostData() async {
    final data = await _supabaseService.getKostList();
    kostList.assignAll(data);
    return data;
  }

  void editKost(String id) {
    editKostId = id;
    final kost = kostList.firstWhere((k) => k.id == id);
    nameController.text = kost.name;
    addressController.text = kost.address;
    roomCountController.text = kost.roomCount.toString();

    Get.toNamed(Routes.editKost);
  }

  Future<void> updateKost() async {
    if (editKostId == null) return;
    
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        roomCountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _supabaseService.updateKost(
        id: editKostId!,
        namaKost: nameController.text,
        alamat: addressController.text,
        totalKamar: int.tryParse(roomCountController.text) ?? 0,
      );

      await fetchKostData();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Data kost berhasil diperbarui',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui data kost: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
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
      await _supabaseService.deleteKost(id);
      await fetchKostData();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Kost berhasil dihapus',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus kost: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  void addKost() {
    nameController.clear();
    addressController.clear();
    roomCountController.clear();
    Get.toNamed(Routes.addKost);
  }

  Future<void> saveNewKost() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        roomCountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _supabaseService.createKost(
        namaKost: nameController.text,
        alamat: addressController.text,
        totalKamar: int.tryParse(roomCountController.text) ?? 0,
      );

      await fetchKostData();
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Kost baru berhasil ditambahkan',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan kost: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    roomCountController.dispose();
    super.onClose();
  }
}
