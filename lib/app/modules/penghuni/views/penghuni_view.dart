import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/penghuni_controller.dart';
import '../models/penghuni_model.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';


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
                        color: Colors.white.withOpacity(0.05),
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
                        color: Colors.white.withOpacity(0.05),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                    style: AppTextStyles.subtitle14.colored (AppColors.primaryLight).copyWith(
                                      fontSize: context.fontSize(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing(16)),
                        // Search Bar
                        TextField(
                          controller: controller.searchController,
                          onChanged: controller.searchPenghuni,
                          decoration: InputDecoration(
                            hintText: 'Cari penghuni, kamar, atau kost...',
                            hintStyle: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)).copyWith(
                              fontSize: context.fontSize(14),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color(0xFF9CA3AF),
                              size: context.iconSize(20),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.borderRadius(12)),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: context.symmetricPadding(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips + Sort
            Padding(
              padding: context.horizontalPadding(16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: context.buttonHeight(40),
                      child: Obx(() {
                        final selected = controller.selectedFilter.value;
                        final countVersion = controller.kostCounts.values
                            .fold<int>(0, (sum, item) => sum + item);

                        return ListView.separated(
                          key: ValueKey('kost-chip-$selected-$countVersion'),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.kostFilterOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final option = controller.kostFilterOptions[index];
                            final count = controller.getPenghuniCountByKost(
                              option,
                            );
                            return _buildFilterChip(
                              option,
                              count,
                              selected == option,
                              count > 0,
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSortButton(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List Penghuni
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        controller.errorMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.colored(const Color(0xFFB91C1C)),
                      ),
                    ),
                  );
                }

                if (controller.filteredPenghuniList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        controller.emptyStateText,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.colored(const Color(0xFF6B7280)),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPenghuniData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredPenghuniList.length,
                    itemBuilder: (context, index) {
                      final penghuni = controller.filteredPenghuniList[index];
                      return _buildPenghuniCard(penghuni);
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

  Widget _buildFilterChip(
    String label,
    int count,
    bool isSelected,
    bool hasPenghuni,
  ) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.borderRadius(20)),
          onTap: () => controller.filterByKost(label),
          child: AnimatedContainer(
            key: ValueKey('$label-$count-$isSelected'),
            duration: const Duration(milliseconds: 120),
            padding: context.symmetricPadding(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6B8E7F) : Colors.white,
              borderRadius: BorderRadius.circular(context.borderRadius(20)),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6B8E7F)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(right: context.spacing(6)),
                    child: Icon(Icons.apartment, size: context.iconSize(16), color: Colors.white),
                  ),
                if (!isSelected && hasPenghuni)
                  Padding(
                    padding: EdgeInsets.only(right: context.spacing(6)),
                    child: Container(
                      width: context.spacing(8),
                      height: context.spacing(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(width: context.spacing(6)),
                Container(
                  padding: context.symmetricPadding(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(context.borderRadius(10)),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTextStyles.body12.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: context.fontSize(12),
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Obx(() {
      final isAsc = controller.isSortAsc.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: controller.toggleSortOrder,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAsc
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  isAsc ? 'Asc' : 'Desc',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPenghuniCard(PenghuniModel penghuni) {
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
                      borderRadius: BorderRadius.circular(context.borderRadius(12)),
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
                          style: AppTextStyles.subtitle16.colored(const Color(0xFF2D3748)).copyWith(
                            fontSize: context.fontSize(16),
                          ),
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
                                style: AppTextStyles.body12.colored(const Color(0xFF718096)).copyWith(
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
                              style: AppTextStyles.body12.colored(const Color(0xFF718096)).copyWith(
                                fontSize: context.fontSize(12),
                              ),
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
                          color: const Color(0xFF10B981).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(context.borderRadius(20)),
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
                          borderRadius: BorderRadius.circular(context.borderRadius(8)),
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
                        style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)).copyWith(
                          fontSize: context.fontSize(12),
                        ),
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
                        style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)).copyWith(
                          fontSize: context.fontSize(12),
                        ),
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
    );
  }
}
