import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/penghuni_model.dart';

class PenghuniController extends GetxController {
  final RxList<PenghuniModel> penghuniList = <PenghuniModel>[].obs;
  final RxList<PenghuniModel> filteredPenghuniList = <PenghuniModel>[].obs;
  final searchController = TextEditingController();
  final selectedFilter = 'Semua Kost'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPenghuniData();
  }

  void loadPenghuniData() {
    // Data dummy untuk contoh
    penghuniList.value = [
      PenghuniModel(
        id: '1',
        nama: 'Ahmad Wijaya',
        noTelepon: '081234567890',
        nomorKamar: 'A-101',
        namaKost: 'Green Valley Kost',
        sewaBulanan: 1500000,
        tanggalMasuk: '15 Jan 2024',
        durasiKontrak: 12,
        sistemPembayaran: 'Bulanan (1 bulan)',
        tanggalBerakhir: '15 Januari 2025',
        totalNilaiKontrak: 18000000,
      ),
      PenghuniModel(
        id: '2',
        nama: 'Sarah Putri',
        noTelepon: '081234567891',
        nomorKamar: 'A-103',
        namaKost: 'Green Valley Kost',
        sewaBulanan: 1500000,
        tanggalMasuk: '01 Feb 2024',
        durasiKontrak: 12,
        sistemPembayaran: 'Bulanan (1 bulan)',
        tanggalBerakhir: '01 Februari 2025',
        totalNilaiKontrak: 18000000,
      ),
      PenghuniModel(
        id: '3',
        nama: 'Budi Santoso',
        noTelepon: '081234567892',
        nomorKamar: 'A-104',
        namaKost: 'Green Valley Kost',
        sewaBulanan: 1500000,
        tanggalMasuk: '01 Des 2023',
        durasiKontrak: 12,
        sistemPembayaran: 'Bulanan (1 bulan)',
        tanggalBerakhir: '01 Desember 2024',
        totalNilaiKontrak: 18000000,
      ),
      PenghuniModel(
        id: '4',
        nama: 'Dewi Lestari',
        noTelepon: '081234567893',
        nomorKamar: '101',
        namaKost: 'Sunrise Boarding House',
        sewaBulanan: 1600000,
        tanggalMasuk: '20 Jan 2024',
        durasiKontrak: 12,
        sistemPembayaran: 'Bulanan (1 bulan)',
        tanggalBerakhir: '20 Januari 2025',
        totalNilaiKontrak: 19200000,
      ),
    ];
    filteredPenghuniList.value = penghuniList;
  }

  void searchPenghuni(String query) {
    if (query.isEmpty) {
      filteredPenghuniList.value = penghuniList;
    } else {
      filteredPenghuniList.value = penghuniList.where((penghuni) {
        return penghuni.nama.toLowerCase().contains(query.toLowerCase()) ||
            penghuni.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
            penghuni.namaKost.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void filterByKost(String kostName) {
    selectedFilter.value = kostName;
    if (kostName == 'Semua Kost') {
      filteredPenghuniList.value = penghuniList;
    } else {
      filteredPenghuniList.value = penghuniList.where((penghuni) {
        return penghuni.namaKost == kostName;
      }).toList();
    }
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
