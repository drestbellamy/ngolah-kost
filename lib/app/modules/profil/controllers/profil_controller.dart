import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ProfilController extends GetxController {
  // Observables for expanded states
  final isUsernameExpanded = false.obs;
  final isPasswordExpanded = false.obs;

  // TextEditingControllers
  final usernameController = TextEditingController(text: 'admin');
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables for password visibility
  final obscureOldPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;


  void toggleUsername() {
    isUsernameExpanded.value = !isUsernameExpanded.value;
    if (isUsernameExpanded.value) isPasswordExpanded.value = false;
  }

  void togglePassword() {
    isPasswordExpanded.value = !isPasswordExpanded.value;
    if (isPasswordExpanded.value) isUsernameExpanded.value = false;
  }

  void saveChanges() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text('Apakah Anda yakin ingin menyimpan perubahan ini?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Tutup pop-up dialog
              Get.back();

              // TODO: Logika penyimpanan data/API call bisa diimplementasikan di sini
              
              // Reset dan tutup form yang sedang terbuka
              isUsernameExpanded.value = false;
              isPasswordExpanded.value = false;
              
              // Kosongkan field kata sandi
              oldPasswordController.clear();
              newPasswordController.clear();
              confirmPasswordController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E8675),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void logout() {
    Get.snackbar(
      'Logout',
      'Anda telah keluar',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    usernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
