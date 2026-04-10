import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../routes/app_routes.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildUsernameSection(),
                  const SizedBox(height: 16),
                  _buildPasswordSection(),
                  const SizedBox(height: 24),
                  // Render Save Button if any section is expanded
                  Obx(() {
                    if (controller.isUsernameExpanded.value ||
                        controller.isPasswordExpanded.value) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.saveChanges,
                            icon: const Icon(Icons.save_outlined, size: 20),
                            label: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E8675),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5E8675),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Bubble Backgrounds
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Header Content
          Padding(
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 40,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.offAllNamed(Routes.home),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kelola akun Anda',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(Get.context!).unfocus();
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Foto Profil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildPhotoOption(
                              icon: Icons.camera_alt_outlined,
                              iconColor: const Color(0xFF5E8675),
                              iconBgColor: const Color(
                                0xFF5E8675,
                              ).withOpacity(0.1),
                              title: 'Ambil Foto',
                              subtitle: 'Gunakan kamera',
                              onTap: () => Get.back(),
                            ),
                            const SizedBox(height: 12),
                            _buildPhotoOption(
                              icon: Icons.photo_library_outlined,
                              iconColor: const Color(0xFFF59E0B),
                              iconBgColor: const Color(
                                0xFFF59E0B,
                              ).withOpacity(0.1),
                              title: 'Pilih dari Galeri',
                              subtitle: 'Pilih foto yang sudah ada',
                              onTap: () => Get.back(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF5E8675),
                      child: Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Administrator',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Obx(() {
      final isExpanded = controller.isUsernameExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              onTap: controller.toggleUsername,
              leading: const Icon(
                CupertinoIcons.person,
                color: Color(0xFF5E8675),
                size: 24,
              ),
              title: const Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: Icon(
                isExpanded
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.usernameController,
                      decoration: InputDecoration(
                        hintText: 'admin',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF5E8675),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPasswordSection() {
    return Obx(() {
      final isExpanded = controller.isPasswordExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              onTap: controller.togglePassword,
              leading: const Icon(
                CupertinoIcons.lock,
                color: Color(0xFF5E8675),
                size: 24,
              ),
              title: const Text(
                'Ubah Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: Icon(
                isExpanded
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildPasswordField(
                      label: 'Password Lama',
                      hint: 'Masukkan password lama',
                      controllerField: controller.oldPasswordController,
                      obscureValue: controller.obscureOldPassword,
                    ),
                    const SizedBox(height: 16),
                    ..._buildPasswordField(
                      label: 'Password Baru',
                      hint: 'Masukkan password baru',
                      helpText: 'Minimal 6 karakter',
                      controllerField: controller.newPasswordController,
                      obscureValue: controller.obscureNewPassword,
                    ),
                    const SizedBox(height: 16),
                    ..._buildPasswordField(
                      label: 'Konfirmasi Password Baru',
                      hint: 'Ulangi password baru',
                      controllerField: controller.confirmPasswordController,
                      obscureValue: controller.obscureConfirmPassword,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controllerField,
    required RxBool obscureValue,
    String? helpText,
  }) {
    return [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      Obx(
        () => TextFormField(
          controller: controllerField,
          obscureText: obscureValue.value,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF5E8675),
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureValue.value
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                color: Colors.grey,
              ),
              onPressed: () => obscureValue.value = !obscureValue.value,
            ),
          ),
        ),
      ),
      if (helpText != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            helpText,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
    ];
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Keluar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        highlightColor: Colors.black.withOpacity(0.05),
        splashColor: Colors.black.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
