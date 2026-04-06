import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/metode_pembayaran_model.dart';

class MetodePembayaranController extends GetxController {
  final metodePembayaranList = <MetodePembayaranModel>[].obs;
  final filteredList = <MetodePembayaranModel>[].obs;

  final selectedKost = 'Semua Kost'.obs;
  final selectedFilter = 'Semua'.obs; // 'Semua', 'Bank', 'Cash', 'QRIS'

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    metodePembayaranList.value = [
      MetodePembayaranModel(
        id: '1',
        nama: 'BCA',
        jenis: 'bank',
        nomorRekening: '7890',
        namaKost: 'Green Valley Kost',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '2',
        nama: 'BRI',
        jenis: 'bank',
        nomorRekening: '3210',
        namaKost: 'Green Valley Kost',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '3',
        nama: 'Mandiri',
        jenis: 'bank',
        nomorRekening: '4455',
        namaKost: 'Green Valley Kost',
        isActive: false,
      ),
      MetodePembayaranModel(
        id: '4',
        nama: 'Cash Payment',
        jenis: 'cash',
        nomorRekening: '-',
        namaKost: 'Green Valley Kost',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '5',
        nama: 'BNI',
        jenis: 'bank',
        nomorRekening: '2211',
        namaKost: 'Sunrise Boarding House',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '6',
        nama: 'Mandiri',
        jenis: 'bank',
        nomorRekening: '9900',
        namaKost: 'Sunrise Boarding House',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '7',
        nama: 'BCA',
        jenis: 'bank',
        nomorRekening: '5566',
        namaKost: 'Peaceful Haven Kost',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '8',
        nama: 'Cash Payment',
        jenis: 'cash',
        nomorRekening: '-',
        namaKost: 'Peaceful Haven Kost',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '9',
        nama: 'BRI',
        jenis: 'bank',
        nomorRekening: '7788',
        namaKost: 'Urban Residence',
        isActive: true,
      ),
      MetodePembayaranModel(
        id: '10',
        nama: 'Mandiri',
        jenis: 'bank',
        nomorRekening: '3344',
        namaKost: 'Cozy Corner Kost',
        isActive: true,
      ),
      // QRIS Payment Methods
      MetodePembayaranModel(
        id: '11',
        nama: 'QRIS Dana',
        jenis: 'qris',
        nomorRekening: '-',
        namaKost: 'Green Valley Kost',
        isActive: true,
        qrisImagePath: 'assets/images/qris_dana.png',
      ),
      MetodePembayaranModel(
        id: '12',
        nama: 'QRIS GoPay',
        jenis: 'qris',
        nomorRekening: '-',
        namaKost: 'Sunrise Boarding House',
        isActive: true,
        qrisImagePath: 'assets/images/qris_gopay.png',
      ),
      MetodePembayaranModel(
        id: '13',
        nama: 'QRIS OVO',
        jenis: 'qris',
        nomorRekening: '-',
        namaKost: 'Peaceful Haven Kost',
        isActive: false,
        qrisImagePath: 'assets/images/qris_ovo.png',
      ),
    ];

    print('Total payment methods loaded: ${metodePembayaranList.length}');
    print(
      'QRIS methods: ${metodePembayaranList.where((m) => m.jenis == 'qris').length}',
    );
    applyFilter();
  }

  void applyFilter() {
    filteredList.value = metodePembayaranList.where((metode) {
      bool matchKost =
          selectedKost.value == 'Semua Kost' ||
          metode.namaKost == selectedKost.value;
      bool matchJenis =
          selectedFilter.value == 'Semua' ||
          (selectedFilter.value == 'Bank' && metode.jenis == 'bank') ||
          (selectedFilter.value == 'Cash' && metode.jenis == 'cash') ||
          (selectedFilter.value == 'QRIS' && metode.jenis == 'qris');
      return matchKost && matchJenis;
    }).toList();

    print(
      'Filter applied - Kost: ${selectedKost.value}, Jenis: ${selectedFilter.value}',
    );
    print('Filtered results: ${filteredList.length} items');
    print(
      'QRIS in filtered: ${filteredList.where((m) => m.jenis == 'qris').length}',
    );
  }

  void setKostFilter(String kost) {
    selectedKost.value = kost;
    applyFilter();
  }

  void setJenisFilter(String jenis) {
    selectedFilter.value = jenis;
    applyFilter();
  }

  int get totalAktif {
    return metodePembayaranList.where((m) => m.isActive).length;
  }

  int get totalMetode {
    return metodePembayaranList.length;
  }

  void toggleStatus(String id) {
    final index = metodePembayaranList.indexWhere((m) => m.id == id);
    if (index != -1) {
      final metode = metodePembayaranList[index];
      metodePembayaranList[index] = MetodePembayaranModel(
        id: metode.id,
        nama: metode.nama,
        jenis: metode.jenis,
        nomorRekening: metode.nomorRekening,
        namaKost: metode.namaKost,
        isActive: !metode.isActive,
      );
      metodePembayaranList.refresh();
      applyFilter();
    }
  }

  void editMetode(String id) {
    final metode = metodePembayaranList.firstWhere((m) => m.id == id);
    Get.toNamed('/edit-metode-pembayaran', arguments: metode);
  }

  void deleteMetode(String id) {
    final metode = metodePembayaranList.firstWhere((m) => m.id == id);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hapus Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Apakah Anda yakin ingin menghapus metode pembayaran ${metode.nama} untuk ${metode.namaKost}?',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () {
                          metodePembayaranList.removeWhere((m) => m.id == id);
                          applyFilter();
                          Get.back();
                          Get.snackbar(
                            'Berhasil',
                            'Metode pembayaran berhasil dihapus',
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tambahMetode() {
    Get.toNamed('/tambah-metode-pembayaran');
  }
}
