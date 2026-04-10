import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';

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
  final String id;
  final String nama;
  final String deskripsi;

  const PeraturanModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
  });

  PeraturanModel copyWith({String? id, String? nama, String? deskripsi}) {
    return PeraturanModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
    );
  }
}

class KelolaPeraturanController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  final gedungKostList = <GedungKostModel>[].obs;
  final selectedGedung = Rxn<GedungKostModel>();
  final kategoriList = <PeraturanModel>[].obs;
  final peraturanCountByKost = <String, int>{}.obs;

  final isLoadingGedung = false.obs;
  final isLoadingPeraturan = false.obs;
  final isSavingPeraturan = false.obs;
  final errorMessage = RxnString();

  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  String _previousText = '';

  @override
  void onInit() {
    super.onInit();
    deskripsiController.addListener(_onDeskripsiChanged);
    loadGedungKost();
  }

  @override
  void onClose() {
    deskripsiController.removeListener(_onDeskripsiChanged);
    namaController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  Future<void> loadGedungKost() async {
    isLoadingGedung.value = true;
    errorMessage.value = null;

    try {
      final kosts = await _supabaseService.getKostList();
      final mapped = kosts
          .map(
            (kost) => GedungKostModel(
              id: kost.id,
              nama: kost.name.trim().isEmpty ? 'Kost' : kost.name.trim(),
              alamat: kost.address.trim().isEmpty ? '-' : kost.address.trim(),
              totalKamar: kost.roomCount,
            ),
          )
          .toList();

      gedungKostList.assignAll(mapped);
      await _loadPeraturanCounts(mapped);

      final activeGedung = selectedGedung.value;
      if (activeGedung != null) {
        final refreshed = mapped.firstWhereOrNull(
          (item) => item.id == activeGedung.id,
        );
        if (refreshed == null) {
          kembaliKePilihGedung();
        } else {
          selectedGedung.value = refreshed;
        }
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat daftar kost.';
      gedungKostList.clear();
      peraturanCountByKost.clear();
      kembaliKePilihGedung();
    } finally {
      isLoadingGedung.value = false;
    }
  }

  Future<void> _loadPeraturanCounts(List<GedungKostModel> gedungList) async {
    if (gedungList.isEmpty) {
      peraturanCountByKost.clear();
      return;
    }

    final pairs = await Future.wait(
      gedungList.map((gedung) async {
        final count = await _supabaseService.getPeraturanCountByKostId(
          gedung.id,
        );
        return MapEntry(gedung.id, count);
      }),
    );

    peraturanCountByKost.assignAll({
      for (final pair in pairs) pair.key: pair.value,
    });
  }

  int getPeraturanCountForKost(String kostId) {
    return peraturanCountByKost[kostId] ?? 0;
  }

  Future<void> pilihGedungKost(GedungKostModel gedung) async {
    selectedGedung.value = gedung;
    await _loadPeraturanByGedung(gedung);
  }

  void kembaliKePilihGedung() {
    selectedGedung.value = null;
    kategoriList.clear();
    errorMessage.value = null;
    resetForm();
  }

  Future<void> refreshPeraturanAktif() async {
    final gedung = selectedGedung.value;
    if (gedung == null) return;

    await _loadPeraturanByGedung(gedung);
  }

  Future<void> _loadPeraturanByGedung(GedungKostModel gedung) async {
    isLoadingPeraturan.value = true;
    errorMessage.value = null;

    try {
      final rows = await _supabaseService.getPeraturanByKostId(gedung.id);
      final mapped = rows
          .map((row) {
            final nama = (row['judul'] ?? row['title'] ?? '').toString().trim();
            final deskripsi =
                (row['isi'] ??
                        row['deskripsi'] ??
                        row['content'] ??
                        row['description'] ??
                        '')
                    .toString()
                    .trim();

            return PeraturanModel(
              id: row['id']?.toString() ?? '',
              nama: nama,
              deskripsi: deskripsi,
            );
          })
          .where((item) => item.id.isNotEmpty)
          .toList();

      kategoriList.assignAll(mapped);
      peraturanCountByKost[gedung.id] = mapped.length;
    } catch (_) {
      errorMessage.value = 'Gagal memuat data peraturan.';
      kategoriList.clear();
    } finally {
      isLoadingPeraturan.value = false;
    }
  }

  int _nextRuleNumber(String text) {
    final lines = text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 1;

    final lastLine = lines.last;
    final match = RegExp(r'^(\d+)\.').firstMatch(lastLine);
    final currentNumber = int.tryParse(match?.group(1) ?? '');

    if (currentNumber == null) {
      return lines.length + 1;
    }

    return currentNumber + 1;
  }

  void _onDeskripsiChanged() {
    final text = deskripsiController.text;

    if (text.isEmpty && _previousText.isNotEmpty) {
      _previousText = text;
      return;
    }

    if (text == _previousText) {
      return;
    }

    if (text.endsWith('\n') && text.length > _previousText.length) {
      final nextNumber = _nextRuleNumber(text.trimRight());
      final newText = '$text$nextNumber. ';

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

  void setFormForEdit(PeraturanModel kategori) {
    namaController.text = kategori.nama;
    deskripsiController.text = kategori.deskripsi;
    _previousText = deskripsiController.text;
    deskripsiController.selection = TextSelection.collapsed(
      offset: deskripsiController.text.length,
    );
  }

  void resetForm() {
    namaController.clear();
    deskripsiController.clear();
    _previousText = '';
  }

  Future<bool> tambahKategori() async {
    final gedung = selectedGedung.value;
    if (gedung == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    final judul = namaController.text.trim();
    final isi = deskripsiController.text.trim();
    if (judul.isEmpty || isi.isEmpty) {
      Get.snackbar('Error', 'Nama kategori dan deskripsi wajib diisi');
      return false;
    }

    try {
      isSavingPeraturan.value = true;
      await _supabaseService.createPeraturan(
        kostId: gedung.id,
        title: judul,
        description: isi,
      );
      await _loadPeraturanByGedung(gedung);
      resetForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menambahkan peraturan'),
      );
      return false;
    } finally {
      isSavingPeraturan.value = false;
    }
  }

  Future<bool> editKategori(String id) async {
    final gedung = selectedGedung.value;
    if (gedung == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    final judul = namaController.text.trim();
    final isi = deskripsiController.text.trim();
    if (judul.isEmpty || isi.isEmpty) {
      Get.snackbar('Error', 'Nama kategori dan deskripsi wajib diisi');
      return false;
    }

    try {
      isSavingPeraturan.value = true;
      await _supabaseService.updatePeraturan(
        id: id,
        title: judul,
        description: isi,
      );
      await _loadPeraturanByGedung(gedung);
      resetForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal memperbarui peraturan'),
      );
      return false;
    } finally {
      isSavingPeraturan.value = false;
    }
  }

  Future<bool> hapusKategori(String id) async {
    final gedung = selectedGedung.value;
    if (gedung == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    try {
      isSavingPeraturan.value = true;
      await _supabaseService.deletePeraturan(id);
      await _loadPeraturanByGedung(gedung);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menghapus peraturan'),
      );
      return false;
    } finally {
      isSavingPeraturan.value = false;
    }
  }

  String _resolveErrorMessage(Object error, String fallback) {
    final raw = error.toString().trim();
    if (raw.isEmpty) return fallback;

    var message = raw;
    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }

    if (message.length > 180) {
      message = '${message.substring(0, 180)}...';
    }

    return message.isEmpty ? fallback : message;
  }
}
