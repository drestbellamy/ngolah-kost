import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GedungKostModel {
  final String id;
  final String nama;
  final String alamat;
  final int totalKamar;

  const GedungKostModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.totalKamar,
  });
}

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
  final gedungKostList = const <GedungKostModel>[
    GedungKostModel(
      id: '1',
      nama: 'Sunrise Boarding House',
      alamat: 'Jl. Gatot Subroto No. 45, Jakarta',
      totalKamar: 8,
    ),
    GedungKostModel(
      id: '2',
      nama: 'Peaceful Haven Kost',
      alamat: 'Jl. Thamrin No. 67, Jakarta',
      totalKamar: 10,
    ),
    GedungKostModel(
      id: '3',
      nama: 'Urban Residence',
      alamat: 'Jl. HR Rasuna Said No. 89, Jakarta',
      totalKamar: 15,
    ),
    GedungKostModel(
      id: '4',
      nama: 'Green Valley Kost',
      alamat: 'Jl. Sudirman No. 123, Jakarta',
      totalKamar: 12,
    ),
  ];

  final selectedGedung = Rxn<GedungKostModel>();
  final kategoriList = <PeraturanModel>[].obs;
  final Map<String, List<PeraturanModel>> _kategoriByGedung = {};

  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  String _previousText = '';

  @override
  void onInit() {
    super.onInit();
    deskripsiController.addListener(_onDeskripsiChanged);
  }

  List<PeraturanModel> _seedKategori() {
    return [
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
    ];
  }

  List<PeraturanModel> _cloneKategori(List<PeraturanModel> source) {
    return source
        .map(
          (item) => PeraturanModel(
            id: item.id,
            nama: item.nama,
            deskripsi: item.deskripsi,
          ),
        )
        .toList();
  }

  void pilihGedungKost(GedungKostModel gedung) {
    selectedGedung.value = gedung;

    _kategoriByGedung.putIfAbsent(gedung.id, _seedKategori);
    kategoriList.value = _cloneKategori(_kategoriByGedung[gedung.id]!);
  }

  void kembaliKePilihGedung() {
    selectedGedung.value = null;
    kategoriList.clear();
    resetForm();
  }

  void _sinkronkanKategoriKeGedungAktif() {
    final gedung = selectedGedung.value;
    if (gedung == null) {
      return;
    }

    _kategoriByGedung[gedung.id] = _cloneKategori(kategoriList);
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

      String newText = '$text$nextNumber. ';

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
    _previousText = '';
  }

  void tambahKategori() {
    if (selectedGedung.value == null) {
      return;
    }

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
    _sinkronkanKategoriKeGedungAktif();

    Get.back(); // Hanya keluar dari dialog
    resetForm();
  }

  void editKategori(String id) {
    if (selectedGedung.value == null) {
      return;
    }

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
      _sinkronkanKategoriKeGedungAktif();

      Get.back(); // Hanya keluar dari dialog
      resetForm();
    }
  }

  void hapusKategori(String id) {
    if (selectedGedung.value == null) {
      return;
    }

    kategoriList.removeWhere((k) => k.id == id);
    _sinkronkanKategoriKeGedungAktif();
    Get.back(); // Hanya tutup dialog
  }
}
