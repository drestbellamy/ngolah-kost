import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tagihan_model.dart';

class KelolaTagihanController extends GetxController {
  final searchController = TextEditingController();
  final selectedFilter = 'semua'.obs;
  final tagihanList = <TagihanModel>[].obs;
  final filteredTagihanList = <TagihanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    tagihanList.value = [
      TagihanModel(
        id: '1',
        namaPenghuni: 'Ahmad Wijaya',
        namaKost: 'Green Valley Kost',
        nomorKamar: 'A-101',
        tanggalJatuhTempo: '20 Mar 2026',
        jumlahTagihan: 1500000,
        status: 'lunas',
      ),
      TagihanModel(
        id: '2',
        namaPenghuni: 'Sarah Putri',
        namaKost: 'Green Valley Kost',
        nomorKamar: 'A-103',
        tanggalJatuhTempo: '20 Mar 2026',
        jumlahTagihan: 1500000,
        status: 'menunggu_verifikasi',
      ),
      TagihanModel(
        id: '3',
        namaPenghuni: 'Budi Santoso',
        namaKost: 'Sunrise Boarding House',
        nomorKamar: 'A-104',
        tanggalJatuhTempo: '20 Mar 2026',
        jumlahTagihan: 1500000,
        status: 'belum_dibayar',
      ),
      TagihanModel(
        id: '4',
        namaPenghuni: 'Dewi Lestari',
        namaKost: 'Sunrise Boarding House',
        nomorKamar: '101',
        tanggalJatuhTempo: '20 Mar 2026',
        jumlahTagihan: 1600000,
        status: 'menunggu_verifikasi',
      ),
    ];
    filterTagihan();
  }

  void filterTagihan() {
    if (selectedFilter.value == 'semua') {
      filteredTagihanList.value = tagihanList;
    } else {
      filteredTagihanList.value = tagihanList
          .where((tagihan) => tagihan.status == selectedFilter.value)
          .toList();
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    filterTagihan();
  }

  void searchTagihan(String query) {
    if (query.isEmpty) {
      filterTagihan();
    } else {
      filteredTagihanList.value = tagihanList.where((tagihan) {
        return tagihan.namaPenghuni.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            tagihan.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
            tagihan.namaKost.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  int getTotalTagihan() {
    return tagihanList.length;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
