import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import '../controllers/kamar_controller.dart';

class KamarView extends GetView<KamarController> {
  const KamarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // Header fixed
            Obx(
              () => CustomHeader(
                title: controller.namaKost.value,
                showBackButton: true,
                onBackPressed: controller.goBack,
                subtitleWidget: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFFA8D5BA),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        controller.alamatKost.value,
                        style: AppTextStyles.body14.colored(const Color(0xFFA8D5BA)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final filteredKamar = controller.filteredKamar;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: context.spacing(12)),

                          // Stats Grid (scrollable)
                          Padding(
                            padding: context.horizontalPadding(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'Total Ruangan',
                                        controller.totalRuangan.value
                                            .toString(),
                                        Icons.home_outlined,
                                        const Color(0xFF6B8E7A),
                                      ),
                                    ),
                                    SizedBox(width: context.spacing(16)),
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'Total Penghuni',
                                        controller.totalPenghuni.value
                                            .toString(),
                                        Icons.how_to_reg_outlined,
                                        const Color(0xFFE59C5A),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.spacing(16)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'Terisi',
                                        controller.ditempati.value.toString(),
                                        Icons.meeting_room_outlined,
                                        const Color(0xFF34D399),
                                      ),
                                    ),
                                    SizedBox(width: context.spacing(16)),
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'Kosong',
                                        controller.kosong.value.toString(),
                                        Icons.door_front_door_outlined,
                                        const Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.spacing(12)),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabsHeaderDelegate(
                        height: context.buttonHeight(64),
                        child: Builder(
                          builder: (context) => Container(
                            color: const Color(0xFFF7F9F8),
                            padding: context.horizontalPadding(24),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: context.verticalPadding(6),
                                    child: Row(
                                      children: [
                                        _buildTab(context, 'Semua Kamar', 0),
                                        _buildTab(context, 'Kosong', 1),
                                        _buildTab(context, 'Terisi Sebagian', 2),
                                        _buildTab(context, 'Penuh', 3),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.spacing(8)),
                                _buildSortButton(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ..._buildBodySlivers(context, filteredKamar),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: controller.tambahKamar,
          backgroundColor: const Color(0xFFF2A65A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius(16)),
          ),
          child: Icon(Icons.add, color: Colors.white, size: context.iconSize(24)),
        ),
      ),
    );
  }

  List<Widget> _buildBodySlivers(BuildContext context, List<Map<String, dynamic>> filteredKamar) {
    if (controller.isLoading.value) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (filteredKamar.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.padding(24),
              context.padding(24),
              context.padding(24),
              context.padding(96),
            ),
            child: Container(
              width: double.infinity,
              padding: context.allPadding(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.borderRadius(16)),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                'Belum ada data kamar. Silakan tekan tombol + untuk menambahkan kamar baru.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14.colored(AppColors.textGray).copyWith(
                  fontSize: context.fontSize(14),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          context.padding(24),
          context.padding(8),
          context.padding(24),
          context.padding(96),
        ),
        sliver: SliverList.builder(
          itemCount: filteredKamar.length,
          itemBuilder: (context, index) {
            final kamar = filteredKamar[index];
            return _buildKamarCard(context, kamar);
          },
        ),
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      height: context.buttonHeight(86),
      padding: context.symmetricPadding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: context.allPadding(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: context.iconSize(24)),
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    final isSelected = controller.selectedTab.value == index;
    final tabColor = _tabColor(index);

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        margin: EdgeInsets.only(right: context.spacing(8)),
        padding: context.symmetricPadding(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? tabColor : Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(20)),
          border: Border.all(
            color: isSelected ? tabColor : const Color(0xFFE5E7EB),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? tabColor.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle12.weighted(
            isSelected ? FontWeight.w700 : FontWeight.w600
          ).colored(isSelected ? Colors.white : AppColors.textGray).copyWith(
            fontSize: context.fontSize(12),
          ),
        ),
      ),
    );
  }

  Color _tabColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFF59E0B); // Kosong
      case 2:
        return const Color(0xFF3B82F6); // Terisi sebagian
      case 3:
        return const Color(0xFF10B981); // Penuh
      default:
        return const Color(0xFF6B8E7A); // Semua kamar
    }
  }

  Widget _buildSortButton(BuildContext context) {
    return Obx(() {
      final isAsc = controller.isSortAsc.value;
      return InkWell(
        onTap: controller.toggleSortOrder,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKamarCard(BuildContext context, Map<String, dynamic> kamar) {
    final kapasitas = kamar['kapasitas'] ?? 2;
    final terisi = kamar['terisi'] ?? (kamar['status'] == 'Kosong' ? 0 : 1);
    final rasioPenghuni = '$terisi/$kapasitas';
    final statusColor = kamar['statusColor'] is Color
        ? kamar['statusColor'] as Color
        : const Color(0xFFF2A65A);

    return GestureDetector(
      onTap: () => controller.navigateToInformasiKamar(kamar),
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing(16)),
        padding: context.allPadding(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.iconSize(48),
                  height: context.iconSize(48),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius(12)),
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    color: const Color(0xFF6B8E7A),
                    size: context.iconSize(24),
                  ),
                ),
                SizedBox(width: context.spacing(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Kamar ${kamar['nomor']}',
                                    style: AppTextStyles.header16.colored(AppColors.textPrimary).copyWith(
                                      fontSize: context.fontSize(16),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: context.spacing(4)),
                                Icon(
                                  Icons.chevron_right,
                                  color: const Color(0xFF6B7280),
                                  size: context.iconSize(18),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: context.symmetricPadding(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(context.borderRadius(20)),
                            ),
                            child: Text(
                              kamar['status'],
                              style: TextStyle(
                                fontSize: context.fontSize(12),
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing(6)),
                      Row(
                        children: [
                          Text(
                            'Penghuni: $rasioPenghuni',
                            style: AppTextStyles.body12.colored(AppColors.textGray).copyWith(
                              fontSize: context.fontSize(12),
                            ),
                          ),
                          SizedBox(width: context.spacing(4)),
                          Icon(
                            Icons.person_outline,
                            size: context.iconSize(16),
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing(10)),
                      Text(
                        kamar['harga'],
                        style: AppTextStyles.subtitle14.colored(AppColors.primary).copyWith(
                          fontSize: context.fontSize(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.editKamar(kamar),
                    icon: Icon(Icons.edit_outlined, size: context.iconSize(18)),
                    label: Text('Edit', style: TextStyle(fontSize: context.fontSize(14))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E7A),
                      foregroundColor: Colors.white,
                      padding: context.symmetricPadding(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.borderRadius(12)),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: context.spacing(12)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.hapusKamar(kamar),
                    icon: Icon(Icons.delete_outline, size: context.iconSize(18)),
                    label: Text('Hapus', style: TextStyle(fontSize: context.fontSize(14))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: const Color(0xFFEF4444),
                      padding: context.symmetricPadding(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.borderRadius(12)),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyTabsHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabsHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
