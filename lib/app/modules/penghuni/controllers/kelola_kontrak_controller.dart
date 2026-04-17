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
  static const int maxTambahanDurasiBulan = 24;
  static const List<int> _preferredSiklusBulan = [1, 3, 6, 12, 24];

  final selectedTab = 0.obs; // 0: Perpanjang, 1: Edit, 2: Akhiri
  final isLoading = false.obs;
  final tambahanDurasi = 0.obs; // Observable untuk durasi tambahan
  final previewTick = 0.obs;
  final paidCoveredPrefixMonths = 0.obs;
  bool _hasLoadedPaidCoverageConstraint = false;

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
      _loadPaidCoverageConstraint();
    }

    // Listen to text changes
    tambahanDurasiController.addListener(() {
      tambahanDurasi.value = int.tryParse(tambahanDurasiController.text) ?? 0;
      _syncPerpanjangSistemPembayaranWithDurasi();
      previewTick.value++;
    });
    tanggalMulaiController.addListener(() => previewTick.value++);
    durasiKontrakController.addListener(() {
      _syncEditSistemPembayaranWithDurasi();
      previewTick.value++;
    });
    sistemPembayaranEditController.addListener(() => previewTick.value++);
    sistemPembayaranPerpanjangController.addListener(() => previewTick.value++);
  }

  void initializeEditForm() {
    if (penghuni != null) {
      tanggalMulaiController.text = penghuni!.tanggalMasuk;
      durasiKontrakController.text = penghuni!.durasiKontrak.toString();
      final siklusAwal = _parseSiklusBulan(penghuni!.sistemPembayaran);
      final labelAwal = siklusAwal > 0
          ? formatSistemPembayaranOption(siklusAwal)
          : penghuni!.sistemPembayaran;
      sistemPembayaranEditController.text = labelAwal;
      sistemPembayaranPerpanjangController.text = labelAwal;
      _syncPerpanjangSistemPembayaranWithDurasi();
      _syncEditSistemPembayaranWithDurasi();
    }
  }

  List<int> get perpanjangSistemPembayaranOptions {
    final durasiTambahan = tambahanDurasi.value;
    final base = _buildSistemPembayaranOptions(
      durasiTambahan,
      include: selectedSistemPembayaranPerpanjangBulan,
    );
    return _filterOptionsByPaidCoverage(base);
  }

  List<int> get editSistemPembayaranOptions {
    final durasi = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    final base = _buildSistemPembayaranOptions(
      durasi,
      include: selectedSistemPembayaranEditBulan,
    );
    return _filterOptionsByPaidCoverage(base);
  }

  int get selectedSistemPembayaranPerpanjangBulan {
    return _parseSiklusBulan(sistemPembayaranPerpanjangController.text);
  }

  int get selectedSistemPembayaranEditBulan {
    return _parseSiklusBulan(sistemPembayaranEditController.text);
  }

  bool get hasPaidCoverageConstraint {
    return paidCoveredPrefixMonths.value > 0;
  }

  String get paidCoverageConstraintNote {
    final covered = paidCoveredPrefixMonths.value;
    if (covered <= 0) return '';
    return 'Beberapa opsi disesuaikan karena $covered bulan awal sudah lunas. Pilih siklus pembayaran yang tetap selaras dengan riwayat lunas.';
  }

  void pilihSistemPembayaranPerpanjang(int bulan) {
    sistemPembayaranPerpanjangController.text = formatSistemPembayaranOption(
      bulan,
    );
  }

  void pilihSistemPembayaranEdit(int bulan) {
    sistemPembayaranEditController.text = formatSistemPembayaranOption(bulan);
  }

  String formatSistemPembayaranOption(int bulan) {
    if (bulan <= 1) return '1 Bulan';
    if (bulan == 3) return '3 Bulan';
    if (bulan == 6) return '6 Bulan';
    if (bulan == 12) return '12 Bulan ( 1 Tahun )';
    if (bulan == 24) return '24 Bulan ( 2 Tahun )';
    return '$bulan Bulan';
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

    await _ensurePaidCoverageConstraintLoaded();

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

    if (tambahan > maxTambahanDurasiBulan) {
      Get.snackbar(
        'Error',
        'Tambahan durasi maksimal $maxTambahanDurasiBulan bulan',
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

    if (sistemPembayaranBulan <= 0) {
      Get.snackbar(
        'Error',
        'Sistem pembayaran tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isSiklusAllowedByPaidCoverage(sistemPembayaranBulan)) {
      Get.snackbar(
        'Error',
        'Sistem pembayaran $sistemPembayaranBulan bulan tidak bisa dipakai karena pembayaran lunas sebelumnya belum selaras',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

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

    await _ensurePaidCoverageConstraintLoaded();

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

    if (sistemPembayaranBulan <= 0) {
      Get.snackbar(
        'Error',
        'Sistem pembayaran tidak valid',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    if (!_isSiklusAllowedByPaidCoverage(sistemPembayaranBulan)) {
      Get.snackbar(
        'Error',
        'Sistem pembayaran $sistemPembayaranBulan bulan tidak bisa dipakai karena pembayaran lunas sebelumnya belum selaras',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

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

    if (value.contains('2 tahunan') || value.contains('2 tahun')) return 24;
    if (value.contains('tahunan') || value.contains('1 tahun')) return 12;

    final numberMatches = RegExp(r'\d+').allMatches(value);
    if (numberMatches.isNotEmpty) {
      var maxNumber = 0;
      for (final match in numberMatches) {
        final parsed = int.tryParse(match.group(0) ?? '') ?? 0;
        if (parsed > maxNumber) {
          maxNumber = parsed;
        }
      }
      if (maxNumber > 0) return maxNumber;
    }

    if (value.contains('bulanan')) return 1;
    if (value.contains('tahunan')) return 12;
    return 0;
  }

  List<int> _buildSistemPembayaranOptions(int durasi, {int include = 0}) {
    if (durasi <= 0) {
      return const [];
    }

    final options = _preferredSiklusBulan
        .where((bulan) => bulan <= durasi)
        .toList();

    // Keep legacy/custom cycle selectable if still within current duration.
    if (include > 0 && include <= durasi) {
      if (!options.contains(include)) {
        options.add(include);
      }
    }

    if (options.isEmpty) {
      options.add(durasi);
    }

    options.sort();
    return options;
  }

  List<int> _filterOptionsByPaidCoverage(List<int> options) {
    if (options.isEmpty) return const [];

    final covered = paidCoveredPrefixMonths.value;
    if (covered <= 0) return options;

    final filtered = options.where((siklus) => covered % siklus == 0).toList();
    if (filtered.isNotEmpty) {
      return filtered;
    }

    if (options.contains(1)) {
      return const [1];
    }

    return [options.first];
  }

  bool _isSiklusAllowedByPaidCoverage(int siklusBulan) {
    final covered = paidCoveredPrefixMonths.value;
    if (covered <= 0) return true;
    if (siklusBulan <= 0) return false;
    return covered % siklusBulan == 0;
  }

  int _findClosestOption(int selected, List<int> options) {
    var best = options.first;
    var bestDistance = (selected - best).abs();

    for (final option in options.skip(1)) {
      final distance = (selected - option).abs();
      if (distance < bestDistance) {
        best = option;
        bestDistance = distance;
      }
    }

    return best;
  }

  void _syncPerpanjangSistemPembayaranWithDurasi() {
    final options = perpanjangSistemPembayaranOptions;
    if (options.isEmpty) {
      if (sistemPembayaranPerpanjangController.text.isNotEmpty) {
        sistemPembayaranPerpanjangController.clear();
      }
      return;
    }

    final selected = selectedSistemPembayaranPerpanjangBulan;
    if (selected > 0 && options.contains(selected)) return;

    final replacement = selected <= 0
        ? options.first
        : _findClosestOption(selected, options);
    final label = formatSistemPembayaranOption(replacement);
    if (sistemPembayaranPerpanjangController.text != label) {
      sistemPembayaranPerpanjangController.text = label;
    }
  }

  void _syncEditSistemPembayaranWithDurasi() {
    final options = editSistemPembayaranOptions;
    if (options.isEmpty) {
      if (sistemPembayaranEditController.text.isNotEmpty) {
        sistemPembayaranEditController.clear();
      }
      return;
    }

    final selected = selectedSistemPembayaranEditBulan;
    if (selected > 0 && options.contains(selected)) return;

    final replacement = selected <= 0
        ? options.first
        : _findClosestOption(selected, options);
    final label = formatSistemPembayaranOption(replacement);
    if (sistemPembayaranEditController.text != label) {
      sistemPembayaranEditController.text = label;
    }
  }

  Future<void> _loadPaidCoverageConstraint() async {
    final p = penghuni;
    if (p == null) return;

    try {
      final latest = await _getLatestKontrakBase(p);
      final startDate = latest.tanggalMasuk;
      final durasi = latest.durasiKontrak;
      final hargaBulanan = p.sewaBulanan.round();

      if (startDate == null || durasi <= 0 || hargaBulanan <= 0) {
        paidCoveredPrefixMonths.value = 0;
        return;
      }

      final rows = await _supabaseService.getTagihanByPenghuniId(p.id);
      if (rows.isEmpty) {
        paidCoveredPrefixMonths.value = 0;
        return;
      }

      final contractKeys = <String>{};
      for (var i = 0; i < durasi; i++) {
        final period = DateTime(startDate.year, startDate.month + i, 1);
        contractKeys.add(_monthKey(period.year, period.month));
      }

      final coveredKeys = <String>{};
      for (final raw in rows) {
        final status = (raw['status'] ?? '').toString().toLowerCase().trim();
        if (status != 'lunas') continue;

        final bulan = _toInt(raw['bulan']);
        final tahun = _toInt(raw['tahun']);
        if (bulan < 1 || bulan > 12 || tahun <= 0) continue;

        final coveredMonths = _estimateCoveredMonthsByJumlah(
          raw['jumlah'],
          hargaBulanan,
        );

        for (var i = 0; i < coveredMonths; i++) {
          final period = DateTime(tahun, bulan + i, 1);
          final key = _monthKey(period.year, period.month);
          if (contractKeys.contains(key)) {
            coveredKeys.add(key);
          }
        }
      }

      var prefixCovered = 0;
      while (prefixCovered < durasi) {
        final period = DateTime(
          startDate.year,
          startDate.month + prefixCovered,
          1,
        );
        final key = _monthKey(period.year, period.month);
        if (!coveredKeys.contains(key)) {
          break;
        }
        prefixCovered += 1;
      }

      paidCoveredPrefixMonths.value = prefixCovered;
      _syncPerpanjangSistemPembayaranWithDurasi();
      _syncEditSistemPembayaranWithDurasi();
      previewTick.value++;
    } catch (_) {
      paidCoveredPrefixMonths.value = 0;
    } finally {
      _hasLoadedPaidCoverageConstraint = true;
    }
  }

  Future<void> _ensurePaidCoverageConstraintLoaded() async {
    if (_hasLoadedPaidCoverageConstraint) return;
    await _loadPaidCoverageConstraint();
  }

  int _estimateCoveredMonthsByJumlah(dynamic jumlah, int hargaBulanan) {
    if (hargaBulanan <= 0) return 1;
    final total = _toInt(jumlah);
    if (total <= 0) return 1;

    final div = total ~/ hargaBulanan;
    final remainder = total % hargaBulanan;
    final months = remainder > 0 ? div + 1 : div;
    return months <= 0 ? 1 : months;
  }

  String _monthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
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
