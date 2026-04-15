import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class UserProfilController extends GetxController {
  final userName = ''.obs;
  final userPhone = ''.obs;
  final nomorKamar = ''.obs;
  final hargaPerBulan = 0.obs;
  final tanggalMasuk = ''.obs;

  // Kontrak Info
  final durasiKontrak = ''.obs;
  final sistemPembayaran = ''.obs;
  final periodeKontrak = ''.obs;
  final totalTagihan = ''.obs;
  final perTagihan = 0.obs;
  final totalNilaiKontrak = 0.obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      // Delay simulasi loading
      await Future.delayed(const Duration(seconds: 1));

      // Dummy Data Ahmad
      userName.value = 'Ahmad';
      userPhone.value = '081234567890';

      // Kamar
      nomorKamar.value = 'A-102';
      hargaPerBulan.value = 1500000;

      // Kontrak
      durasiKontrak.value = '6 Bulan';
      sistemPembayaran.value = '2 Bulan Sekali';
      tanggalMasuk.value = '27 Maret 2026';
      periodeKontrak.value = '27 Maret 2026 - 27 September 2026';
      totalNilaiKontrak.value = 9000000;
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
