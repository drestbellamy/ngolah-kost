import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../kost/models/kost_model.dart';
import '../views/widgets/tambah_kamar_bottom_sheet.dart';
import '../views/widgets/edit_kamar_bottom_sheet.dart';
import '../views/widgets/hapus_kamar_dialog.dart';

class KamarController extends GetxController {
  final selectedTab = 0.obs;

  // Data kost
  final namaKost = ''.obs;
  final alamatKost = ''.obs;
  final totalRuangan = 5.obs;
  final ditempati = 4.obs;
  final kosong = 1.obs;
  final totalPenghuni = 4.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data kost dari arguments yang dikirim dari halaman kost
    final args = Get.arguments;
    if (args != null && args is KostModel) {
      namaKost.value = args.name;
      alamatKost.value = args.address;
    }
  }

  // List kamar
  final kamarList = <Map<String, dynamic>>[
    {
      'nomor': 'A-101',
      'status': 'Ditempati',
      'penghuni': 'John Doe',
      'kapasitas': 2,
      'terisi': 1,
      'harga': 'Rp 1.500.000/Bulan',
      'statusColor': const Color(0xFF10B981),
    },
    {
      'nomor': 'A-102',
      'status': 'Kosong',
      'penghuni': null,
      'kapasitas': 2,
      'terisi': 0,
      'harga': 'Rp 1.500.000/Bulan',
      'statusColor': const Color(0xFFF2A65A),
    },
    {
      'nomor': 'A-103',
      'status': 'Ditempati',
      'penghuni': 'Jane Smith',
      'kapasitas': 2,
      'terisi': 2,
      'harga': 'Rp 1.500.000/Bulan',
      'statusColor': const Color(0xFF10B981),
    },
    {
      'nomor': 'B-201',
      'status': 'Kosong',
      'penghuni': null,
      'kapasitas': 4,
      'terisi': 0,
      'harga': 'Rp 1.800.000/Bulan',
      'statusColor': const Color(0xFFF2A65A),
    },
  ].obs;

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
      kamarList.add({
        'nomor': result['nomor'],
        'status': 'Kosong',
        'penghuni': null,
        'kapasitas': result['kapasitas'],
        'terisi': 0,
        'harga': 'Rp ${result['harga']}/Bulan',
        'statusColor': const Color(0xFFF2A65A),
      });

      totalRuangan.value++;
      kosong.value++;

      Get.snackbar(
        'Berhasil',
        'Kamar ${result['nomor']} berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    }
  }

  void editKamar(Map<String, dynamic> kamar) async {
    final result = await Get.dialog(EditKamarBottomSheet(kamar: kamar));

    if (result != null) {
      final index = kamarList.indexWhere((k) => k['nomor'] == kamar['nomor']);
      if (index != -1) {
        kamarList[index]['nomor'] = result['nomor'];
        kamarList[index]['harga'] = 'Rp ${result['harga']}/Bulan';
        kamarList[index]['kapasitas'] = result['kapasitas'];
        kamarList.refresh();

        Get.snackbar(
          'Berhasil',
          'Kamar berhasil diupdate',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      }
    }
  }

  void hapusKamar(Map<String, dynamic> kamar) async {
    final result = await Get.dialog(HapusKamarDialog(kamar: kamar));

    if (result == true) {
      final wasOccupied = kamar['status'] == 'Ditempati';
      kamarList.removeWhere((k) => k['nomor'] == kamar['nomor']);

      totalRuangan.value--;
      if (wasOccupied) {
        ditempati.value--;
      } else {
        kosong.value--;
      }

      Get.snackbar(
        'Berhasil',
        'Kamar ${kamar['nomor']} berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    }
  }
}
