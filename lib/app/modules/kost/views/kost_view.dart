import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/text_styles.dart';
import '../../../core/values/app_colors.dart';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.kostMap),
                  icon: const Icon(Icons.map, size: 20),
                  label: Text(
                    'Lihat Peta Lokasi Kost',
                    style: AppTextStyles.buttonMedium,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7F),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.kostList.length,
                      itemBuilder: (context, index) {
                        final kost = controller.kostList[index];
                        return _buildKostCard(kost);
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

  Widget _buildKostCard(KostModel kost) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.kamar, arguments: kost),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Color(0xFF6B8E7F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kost.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.header16.colored(AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kost.address,
                              style: AppTextStyles.body12.colored(AppColors.textTertiary),
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
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF718096),
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'edit') {
                      controller.editKost(kost.id);
                    } else if (value == 'delete') {
                      controller.deleteKost(kost.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 20,
                            color: Color.fromARGB(255, 54, 54, 54),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit',
                            style: AppTextStyles.bodyMedium.colored(const Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Color(0xFFE53E3E),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: AppTextStyles.bodyMedium.colored(const Color(0xFFE53E3E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Room count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${kost.roomCount} Rooms',
                style: AppTextStyles.body12.colored(AppColors.successLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
