import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TambahPenghuniController extends GetxController {
  // Step management
  final currentStep = 1.obs;

  // Room info
  final nomorKamar = ''.obs;
  final namaKost = ''.obs;
  final hargaPerBulan = ''.obs;
  final hargaBulanan = 0.obs;

  // Step 1 - Data Pribadi & Akun
  final namaController = TextEditingController();
  final teleponController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Step 2 - Informasi Kontrak
  final tanggalMasuk = ''.obs;
  final tanggalMasukDate = Rx<DateTime?>(null);
  final durasiKontrak = ''.obs;
  final durasiKontrakBulan = 0.obs;
  final sistemPembayaran = ''.obs;
  final sistemPembayaranBulan = 0.obs;
  final tanggalBerakhir = ''.obs;

  // Durasi options
  final durasiOptions = [
    '1 Bulan',
    '3 Bulan',
    '6 Bulan',
    '12 Bulan ( 1 Tahun )',
    '24 Bulan ( 2 Tahun )',
  ];

  // Sistem pembayaran options (dynamic based on durasi)
  final sistemPembayaranOptions = <String>[].obs;

  // Calculated values
  final totalKontrak = ''.obs;
  final sistemPembayaranLabel = ''.obs;
  final jumlahTagihan = ''.obs;
  final perTagihan = ''.obs;
  final totalNilaiKontrak = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load data from arguments
    if (Get.arguments != null) {
      final kamar = Get.arguments as Map<String, dynamic>;
      nomorKamar.value = kamar['nomor'] ?? '';
      namaKost.value = 'Green Valley Kost';
      hargaPerBulan.value = kamar['harga'] ?? '';

      // Extract numeric value from harga
      final hargaStr = hargaPerBulan.value.replaceAll(RegExp(r'[^0-9]'), '');
      hargaBulanan.value = int.tryParse(hargaStr) ?? 0;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    teleponController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void handleBack() {
    if (currentStep.value == 1) {
      Get.back();
    } else {
      currentStep.value = 1;
    }
  }

  void handleNext() {
    if (currentStep.value == 1) {
      if (_validateStep1()) {
        currentStep.value = 2;
      }
    } else {
      if (_validateStep2()) {
        _submitForm();
      }
    }
  }

  bool _validateStep1() {
    if (namaController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama lengkap harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (teleponController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor telepon harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (usernameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    if (tanggalMasuk.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Tanggal mulai masuk harus dipilih',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (durasiKontrak.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Durasi kontrak harus dipilih',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (sistemPembayaran.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Sistem pembayaran harus dipilih',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void _submitForm() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 32,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Penghuni Berhasil Ditambahkan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Penghuni ${namaController.text} telah berhasil ditambahkan ke ${nomorKamar.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog

                    // Kembalikan data penghuni baru ke halaman sebelumnya (Informasi Kamar)
                    Get.back(
                      result: {
                        'nama': namaController.text,
                        'telepon': teleponController.text,
                        'username': '@${usernameController.text}',
                        'statusKontrak': 'Aktif',
                        'durasiKontrak': durasiKontrak.value,
                        'siklusBayar': sistemPembayaran.value,
                        'tanggalMulai': tanggalMasuk.value,
                        'tanggalBerakhir': tanggalBerakhir.value,
                        'hargaSewa': perTagihan.value,
                        'isExpanded': false,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void setTanggalMasuk(DateTime date) {
    tanggalMasukDate.value = date;
    // Format: 27 Maret 2026
    final months = [
      '',
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
    tanggalMasuk.value = '${date.day} ${months[date.month]} ${date.year}';
    _calculateTanggalBerakhir();
  }

  void setDurasiKontrak(String durasi) {
    durasiKontrak.value = durasi;

    // Extract months from durasi
    if (durasi.contains('1 Bulan')) {
      durasiKontrakBulan.value = 1;
    } else if (durasi.contains('3 Bulan')) {
      durasiKontrakBulan.value = 3;
    } else if (durasi.contains('6 Bulan')) {
      durasiKontrakBulan.value = 6;
    } else if (durasi.contains('12 Bulan')) {
      durasiKontrakBulan.value = 12;
    } else if (durasi.contains('24 Bulan')) {
      durasiKontrakBulan.value = 24;
    }

    // Update sistem pembayaran options based on durasi
    _updateSistemPembayaranOptions();

    // Reset sistem pembayaran
    sistemPembayaran.value = '';
    sistemPembayaranBulan.value = 0;

    // Calculate tanggal berakhir
    _calculateTanggalBerakhir();

    // Update total kontrak
    totalKontrak.value = '${durasiKontrakBulan.value} bulan';
  }

  void _updateSistemPembayaranOptions() {
    sistemPembayaranOptions.clear();

    final durasi = durasiKontrakBulan.value;

    // Always include 1 bulan
    sistemPembayaranOptions.add('1 Bulan');

    // Add options based on durasi
    if (durasi >= 3) {
      sistemPembayaranOptions.add('3 Bulan');
    }
    if (durasi >= 6) {
      sistemPembayaranOptions.add('6 Bulan');
    }
    if (durasi >= 12) {
      sistemPembayaranOptions.add('12 Bulan ( 1 Tahun )');
    }
    if (durasi >= 24) {
      sistemPembayaranOptions.add('24 Bulan ( 2 Tahun )');
    }
  }

  void setSistemPembayaran(String sistem) {
    sistemPembayaran.value = sistem;

    // Extract months from sistem
    if (sistem.contains('1 Bulan')) {
      sistemPembayaranBulan.value = 1;
      sistemPembayaranLabel.value = 'Bulanan (1 bulan)';
    } else if (sistem.contains('3 Bulan')) {
      sistemPembayaranBulan.value = 3;
      sistemPembayaranLabel.value = '3 Bulanan';
    } else if (sistem.contains('6 Bulan')) {
      sistemPembayaranBulan.value = 6;
      sistemPembayaranLabel.value = '6 Bulanan';
    } else if (sistem.contains('12 Bulan')) {
      sistemPembayaranBulan.value = 12;
      sistemPembayaranLabel.value = 'Tahunan (1 tahun)';
    } else if (sistem.contains('24 Bulan')) {
      sistemPembayaranBulan.value = 24;
      sistemPembayaranLabel.value = '2 Tahunan';
    }

    _calculatePayment();
  }

  void _calculateTanggalBerakhir() {
    if (tanggalMasukDate.value != null && durasiKontrakBulan.value > 0) {
      final endDate = DateTime(
        tanggalMasukDate.value!.year,
        tanggalMasukDate.value!.month + durasiKontrakBulan.value,
        tanggalMasukDate.value!.day,
      );
      // Format: 27 Maret 2027
      final months = [
        '',
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
      tanggalBerakhir.value =
          '${endDate.day} ${months[endDate.month]} ${endDate.year}';
    }
  }

  void _calculatePayment() {
    if (durasiKontrakBulan.value > 0 && sistemPembayaranBulan.value > 0) {
      // Calculate number of payments
      final numPayments =
          (durasiKontrakBulan.value / sistemPembayaranBulan.value).ceil();
      jumlahTagihan.value = '${numPayments}x tagihan';

      // Calculate per payment
      final perPayment = hargaBulanan.value * sistemPembayaranBulan.value;
      perTagihan.value = _formatCurrency(perPayment);

      // Calculate total
      final total = hargaBulanan.value * durasiKontrakBulan.value;
      totalNilaiKontrak.value = _formatCurrency(total);
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
