import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import 'package:intl/intl.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../../../../repositories/pembayaran_repository.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../services/supabase_service.dart';

class UserHomeController extends GetxController {
  final AuthRepository _authRepo;
  final PenghuniRepository _penghuniRepo;
  final TagihanRepository _tagihanRepo;
  final PembayaranRepository _pembayaranRepo;
  final authController = Get.find<AuthController>();

  UserHomeController({
    AuthRepository? authRepository,
    PenghuniRepository? penghuniRepository,
    TagihanRepository? tagihanRepository,
    PembayaranRepository? pembayaranRepository,
  }) : _authRepo = authRepository ?? RepositoryFactory.instance.authRepository,
       _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _tagihanRepo =
           tagihanRepository ?? RepositoryFactory.instance.tagihanRepository,
       _pembayaranRepo =
           pembayaranRepository ??
           RepositoryFactory.instance.pembayaranRepository;

  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final fotoProfilUrl = Rxn<String>();
  final namaKost = 'Ngolah Kost'.obs; // Observable for kost name

  // Computed properties from profile
  String get userName => userProfile.value?.nama ?? 'User';
  String get roomNumber => userProfile.value?.nomorKamar ?? '-';
  String get kostName => namaKost.value; // Get from observable
  String get tenantStatus =>
      userProfile.value?.status == 'aktif' ? 'Active Tenant' : 'Inactive';

  // Payment info - computed from profile
  String get nextPaymentDate {
    final profile = userProfile.value;
    if (profile == null) return '-';
    try {
      final masuk = DateTime.parse(profile.tanggalMasuk);
      return DateFormat('d MMM yyyy', 'id_ID').format(masuk);
    } catch (e) {
      return '-';
    }
  }

  String get nextPaymentAmount {
    final profile = userProfile.value;
    if (profile == null) return 'Rp 0';
    return _formatCurrency(profile.hargaPerBulan);
  }

  // Tagihan info
  final dueDate = ''.obs;
  final dueAmount = 0.obs;
  final hasDuePayment = false.obs;
  final dueStatus = ''.obs; // 'overdue', 'soon', 'upcoming', 'none', 'pending'
  final daysUntilDue = 0.obs;
  final hasPendingPayment = false.obs; // Track if there's pending payment

  // Payment summary
  final totalLunas = 0.obs;
  final totalBelumBayar = 0.obs;
  final lunasDate = ''.obs;
  final belumBayarDate = ''.obs;

  // Announcements
  final announcements = <Map<String, dynamic>>[].obs;

  // Contact info
  final phoneNumber = '0812-3456-7890'.obs;
  final email = 'KostHummatech@gmail.com'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    // Refresh notifications when home page is opened
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      notificationController.checkNotifications();
    }
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = authController.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User tidak ditemukan');
      }

      // Fetch user data untuk foto profil
      final userData = await _authRepo.getUserById(userId);
      if (userData != null) {
        fotoProfilUrl.value = userData['foto_profil']?.toString();
      }

      // Fetch user profile
      final profileData = await _penghuniRepo.getPenghuniByUserId(userId);
      if (profileData != null) {
        userProfile.value = UserProfileModel.fromMap(profileData);

        // Fetch kost name
        final kostId = profileData['kost_id']?.toString();
        if (kostId != null && kostId.isNotEmpty) {
          // TODO: Replace with KostRepository.getKostById when available
          final kostData = await SupabaseService().supabase
              .from('kost')
              .select('nama_kost')
              .eq('id', kostId)
              .maybeSingle();

          if (kostData != null) {
            namaKost.value = kostData['nama_kost']?.toString() ?? 'Ngolah Kost';
          }
        }

        // Fetch tagihan data
        await _fetchTagihanData(profileData['id']?.toString() ?? '');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchTagihanData(String penghuniId) async {
    if (penghuniId.isEmpty) return;

    try {
      final tagihanList = await _tagihanRepo.getTagihanByPenghuniId(penghuniId);

      // Get pembayaran data to check for pending payments
      final pembayaranList = await _pembayaranRepo.getPembayaranByPenghuniId(
        penghuniId,
      );

      // Count lunas and belum bayar
      int lunas = 0;
      int belumBayar = 0;
      DateTime? nearestDue;
      int? nearestAmount;
      bool hasPending = false;

      final now = DateTime.now();

      for (final tagihan in tagihanList) {
        final status = tagihan['status']?.toString() ?? '';
        final tagihanId = tagihan['id']?.toString() ?? '';

        // Check if this tagihan has pending payment
        final hasPendingPayment = pembayaranList.any(
          (p) =>
              p['tagihan_id']?.toString() == tagihanId &&
              p['status'] == 'pending',
        );

        if (status == 'lunas') {
          lunas++;
        } else if (status == 'belum_dibayar') {
          if (hasPendingPayment) {
            // Don't count as belum bayar if has pending payment
            hasPending = true;
          } else {
            belumBayar++;
          }

          // Find nearest due date (only for non-pending)
          if (!hasPendingPayment) {
            final bulan = tagihan['bulan'] as int? ?? 0;
            final tahun = tagihan['tahun'] as int? ?? 0;

            // Get jatuh tempo from database or fallback to 20th of month
            DateTime dueDateTime;
            if (tagihan['tanggal_jatuh_tempo'] != null) {
              dueDateTime =
                  DateTime.tryParse(
                    tagihan['tanggal_jatuh_tempo'].toString(),
                  ) ??
                  DateTime(tahun, bulan, 20);
            } else {
              dueDateTime = DateTime(tahun, bulan, 20);
            }

            if (nearestDue == null || dueDateTime.isBefore(nearestDue)) {
              nearestDue = dueDateTime;
              nearestAmount = tagihan['jumlah'] as int? ?? 0;
            }
          }
        }
      }

      totalLunas.value = lunas;
      totalBelumBayar.value = belumBayar;
      hasPendingPayment.value = hasPending;

      if (hasPending && nearestDue == null) {
        // If only pending payment exists, show pending status
        hasDuePayment.value = true;
        dueStatus.value = 'pending';
        dueDate.value = 'Menunggu Verifikasi';
        dueAmount.value = 0;
      } else if (nearestDue != null && nearestAmount != null) {
        hasDuePayment.value = true;
        dueDate.value = DateFormat('d MMMM yyyy', 'id_ID').format(nearestDue);
        dueAmount.value = nearestAmount;

        // Calculate days until due and determine status
        final difference = nearestDue.difference(now).inDays;
        daysUntilDue.value = difference;

        if (difference < 0) {
          dueStatus.value = 'overdue'; // Sudah lewat jatuh tempo
        } else if (difference <= 3) {
          dueStatus.value = 'soon'; // Segera jatuh tempo (3 hari atau kurang)
        } else {
          dueStatus.value = 'upcoming'; // Belum jatuh tempo
        }
      } else {
        hasDuePayment.value = false;
        dueStatus.value = 'none'; // Tidak ada tagihan
      }

      // Set summary dates
      if (lunas > 0) {
        lunasDate.value = 'Total $lunas pembayaran';
      }
      if (belumBayar > 0) {
        belumBayarDate.value = 'Total $belumBayar tagihan';
      }
    } catch (e) {
      print('Error fetching tagihan: $e');
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void payNow() {
    Get.toNamed(Routes.userTagihan);
  }

  void viewAllAnnouncements() {
    ToastHelper.showInfo('Menampilkan semua pengumuman');
  }

  void callKostManagement() {
    ToastHelper.showInfo('Menghubungi ${phoneNumber.value}');
  }

  void emailKostManagement() {
    ToastHelper.showInfo('Mengirim email ke ${email.value}');
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Anda yakin ingin logout?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F2F2F),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    Get.back(); // Close dialog
    await authController.clearUser();
    Get.offAllNamed(Routes.login);
  }
}
