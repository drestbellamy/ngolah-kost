import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/storage_repository.dart';
import '../../../../repositories/repository_factory.dart';

class ProfilController extends GetxController {
  final authController = Get.find<AuthController>();
  final AuthRepository _authRepo;
  final StorageRepository _storageRepo;
  final imagePicker = ImagePicker();

  ProfilController({
    AuthRepository? authRepository,
    StorageRepository? storageRepository,
  }) : _authRepo = authRepository ?? RepositoryFactory.instance.authRepository,
       _storageRepo =
           storageRepository ?? RepositoryFactory.instance.storageRepository;

  // Observables for expanded states
  final isUsernameExpanded = false.obs;
  final isPasswordExpanded = false.obs;

  // Observable for profile photo
  final fotoProfilUrl = Rxn<String>();
  final isUploadingPhoto = false.obs;

  // TextEditingControllers
  final usernameController = TextEditingController(text: 'admin');
  final confirmPasswordForUsernameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables for password visibility
  final obscureConfirmPasswordForUsername = true.obs;
  final obscureOldPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onReady() {
    super.onReady();
    // Load profile lagi saat halaman siap, untuk memastikan data terbaru
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = authController.currentUser;
    if (user == null) {
      print('No user logged in');
      return;
    }

    try {
      print('Loading profile for user: ${user.id}');
      final userData = await _authRepo.getUserById(user.id);
      if (userData != null) {
        final fotoProfil = userData['foto_profil']?.toString();
        fotoProfilUrl.value = fotoProfil;
        usernameController.text = userData['username']?.toString() ?? 'admin';
        print('Profile loaded - foto_profil: $fotoProfil');
      } else {
        print('User data not found in database');
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadPhoto(image);
      }
    } catch (e) {
      ToastHelper.showError('Gagal mengambil foto: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadPhoto(image);
      }
    } catch (e) {
      ToastHelper.showError('Gagal memilih foto: $e');
    }
  }

  Future<void> uploadPhoto(XFile image) async {
    final user = authController.currentUser;
    if (user == null) {
      ToastHelper.showError('User tidak ditemukan');
      return;
    }

    try {
      isUploadingPhoto.value = true;
      Get.back(); // Close bottom sheet

      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;

      print('=== UPLOAD PHOTO DEBUG ===');
      print('User ID: ${user.id}');
      print('User username: ${user.username}');

      // Upload to storage
      final photoUrl = await _storageRepo.uploadFotoProfilAdmin(
        imageBytes: bytes,
        fileExt: fileExt,
        userId: user.id,
      );

      print('Photo uploaded to storage: $photoUrl');

      // Update database
      try {
        print('Attempting to update database...');
        await _authRepo.updateFotoProfilUser(
          userId: user.id,
          fotoProfilUrl: photoUrl,
        );
        print('✅ Database updated successfully!');

        // Verify update
        final userData = await _authRepo.getUserById(user.id);
        print('Verification - foto_profil in DB: ${userData?['foto_profil']}');
      } catch (dbError) {
        print('❌ Database update error: $dbError');
        throw Exception('Gagal update database: $dbError');
      }

      fotoProfilUrl.value = photoUrl;

      ToastHelper.showSuccess('Foto profil berhasil diperbarui');
    } catch (e) {
      print('❌ Upload photo error: $e');
      ToastHelper.showError('Gagal mengupload foto: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> deletePhoto() async {
    final user = authController.currentUser;
    if (user == null) {
      ToastHelper.showError('User tidak ditemukan');
      return;
    }

    try {
      Get.back(); // Close bottom sheet

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Hapus Foto Profil'),
          content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isUploadingPhoto.value = true;

      // Update database to set foto_profil to null
      await _authRepo.updateFotoProfilUser(
        userId: user.id,
        fotoProfilUrl: null,
      );

      fotoProfilUrl.value = null;

      ToastHelper.showSuccess('Foto profil berhasil dihapus');
    } catch (e) {
      ToastHelper.showError('Gagal menghapus foto: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  void toggleUsername() {
    isUsernameExpanded.value = !isUsernameExpanded.value;
    if (isUsernameExpanded.value) isPasswordExpanded.value = false;
  }

  void togglePassword() {
    isPasswordExpanded.value = !isPasswordExpanded.value;
    if (isPasswordExpanded.value) isUsernameExpanded.value = false;
  }

  void saveChanges() {
    // Tutup keyboard sebelum proses
    FocusManager.instance.primaryFocus?.unfocus();

    // Validasi input
    if (isUsernameExpanded.value) {
      final newUsername = usernameController.text.trim();
      final confirmPassword = confirmPasswordForUsernameController.text;

      if (newUsername.isEmpty) {
        ToastHelper.showError('Username tidak boleh kosong');
        return;
      }

      if (confirmPassword.isEmpty) {
        ToastHelper.showError(
          'Masukkan password untuk konfirmasi perubahan username',
        );
        return;
      }
    }

    if (isPasswordExpanded.value) {
      final oldPassword = oldPasswordController.text;
      final newPassword = newPasswordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (oldPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmPassword.isEmpty) {
        ToastHelper.showError('Semua field password harus diisi');
        return;
      }

      if (newPassword.length < 6) {
        ToastHelper.showError('Password baru minimal 6 karakter');
        return;
      }

      if (newPassword != confirmPassword) {
        ToastHelper.showError('Password baru dan konfirmasi tidak cocok');
        return;
      }
    }

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
            onPressed: () async {
              Get.back(); // Tutup dialog
              await _performSaveChanges();
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

  Future<void> _performSaveChanges() async {
    final user = authController.currentUser;
    if (user == null) {
      ToastHelper.showError('User tidak ditemukan');
      return;
    }

    try {
      isUploadingPhoto.value = true; // Reuse loading indicator

      if (isUsernameExpanded.value) {
        final newUsername = usernameController.text.trim();
        final confirmPassword = confirmPasswordForUsernameController.text;

        // Verify password first
        await _authRepo.verifyPassword(
          userId: user.id,
          password: confirmPassword,
        );

        // Then update username
        await _authRepo.updateUsername(
          userId: user.id,
          newUsername: newUsername,
        );
      }

      if (isPasswordExpanded.value) {
        final oldPassword = oldPasswordController.text;
        final newPassword = newPasswordController.text;

        await _authRepo.updatePassword(
          userId: user.id,
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
      }

      // Reset form
      isUsernameExpanded.value = false;
      isPasswordExpanded.value = false;
      confirmPasswordForUsernameController.clear();
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Reload profile
      await loadUserProfile();

      ToastHelper.showSuccess('Perubahan berhasil disimpan');
    } catch (e) {
      ToastHelper.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> logout() async {
    await authController.clearUser();
    ToastHelper.showInfo('Anda telah keluar', title: 'Logout');
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    usernameController.dispose();
    confirmPasswordForUsernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
