import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/text_styles.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../controllers/kost_controller.dart';
import '../models/kost_model.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../routes/app_routes.dart';
import 'widgets/kost_shimmer_widget.dart';

class KostView extends GetView<KostController> {
  const KostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            const CustomHeader(
              title: 'Unit Kost',
              subtitle: 'Kelola unit kost Anda',
              showBackButton: false,
            ),

            // Content
            Expanded(
              child: FutureBuilder<List<KostModel>>(
                future: controller.kostFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const KostShimmerWidget();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat data kost: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.colored(
                          AppColors.error,
                        ),
                      ),
                    );
                  }

                  return Obx(() {
                    if (controller.kostList.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildKostListContent(context);
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.kostList.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: controller.addKost,
                backgroundColor: const Color(0xFFFF9F66),
                child: const Icon(Icons.add, color: Colors.white),
              ).animate().scale(
                delay: 200.ms,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ).animate().scale(delay: 200.ms, duration: 400.ms).fadeIn(),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Unit Kost',
              style: AppTextStyles.header16.colored(AppColors.textPrimary),
            ).animate().slideY(begin: 0.5, delay: 300.ms).fadeIn(),
            const SizedBox(height: 12),
            Text(
              'Tambahkan unit kost pertama Anda\nuntuk mulai mengelola properti.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14
                  .colored(AppColors.textGray)
                  .copyWith(height: 1.5),
            ).animate().slideY(begin: 0.5, delay: 400.ms).fadeIn(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.addKost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tambah Kost',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ).animate().scale(delay: 500.ms).fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildKostListContent(BuildContext context) {
    return Column(
      children: [
        // Map View Button
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.padding(16),
            context.padding(16),
            context.padding(16),
            0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.kostMap),
              icon: Icon(Icons.map, size: context.iconSize(20)),
              label: Text(
                'Lihat Peta Lokasi Kost',
                style: AppTextStyles.buttonMedium.copyWith(
                  fontSize: context.fontSize(14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7F),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: context.padding(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius(12)),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
        // Kost List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.padding(context, 16)),
            itemCount: controller.kostList.length,
            itemBuilder: (context, index) {
              final kost = controller.kostList[index];
              return _buildKostCard(context, kost, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKostCard(BuildContext context, KostModel kost, int index) {
    return GestureDetector(
          onTap: () => Get.toNamed(Routes.kamar, arguments: kost),
          child: Container(
            margin: EdgeInsets.only(bottom: context.padding(16)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: context.allPadding(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0ED),
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(12),
                        ),
                      ),
                      child: Icon(
                        Icons.apartment,
                        color: const Color(0xFF6B8E7F),
                        size: context.iconSize(24),
                      ),
                    ),
                    SizedBox(width: context.spacing(12)),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kost.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.header16
                                .colored(AppColors.textSecondary)
                                .copyWith(fontSize: context.fontSize(16)),
                          ),
                          SizedBox(height: context.spacing(4)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: context.iconSize(14),
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: context.spacing(4)),
                              Expanded(
                                child: Text(
                                  kost.address,
                                  style: AppTextStyles.body12
                                      .colored(AppColors.textTertiary)
                                      .copyWith(fontSize: context.fontSize(12)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Three-dot menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: const Color(0xFF718096),
                        size: context.iconSize(24),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(12),
                        ),
                      ),
                      offset: Offset(0, context.padding(40)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          controller.editKost(kost.id);
                        } else if (value == 'delete') {
                          controller.deleteKost(kost.id);
                        }
                      },
                      itemBuilder: (BuildContext menuContext) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: context.iconSize(20),
                                color: const Color.fromARGB(255, 54, 54, 54),
                              ),
                              SizedBox(width: context.spacing(12)),
                              Text(
                                'Edit',
                                style: AppTextStyles.bodyMedium
                                    .colored(const Color(0xFF2D3748))
                                    .copyWith(fontSize: context.fontSize(14)),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: context.iconSize(20),
                                color: const Color(0xFFE53E3E),
                              ),
                              SizedBox(width: context.spacing(12)),
                              Text(
                                'Delete',
                                style: AppTextStyles.bodyMedium
                                    .colored(const Color(0xFFE53E3E))
                                    .copyWith(fontSize: context.fontSize(14)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(12)),
                // Room count
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.padding(8),
                    vertical: context.padding(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(
                      context.borderRadius(6),
                    ),
                  ),
                  child: Text(
                    '${kost.roomCount} Rooms',
                    style: AppTextStyles.body12
                        .colored(AppColors.successLight)
                        .copyWith(fontSize: context.fontSize(12)),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
