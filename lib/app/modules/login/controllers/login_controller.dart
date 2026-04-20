import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../../services/supabase_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final usernameError = Rx<String?>(null);
  final passwordError = Rx<String?>(null);
  final supabaseService = SupabaseService();
  AuthController get authController {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }
    return Get.put(AuthController(), permanent: true);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    // Tutup keyboard sebelum proses login
    FocusManager.instance.primaryFocus?.unfocus();
    
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    usernameError.value = null;
    passwordError.value = null;

    bool hasError = false;

    if (username.isEmpty) {
      usernameError.value = 'Username tidak boleh kosong';
      hasError = true;
    }
    if (password.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
      hasError = true;
    }

    if (hasError) return;

    isLoading.value = true;
    try {
      final user = await supabaseService.login(username, password);

      if (user == null) {
        usernameError.value = 'Username salah';
        passwordError.value = 'Password salah';
        return;
      }

      await authController.setUser(user);

      if (user.isAdmin) {
        Get.offAllNamed(Routes.home);
        return;
      }

      if (user.isUser) {
        Get.offAllNamed(Routes.userHome);
        return;
      }

      Get.snackbar(
        'Role Tidak Dikenal',
        'Role akun tidak dikenali: ${user.role}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      var message = 'Terjadi kesalahan saat login. Coba lagi.';

      if (e is PostgrestException) {
        final lowerMessage = e.message.toLowerCase();
        if (lowerMessage.contains('login_user_secure') ||
            lowerMessage.contains('function')) {
          if (lowerMessage.contains('crypt(text, text) does not exist')) {
            message =
                'Setup pgcrypto belum sesuai. Jalankan ulang SQL migrasi secure login versi terbaru.';
          } else {
            message = 'Setup keamanan login belum lengkap: ${e.message}';
          }
        } else {
          message = 'Error database: ${e.message}';
        }
      } else if (e is AuthException ||
          e.toString().toLowerCase().contains('socketexception') ||
          e.toString().toLowerCase().contains('failed host lookup')) {
        message =
            'Tidak dapat terhubung ke server. Periksa internet atau DNS jaringan Anda.';
      }

      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
