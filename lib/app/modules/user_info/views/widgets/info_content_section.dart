import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_info_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import 'pengumuman_card.dart';
import 'peraturan_card.dart';

class InfoContentSection extends GetView<UserInfoController> {
  const InfoContentSection({super.key});

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal', style: AppTextStyles.subtitle14)),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: controller.selectedTabIndex.value == 0
            ? _buildPengumumanList()
            : _buildPeraturanList(),
      );
    });
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
              ),
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showLogoutDialog(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengumumanList() {
    if (controller.pengumumanList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Text(
            'Belum ada pengumuman',
            style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.pengumumanList.length,
      itemBuilder: (context, index) {
        final pengumuman = controller.pengumumanList[index];
        return PengumumanCard(pengumuman: pengumuman);
      },
    );
  }

  Widget _buildPeraturanList() {
    if (controller.peraturanList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Text(
            'Belum ada peraturan',
            style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.peraturanList.length,
      itemBuilder: (context, index) {
        final peraturan = controller.peraturanList[index];
        return PeraturanCard(peraturan: peraturan);
      },
    );
  }
}
