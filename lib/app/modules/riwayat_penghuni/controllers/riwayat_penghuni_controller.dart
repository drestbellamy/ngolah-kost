import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RiwayatPenghuniController extends GetxController {
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final riwayatList = <Map<String, dynamic>>[].obs;
  final filteredRiwayatList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRiwayatData();
  }

  Future<void> loadRiwayatData() async {
    try {
      isLoading.value = true;
      // TODO: Fetch from database
      // Mock data for now
      riwayatList.value = [];
      filteredRiwayatList.value = riwayatList;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data riwayat');
    } finally {
      isLoading.value = false;
    }
  }

  void searchRiwayat(String query) {
    if (query.isEmpty) {
      filteredRiwayatList.value = riwayatList;
    } else {
      filteredRiwayatList.value = riwayatList.where((item) {
        final nama = item['nama']?.toString().toLowerCase() ?? '';
        final kost = item['namaKost']?.toString().toLowerCase() ?? '';
        return nama.contains(query.toLowerCase()) ||
            kost.contains(query.toLowerCase());
      }).toList();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
