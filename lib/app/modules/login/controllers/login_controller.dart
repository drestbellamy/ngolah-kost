import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../services/supabase_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final usernameError = Rx<String?>(null);
  final passwordError = Rx<String?>(null);
  final supabaseService = SupabaseService();

  // SharedPreferences keys
  static const String _rememberMeKey = 'remember_me';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  AuthController get authController {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }
    return Get.put(AuthController(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
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

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shouldRemember = prefs.getBool(_rememberMeKey) ?? false;

      if (shouldRemember) {
        final savedUsername = prefs.getString(_savedUsernameKey) ?? '';
        final savedPassword = prefs.getString(_savedPasswordKey) ?? '';

        usernameController.text = savedUsername;
        passwordController.text = savedPassword;
        rememberMe.value = true;
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (rememberMe.value) {
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(
          _savedUsernameKey,
          usernameController.text.trim(),
        );
        await prefs.setString(
          _savedPasswordKey,
          passwordController.text.trim(),
        );
      } else {
        await prefs.remove(_rememberMeKey);
        await prefs.remove(_savedUsernameKey);
        await prefs.remove(_savedPasswordKey);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
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
      // Try to login directly
      final user = await supabaseService.login(username, password);

      if (user == null) {
        // Login failed - check if username exists
        final usernameExists = await supabaseService.checkUsernameExists(
          username,
        );

        if (!usernameExists) {
          // Username doesn't exist
          usernameError.value = 'Username salah';
          passwordError.value = null;
        } else {
          // Username exists, so password must be wrong
          usernameError.value = null;
          passwordError.value = 'Password salah';
        }
        return;
      }

      // Save credentials if remember me is checked
      await _saveCredentials();

      await authController.setUser(user);

      if (user.isAdmin) {
        Get.offAllNamed(Routes.home);
        return;
      }

      if (user.isUser) {
        Get.offAllNamed(Routes.userHome);
        return;
      }

      ToastHelper.showWarning(
        'Role akun tidak dikenali: ${user.role}',
        title: 'Role Tidak Dikenal',
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

      ToastHelper.showError(message);
    } finally {
      isLoading.value = false;
    }
  }
}
