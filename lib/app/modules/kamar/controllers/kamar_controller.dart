import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kamar_repository.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../kost/models/kost_model.dart';
import '../views/widgets/tambah_kamar_bottom_sheet.dart';
import '../views/widgets/edit_kamar_bottom_sheet.dart';
import '../views/widgets/hapus_kamar_dialog.dart';

class KamarController extends GetxController {
  final KamarRepository _kamarRepo;
  final PenghuniRepository _penghuniRepo;

  KamarController({
    KamarRepository? kamarRepository,
    PenghuniRepository? penghuniRepository,
  }) : _kamarRepo =
           kamarRepository ?? RepositoryFactory.instance.kamarRepository,
       _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository;
  final NumberFormat _idrFormatter = NumberFormat.decimalPattern('id_ID');
  final selectedTab = 0.obs;
  final isSortAsc = true.obs;
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
      final response = await _kamarRepo.getKamarByKostId(_kostId!);
      final mapped = response.map((item) {
        final status = _normalizeStatus(item['status']?.toString());
        final kapasitas = _toInt(item['kapasitas'], fallback: 1);
        return {
          'id': item['id']?.toString() ?? '',
          'namaKost': namaKost.value,
          'nomor': item['no_kamar']?.toString() ?? '-',
          'status': status,
          'penghuni': null,
          'kapasitas': kapasitas,
          'terisi': status == 'Kosong' ? 0 : 1,
          'harga': _formatHargaDisplay(_toInt(item['harga'])),
          'statusColor': _statusColor(status),
        };
      }).toList();

      await _syncOccupancyFromPenghuni(mapped);
      kamarList.assignAll(mapped);
      _recalculateStats();
    } catch (e) {
      ToastHelper.showError(
        'Gagal memuat data kamar. Exception: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncOccupancyFromPenghuni(
    List<Map<String, dynamic>> rooms,
  ) async {
    final tasks = rooms.map((room) async {
      final kamarId = room['id']?.toString() ?? '';
      if (kamarId.isEmpty) return;

      final kapasitas = _toInt(room['kapasitas'], fallback: 1);
      final count = await _penghuniRepo.getPenghuniCountByKamarId(kamarId);

      final normalizedCount = count > kapasitas ? kapasitas : count;
      final status = _statusByOccupancy(normalizedCount, kapasitas);

      room['terisi'] = normalizedCount;
      room['status'] = status;
      room['statusColor'] = _statusColor(status);
    });

    await Future.wait(tasks);
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _extractRoomNumber(Map<String, dynamic> room) {
    final nomor = room['nomor']?.toString() ?? '';
    final match = RegExp(r'\d+').firstMatch(nomor);
    if (match == null) return 0;
    return int.tryParse(match.group(0) ?? '') ?? 0;
  }

  int _compareRooms(Map<String, dynamic> a, Map<String, dynamic> b) {
    final numberA = _extractRoomNumber(a);
    final numberB = _extractRoomNumber(b);
    if (numberA != numberB) {
      return numberA.compareTo(numberB);
    }

    final labelA = a['nomor']?.toString() ?? '';
    final labelB = b['nomor']?.toString() ?? '';
    return labelA.compareTo(labelB);
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
    if (normalized == 'penuh') return 'Penuh';
    if (normalized == 'terisi sebagian') return 'Terisi Sebagian';
    return normalized == 'ditempati' ? 'Terisi Sebagian' : 'Kosong';
  }

  String _statusByOccupancy(int terisi, int kapasitas) {
    if (terisi <= 0) return 'Kosong';
    if (terisi >= kapasitas) return 'Penuh';
    return 'Terisi Sebagian';
  }

  Color _statusColor(String status) {
    if (status == 'Penuh') return const Color(0xFF10B981);
    if (status == 'Terisi Sebagian') return const Color(0xFF3B82F6);
    return const Color(0xFFF2A65A);
  }

  bool _isOccupiedStatus(String status) {
    return status == 'Terisi Sebagian' || status == 'Penuh';
  }

  void _recalculateStats() {
    totalRuangan.value = kamarList.length;
    ditempati.value = kamarList
        .where((k) => _isOccupiedStatus(k['status']?.toString() ?? 'Kosong'))
        .length;
    kosong.value = kamarList.where((k) => k['status'] == 'Kosong').length;
    totalPenghuni.value = kamarList.fold<int>(
      0,
      (total, kamar) => total + _toInt(kamar['terisi']),
    );
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void toggleSortOrder() {
    isSortAsc.value = !isSortAsc.value;
  }

  List<Map<String, dynamic>> get filteredKamar {
    List<Map<String, dynamic>> filtered;
    if (selectedTab.value == 0) {
      filtered = List<Map<String, dynamic>>.from(kamarList);
    } else if (selectedTab.value == 1) {
      filtered = kamarList.where((k) => k['status'] == 'Kosong').toList();
    } else if (selectedTab.value == 2) {
      filtered = kamarList
          .where((k) => k['status'] == 'Terisi Sebagian')
          .toList();
    } else {
      filtered = kamarList.where((k) => k['status'] == 'Penuh').toList();
    }

    filtered.sort(_compareRooms);
    if (!isSortAsc.value) {
      filtered = filtered.reversed.toList();
    }

    return filtered;
  }

  void goBack() {
    Get.back();
  }

  Future<void> navigateToInformasiKamar(Map<String, dynamic> kamar) async {
    // Navigasi ke informasi kamar untuk kamar terisi atau kosong
    await Get.toNamed('/informasi-kamar', arguments: kamar);
    await fetchKamarData();
  }

  void tambahKamar() async {
    final result = await Get.dialog(const TambahKamarBottomSheet());

    if (result != null) {
      if (_kostId == null) return;

      try {
        await _kamarRepo.createKamar(
          kostId: _kostId!,
          noKamar: result['nomor'],
          harga: _hargaToInt(result['harga'].toString()),
          kapasitas: _toInt(result['kapasitas'], fallback: 1),
          status: 'kosong',
        );

        await fetchKamarData();
        ToastHelper.showSuccess(
          'Kamar ${result['nomor']} berhasil ditambahkan',
        );
      } catch (e) {
        ToastHelper.showError(
          'Gagal menambahkan kamar. Exception: ${e.toString()}',
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
        await _kamarRepo.updateKamar(
          id: kamarId,
          noKamar: result['nomor'],
          harga: _hargaToInt(result['harga'].toString()),
          kapasitas: _toInt(result['kapasitas'], fallback: 1),
          status: kamar['status'] == 'Kosong' ? 'kosong' : 'ditempati',
        );

        await fetchKamarData();
        ToastHelper.showSuccess('Kamar berhasil diupdate');
      } catch (e) {
        ToastHelper.showError(
          'Gagal mengupdate kamar. Exception: ${e.toString()}',
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
        await _kamarRepo.deleteKamar(kamarId);
        await fetchKamarData();

        ToastHelper.showSuccess('Kamar ${kamar['nomor']} berhasil dihapus');
      } catch (e) {
        ToastHelper.showError(
          'Gagal menghapus kamar. Exception: ${e.toString()}',
        );
      }
    }
  }
}
