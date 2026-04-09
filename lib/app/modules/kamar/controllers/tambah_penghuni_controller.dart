import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/supabase_service.dart';

class TambahPenghuniController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  // Step management
  final currentStep = 1.obs;

  // Room info
  final kamarId = ''.obs;
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

  // Inline error states
  final namaError = RxnString();
  final teleponError = RxnString();
  final usernameError = RxnString();
  final passwordError = RxnString();
  final tanggalMasukError = RxnString();
  final durasiKontrakError = RxnString();
  final sistemPembayaranError = RxnString();
  final submitError = RxnString();
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load data from arguments
    if (Get.arguments != null) {
      final kamar = Get.arguments as Map<String, dynamic>;
      kamarId.value = kamar['kamar_id']?.toString() ?? '';
      nomorKamar.value = kamar['nomor'] ?? '';
      namaKost.value = kamar['namaKost']?.toString() ?? '-';
      hargaPerBulan.value = kamar['harga'] ?? '';

      // Extract numeric value from harga
      final hargaStr = hargaPerBulan.value.replaceAll(RegExp(r'[^0-9]'), '');
      hargaBulanan.value = int.tryParse(hargaStr) ?? 0;

      if (usernameController.text.trim().isEmpty) {
        _setInitialUsernamePreview();
      }
    }
  }

  Future<void> _setInitialUsernamePreview() async {
    final nextNumber = await _getNextOccupantNumber();
    usernameController.text = _buildPreviewUsername(
      namaKost.value,
      nomorKamar.value,
      occupantNumber: nextNumber,
    );
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
    submitError.value = null;
    if (currentStep.value == 1) {
      Get.back();
    } else {
      currentStep.value = 1;
    }
  }

  void handleNext() async {
    if (currentStep.value == 1) {
      if (_validateStep1()) {
        currentStep.value = 2;
      }
    } else {
      if (_validateStep2()) {
        await _submitForm();
      }
    }
  }

  bool _validateStep1() {
    final nama = namaController.text.trim();
    final telepon = teleponController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    namaError.value = nama.isEmpty
        ? 'Nama lengkap harus diisi'
        : nama.length > 50
        ? 'Nama maksimal 50 karakter'
        : null;

    teleponError.value = telepon.isEmpty
        ? 'Nomor telepon harus diisi'
        : telepon.length < 10
        ? 'Nomor telepon minimal 10 digit'
        : telepon.length > 15
        ? 'Nomor telepon maksimal 15 digit'
        : null;

    usernameError.value = username.isEmpty
        ? null
        : username.length < 4
        ? 'Username minimal 4 karakter'
        : username.length > 20
        ? 'Username maksimal 20 karakter'
        : null;

    passwordError.value = password.isEmpty
        ? 'Password harus diisi'
        : password.length < 6
        ? 'Password minimal 6 karakter'
        : password.length > 32
        ? 'Password maksimal 32 karakter'
        : null;

    return namaError.value == null &&
        teleponError.value == null &&
        usernameError.value == null &&
        passwordError.value == null;
  }

  bool _validateStep2() {
    tanggalMasukError.value = tanggalMasuk.value.isEmpty
        ? 'Tanggal mulai masuk harus dipilih'
        : null;
    durasiKontrakError.value = durasiKontrak.value.isEmpty
        ? 'Durasi kontrak harus dipilih'
        : null;
    sistemPembayaranError.value = sistemPembayaran.value.isEmpty
        ? 'Sistem pembayaran harus dipilih'
        : null;

    return tanggalMasukError.value == null &&
        durasiKontrakError.value == null &&
        sistemPembayaranError.value == null;
  }

  Future<void> _submitForm() async {
    if (isSubmitting.value) return;
    submitError.value = null;

    if (kamarId.value.isEmpty) {
      submitError.value = 'ID kamar tidak ditemukan';
      return;
    }

    if (tanggalMasukDate.value == null || durasiKontrakBulan.value <= 0) {
      submitError.value = 'Data kontrak belum lengkap';
      return;
    }

    final nama = namaController.text.trim();
    final telepon = teleponController.text.trim();
    var username = usernameController.text.trim();
    final password = passwordController.text;
    final kostPrefix = _buildKostPrefix(namaKost.value);

    final tanggalKeluarDate = DateTime(
      tanggalMasukDate.value!.year,
      tanggalMasukDate.value!.month + durasiKontrakBulan.value,
      tanggalMasukDate.value!.day,
    );

    isSubmitting.value = true;
    try {
      String userId = '';
      var retryCount = 0;

      while (retryCount < 5) {
        try {
          userId = await _supabaseService.createPenghuniUserSecure(
            nama: nama,
            noTlpn: telepon,
            username: username,
            password: password,
            kostPrefix: kostPrefix,
          );
          break;
        } on PostgrestException catch (e) {
          final err = e.toString().toLowerCase();
          if (_isDuplicateUsernameError(err) &&
              _isRoomBasedUsername(username)) {
            username = _nextRoomBasedUsername(username);
            retryCount++;
            continue;
          }
          rethrow;
        }
      }

      if (userId.isEmpty) {
        throw Exception('Gagal membuat akun penghuni');
      }

      usernameController.text = username;

      await _supabaseService.createPenghuni(
        userId: userId,
        kamarId: kamarId.value,
        durasiKontrak: durasiKontrakBulan.value,
        sistemPembayaranBulan: sistemPembayaranBulan.value,
        tanggalMasuk: tanggalMasukDate.value!,
        tanggalKeluar: tanggalKeluarDate,
        status: 'aktif',
      );

      await _supabaseService.updateKamarStatus(
        id: kamarId.value,
        status: 'ditempati',
      );
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      if (e is PostgrestException && _isDuplicateUsernameError(errorText)) {
        submitError.value = 'Username sudah digunakan. Gunakan username lain.';
      } else {
        submitError.value = 'Gagal menyimpan data penghuni. Coba lagi.';
      }
      isSubmitting.value = false;
      return;
    }

    isSubmitting.value = false;

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

  String _buildKostPrefix(String kostName) {
    final words = kostName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'KST';

    final initials = words.map((word) {
      final first = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      if (first.isEmpty) return '';
      return first[0].toUpperCase();
    }).join();

    final prefix = initials.isEmpty ? 'KST' : initials;
    return prefix.length > 5 ? prefix.substring(0, 5) : prefix;
  }

  String _sanitizeRoomCode(String roomNumber) {
    final cleaned = roomNumber.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    return cleaned.isEmpty ? 'KM' : cleaned;
  }

  Future<int> _getNextOccupantNumber() async {
    if (kamarId.value.isEmpty) return 1;
    try {
      final count = await _supabaseService.getPenghuniCountByKamarId(
        kamarId.value,
      );
      return count + 1;
    } catch (_) {
      return 1;
    }
  }

  String _buildPreviewUsername(
    String kostName,
    String roomNumber, {
    int occupantNumber = 1,
  }) {
    final prefix = _buildKostPrefix(kostName);
    final roomCode = _sanitizeRoomCode(roomNumber);
    return _buildRoomBasedUsername(prefix, roomCode, occupantNumber);
  }

  String _buildRoomBasedUsername(String prefix, String roomCode, int number) {
    final suffix = number > 1 ? '_$number' : '';
    final maxBaseLength = 20 - suffix.length;
    final baseRaw = '${prefix}_$roomCode';
    final safeBaseLength = maxBaseLength < 1 ? 1 : maxBaseLength;
    final base = baseRaw.length > safeBaseLength
        ? baseRaw.substring(0, safeBaseLength)
        : baseRaw;
    return '$base$suffix';
  }

  bool _isDuplicateUsernameError(String errorText) {
    return errorText.contains('username sudah digunakan') ||
        errorText.contains('already used') ||
        errorText.contains('duplicate');
  }

  bool _isRoomBasedUsername(String username) {
    return username.contains('_');
  }

  String _nextRoomBasedUsername(String username) {
    final regex = RegExp(r'^(.*?)(?:_(\d+))?$');
    final match = regex.firstMatch(username);

    if (match == null) {
      final fallback = '${username}_2';
      return fallback.length > 20 ? fallback.substring(0, 20) : fallback;
    }

    final root = match.group(1) ?? username;
    final number = int.tryParse(match.group(2) ?? '') ?? 1;
    final next = number + 1;
    final suffix = '_$next';
    final maxRootLength = 20 - suffix.length;
    final safeRootLength = maxRootLength < 1 ? 1 : maxRootLength;
    final trimmedRoot = root.length > safeRootLength
        ? root.substring(0, safeRootLength)
        : root;
    return '$trimmedRoot$suffix';
  }

  Future<void> regenerateUsernamePreview() async {
    final nextNumber = await _getNextOccupantNumber();
    usernameController.text = _buildPreviewUsername(
      namaKost.value,
      nomorKamar.value,
      occupantNumber: nextNumber,
    );
    usernameError.value = null;
    submitError.value = null;
  }

  void setTanggalMasuk(DateTime date) {
    submitError.value = null;
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
    tanggalMasukError.value = null;
    _calculateTanggalBerakhir();
  }

  void setDurasiKontrak(String durasi) {
    submitError.value = null;
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
    durasiKontrakError.value = null;
    sistemPembayaranError.value = null;

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
    submitError.value = null;
    sistemPembayaran.value = sistem;
    sistemPembayaranError.value = null;

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

  void onNamaChanged(String value) {
    submitError.value = null;
    if (namaError.value != null) {
      final v = value.trim();
      namaError.value = v.isEmpty
          ? 'Nama lengkap harus diisi'
          : v.length > 50
          ? 'Nama maksimal 50 karakter'
          : null;
    }
  }

  void onTeleponChanged(String value) {
    submitError.value = null;
    if (teleponError.value != null) {
      teleponError.value = value.isEmpty
          ? 'Nomor telepon harus diisi'
          : value.length < 10
          ? 'Nomor telepon minimal 10 digit'
          : value.length > 15
          ? 'Nomor telepon maksimal 15 digit'
          : null;
    }
  }

  void onUsernameChanged(String value) {
    submitError.value = null;
    if (usernameError.value != null) {
      final v = value.trim();
      usernameError.value = v.isEmpty
          ? null
          : v.length < 4
          ? 'Username minimal 4 karakter'
          : v.length > 20
          ? 'Username maksimal 20 karakter'
          : null;
    }
  }

  void onPasswordChanged(String value) {
    submitError.value = null;
    if (passwordError.value != null) {
      passwordError.value = value.isEmpty
          ? 'Password harus diisi'
          : value.length < 6
          ? 'Password minimal 6 karakter'
          : value.length > 32
          ? 'Password maksimal 32 karakter'
          : null;
    }
  }
}
