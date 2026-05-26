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
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTagihanItemShimmer(context, index),
              childCount: 5,
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
                      style: AppTextStyles.subtitle18
                          .colored(AppColors.textPrimary)
                          .copyWith(fontSize: context.fontSize(18)),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14
                          .colored(AppColors.textGray)
                          .copyWith(fontSize: context.fontSize(14)),
                    ),
                    SizedBox(height: context.spacing(16)),
                    ElevatedButton(
                      onPressed: () => controller.loadTagihanData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.borderRadius(8),
                          ),
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
                          borderRadius: BorderRadius.circular(
                            context.borderRadius(8),
                          ),
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
                      style: AppTextStyles.subtitle18
                          .colored(AppColors.textPrimary)
                          .copyWith(fontSize: context.fontSize(18)),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Text(
                      'Tidak ada tagihan yang perlu dibayar saat ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14
                          .colored(AppColors.textGray)
                          .copyWith(fontSize: context.fontSize(14)),
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

  Widget _buildTagihanItemShimmer(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(16)),
      padding: context.allPadding(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _ShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.screenWidth * 0.3,
                      height: context.fontSize(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: context.spacing(6)),
                    Container(
                      width: context.screenWidth * 0.25,
                      height: context.fontSize(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.borderRadius(20)),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing(12)),
            const Divider(),
            SizedBox(height: context.spacing(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: context.screenWidth * 0.2,
                  height: context.fontSize(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: context.screenWidth * 0.3,
                  height: context.fontSize(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing(12)),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.borderRadius(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
