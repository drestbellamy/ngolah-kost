import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/penghuni_model.dart';

class KelolaKontrakController extends GetxController {
  final selectedTab = 0.obs; // 0: Perpanjang, 1: Edit, 2: Akhiri
  final isLoading = false.obs;
  final tambahanDurasi = 0.obs; // Observable untuk durasi tambahan

  // Form controllers untuk Perpanjang
  final tambahanDurasiController = TextEditingController();
  final sistemPembayaranPerpanjangController = TextEditingController();

  // Form controllers untuk Edit
  final tanggalMulaiController = TextEditingController();
  final durasiKontrakController = TextEditingController();
  final sistemPembayaranEditController = TextEditingController();

  PenghuniModel? penghuni;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is PenghuniModel) {
      penghuni = Get.arguments as PenghuniModel;
      initializeEditForm();
    }

    // Listen to text changes
    tambahanDurasiController.addListener(() {
      tambahanDurasi.value = int.tryParse(tambahanDurasiController.text) ?? 0;
    });
  }

  void initializeEditForm() {
    if (penghuni != null) {
      tanggalMulaiController.text = penghuni!.tanggalMasuk;
      durasiKontrakController.text = penghuni!.durasiKontrak.toString();
      sistemPembayaranEditController.text = penghuni!.sistemPembayaran;
    }
  }

  void changeTab(int index) {
    if (selectedTab.value != index) {
      // Tambahkan haptic feedback yang lebih halus
      HapticFeedback.lightImpact();
      selectedTab.value = index;
    }
  }

  // Fungsi Perpanjang Kontrak
  void perpanjangKontrak() {
    if (tambahanDurasiController.text.isEmpty ||
        sistemPembayaranPerpanjangController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Integrasi dengan backend
    // final response = await apiService.post('/api/kontrak/perpanjang', {...});

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Kontrak berhasil diperpanjang',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Fungsi Edit Kontrak
  void editKontrak() {
    if (tanggalMulaiController.text.isEmpty ||
        durasiKontrakController.text.isEmpty ||
        sistemPembayaranEditController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Integrasi dengan backend
    // final response = await apiService.put('/api/kontrak/${penghuni.id}', {...});

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Kontrak berhasil diperbarui',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Fungsi Akhiri Kontrak
  void akhiriKontrak() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText:
          'Penghuni akan kehilangan akses ke kamar\nData kontrak akan diarsipkan\nAkun penghuni akan dinonaktifkan',
      textConfirm: 'Akhiri Kontrak',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEF4444),
      cancelTextColor: const Color(0xFF6B7280),
      onConfirm: () {
        // TODO: Integrasi dengan backend
        // final response = await apiService.delete('/api/kontrak/${penghuni?.id}');

        Get.back(); // Close dialog
        Get.back(); // Close bottom sheet
        Get.back(); // Back to list
        Get.snackbar(
          'Berhasil',
          'Kontrak berhasil diakhiri',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      },
    );
  }

  int calculateNewDuration() {
    if (penghuni == null) return 0;
    int currentDuration = penghuni!.durasiKontrak;
    return currentDuration + tambahanDurasi.value;
  }

  double calculateNewTotal() {
    if (penghuni == null) return 0;
    int newDuration = calculateNewDuration();
    return penghuni!.sewaBulanan * newDuration;
  }

  @override
  void onClose() {
    tambahanDurasiController.dispose();
    sistemPembayaranPerpanjangController.dispose();
    tanggalMulaiController.dispose();
    durasiKontrakController.dispose();
    sistemPembayaranEditController.dispose();
    super.onClose();
  }
}
