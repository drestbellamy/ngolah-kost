import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../../kamar/controllers/informasi_kamar_controller.dart';
import '../../kelola_tagihan/controllers/kelola_tagihan_controller.dart';
import '../models/penghuni_model.dart';
import 'penghuni_controller.dart';

class KelolaKontrakController extends GetxController {
  final PenghuniRepository _penghuniRepo;
  final TagihanRepository _tagihanRepo;

  KelolaKontrakController({
    PenghuniRepository? penghuniRepository,
    TagihanRepository? tagihanRepository,
  }) : _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _tagihanRepo =
           tagihanRepository ?? RepositoryFactory.instance.tagihanRepository;
  static const int maxTambahanDurasiBulan = 24;
  static const int maxDurasiKontrakBulan = 144; // 12 tahun
  static const List<int> _preferredSiklusBulan = [1, 3, 6, 12, 24];

  final selectedTab = 0.obs; // 0: Perpanjang, 1: Edit, 2: Akhiri
  final isLoading = false.obs;
  final tambahanDurasi = 0.obs; // Observable untuk durasi tambahan
  final previewTick = 0.obs;
  final paidCoveredPrefixMonths = 0.obs;
  bool _hasLoadedPaidCoverageConstraint = false;
  final showAutoChangeNotification = false.obs;
  String autoChangeMessage = '';
  DateTime? selectedStartDate;

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
    if (penghuni == null &&
        Get.arguments != null &&
        Get.arguments is PenghuniModel) {
      penghuni = Get.arguments as PenghuniModel;
    }
    if (penghuni != null) {
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
      final durasi = int.tryParse(durasiKontrakController.text) ?? 0;
      if (durasi > maxDurasiKontrakBulan) {
        durasiKontrakController.text = maxDurasiKontrakBulan.toString();
        durasiKontrakController.selection = TextSelection.fromPosition(
          TextPosition(offset: durasiKontrakController.text.length),
        );
      }
      _syncEditSistemPembayaranWithDurasi();
      previewTick.value++;
    });
    sistemPembayaranEditController.addListener(() => previewTick.value++);
    sistemPembayaranPerpanjangController.addListener(() => previewTick.value++);
  }

  void initializeEditForm() {
    if (penghuni != null) {
      final parsedDate = _parseDateFlexible(penghuni!.tanggalMasuk);
      selectedStartDate = parsedDate;
      tanggalMulaiController.text = parsedDate != null
          ? _formatDateId(parsedDate)
          : penghuni!.tanggalMasuk;

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

  // Method untuk set penghuni dari luar dan re-initialize form
  void setPenghuniAndInitialize(PenghuniModel penghuniModel) {
    penghuni = penghuniModel;
    initializeEditForm();
    if (!_hasLoadedPaidCoverageConstraint) {
      _loadPaidCoverageConstraint();
    }
    update(); // Trigger rebuild untuk GetBuilder
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
    return 'ℹ️ $covered bulan pertama sudah dibayar lunas. Sistem pembayaran yang tersedia disesuaikan agar tetap selaras dengan pembayaran sebelumnya (contoh: jika 6 bulan sudah lunas, pilih kelipatan 6 seperti 6 atau 12 bulan).';
  }

  void pilihSistemPembayaranPerpanjang(int bulan) {
    sistemPembayaranPerpanjangController.text = formatSistemPembayaranOption(
      bulan,
    );
    showAutoChangeNotification.value = false;
  }

  void pilihSistemPembayaranEdit(int bulan) {
    sistemPembayaranEditController.text = formatSistemPembayaranOption(bulan);
    showAutoChangeNotification.value = false;
  }

  // Date picker untuk tanggal mulai sewa
  Future<void> pickStartDate() async {
    final now = DateTime.now();
    final initialDate = selectedStartDate ?? now;

    final picked = await Get.dialog<DateTime>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Tanggal Mulai Sewa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (date) {
                    Get.back(result: date);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      selectedStartDate = picked;
      tanggalMulaiController.text = _formatDateId(picked);
      previewTick.value++;
    }
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
      try {
        HapticFeedback.lightImpact();
      } catch (_) {
        // Ignore haptic feedback errors
      }
      selectedTab.value = index;
      showAutoChangeNotification.value = false;
    }
  }

  // Fungsi Perpanjang Kontrak
  Future<void> perpanjangKontrak() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignore haptic feedback errors
    }

    // Dismiss keyboard after a small delay to avoid build errors
    Future.microtask(() {
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (_) {
        // Ignore if focus manager is not available
      }
    });

    if (tambahanDurasiController.text.isEmpty) {
      ToastHelper.showWarning(
        'Silakan isi tambahan durasi kontrak terlebih dahulu',
        title: 'Validasi Gagal',
      );
      return;
    }

    final p = penghuni;
    if (p == null) {
      ToastHelper.showError(
        'Data penghuni tidak ditemukan. Silakan kembali dan coba lagi.',
      );
      return;
    }

    await _ensurePaidCoverageConstraintLoaded();

    final tambahan = int.tryParse(tambahanDurasiController.text.trim()) ?? 0;
    if (tambahan <= 0) {
      ToastHelper.showWarning(
        'Tambahan durasi harus lebih dari 0 bulan',
        title: 'Validasi Gagal',
      );
      return;
    }

    if (tambahan > maxTambahanDurasiBulan) {
      Get.snackbar(
        'Validasi Gagal',
        'Tambahan durasi maksimal $maxTambahanDurasiBulan bulan. Anda memasukkan $tambahan bulan.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final latestKontrak = await _getLatestKontrakBase(p);
    final tanggalMasuk = latestKontrak.tanggalMasuk;
    if (tanggalMasuk == null) {
      Get.snackbar(
        'Error Data',
        'Tanggal mulai kontrak tidak valid. Silakan periksa data kontrak di menu Edit.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final durasiBaru = latestKontrak.durasiKontrak + tambahan;

    final rawSistemInput = sistemPembayaranPerpanjangController.text.trim();
    final sistemPembayaranBulanRaw = rawSistemInput.isEmpty
        ? latestKontrak.sistemPembayaranBulan
        : _parseSiklusBulan(rawSistemInput);

    if (sistemPembayaranBulanRaw <= 0) {
      ToastHelper.showWarning(
        'Format sistem pembayaran tidak valid. Silakan pilih sistem pembayaran dari daftar yang tersedia.',
        title: 'Validasi Gagal',
      );
      return;
    }

    final sistemPembayaranBulan = sistemPembayaranBulanRaw > durasiBaru
        ? durasiBaru
        : sistemPembayaranBulanRaw;

    if (sistemPembayaranBulan <= 0) {
      ToastHelper.showWarning(
        'Sistem pembayaran tidak valid. Silakan pilih ulang sistem pembayaran.',
        title: 'Validasi Gagal',
      );
      return;
    }

    if (!_isSiklusAllowedByPaidCoverage(sistemPembayaranBulan)) {
      final covered = paidCoveredPrefixMonths.value;
      Get.snackbar(
        'Sistem Pembayaran Tidak Sesuai',
        'Sistem pembayaran $sistemPembayaranBulan bulan tidak dapat digunakan karena $covered bulan pertama sudah lunas. Pilih sistem pembayaran yang merupakan kelipatan dari $covered bulan.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    try {
      isLoading.value = true;

      await _penghuniRepo.updatePenghuniKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        status: 'aktif',
      );

      await _tagihanRepo.sinkronTagihanKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        hargaBulanan: p.sewaBulanan.round(),
      );

      // Wait for data to be fully synced
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshRelatedData();

      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        // Ignore haptic feedback errors on unsupported devices
      }

      if (Get.isBottomSheetOpen ?? false) {
        Get.back(result: true);
      }

      Get.snackbar(
        'Berhasil! 🎉',
        'Kontrak berhasil diperpanjang $tambahan bulan. Data tagihan telah diperbarui.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      ToastHelper.showError(
        'Terjadi kesalahan saat memperpanjang kontrak: ${e.toString()}. Silakan coba lagi atau hubungi administrator.',
        title: 'Gagal Memperpanjang Kontrak',
        duration: const Duration(seconds: 5),
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
      final row = await _penghuniRepo.getPenghuniDetailById(p.id);
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
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignore haptic feedback errors
    }

    // Dismiss keyboard after a small delay to avoid build errors
    Future.microtask(() {
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (_) {
        // Ignore if focus manager is not available
      }
    });

    if (tanggalMulaiController.text.isEmpty ||
        durasiKontrakController.text.isEmpty ||
        sistemPembayaranEditController.text.isEmpty) {
      ToastHelper.showWarning(
        'Semua field harus diisi. Silakan lengkapi Tanggal Mulai, Durasi Kontrak, dan Sistem Pembayaran.',
        title: 'Validasi Gagal',
      );
      return;
    }

    final p = penghuni;
    if (p == null) {
      ToastHelper.showError(
        'Data penghuni tidak ditemukan. Silakan kembali dan coba lagi.',
      );
      return;
    }

    await _ensurePaidCoverageConstraintLoaded();

    final tanggalMasuk =
        selectedStartDate ??
        _parseDateFlexible(tanggalMulaiController.text.trim());
    if (tanggalMasuk == null) {
      Get.snackbar(
        'Tanggal Tidak Valid',
        'Format tanggal mulai tidak valid. Silakan pilih tanggal dari date picker.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final durasiBaru = int.tryParse(durasiKontrakController.text.trim()) ?? 0;
    if (durasiBaru <= 0) {
      ToastHelper.showWarning(
        'Durasi kontrak harus lebih dari 0 bulan',
        title: 'Validasi Gagal',
      );
      return;
    }

    if (durasiBaru > maxDurasiKontrakBulan) {
      Get.snackbar(
        'Validasi Gagal',
        'Durasi kontrak maksimal $maxDurasiKontrakBulan bulan (12 tahun). Anda memasukkan $durasiBaru bulan.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final sistemPembayaranBulanRaw = _parseSiklusBulan(
      sistemPembayaranEditController.text,
    );
    if (sistemPembayaranBulanRaw <= 0) {
      ToastHelper.showWarning(
        'Format sistem pembayaran tidak valid. Silakan pilih sistem pembayaran dari daftar yang tersedia.',
        title: 'Validasi Gagal',
      );
      return;
    }

    final sistemPembayaranBulan = sistemPembayaranBulanRaw > durasiBaru
        ? durasiBaru
        : sistemPembayaranBulanRaw;

    if (sistemPembayaranBulan <= 0) {
      ToastHelper.showWarning(
        'Sistem pembayaran tidak valid. Silakan pilih ulang sistem pembayaran.',
        title: 'Validasi Gagal',
      );
      return;
    }

    if (!_isSiklusAllowedByPaidCoverage(sistemPembayaranBulan)) {
      final covered = paidCoveredPrefixMonths.value;
      Get.snackbar(
        'Sistem Pembayaran Tidak Sesuai',
        'Sistem pembayaran $sistemPembayaranBulan bulan tidak dapat digunakan karena $covered bulan pertama sudah lunas. Pilih sistem pembayaran yang merupakan kelipatan dari $covered bulan.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    try {
      isLoading.value = true;

      await _penghuniRepo.updatePenghuniKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        status: 'aktif',
      );

      await _tagihanRepo.sinkronTagihanKontrak(
        penghuniId: p.id,
        tanggalMasuk: tanggalMasuk,
        durasiKontrakBulan: durasiBaru,
        sistemPembayaranBulan: sistemPembayaranBulan,
        hargaBulanan: p.sewaBulanan.round(),
      );

      // Wait for data to be fully synced
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshRelatedData();

      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        // Ignore haptic feedback errors on unsupported devices
      }

      if (Get.isBottomSheetOpen ?? false) {
        Get.back(result: true);
      }

      Get.snackbar(
        'Berhasil! 🎉',
        'Kontrak berhasil diperbarui. Data tagihan telah disesuaikan.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      ToastHelper.showError(
        'Terjadi kesalahan saat memperbarui kontrak: ${e.toString()}. Silakan coba lagi atau hubungi administrator.',
        title: 'Gagal Memperbarui Kontrak',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Akhiri Kontrak
  void akhiriKontrak() {
    // Tampilkan popup konfirmasi sesuai desain
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon warning dengan background merah muda
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFEF4444),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.priority_high,
                        color: Color(0xFFEF4444),
                        size: 32,
                        weight: 700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Akhiri Kontrak?',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              const Text(
                'Tindakan ini bersifat permanen dan akan\nlangsung berdampak pada akses penghuni.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Konsekuensi section
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Konsekuensi tindakan ini:',
                      style: TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Konsekuensi 1: Cabut Akses Kamar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.key_off,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Cabut Akses Kamar',
                                style: TextStyle(
                                  fontFamily: 'Helvetica Neue',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Penghuni tidak dapat lagi masuk ke kamar atau gedung.',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Konsekuensi 2: Nonaktifkan Akun
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_off,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Nonaktifkan Akun',
                                style: TextStyle(
                                  fontFamily: 'Helvetica Neue',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Akun penghuni pada aplikasi akan segera dibekukan.',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF374151),
                        side: const BorderSide(
                          color: Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final p = penghuni;
                        if (p == null) {
                          if (Get.isDialogOpen ?? false) Get.back();
                          ToastHelper.showError(
                            'Data penghuni tidak ditemukan. Silakan kembali dan coba lagi.',
                          );
                          return;
                        }

                        if (Get.isDialogOpen ?? false) Get.back(); // Close dialog

                        try {
                          HapticFeedback.mediumImpact();
                        } catch (_) {
                          // Ignore haptic feedback errors
                        }

                        try {
                          isLoading.value = true;

                          await _penghuniRepo.akhiriKontrakPenghuni(
                            penghuniId: p.id,
                            onDeleteUser: (_) {},
                          );

                          // Wait for data to be fully synced
                          await Future.delayed(const Duration(milliseconds: 500));
                          await _refreshRelatedData();

                          try {
                            HapticFeedback.heavyImpact();
                          } catch (_) {
                            // Ignore haptic feedback errors
                          }

                          if (Get.isBottomSheetOpen ?? false) {
                            Get.back(
                              result: 'kontrak_diakhiri',
                            ); // Return special value for ended contract
                          }

                          // Navigate back to penghuni list page
                          Get.until((route) => route.settings.name == Routes.penghuni);

                          ToastHelper.showSuccess(
                            'Kontrak ${p.nama} telah diakhiri. Akun penghuni telah dinonaktifkan.',
                            title: 'Kontrak Diakhiri',
                            duration: const Duration(seconds: 4),
                          );
                        } catch (e) {
                          ToastHelper.showError(
                            'Terjadi kesalahan saat mengakhiri kontrak: ${e.toString()}. Silakan coba lagi atau hubungi administrator.',
                            title: 'Gagal Mengakhiri Kontrak',
                            duration: const Duration(seconds: 5),
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Akhiri',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
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
    final startDate =
        selectedStartDate ?? _parseDateFlexible(tanggalMulaiController.text);
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
      showAutoChangeNotification.value = false;
      return;
    }

    final selected = selectedSistemPembayaranPerpanjangBulan;
    if (selected > 0 && options.contains(selected)) {
      showAutoChangeNotification.value = false;
      return;
    }

    final replacement = selected <= 0
        ? options.first
        : _findClosestOption(selected, options);

    // Show notification if auto-changed (only if user had a previous selection)
    if (selected > 0 &&
        replacement != selected &&
        sistemPembayaranPerpanjangController.text.isNotEmpty) {
      autoChangeMessage =
          'Sistem pembayaran otomatis disesuaikan dari ${formatSistemPembayaranOption(selected)} ke ${formatSistemPembayaranOption(replacement)} karena perubahan durasi kontrak.';
      showAutoChangeNotification.value = true;
    }

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
      showAutoChangeNotification.value = false;
      return;
    }

    final selected = selectedSistemPembayaranEditBulan;
    if (selected > 0 && options.contains(selected)) {
      showAutoChangeNotification.value = false;
      return;
    }

    final replacement = selected <= 0
        ? options.first
        : _findClosestOption(selected, options);

    // Show notification if auto-changed (only if user had a previous selection)
    if (selected > 0 &&
        replacement != selected &&
        sistemPembayaranEditController.text.isNotEmpty) {
      autoChangeMessage =
          'Sistem pembayaran otomatis disesuaikan dari ${formatSistemPembayaranOption(selected)} ke ${formatSistemPembayaranOption(replacement)} karena perubahan durasi kontrak.';
      showAutoChangeNotification.value = true;
    }

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

      final rows = await _tagihanRepo.getTagihanByPenghuniId(p.id);
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

    // Try ISO format first
    final iso = DateTime.tryParse(input);
    if (iso != null) {
      // Validate date is reasonable
      if (iso.year < 1900 || iso.year > 2100) return null;
      if (iso.month < 1 || iso.month > 12) return null;
      if (iso.day < 1 || iso.day > 31) return null;

      // Check for invalid dates like Feb 31
      try {
        final validated = DateTime(iso.year, iso.month, iso.day);
        if (validated.month != iso.month) return null; // Date rolled over
        return validated;
      } catch (_) {
        return null;
      }
    }

    // Try various date formats
    const patterns = ['d MMM yyyy', 'd MMMM yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd'];
    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern, 'id_ID').parseStrict(input);
        // Validate parsed date
        if (parsed.year < 1900 || parsed.year > 2100) continue;
        if (parsed.month < 1 || parsed.month > 12) continue;
        if (parsed.day < 1 || parsed.day > 31) continue;

        // Verify date didn't roll over
        final validated = DateTime(parsed.year, parsed.month, parsed.day);
        if (validated.month == parsed.month && validated.day == parsed.day) {
          return validated;
        }
      } catch (_) {
        // Try next pattern
      }

      try {
        final parsed = DateFormat(pattern).parseStrict(input);
        // Validate parsed date
        if (parsed.year < 1900 || parsed.year > 2100) continue;
        if (parsed.month < 1 || parsed.month > 12) continue;
        if (parsed.day < 1 || parsed.day > 31) continue;

        // Verify date didn't roll over
        final validated = DateTime(parsed.year, parsed.month, parsed.day);
        if (validated.month == parsed.month && validated.day == parsed.day) {
          return validated;
        }
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
