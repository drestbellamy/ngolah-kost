import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/supabase_service.dart';
import '../../kost/models/kost_model.dart';
import '../views/widgets/tambah_kamar_bottom_sheet.dart';
import '../views/widgets/edit_kamar_bottom_sheet.dart';
import '../views/widgets/hapus_kamar_dialog.dart';

class KamarController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final NumberFormat _idrFormatter = NumberFormat.decimalPattern('id_ID');
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  String? _kostId;

  // Data kost
  final namaKost = ''.obs;
  final alamatKost = ''.obs;
  final totalRuangan = 0.obs;
  final ditempati = 0.obs;
  final kosong = 0.obs;
  final totalPenghuni = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data kost dari arguments yang dikirim dari halaman kost
    final args = Get.arguments;
    if (args != null && args is KostModel) {
      _kostId = args.id;
      namaKost.value = args.name;
      alamatKost.value = args.address;
      fetchKamarData();
    }
  }

  // List kamar
  final kamarList = <Map<String, dynamic>>[].obs;

  Future<void> fetchKamarData() async {
    if (_kostId == null) return;

    isLoading.value = true;
    try {
      final response = await _supabaseService.getKamarByKostId(_kostId!);
      final mapped = response.map((item) {
        final status = _normalizeStatus(item['status']?.toString());
        final kapasitas = _toInt(item['kapasitas'], fallback: 1);
        return {
          'id': item['id']?.toString() ?? '',
          'nomor': item['no_kamar']?.toString() ?? '-',
          'status': status,
          'penghuni': null,
          'kapasitas': kapasitas,
          'terisi': status == 'Ditempati' ? 1 : 0,
          'harga': _formatHargaDisplay(_toInt(item['harga'])),
          'statusColor': status == 'Ditempati'
              ? const Color(0xFF10B981)
              : const Color(0xFFF2A65A),
        };
      }).toList();

      kamarList.assignAll(mapped);
      _recalculateStats();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data kamar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _hargaToInt(String value) {
    final numeric = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numeric) ?? 0;
  }

  String _formatHargaDisplay(int value) {
    return 'Rp ${_idrFormatter.format(value)}/Bulan';
  }

  String _normalizeStatus(String? status) {
    final normalized = status?.toLowerCase().trim() ?? 'kosong';
    return normalized == 'ditempati' ? 'Ditempati' : 'Kosong';
  }

  void _recalculateStats() {
    totalRuangan.value = kamarList.length;
    ditempati.value = kamarList.where((k) => k['status'] == 'Ditempati').length;
    kosong.value = kamarList.where((k) => k['status'] == 'Kosong').length;
    totalPenghuni.value = kamarList.fold<int>(
      0,
      (total, kamar) => total + _toInt(kamar['terisi']),
    );
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  List<Map<String, dynamic>> get filteredKamar {
    if (selectedTab.value == 0) {
      return kamarList;
    } else if (selectedTab.value == 1) {
      return kamarList.where((k) => k['status'] == 'Kosong').toList();
    } else {
      return kamarList.where((k) => k['status'] == 'Ditempati').toList();
    }
  }

  void goBack() {
    Get.back();
  }

  void navigateToInformasiKamar(Map<String, dynamic> kamar) {
    // Navigasi ke informasi kamar untuk kamar terisi atau kosong
    Get.toNamed('/informasi-kamar', arguments: kamar);
  }

  void tambahKamar() async {
    final result = await Get.dialog(const TambahKamarBottomSheet());

    if (result != null) {
      if (_kostId == null) return;

      try {
        await _supabaseService.createKamar(
          kostId: _kostId!,
          noKamar: result['nomor'],
          harga: _hargaToInt(result['harga'].toString()),
          kapasitas: _toInt(result['kapasitas'], fallback: 1),
          status: 'kosong',
        );

        await fetchKamarData();
        Get.snackbar(
          'Berhasil',
          'Kamar ${result['nomor']} berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menambahkan kamar: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void editKamar(Map<String, dynamic> kamar) async {
    final result = await Get.dialog(EditKamarBottomSheet(kamar: kamar));

    if (result != null) {
      final kamarId = kamar['id']?.toString();
      if (kamarId == null || kamarId.isEmpty) return;

      try {
        await _supabaseService.updateKamar(
          id: kamarId,
          noKamar: result['nomor'],
          harga: _hargaToInt(result['harga'].toString()),
          kapasitas: _toInt(result['kapasitas'], fallback: 1),
          status: kamar['status'] == 'Ditempati' ? 'ditempati' : 'kosong',
        );

        await fetchKamarData();
        Get.snackbar(
          'Berhasil',
          'Kamar berhasil diupdate',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mengupdate kamar: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void hapusKamar(Map<String, dynamic> kamar) async {
    final result = await Get.dialog(HapusKamarDialog(kamar: kamar));

    if (result == true) {
      final kamarId = kamar['id']?.toString();
      if (kamarId == null || kamarId.isEmpty) return;

      try {
        await _supabaseService.deleteKamar(kamarId);
        await fetchKamarData();

        Get.snackbar(
          'Berhasil',
          'Kamar ${kamar['nomor']} berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menghapus kamar: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
