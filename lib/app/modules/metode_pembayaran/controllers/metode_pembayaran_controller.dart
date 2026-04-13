import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';
import '../models/metode_pembayaran_model.dart';

class MetodePembayaranController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  final metodePembayaranList = <MetodePembayaranModel>[].obs;
  final filteredList = <MetodePembayaranModel>[].obs;
  final kostFilterOptions = <String>['Semua Kost'].obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final updatingStatusIds = <String>{}.obs;

  final selectedKost = 'Semua Kost'.obs;
  final selectedFilter = 'Semua'.obs; // 'Semua', 'Bank', 'Cash', 'QRIS'

  @override
  void onInit() {
    super.onInit();
    loadMetodePembayaran();
  }

  Future<void> loadMetodePembayaran({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final kostFuture = _supabaseService.getKostList();
      final metodeFuture = _supabaseService.getMetodePembayaranList();

      final kostList = await kostFuture;
      final metodeRows = await metodeFuture;

      final kostNameById = <String, String>{
        for (final kost in kostList)
          kost.id: kost.name.trim().isEmpty ? 'Kost' : kost.name.trim(),
      };

      final mapped = metodeRows
          .map(
            (row) =>
                MetodePembayaranModel.fromMap(row, kostNameById: kostNameById),
          )
          .where((item) => item.id.isNotEmpty)
          .toList();

      metodePembayaranList.assignAll(mapped);
      _syncKostFilterOptions(kostList.map((k) => k.name).toList(), mapped);
      applyFilter();
    } catch (e) {
      metodePembayaranList.clear();
      filteredList.clear();
      kostFilterOptions.assignAll(['Semua Kost']);
      selectedKost.value = 'Semua Kost';
      errorMessage.value = _resolveErrorMessage(
        e,
        'Gagal memuat data metode pembayaran.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _syncKostFilterOptions(
    List<String> kostNamesFromMaster,
    List<MetodePembayaranModel> metodeList,
  ) {
    final names = <String>{};

    for (final name in kostNamesFromMaster) {
      final cleaned = name.trim();
      if (cleaned.isNotEmpty) names.add(cleaned);
    }
    for (final item in metodeList) {
      final cleaned = item.namaKost.trim();
      if (cleaned.isNotEmpty) names.add(cleaned);
    }

    final options = ['Semua Kost', ...names.toList()..sort()];
    kostFilterOptions.assignAll(options);

    if (!options.contains(selectedKost.value)) {
      selectedKost.value = 'Semua Kost';
    }
  }

  Future<void> refreshList() async {
    await loadMetodePembayaran(showLoading: false);
  }

  String _resolveErrorMessage(Object error, String fallback) {
    var message = error.toString().trim();
    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }
    if (message.length > 180) {
      message = '${message.substring(0, 180)}...';
    }
    return message.isEmpty ? fallback : message;
  }

  Future<void> _handleDeleteConfirmed(String id) async {
    try {
      await _supabaseService.deleteMetodePembayaran(id);
      metodePembayaranList.removeWhere((m) => m.id == id);
      applyFilter();

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran berhasil dihapus',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menghapus metode pembayaran'),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _handleFormResult(dynamic result) async {
    if (result == true) {
      await loadMetodePembayaran(showLoading: false);
    }
  }

  Future<void> tambahMetode() async {
    final result = await Get.toNamed('/tambah-metode-pembayaran');
    await _handleFormResult(result);
  }

  Future<void> editMetode(String id) async {
    final metode = metodePembayaranList.firstWhereOrNull((m) => m.id == id);
    if (metode == null) return;

    final result = await Get.toNamed(
      '/edit-metode-pembayaran',
      arguments: metode,
    );
    await _handleFormResult(result);
  }

  Future<void> toggleStatus(String id) async {
    final index = metodePembayaranList.indexWhere((m) => m.id == id);
    if (index == -1) return;
    if (updatingStatusIds.contains(id)) return;

    final current = metodePembayaranList[index];
    final targetStatus = !current.isActive;

    updatingStatusIds.add(id);

    metodePembayaranList[index] = current.copyWith(isActive: targetStatus);
    metodePembayaranList.refresh();
    applyFilter();

    try {
      await _supabaseService.updateMetodePembayaranStatus(
        id: id,
        isActive: targetStatus,
      );
    } catch (e) {
      // Rollback UI if backend update fails.
      metodePembayaranList[index] = current;
      metodePembayaranList.refresh();
      applyFilter();

      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal memperbarui status metode pembayaran'),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      updatingStatusIds.remove(id);
    }
  }

  void applyFilter() {
    filteredList.value = metodePembayaranList.where((metode) {
      bool matchKost =
          selectedKost.value == 'Semua Kost' ||
          metode.namaKost == selectedKost.value;
      bool matchJenis =
          selectedFilter.value == 'Semua' ||
          (selectedFilter.value == 'Bank' && metode.jenis == 'bank') ||
          (selectedFilter.value == 'Cash' && metode.jenis == 'cash') ||
          (selectedFilter.value == 'QRIS' && metode.jenis == 'qris');
      return matchKost && matchJenis;
    }).toList();
  }

  void setKostFilter(String kost) {
    selectedKost.value = kost;
    applyFilter();
  }

  void setJenisFilter(String jenis) {
    selectedFilter.value = jenis;
    applyFilter();
  }

  int get totalAktif {
    return metodePembayaranList.where((m) => m.isActive).length;
  }

  int get totalMetode {
    return metodePembayaranList.length;
  }

  void deleteMetode(String id) {
    final metode = metodePembayaranList.firstWhereOrNull((m) => m.id == id);
    if (metode == null) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hapus Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Apakah Anda yakin ingin menghapus metode pembayaran ${metode.nama} untuk ${metode.namaKost}?',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await _handleDeleteConfirmed(id);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
}
