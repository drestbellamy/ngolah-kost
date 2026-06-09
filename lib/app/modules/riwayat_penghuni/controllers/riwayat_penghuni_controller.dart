import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../repositories/kost_repository.dart';
import '../../../../repositories/kamar_repository.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/repository_factory.dart';

class RiwayatPenghuniController extends GetxController {
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;
  final kostList = <Map<String, dynamic>>[].obs;
  final selectedKostId = RxnString();

  final KostRepository _kostRepository;
  final KamarRepository _kamarRepository;
  final PenghuniRepository _penghuniRepository;

  RiwayatPenghuniController({
    KostRepository? kostRepository,
    KamarRepository? kamarRepository,
    PenghuniRepository? penghuniRepository,
  }) : _kostRepository = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _kamarRepository = kamarRepository ?? RepositoryFactory.instance.kamarRepository,
       _penghuniRepository = penghuniRepository ?? RepositoryFactory.instance.penghuniRepository;

  @override
  void onInit() {
    super.onInit();
    loadRiwayatData();
  }

  Future<void> loadRiwayatData() async {
    try {
      isLoading.value = true;

      final kosts = await _kostRepository.getKostList();
      final allRiwayat = <Map<String, dynamic>>[];

      for (final kost in kosts) {
        final kamarList = await _kamarRepository.getKamarByKostId(kost.id);

        for (final kamar in kamarList) {
          final kamarId = kamar['id']?.toString() ?? '';
          if (kamarId.isEmpty) continue;

          final penghuniList = await _penghuniRepository.getPenghuniByKamarId(
            kamarId,
            onlyActive: false,
          );

          for (final penghuni in penghuniList) {
            final status = penghuni['status']?.toString().toLowerCase() ?? '';
            if (status == 'berakhir') {
              final userData = penghuni['users'] is Map
                  ? Map<String, dynamic>.from(penghuni['users'] as Map)
                  : <String, dynamic>{};

              allRiwayat.add({
                'id': penghuni['id']?.toString() ?? '',
                'nama': (userData['nama'] ?? 'Penghuni').toString(),
                'namaKost': kost.name,
                'kostId': kost.id,
                'noKamar': (kamar['no_kamar'] ?? '-').toString(),
                'tanggalKeluar': _formatDate(penghuni['tanggal_keluar']),
                'tanggalMasuk': _formatDate(penghuni['tanggal_masuk']),
                'sewaBulanan': kamar['harga']?.toString() ?? '0',
                'durasiKontrak': penghuni['durasi_kontrak']?.toString() ?? '0',
              });
            }
          }
        }
      }

      // Build kost list with count
      final kostCountMap = <String, int>{};
      for (final riwayat in allRiwayat) {
        final kostId = riwayat['kostId']?.toString() ?? '';
        kostCountMap[kostId] = (kostCountMap[kostId] ?? 0) + 1;
      }

      kostList.value = [
        {
          'id': null,
          'nama': 'Semua Kost',
          'count': allRiwayat.length,
        },
        ...kosts.map((kost) => {
              'id': kost.id,
              'nama': kost.name,
              'count': kostCountMap[kost.id] ?? 0,
            }),
      ];

      riwayatList.value = allRiwayat;
      filteredRiwayatList.value = allRiwayat;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data riwayat: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByKost(String? kostId) {
    selectedKostId.value = kostId;
    _applyFilters();
  }

  void searchRiwayat(String query) {
    _applyFilters(searchQuery: query);
  }

  void _applyFilters({String? searchQuery}) {
    var result = riwayatList.toList();

    // Filter by kost
    if (selectedKostId.value != null) {
      result = result.where((item) {
        return item['kostId'] == selectedKostId.value;
      }).toList();
    }

    // Filter by search query
    final query = searchQuery ?? searchController.text;
    if (query.isNotEmpty) {
      result = result.where((item) {
        final nama = item['nama']?.toString().toLowerCase() ?? '';
        final kost = item['namaKost']?.toString().toLowerCase() ?? '';
        final kamar = item['noKamar']?.toString().toLowerCase() ?? '';
        return nama.contains(query.toLowerCase()) ||
            kost.contains(query.toLowerCase()) ||
            kamar.contains(query.toLowerCase());
      }).toList();
    }

    filteredRiwayatList.value = result;
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    
    try {
      final dateStr = date.toString();
      final parsedDate = DateTime.parse(dateStr);
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${parsedDate.day} ${months[parsedDate.month]} ${parsedDate.year}';
    } catch (e) {
      return date.toString();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
