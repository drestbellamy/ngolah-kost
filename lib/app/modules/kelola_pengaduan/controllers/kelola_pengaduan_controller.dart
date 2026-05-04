import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../repositories/pengaduan_repository.dart';
import '../models/pengaduan_admin_model.dart';

class KelolaPengaduanController extends GetxController {
  final PengaduanRepository _pengaduanRepo;

  KelolaPengaduanController({PengaduanRepository? pengaduanRepository})
    : _pengaduanRepo =
          pengaduanRepository ?? PengaduanRepository(Supabase.instance.client);

  final searchController = TextEditingController();
  final selectedFilter = 'semua'.obs;
  final selectedKostId = 'semua'.obs;
  final selectedBulan = 'semua'.obs;
  final searchQuery = ''.obs;
  final pengaduanList = <PengaduanAdminModel>[].obs;
  final filteredPengaduanList = <PengaduanAdminModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPengaduanData();
  }

  Future<void> loadPengaduanData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final rows = await _pengaduanRepo.fetchAllPengaduanForAdmin();
      final mapped = rows
          .map((row) => PengaduanAdminModel.fromJson(row))
          .toList();

      pengaduanList.assignAll(mapped);
      _applyFilters();
    } catch (e) {
      print('Error loading pengaduan: $e');
      errorMessage.value = 'Gagal memuat data pengaduan.';
      pengaduanList.clear();
      filteredPengaduanList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void changeKostFilter(String kostId) {
    selectedKostId.value = kostId;
    _applyFilters();
  }

  void changeBulanFilter(String bulan) {
    selectedBulan.value = bulan;
    _applyFilters();
  }

  void searchPengaduan(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  int getTotalPengaduan() {
    return filteredPengaduanList.length;
  }

  int getCountByStatus(String status) {
    if (status == 'semua') return pengaduanList.length;
    return pengaduanList
        .where(
          (pengaduan) => pengaduan.status.toUpperCase() == status.toUpperCase(),
        )
        .length;
  }

  /// Get list of unique kost from pengaduan data
  List<Map<String, String>> get kostFilterList {
    final kostMap = <String, String>{};
    for (final pengaduan in pengaduanList) {
      final kostName = pengaduan.namaKost;
      if (kostName.isNotEmpty && kostName != '-') {
        kostMap[kostName] = kostName;
      }
    }

    final sorted =
        kostMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList()
          ..sort((a, b) => a['name']!.compareTo(b['name']!));

    return sorted;
  }

  String getKostFilterLabel(String kostId) {
    if (kostId == 'semua') return 'Semua Kost';
    return kostId;
  }

  /// Get list of unique months from pengaduan data
  List<Map<String, String>> get bulanFilterList {
    final bulanMap = <String, String>{};
    for (final pengaduan in pengaduanList) {
      try {
        final date = pengaduan.tanggal;
        final monthYear = '${date.month}-${date.year}';
        final monthNames = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        final label = '${monthNames[date.month - 1]} ${date.year}';
        bulanMap[monthYear] = label;
      } catch (e) {
        // Skip invalid dates
      }
    }

    final sorted =
        bulanMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList()
          ..sort((a, b) {
            // Sort by date descending (newest first)
            final aParts = a['id']!.split('-');
            final bParts = b['id']!.split('-');
            final aDate = DateTime(int.parse(aParts[1]), int.parse(aParts[0]));
            final bDate = DateTime(int.parse(bParts[1]), int.parse(bParts[0]));
            return bDate.compareTo(aDate);
          });

    return sorted;
  }

  void _applyFilters() {
    final query = searchQuery.value;
    final filter = selectedFilter.value;
    final kostFilter = selectedKostId.value;
    final bulanFilter = selectedBulan.value;

    final result = pengaduanList.where((pengaduan) {
      final matchFilter =
          filter == 'semua' ||
          pengaduan.status.toUpperCase() == filter.toUpperCase();
      final matchKost =
          kostFilter == 'semua' || pengaduan.namaKost == kostFilter;

      // Match bulan - extract month from tanggal
      final matchBulan =
          bulanFilter == 'semua' || _matchBulan(pengaduan.tanggal, bulanFilter);

      final matchQuery =
          query.isEmpty ||
          pengaduan.namaPenghuni.toLowerCase().contains(query) ||
          pengaduan.kodeLaporan.toLowerCase().contains(query) ||
          pengaduan.namaKost.toLowerCase().contains(query) ||
          pengaduan.nomorKamar.toLowerCase().contains(query);
      return matchFilter && matchKost && matchBulan && matchQuery;
    }).toList();

    filteredPengaduanList.assignAll(result);
  }

  bool _matchBulan(DateTime tanggal, String bulanFilter) {
    try {
      final monthYear = '${tanggal.month}-${tanggal.year}';
      return monthYear == bulanFilter;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateStatus(int idLaporan, String newStatus) async {
    try {
      isLoading.value = true;

      await _pengaduanRepo.updateStatusPengaduan(
        idLaporan: idLaporan,
        newStatus: newStatus,
      );

      // Reload data
      await loadPengaduanData();
    } catch (e) {
      // Re-throw error untuk di-handle di view
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
