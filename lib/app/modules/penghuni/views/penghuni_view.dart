import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/penghuni_controller.dart';
import '../models/penghuni_model.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../riwayat_penghuni/views/riwayat_penghuni_view.dart';
import '../../riwayat_penghuni/bindings/riwayat_penghuni_binding.dart';
import 'widgets/penghuni_shimmer_widget.dart';

class PenghuniView extends GetView<PenghuniController> {
  const PenghuniView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B8E7A), Color(0xFF4F6F5D)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.borderRadius(24)),
                  bottomRight: Radius.circular(context.borderRadius(24)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -64,
                    top: -64,
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -48,
                    bottom: -48,
                    child: Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.padding(24),
                      MediaQuery.of(context).padding.top + context.padding(24),
                      context.padding(24),
                      context.padding(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Penghuni',
                              style: AppTextStyles.headlineSmall
                                  .weighted(FontWeight.w700)
                                  .colored(Colors.white)
                                  .copyWith(fontSize: context.fontSize(24)),
                            ),
                            SizedBox(height: context.spacing(4)),
                            Obx(
                              () => Text(
                                '${controller.penghuniList.length} penghuni',
                                style: AppTextStyles.subtitle14
                                    .colored(AppColors.primaryLight)
                                    .copyWith(
                                      fontSize: context.fontSize(14),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: context.horizontalPadding(16),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.searchPenghuni,
                decoration: InputDecoration(
                  hintText: 'Cari penghuni, kamar, atau kost...',
                  hintStyle: AppTextStyles.body14
                      .colored(const Color(0xFF9CA3AF))
                      .copyWith(fontSize: context.fontSize(14)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF9CA3AF),
                    size: context.iconSize(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.borderRadius(12),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: context.symmetricPadding(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Kost Dropdown and History Button
            Padding(
              padding: context.horizontalPadding(16),
              child: Row(
                children: [
                  // Filter Dropdown
                  Expanded(
                    child: Obx(() {
                      final kostOptions = controller.kostFilterOptions;
                      final selectedKost = controller.selectedFilter.value;
                      final selectedCount = controller.getPenghuniCountByKost(selectedKost);
                      
                      return Container(
                        padding: context.symmetricPadding(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.borderRadius(12)),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.apartment_rounded,
                                size: context.iconSize(20),
                                color: const Color(0xFF6B8E7A),
                              ),
                            ),
                            SizedBox(width: context.spacing(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kost',
                                    style: AppTextStyles.body12.copyWith(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: context.fontSize(11),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedKost,
                                          style: AppTextStyles.body14.copyWith(
                                            color: const Color(0xFF2D3748),
                                            fontSize: context.fontSize(14),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6B8E7A).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$selectedCount',
                                          style: TextStyle(
                                            fontSize: context.fontSize(12),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF6B8E7A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFF6B7280),
                                size: context.iconSize(24),
                              ),
                              color: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              offset: const Offset(0, 8),
                              itemBuilder: (BuildContext context) {
                                return kostOptions.map((String kost) {
                                  final count = controller.getPenghuniCountByKost(kost);
                                  final isSelected = kost == selectedKost;
                                  
                                  return PopupMenuItem<String>(
                                    value: kost,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? const Color(0xFF6B8E7A).withValues(alpha: 0.08)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                size: 18,
                                                color: const Color(0xFF6B8E7A),
                                              ),
                                            ),
                                          Expanded(
                                            child: Text(
                                              kost,
                                              style: TextStyle(
                                                color: isSelected 
                                                    ? const Color(0xFF6B8E7A)
                                                    : const Color(0xFF2D3748),
                                                fontWeight: isSelected 
                                                    ? FontWeight.w600 
                                                    : FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF6B8E7A).withValues(alpha: 0.15)
                                                  : const Color(0xFFF3F4F6),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              count.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? const Color(0xFF6B8E7A)
                                                    : const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onSelected: (String newValue) {
                                controller.filterByKost(newValue);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  
                  SizedBox(width: context.spacing(12)),
                  
                  // History Button
                  GestureDetector(
                    onTap: () {
                      RiwayatPenghuniBinding().dependencies();
                      Get.to(() => const RiwayatPenghuniView());
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.borderRadius(12)),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: context.iconSize(24),
                            color: const Color(0xFF6B8E7A),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List Penghuni
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const PenghuniShimmerWidget();
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        controller.errorMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.colored(
                          const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  );
                }

                if (controller.filteredPenghuniList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 70),
                        padding: const EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 24,
                        ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLighter,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.people_outline,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                )
                                .animate()
                                .scale(delay: 200.ms, duration: 400.ms)
                                .fadeIn(),
                            const SizedBox(height: 24),
                            Text(
                                  'Belum Ada Penghuni',
                                  style: AppTextStyles.header16.colored(
                                    AppColors.textPrimary,
                                  ),
                                )
                                .animate()
                                .slideY(begin: 0.5, delay: 300.ms)
                                .fadeIn(),
                            const SizedBox(height: 12),
                            Text(
                              'Tambahkan data penghuni masa sewa\ndan tagihan dari penghuni.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body14
                                  .colored(AppColors.textGray)
                                  .copyWith(height: 1.5),
                            ).animate().slideY(begin: 0.5, delay: 400.ms).fadeIn(),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: controller.tambahPenghuni,
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
                                'Tambah Penghuni',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ).animate().scale(delay: 500.ms).fadeIn(),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms);
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPenghuniData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredPenghuniList.length,
                    itemBuilder: (context, index) {
                      final penghuni = controller.filteredPenghuniList[index];
                      return _buildPenghuniCard(penghuni, index);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildPenghuniCard(PenghuniModel penghuni, int index) {
    final roomLabel = controller.getRoomDisplayLabel(penghuni);
    final occupancyLabel = controller.getOccupancyStatusLabel(penghuni);

    return Builder(
          builder: (context) => GestureDetector(
            onTap: () => controller.goToDetail(penghuni),
            child: Container(
              margin: EdgeInsets.only(bottom: context.spacing(12)),
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
                      Container(
                        width: context.iconSize(48),
                        height: context.iconSize(48),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0ED),
                          borderRadius: BorderRadius.circular(
                            context.borderRadius(12),
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: const Color(0xFF6B8E7F),
                          size: context.iconSize(24),
                        ),
                      ),
                      SizedBox(width: context.spacing(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              penghuni.nama,
                              style: AppTextStyles.subtitle16
                                  .colored(const Color(0xFF2D3748))
                                  .copyWith(fontSize: context.fontSize(16)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: context.spacing(4)),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: context.iconSize(14),
                                  color: const Color(0xFF718096),
                                ),
                                SizedBox(width: context.spacing(4)),
                                Expanded(
                                  child: Text(
                                    penghuni.namaKost,
                                    style: AppTextStyles.body12
                                        .colored(const Color(0xFF718096))
                                        .copyWith(
                                          fontSize: context.fontSize(12),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing(2)),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: context.iconSize(14),
                                  color: const Color(0xFF718096),
                                ),
                                SizedBox(width: context.spacing(4)),
                                Text(
                                  penghuni.noTelepon,
                                  style: AppTextStyles.body12
                                      .colored(const Color(0xFF718096))
                                      .copyWith(fontSize: context.fontSize(12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: context.symmetricPadding(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: context.iconSize(12),
                                  color: const Color(0xFF10B981),
                                ),
                                SizedBox(width: context.spacing(4)),
                                Text(
                                  occupancyLabel,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: context.fontSize(11),
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.spacing(8)),
                          Container(
                            padding: context.symmetricPadding(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B8E7F),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius(8),
                              ),
                            ),
                            child: Text(
                              roomLabel,
                              style: AppTextStyles.body12.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: context.fontSize(12),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing(12)),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  SizedBox(height: context.spacing(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sewa Bulanan',
                            style: AppTextStyles.body12
                                .colored(const Color(0xFF9CA3AF))
                                .copyWith(fontSize: context.fontSize(12)),
                          ),
                          SizedBox(height: context.spacing(4)),
                          Text(
                            'Rp ${penghuni.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: AppTextStyles.body14.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: context.fontSize(14),
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tanggal Masuk',
                            style: AppTextStyles.body12
                                .colored(const Color(0xFF9CA3AF))
                                .copyWith(fontSize: context.fontSize(12)),
                          ),
                          SizedBox(height: context.spacing(4)),
                          Text(
                            penghuni.tanggalMasuk,
                            style: AppTextStyles.body14.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: context.fontSize(14),
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
