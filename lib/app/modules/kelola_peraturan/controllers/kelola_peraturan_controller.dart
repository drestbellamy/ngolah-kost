import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeraturanModel {
  String id;
  String nama;
  String deskripsi;

  PeraturanModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
  });
}

class KelolaPeraturanController extends GetxController {
  final kategoriList = <PeraturanModel>[].obs;

  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  String _previousText = '';

  @override
  void onInit() {
    super.onInit();
    deskripsiController.addListener(_onDeskripsiChanged);
    // Load data awal sesuai gambar
    kategoriList.addAll([
      PeraturanModel(
        id: '1',
        nama: 'Jam Malam & Keamanan',
        deskripsi:
            '1. Jam malam pukul 22:00 WIB untuk tamu\n2. Pintu utama ditutup pukul 23:00 WIB (gunakan kunci kamar untuk akses)\n3. CCTV aktif 24 jam di area umum\n4. Wajib mengisi buku tamu untuk tamu yang menginap',
      ),
      PeraturanModel(
        id: '2',
        nama: 'Kebersihan & Kerapihan',
        deskripsi:
            '1. Buang sampah di tempat yang telah disediakan\n2. Jaga kebersihan kamar mandi bersama\n3. Tidak boleh menjemur pakaian di balkon depan\n4. Area jemuran tersedia di lantai atas',
      ),
      PeraturanModel(
        id: '3',
        nama: 'Larangan',
        deskripsi:
            '1. Dilarang membawa senjata tajam, narkoba, atau minuman keras\n2. Dilarang berjudi atau melakukan kegiatan ilegal\n3. Dilarang membuat keributan setelah pukul 22:00\n4. Dilarang memelihara binatang peliharaan',
      ),
    ]);
  }

  @override
  void onClose() {
    deskripsiController.removeListener(_onDeskripsiChanged);
    namaController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  void _onDeskripsiChanged() {
    String text = deskripsiController.text;

    // Jika teks kosong karena dihapus semua, biarkan kosong atau set '1. '
    // Tapi karena requestnya saat dipencet kosong mau muncul 1, kita handle.
    if (text.isEmpty && _previousText.isNotEmpty) {
      _previousText = text;
      return;
    }

    if (text == _previousText) return;

    if (text.endsWith('\n') && text.length > _previousText.length) {
      List<String> lines = text.trimRight().split('\n');
      int nextNumber = lines.length + 1;

      String newText = text + '$nextNumber. ';

      deskripsiController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      _previousText = newText;
    } else {
      _previousText = text;
    }
  }

  void requestFocusToDeskripsi() {
    if (deskripsiController.text.isEmpty) {
      deskripsiController.text = '1. ';
      deskripsiController.selection = TextSelection.collapsed(
        offset: deskripsiController.text.length,
      );
    }
  }

  void resetForm() {
    namaController.clear();
    deskripsiController.clear();
  }

  void tambahKategori() {
    if (namaController.text.trim().isEmpty ||
        deskripsiController.text.trim().isEmpty) {
      return;
    }

    kategoriList.add(
      PeraturanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: namaController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
      ),
    );

    Get.back(); // Hanya keluar dari dialog
    resetForm();
  }

  void editKategori(String id) {
    if (namaController.text.trim().isEmpty ||
        deskripsiController.text.trim().isEmpty) {
      return;
    }

    final index = kategoriList.indexWhere((k) => k.id == id);
    if (index != -1) {
      kategoriList[index] = PeraturanModel(
        id: id,
        nama: namaController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
      );

      Get.back(); // Hanya keluar dari dialog
      resetForm();
    }
  }

  void hapusKategori(String id) {
    kategoriList.removeWhere((k) => k.id == id);
    Get.back(); // Hanya tutup dialog
  }
}
