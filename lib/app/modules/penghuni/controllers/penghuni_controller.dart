import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kost_repository.dart';
import '../../../../repositories/kamar_repository.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../models/penghuni_model.dart';

class PenghuniController extends GetxController {
  final KostRepository _kostRepo;
  final KamarRepository _kamarRepo;
  final PenghuniRepository _penghuniRepo;

  PenghuniController({
    KostRepository? kostRepository,
    KamarRepository? kamarRepository,
    PenghuniRepository? penghuniRepository,
  }) : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _kamarRepo =
           kamarRepository ?? RepositoryFactory.instance.kamarRepository,
       _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository;
  final RxList<PenghuniModel> penghuniList = <PenghuniModel>[].obs;
  final RxList<PenghuniModel> filteredPenghuniList = <PenghuniModel>[].obs;
  final RxList<String> allKostNames = <String>[].obs;
  final RxMap<String, int> kostCounts = <String, int>{}.obs;
  final searchController = TextEditingController();
  final selectedFilter = 'Semua Kost'.obs;
  final searchQuery = ''.obs;
  final isSortAsc = true.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPenghuniData();
  }

  Future<void> loadPenghuniData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final kosts = await _kostRepo.getKostList();
      final names =
          kosts
              .map((k) => k.name.trim())
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      allKostNames.assignAll(names);
      kostCounts.assignAll({for (final name in names) name: 0});

      if (selectedFilter.value != 'Semua Kost' &&
          !allKostNames.contains(selectedFilter.value)) {
        selectedFilter.value = 'Semua Kost';
      }

      final merged = <PenghuniModel>[];

      for (final kost in kosts) {
        final kamarList = await _kamarRepo.getKamarByKostId(kost.id);

        for (final kamar in kamarList) {
          final kamarId = kamar['id']?.toString() ?? '';
          if (kamarId.isEmpty) continue;

          final penghuniRows = await _penghuniRepo.getPenghuniByKamarId(
            kamarId,
            onlyActive: true,
          );

          for (final row in penghuniRows) {
            final user = row['users'] is Map
                ? Map<String, dynamic>.from(row['users'] as Map)
                : <String, dynamic>{};

            final durasi = _toInt(row['durasi_kontrak']);
            final siklusBulanRaw = _toInt(row['sistem_pembayaran_bulan']);
            final siklusBulan = siklusBulanRaw <= 0 ? 1 : siklusBulanRaw;
            final harga = _toDouble(kamar['harga']);

            // Format data baru
            final tanggalLahirDate = DateTime.tryParse(
              row['tanggal_lahir']?.toString() ?? '',
            );

            merged.add(
              PenghuniModel(
                id: row['id']?.toString() ?? '',
                nama: (user['nama'] ?? row['nama'] ?? 'Penghuni').toString(),
                noTelepon: (user['no_tlpn'] ?? row['no_tlpn'] ?? '-')
                    .toString(),
                nomorKamar: (kamar['no_kamar'] ?? '-').toString(),
                namaKost: kost.name.trim().isEmpty ? '-' : kost.name.trim(),
                sewaBulanan: harga,
                tanggalMasuk: _formatDate(row['tanggal_masuk']),
                durasiKontrak: durasi,
                sistemPembayaran: _formatSistemPembayaran(siklusBulan),
                tanggalBerakhir: _formatDate(row['tanggal_keluar']),
                totalNilaiKontrak: harga * durasi,
                historyPembayaran: const [],
                // New fields
                nomorKtp: row['nomor_ktp']?.toString(),
                jenisKelamin: row['jenis_kelamin']?.toString(),
                tanggalLahir: tanggalLahirDate != null
                    ? _formatDate(row['tanggal_lahir'])
                    : null,
                alamatAsal: row['alamat_asal']?.toString(),
                namaKontakDarurat: row['nama_kontak_darurat']?.toString(),
                teleponKontakDarurat: row['telepon_kontak_darurat']?.toString(),
                hubunganKontakDarurat: row['hubungan_kontak_darurat']
                    ?.toString(),
              ),
            );
          }
        }
      }

      penghuniList.assignAll(merged);
      _syncKostCounts();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data penghuni';
      allKostNames.clear();
      kostCounts.clear();
      selectedFilter.value = 'Semua Kost';
      penghuniList.clear();
      filteredPenghuniList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void searchPenghuni(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  void filterByKost(String kostName) {
    selectedFilter.value = kostName.trim();
    _applyFilters();
  }

  void toggleSortOrder() {
    isSortAsc.value = !isSortAsc.value;
    _applyFilters();
  }

  List<String> get kostFilterOptions {
    final sorted = List<String>.from(allKostNames);
    sorted.sort((a, b) {
      final countA = kostCounts[a] ?? 0;
      final countB = kostCounts[b] ?? 0;

      if (countA != countB) {
        return countB.compareTo(countA);
      }

      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return ['Semua Kost', ...sorted];
  }

  String get emptyStateText {
    if (searchQuery.value.isNotEmpty) {
      return 'Tidak ada penghuni yang cocok dengan pencarian.';
    }
    if (selectedFilter.value != 'Semua Kost') {
      return 'Belum ada penghuni di kost ${selectedFilter.value}.';
    }
    return 'Belum ada data penghuni.';
  }

  void _applyFilters() {
    final activeFilter = selectedFilter.value;
    final query = searchQuery.value;
    final normalizedFilter = _normalizeKostName(activeFilter);

    final result = penghuniList.where((penghuni) {
      final matchKost =
          activeFilter == 'Semua Kost' ||
          _normalizeKostName(penghuni.namaKost) == normalizedFilter;
      final matchQuery =
          query.isEmpty ||
          penghuni.nama.toLowerCase().contains(query) ||
          penghuni.nomorKamar.toLowerCase().contains(query) ||
          _normalizeKostName(penghuni.namaKost).contains(query);
      return matchKost && matchQuery;
    }).toList();

    result.sort(_compareByRoom);
    if (!isSortAsc.value) {
      filteredPenghuniList.assignAll(result.reversed);
      return;
    }

    filteredPenghuniList.assignAll(result);
  }

  int getPenghuniCountByKost(String kostName) {
    final trimmed = kostName.trim();
    if (trimmed == 'Semua Kost') return penghuniList.length;
    return kostCounts[trimmed] ?? 0;
  }

  String getRoomDisplayLabel(PenghuniModel penghuni) {
    return penghuni.nomorKamar;
  }

  String getOccupancyStatusLabel(PenghuniModel penghuni) {
    final roomMembers = penghuniList
        .where((item) => _isSameRoom(item, penghuni))
        .toList();

    final total = roomMembers.length;
    if (total <= 1) return 'Terisi';

    final sequence = _getSequenceInRoom(roomMembers, penghuni);
    return 'Penghuni $sequence/$total';
  }

  void _syncKostCounts() {
    final next = <String, int>{for (final name in allKostNames) name: 0};

    for (final penghuni in penghuniList) {
      final key = allKostNames.firstWhereOrNull(
        (name) =>
            _normalizeKostName(name) == _normalizeKostName(penghuni.namaKost),
      );
      if (key == null) continue;
      next[key] = (next[key] ?? 0) + 1;
    }

    kostCounts.assignAll(next);
  }

  bool _isSameRoom(PenghuniModel a, PenghuniModel b) {
    return _normalizeKostName(a.namaKost) == _normalizeKostName(b.namaKost) &&
        a.nomorKamar.trim().toLowerCase() == b.nomorKamar.trim().toLowerCase();
  }

  int _getSequenceInRoom(
    List<PenghuniModel> roomMembers,
    PenghuniModel target,
  ) {
    for (var i = 0; i < roomMembers.length; i++) {
      if (identical(roomMembers[i], target)) {
        return i + 1;
      }
    }

    final targetId = target.id.trim();
    if (targetId.isNotEmpty) {
      for (var i = 0; i < roomMembers.length; i++) {
        if (roomMembers[i].id.trim() == targetId) {
          return i + 1;
        }
      }
    }

    return 1;
  }

  String _normalizeKostName(String name) {
    return name.trim().toLowerCase();
  }

  String _formatSistemPembayaran(int bulan) {
    if (bulan <= 1) return 'Bulanan (1 bulan)';
    if (bulan == 3) return '3 Bulanan';
    if (bulan == 6) return '6 Bulanan';
    if (bulan == 12) return 'Tahunan (1 tahun)';
    if (bulan == 24) return '2 Tahunan';
    return '$bulan Bulanan';
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _extractRoomNumber(String noKamar) {
    final match = RegExp(r'\d+').firstMatch(noKamar);
    if (match == null) return 0;
    return int.tryParse(match.group(0) ?? '') ?? 0;
  }

  int _compareByRoom(PenghuniModel a, PenghuniModel b) {
    final numberA = _extractRoomNumber(a.nomorKamar);
    final numberB = _extractRoomNumber(b.nomorKamar);
    if (numberA != numberB) {
      return numberA.compareTo(numberB);
    }

    final roomA = a.nomorKamar.toLowerCase();
    final roomB = b.nomorKamar.toLowerCase();
    if (roomA != roomB) {
      return roomA.compareTo(roomB);
    }

    return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString() ?? '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  }

  void goToDetail(PenghuniModel penghuni) {
    Get.toNamed('/penghuni/detail', arguments: penghuni);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
