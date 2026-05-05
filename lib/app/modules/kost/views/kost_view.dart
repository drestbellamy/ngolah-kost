import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/text_styles.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../controllers/kost_controller.dart';
import '../models/kost_model.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../routes/app_routes.dart';

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

            // Map View Button
            Builder(
              builder: (context) => Padding(
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
                      padding: EdgeInsets.symmetric(
                        vertical: context.padding(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // List Kost
            Expanded(
              child: FutureBuilder<List<KostModel>>(
                future: controller.kostFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat data kost: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.colored(AppColors.error),
                      ),
                    );
                  }

                  if (controller.kostList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada data kost',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400, // Regular
                          color: Color(0xFF718096),
                        ),
                      ),
                    );
                  }

                  return Obx(
                    () => ListView.builder(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.padding(context, 16),
                      ),
                      itemCount: controller.kostList.length,
                      itemBuilder: (context, index) {
                        final kost = controller.kostList[index];
                        return _buildKostCard(context, kost);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addKost,
        backgroundColor: const Color(0xFFFF9F66),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildKostCard(BuildContext context, KostModel kost) {
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
                borderRadius: BorderRadius.circular(context.borderRadius(6)),
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
    );
  }
}
