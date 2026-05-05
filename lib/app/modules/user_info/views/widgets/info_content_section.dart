import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_info_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import 'pengumuman_card.dart';
import 'peraturan_card.dart';

class InfoContentSection extends GetView<UserInfoController> {
  const InfoContentSection({super.key});

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Keluar', style: TextStyle(fontSize: context.fontSize(18))),
        content: Text('Apakah Anda yakin ingin keluar?', style: TextStyle(fontSize: context.fontSize(14))),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: Text('Batal', style: AppTextStyles.subtitle14.copyWith(fontSize: context.fontSize(14))),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red).copyWith(fontSize: context.fontSize(14))),
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
        padding: EdgeInsets.symmetric(horizontal: context.spacing(24), vertical: context.spacing(8)),
        child: controller.selectedTabIndex.value == 0
            ? _buildPengumumanList(context)
            : _buildPeraturanList(context),
      );
    });
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(Get.context!.spacing(24)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: Get.context!.iconSize(48), color: Colors.red),
            SizedBox(height: Get.context!.spacing(16)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(Colors.red).copyWith(
                fontSize: Get.context!.fontSize(14),
              ),
            ),
            SizedBox(height: Get.context!.spacing(16)),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
              ),
              child: Text('Coba Lagi', style: TextStyle(fontSize: Get.context!.fontSize(14))),
            ),
            SizedBox(height: Get.context!.spacing(12)),
            OutlinedButton(
              onPressed: () => _showLogoutDialog(Get.context!),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(8)),
                ),
              ),
              child: Text('Keluar', style: TextStyle(color: Colors.red, fontSize: Get.context!.fontSize(14))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengumumanList(BuildContext context) {
    if (controller.pengumumanList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(context.spacing(48)),
        child: Center(
          child: Text(
            'Belum ada pengumuman',
            style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)).copyWith(
              fontSize: context.fontSize(14),
            ),
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

  Widget _buildPeraturanList(BuildContext context) {
    if (controller.peraturanList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(context.spacing(48)),
        child: Center(
          child: Text(
            'Belum ada peraturan',
            style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)).copyWith(
              fontSize: context.fontSize(14),
            ),
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
