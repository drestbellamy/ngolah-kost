import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_penghuni_controller.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class RiwayatPenghuniView extends GetView<RiwayatPenghuniController> {
  const RiwayatPenghuniView({super.key});

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
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: context.spacing(16)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Riwayat Penghuni',
                              style: AppTextStyles.headlineSmall
                                  .weighted(FontWeight.w700)
                                  .colored(Colors.white)
                                  .copyWith(fontSize: context.fontSize(24)),
                            ),
                            SizedBox(height: context.spacing(4)),
                            Obx(
                              () => Text(
                                '${controller.riwayatList.length} penghuni',
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

            // Search Bar and Filter
            Padding(
              padding: context.horizontalPadding(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.searchRiwayat,
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Kost Dropdown
            Padding(
              padding: context.horizontalPadding(16),
              child: Obx(() {
                final kostOptions = controller.kostList;
                if (kostOptions.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                final selectedId = controller.selectedKostId.value;
                
                // Find selected kost
                final selectedKost = kostOptions.firstWhere(
                  (k) => k['id'] == selectedId,
                  orElse: () => kostOptions.first,
                );
                
                final selectedName = selectedKost['nama']?.toString() ?? 'Semua Kost';
                final selectedCount = selectedKost['count'] as int? ?? 0;

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
                                    selectedName,
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
                          color: const Color(0xFF6B8E7A),
                          size: context.iconSize(24),
                        ),
                        offset: const Offset(0, 8),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (BuildContext context) {
                          return kostOptions.map((kost) {
                            final id = kost['id']?.toString();
                            final name = kost['nama']?.toString() ?? '';
                            final count = kost['count'] as int? ?? 0;
                            final isSelected = id == selectedId;

                            return PopupMenuItem<String>(
                              value: id,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6B8E7A).withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.apartment_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? const Color(0xFF6B8E7A)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? const Color(0xFF6B8E7A)
                                              : const Color(0xFF2D3748),
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
                        onSelected: (String? value) {
                          controller.filterByKost(value);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // List Riwayat
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B8E7A),
                    ),
                  );
                }

                if (controller.filteredRiwayatList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: const Color(0xFF6B8E7A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum Ada Riwayat',
                          style: AppTextStyles.subtitle16.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Riwayat penghuni yang sudah keluar\nakan muncul di sini',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: context.symmetricPadding(horizontal: 16, vertical: 0),
                  itemCount: controller.filteredRiwayatList.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredRiwayatList[index];
                    return _buildRiwayatCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6B8E7F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'] ?? '',
                      style: AppTextStyles.subtitle16.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['namaKost'] ?? '',
                            style: AppTextStyles.body12.copyWith(
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 14,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Keluar ${item['tanggalKeluar'] ?? ''}',
                          style: AppTextStyles.body12.copyWith(
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          size: 12,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Berakhir',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B8E7F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['noKamar'] ?? '',
                      style: AppTextStyles.body12.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sewa Bulanan',
                        style: AppTextStyles.body12.copyWith(
                          color: const Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_formatCurrency(item['sewaBulanan'])}',
                        style: AppTextStyles.subtitle14.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tanggal Masuk',
                        style: AppTextStyles.body12.copyWith(
                          color: const Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['tanggalMasuk'] ?? '-',
                        style: AppTextStyles.subtitle12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    
    try {
      final amount = int.tryParse(value.toString()) ?? 0;
      return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } catch (e) {
      return '0';
    }
  }
}
