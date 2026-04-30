import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_tagihan_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'tagihan_card.dart';

class TagihanListSection extends GetView<UserTagihanController> {
  const TagihanListSection({super.key});

  void _showLogoutDialog() {
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

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: context.allPadding(24),
      sliver: Obx(() {
        if (controller.isLoading.value) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: context.allPadding(40),
                child: const CircularProgressIndicator(color: Color(0xFF6B8E7A)),
              ),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: context.allPadding(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: context.iconSize(48),
                      color: const Color(0xFFEF4444),
                    ),
                    SizedBox(height: context.spacing(16)),
                    Text(
                      'Terjadi Kesalahan',
                      style: AppTextStyles.subtitle18.colored(AppColors.textPrimary).copyWith(
                        fontSize: context.fontSize(18),
                      ),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14.colored(AppColors.textGray).copyWith(
                        fontSize: context.fontSize(14),
                      ),
                    ),
                    SizedBox(height: context.spacing(16)),
                    ElevatedButton(
                      onPressed: () => controller.loadTagihanData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius(8)),
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: context.spacing(12)),
                    OutlinedButton(
                      onPressed: () => _showLogoutDialog(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius(8)),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (controller.tagihanBelumDibayar.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: context.allPadding(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: context.iconSize(48),
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(height: context.spacing(16)),
                    Text(
                      'Semua Tagihan Lunas',
                      style: AppTextStyles.subtitle18.colored(AppColors.textPrimary).copyWith(
                        fontSize: context.fontSize(18),
                      ),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Text(
                      'Tidak ada tagihan yang perlu dibayar saat ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14.colored(AppColors.textGray).copyWith(
                        fontSize: context.fontSize(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final tagihan = controller.tagihanBelumDibayar[index];
            return TagihanCard(tagihan: tagihan);
          }, childCount: controller.tagihanBelumDibayar.length),
        );
      }),
    );
  }
}
