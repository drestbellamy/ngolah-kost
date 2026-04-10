import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';
import '../models/tagihan_model.dart';

class KelolaTagihanController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final searchController = TextEditingController();
  final selectedFilter = 'semua'.obs;
  final selectedMonthKey = 'semua'.obs;
  final searchQuery = ''.obs;
  final tagihanList = <TagihanModel>[].obs;
  final filteredTagihanList = <TagihanModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTagihanData();
  }

  Future<void> loadTagihanData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final rows = await _supabaseService.getTagihanList();
      final mapped = rows.map((row) {
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);

        return TagihanModel(
          id: row['id']?.toString() ?? '',
          namaPenghuni: (row['nama_penghuni'] ?? 'Penghuni').toString(),
          namaKost: (row['nama_kost'] ?? '-').toString(),
          nomorKamar: (row['nomor_kamar'] ?? '-').toString(),
          bulan: bulan,
          tahun: tahun,
          tanggalJatuhTempo: _formatPeriode(bulan, tahun),
          jumlahTagihan: _toDouble(row['jumlah']),
          status: _normalizeStatus(row['status']?.toString()),
        );
      }).toList();

      tagihanList.assignAll(mapped);

      // Default to all months so historical and newly generated bills are shown together.
      selectedMonthKey.value = 'semua';

      _applyFilters();
    } catch (_) {
      errorMessage.value = 'Gagal memuat data tagihan.';
      selectedMonthKey.value = 'semua';
      tagihanList.clear();
      filteredTagihanList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterTagihan() {
    _applyFilters();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void changeMonthFilter(String monthKey) {
    selectedMonthKey.value = monthKey;
    _applyFilters();
  }

  void searchTagihan(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  int getTotalTagihan() {
    return tagihanList.length;
  }

  int getCountByStatus(String status) {
    final monthScoped = tagihanList.where(_matchesSelectedMonth);
    if (status == 'semua') return monthScoped.length;
    return monthScoped.where((tagihan) => tagihan.status == status).length;
  }

  List<String> get monthFilterKeys {
    final keys = <String>{};
    for (final tagihan in tagihanList) {
      if (tagihan.bulan < 1 || tagihan.bulan > 12 || tagihan.tahun <= 0) {
        continue;
      }
      keys.add(_buildMonthKey(tagihan.bulan, tagihan.tahun));
    }

    final sorted = keys.toList()..sort((a, b) => b.compareTo(a));
    return ['semua', ...sorted];
  }

  String getMonthFilterLabel(String monthKey) {
    if (monthKey == 'semua') return 'Semua Bulan';

    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;

    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    return _formatPeriode(month, year);
  }

  void _applyFilters() {
    final query = searchQuery.value;
    final filter = selectedFilter.value;

    final result = tagihanList.where((tagihan) {
      final matchMonth = _matchesSelectedMonth(tagihan);
      final matchFilter = filter == 'semua' || tagihan.status == filter;
      final matchQuery =
          query.isEmpty ||
          tagihan.namaPenghuni.toLowerCase().contains(query) ||
          tagihan.nomorKamar.toLowerCase().contains(query) ||
          tagihan.namaKost.toLowerCase().contains(query);
      return matchMonth && matchFilter && matchQuery;
    }).toList();

    filteredTagihanList.assignAll(result);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPeriode(int bulan, int tahun) {
    if (bulan < 1 || bulan > 12 || tahun <= 0) return '-';
    const namaBulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${namaBulan[bulan]} $tahun';
  }

  bool _matchesSelectedMonth(TagihanModel tagihan) {
    final selected = selectedMonthKey.value;
    if (selected == 'semua') return true;
    return _buildMonthKey(tagihan.bulan, tagihan.tahun) == selected;
  }

  String _buildMonthKey(int bulan, int tahun) {
    return '$tahun-${bulan.toString().padLeft(2, '0')}';
  }

  String _normalizeStatus(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    if (s == 'lunas') return 'lunas';
    if (s == 'menunggu_verifikasi') return 'menunggu_verifikasi';
    return 'belum_dibayar';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
