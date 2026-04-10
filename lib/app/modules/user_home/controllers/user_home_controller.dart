import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class UserHomeController extends GetxController {
  final authController = Get.find<AuthController>();

  // User info
  final userName = 'Ahmad'.obs;
  final roomNumber = 'A-101'.obs;
  final kostName = 'Green Valley Kost'.obs;
  final tenantStatus = 'Active Tenant'.obs;

  // Payment info
  final nextPaymentDate = '15 Jan 2024'.obs;
  final nextPaymentAmount = 'Rp 1.5 Juta'.obs;
  final dueDate = '20 Maret 2026'.obs;
  final dueAmount = 'Rp 1.500.000'.obs;

  // Payment summary
  final totalLunas = '14 Bulan'.obs;
  final totalBelumBayar = '1 Bulan'.obs;
  final lunasDate = 'Sejak Jan 2024'.obs;
  final belumBayarDate = 'Maret 2026'.obs;

  // Announcements
  final announcements = <Map<String, dynamic>>[
    {
      'title': 'Pemeliharaan Air',
      'description':
          'Air akan dimatikan sementara pada tanggal 27 Maret untuk pemeliharaan rutin.',
      'date': '15 Maret 2026',
      'icon': 'water',
      'color': 0xFF3B82F6,
    },
    {
      'title': 'Libur Lebaran',
      'description':
          'Kantor kost libur tanggal 30 Maret - 3 April. Untuk keadaan darurat hubungi nomor emergency.',
      'date': '15 Maret 2026',
      'icon': 'holiday',
      'color': 0xFF10B981,
    },
  ].obs;

  // Contact info
  final phoneNumber = '0812-3456-7890'.obs;
  final email = 'KostHummatech@gmail.com'.obs;

  void payNow() {
    Get.snackbar(
      'Info',
      'Fitur pembayaran akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B8E7A),
      colorText: Colors.white,
    );
  }

  void viewAllAnnouncements() {
    Get.snackbar(
      'Info',
      'Menampilkan semua pengumuman',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void callKostManagement() {
    Get.snackbar(
      'Info',
      'Menghubungi ${phoneNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void emailKostManagement() {
    Get.snackbar(
      'Info',
      'Mengirim email ke ${email.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
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
