import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/supabase_service.dart';
import '../../kamar/controllers/informasi_kamar_controller.dart';
import '../../kelola_tagihan/controllers/kelola_tagihan_controller.dart';
import '../models/penghuni_model.dart';
import 'penghuni_controller.dart';

class KelolaKontrakController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  final selectedTab = 0.obs; // 0: Perpanjang, 1: Edit, 2: Akhiri
  final isLoading = false.obs;
  final tambahanDurasi = 0.obs; // Observable untuk durasi tambahan
  final previewTick = 0.obs;

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
      previewTick.value++;
    });
    tanggalMulaiController.addListener(() => previewTick.value++);
    durasiKontrakController.addListener(() => previewTick.value++);
    sistemPembayaranEditController.addListener(() => previewTick.value++);
    sistemPembayaranPerpanjangController.addListener(() => previewTick.value++);
  }

  void initializeEditForm() {
    if (penghuni != null) {
      tanggalMulaiController.text = penghuni!.tanggalMasuk;
      durasiKontrakController.text = penghuni!.durasiKontrak.toString();
      sistemPembayaranEditController.text = penghuni!.sistemPembayaran;
      sistemPembayaranPerpanjangController.text = penghuni!.sistemPembayaran;
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
  Future<void> perpanjangKontrak() async {
    if (tambahanDurasiController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Tambahan durasi harus diisi',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final p = penghuni;
    if (p == null) {
      Get.snackbar(
        'Error',
        'Data penghuni tidak ditemukan',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final tambahan = int.tryParse(tambahanDurasiController.text.trim()) ?? 0;
    if (tambahan <= 0) {
      Get.snackbar(
        'Error',
        'Tambahan durasi harus lebih dari 0 bulan',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final latestKontrak = await _getLatestKontrakBase(p);
    final tanggalMasuk = latestKontrak.tanggalMasuk;
    if (tanggalMasuk == null) {
      Get.snackbar(
        'Error',
        'Tanggal mulai kontrak tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final durasiBaru = latestKontrak.durasiKontrak + tambahan;

    final rawSistemInput = sistemPembayaranPerpanjangController.text.trim();
    final sistemPembayaranBulanRaw = rawSistemInput.isEmpty
        ? latestKontrak.sistemPembayaranBulan
        : _parseSiklusBulan(rawSistemInput);

    if (sistemPembayaranBulanRaw <= 0) {
      Get.snackbar(
        'Error',
        'Format sistem pembayaran tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final sistemPembayaranBulan = sistemPembayaranBulanRaw > durasiBaru
        ? durasiBaru
        : sistemPembayaranBulanRaw;

    try {
      isLoading.value = true;
      await _supabaseService.updatePenghuniKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        status: 'aktif',
      );

      await _supabaseService.sinkronTagihanKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        hargaBulanan: p.sewaBulanan.round(),
      );

      await _refreshRelatedData();

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Kontrak berhasil diperpanjang',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal memperpanjang kontrak',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    ({DateTime? tanggalMasuk, int durasiKontrak, int sistemPembayaranBulan})
  >
  _getLatestKontrakBase(PenghuniModel p) async {
    final fallbackTanggalMasuk = _parseDateFlexible(p.tanggalMasuk);
    final fallbackSiklus = _parseSiklusBulan(p.sistemPembayaran);

    try {
      final row = await _supabaseService.getPenghuniDetailById(p.id);
      if (row == null) {
        final siklus = fallbackSiklus <= 0 ? 1 : fallbackSiklus;
        final durasi = p.durasiKontrak <= 0 ? 1 : p.durasiKontrak;
        return (
          tanggalMasuk: fallbackTanggalMasuk,
          durasiKontrak: durasi,
          sistemPembayaranBulan: siklus > durasi ? durasi : siklus,
        );
      }

      final durasiRaw = _toInt(row['durasi_kontrak']);
      final durasi = durasiRaw <= 0 ? p.durasiKontrak : durasiRaw;

      final siklusRaw = _toInt(row['sistem_pembayaran_bulan']);
      var siklus = siklusRaw <= 0 ? fallbackSiklus : siklusRaw;
      if (siklus <= 0) siklus = 1;
      if (siklus > durasi) siklus = durasi;

      final tanggalMasuk =
          _parseDateFlexible((row['tanggal_masuk'] ?? '').toString()) ??
          fallbackTanggalMasuk;

      return (
        tanggalMasuk: tanggalMasuk,
        durasiKontrak: durasi,
        sistemPembayaranBulan: siklus,
      );
    } catch (_) {
      final siklus = fallbackSiklus <= 0 ? 1 : fallbackSiklus;
      final durasi = p.durasiKontrak <= 0 ? 1 : p.durasiKontrak;
      return (
        tanggalMasuk: fallbackTanggalMasuk,
        durasiKontrak: durasi,
        sistemPembayaranBulan: siklus > durasi ? durasi : siklus,
      );
    }
  }

  // Fungsi Edit Kontrak
  Future<void> editKontrak() async {
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

    final p = penghuni;
    if (p == null) {
      Get.snackbar(
        'Error',
        'Data penghuni tidak ditemukan',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final tanggalMasuk = _parseDateFlexible(tanggalMulaiController.text.trim());
    if (tanggalMasuk == null) {
      Get.snackbar(
        'Error',
        'Tanggal mulai tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final durasiBaru = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    if (durasiBaru <= 0) {
      Get.snackbar(
        'Error',
        'Durasi kontrak harus lebih dari 0 bulan',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final sistemPembayaranBulanRaw = _parseSiklusBulan(
      sistemPembayaranEditController.text,
    );
    if (sistemPembayaranBulanRaw <= 0) {
      Get.snackbar(
        'Error',
        'Format sistem pembayaran tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final sistemPembayaranBulan = sistemPembayaranBulanRaw > durasiBaru
        ? durasiBaru
        : sistemPembayaranBulanRaw;

    try {
      isLoading.value = true;
      await _supabaseService.updatePenghuniKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        status: 'aktif',
      );

      await _supabaseService.sinkronTagihanKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        hargaBulanan: p.sewaBulanan.round(),
      );

      await _refreshRelatedData();

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Kontrak berhasil diperbarui',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui kontrak',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
      onConfirm: () async {
        final p = penghuni;
        if (p == null) {
          Get.back();
          Get.snackbar(
            'Error',
            'Data penghuni tidak ditemukan',
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
          );
          return;
        }

        try {
          isLoading.value = true;
          Get.back(); // Close dialog

          await _supabaseService.akhiriKontrakPenghuni(penghuniId: p.id);
          await _refreshRelatedData();

          Get.back(result: true); // Close bottom sheet
          Get.snackbar(
            'Berhasil',
            'Kontrak berhasil diakhiri',
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
          );
        } catch (_) {
          Get.snackbar(
            'Error',
            'Gagal mengakhiri kontrak',
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
          );
        } finally {
          isLoading.value = false;
        }
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

  String get currentEndDateLabel {
    return penghuni?.tanggalBerakhir ?? '-';
  }

  String get remainingTimeLabel {
    final endDate = _parseDateFlexible(penghuni?.tanggalBerakhir ?? '');
    if (endDate == null) return '-';

    final today = DateTime.now();
    final diff = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).difference(DateTime(today.year, today.month, today.day));

    if (diff.inDays < 0) return 'Sudah berakhir';
    if (diff.inDays == 0) return 'Berakhir hari ini';
    if (diff.inDays < 30) return '${diff.inDays} hari lagi';

    final months = (diff.inDays / 30).floor();
    return '$months bulan lagi';
  }

  String get newEndDateLabel {
    final p = penghuni;
    if (p == null) return '-';

    final startDate = _parseDateFlexible(p.tanggalMasuk);
    if (startDate == null) return '-';

    final newDuration = calculateNewDuration();
    if (newDuration <= 0) return '-';

    final endDate = DateTime(
      startDate.year,
      startDate.month + newDuration,
      startDate.day,
    );
    return _formatDateId(endDate);
  }

  String get editEndDateLabel {
    final startDate = _parseDateFlexible(tanggalMulaiController.text);
    final duration = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    if (startDate == null || duration <= 0) return '-';

    final endDate = DateTime(
      startDate.year,
      startDate.month + duration,
      startDate.day,
    );
    return _formatDateId(endDate);
  }

  String get editTotalTagihanLabel {
    final p = penghuni;
    if (p == null) return '-';

    final duration = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    if (duration <= 0) return '-';
    return '${duration}x @ ${_formatCurrency(p.sewaBulanan)}';
  }

  String get editTotalNilaiKontrakLabel {
    final p = penghuni;
    if (p == null) return '-';

    final duration = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    if (duration <= 0) return '-';
    return _formatCurrency(p.sewaBulanan * duration);
  }

  String _formatDateId(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  String _formatCurrency(double value) {
    final amount = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $amount';
  }

  int _parseSiklusBulan(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return 0;

    final direct = int.tryParse(value);
    if (direct != null && direct > 0) return direct;

    final numberMatch = RegExp(r'\d+').firstMatch(value);
    if (numberMatch != null) {
      final parsed = int.tryParse(numberMatch.group(0) ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }

    if (value.contains('bulanan')) return 1;
    if (value.contains('tahunan')) return 12;
    return 0;
  }

  DateTime? _parseDateFlexible(String raw) {
    final input = raw.trim();
    if (input.isEmpty || input == '-') return null;

    final iso = DateTime.tryParse(input);
    if (iso != null) return iso;

    const patterns = ['d MMM yyyy', 'd MMMM yyyy', 'dd/MM/yyyy'];
    for (final pattern in patterns) {
      try {
        return DateFormat(pattern, 'id_ID').parseStrict(input);
      } catch (_) {
        // Try next pattern
      }
      try {
        return DateFormat(pattern).parseStrict(input);
      } catch (_) {
        // Try next pattern
      }
    }

    return null;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _refreshRelatedData() async {
    if (Get.isRegistered<PenghuniController>()) {
      await Get.find<PenghuniController>().loadPenghuniData();
    }

    if (Get.isRegistered<InformasiKamarController>()) {
      await Get.find<InformasiKamarController>().fetchPenghuniData();
    }

    if (Get.isRegistered<KelolaTagihanController>()) {
      await Get.find<KelolaTagihanController>().loadTagihanData();
    }
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
