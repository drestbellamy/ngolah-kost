import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repositories/pengajuan_pindah_repository.dart';
import '../../../data/models/pengajuan_pindah_model.dart';
import '../../../core/utils/toast_helper.dart';

import '../../../../repositories/repository_factory.dart';
import '../../kamar/controllers/kamar_controller.dart';
import '../../penghuni/controllers/penghuni_controller.dart';

class AdminPengajuanPindahController extends GetxController {
  final PengajuanPindahRepository _repository;
  final _penghuniRepo = RepositoryFactory.instance.penghuniRepository;

  AdminPengajuanPindahController({PengajuanPindahRepository? repository})
    : _repository = repository ?? PengajuanPindahRepository();

  final isLoading = false.obs;
  final listPengajuan = <PengajuanPindahModel>[].obs;

  // Filtering and Searching
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedFilter = 'semua'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengajuan();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<PengajuanPindahModel> get filteredList {
    final query = searchQuery.value.toLowerCase();
    final filter = selectedFilter.value;

    return listPengajuan.where((item) {
      // Apply status filter
      if (filter != 'semua' && item.status != filter) {
        return false;
      }

      // Apply search query
      if (query.isNotEmpty) {
        final nama = (item.namaPenghuni ?? '').toLowerCase();
        final asal = (item.noKamarAsal ?? '').toLowerCase();
        final tujuan = (item.noKamarTujuan ?? '').toLowerCase();
        return nama.contains(query) ||
            asal.contains(query) ||
            tujuan.contains(query);
      }

      return true;
    }).toList();
  }

  int get countMenunggu =>
      listPengajuan.where((e) => e.status == 'menunggu').length;
  int get countDisetujui =>
      listPengajuan.where((e) => e.status == 'disetujui').length;
  int get countDitolak =>
      listPengajuan.where((e) => e.status == 'ditolak').length;

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) {
      selectedFilter.value = 'semua';
    } else {
      selectedFilter.value = filter;
    }
  }

  Future<void> fetchPengajuan() async {
    try {
      isLoading.value = true;
      final rawList = await _repository.getAllPengajuan();

      // Enrich with Penghuni lookup
      final lookup = await _penghuniRepo.buildPenghuniLookup();

      final enrichedList = rawList.map((item) {
        final penghuniData = lookup[item.penghuniId];
        if (penghuniData != null) {
          return PengajuanPindahModel(
            id: item.id,
            penghuniId: item.penghuniId,
            kamarTujuanId: item.kamarTujuanId,
            tanggalPindah: item.tanggalPindah,
            alasan: item.alasan,
            status: item.status,
            keteranganAdmin: item.keteranganAdmin,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            noKamarTujuan: item.noKamarTujuan,
            namaKostTujuan: item.namaKostTujuan,
            namaPenghuni: penghuniData['nama'],
            noTeleponPenghuni: penghuniData['no_tlpn'],
            noKamarAsal: penghuniData['nomor_kamar'],
            namaKostAsal: penghuniData['nama_kost'],
            alamatKostAsal: penghuniData['alamat_kost'],
            alamatKostTujuan: item.alamatKostTujuan,
            hargaKamarTujuan: item.hargaKamarTujuan,
          );
        }
        return item;
      }).toList();

      listPengajuan.assignAll(enrichedList);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data pengajuan pindah kamar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showDetailBottomSheet(PengajuanPindahModel pengajuan) {
    Get.toNamed('/admin-pengajuan-pindah-detail', arguments: pengajuan);
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? keteranganAdmin,
  }) async {
    try {
      isLoading.value = true;

      // 🆕 Call RPC via repository (return Map dengan result)
      final result = await _repository.updateStatusPengajuan(
        id,
        status,
        keteranganAdmin: keteranganAdmin,
      );

      // 🆕 Parse result dari RPC
      final success = result['success'] as bool? ?? false;
      final message =
          result['message'] as String? ?? 'Status berhasil diperbarui';
      final data = result['data'] as Map<String, dynamic>? ?? {};

      if (success) {
        ToastHelper.showSuccess(message);

        // 🆕 Log detail perpindahan untuk debugging (optional)
        if (data.isNotEmpty && status == 'disetujui') {
          print('📦 Perpindahan kamar berhasil:');
          print('   Penghuni ID: ${data['penghuni_id']}');
          print(
            '   Dari Kamar: ${data['kamar_asal_id']} (${data['status_kamar_asal']})',
          );
          print(
            '   Ke Kamar: ${data['kamar_tujuan_id']} (${data['status_kamar_tujuan']})',
          );
          print('   Terisi Asal: ${data['terisi_asal']}');
          print('   Terisi Tujuan: ${data['terisi_tujuan']}');
          print('   Harga: ${data['harga_lama']} → ${data['harga_baru']}');
        }

        // Refresh list pengajuan
        await fetchPengajuan();

        // Update sinkronisasi data UI state di page lain jika ada
        if (status == 'disetujui') {
          if (Get.isRegistered<KamarController>()) {
            Get.find<KamarController>().fetchKamarData();
          }
          if (Get.isRegistered<PenghuniController>()) {
            Get.find<PenghuniController>().loadPenghuniData();
          }
        }
      } else {
        ToastHelper.showError(message);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ToastHelper.showError('Gagal memperbarui status: $errorMsg');
      print('❌ Error updating status: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
