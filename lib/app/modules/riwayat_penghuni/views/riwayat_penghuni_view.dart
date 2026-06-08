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
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.padding(16),
                  MediaQuery.of(context).padding.top + context.padding(16),
                  context.padding(16),
                  context.padding(20),
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
                              .copyWith(fontSize: context.fontSize(20)),
                        ),
                        SizedBox(height: context.spacing(4)),
                        Text(
                          'Informasi riwayat penghuni kost',
                          style: AppTextStyles.body14
                              .colored(AppColors.primaryLight)
                              .copyWith(fontSize: context.fontSize(13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
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
                  SizedBox(width: context.spacing(12)),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: const Color(0xFF6B8E7A),
                      size: context.iconSize(20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            Padding(
              padding: context.horizontalPadding(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Semua Kost', true, 8),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Green Valley Kost', false, 2),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Sunrise House', false, 0),
                  ],
                ),
              ),
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

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6B8E7A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF6B8E7A) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF6B8E7A),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFF6B8E7A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF6B8E7A),
              ),
            ),
          ),
        ],
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
      child: Row(
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
                    Text(
                      item['namaKost'] ?? '',
                      style: AppTextStyles.body12.copyWith(
                        color: const Color(0xFF718096),
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
    );
  }
}
