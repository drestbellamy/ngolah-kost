import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/penghuni_controller.dart';
import '../models/penghuni_model.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class PenghuniView extends GetView<PenghuniController> {
  const PenghuniView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kelola Penghuni',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    '${controller.penghuniList.length} penghuni',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFA8D5BA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search Bar
                        TextField(
                          controller: controller.searchController,
                          onChanged: controller.searchPenghuni,
                          decoration: InputDecoration(
                            hintText: 'Cari penghuni, kamar, atau kost...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
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
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 14,
                        ),
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
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          height: 1.4,
                        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => controller.filterByKost(label),
        child: AnimatedContainer(
          key: ValueKey('$label-$count-$isSelected'),
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B8E7F) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B8E7F)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.apartment, size: 16, color: Colors.white),
                ),
              if (!isSelected && hasPenghuni)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
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
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
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

    return GestureDetector(
      onTap: () => controller.goToDetail(penghuni),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                        penghuni.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                              penghuni.namaKost,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            penghuni.noTelepon,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            occupancyLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E7F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roomLabel,
                        style: const TextStyle(
                          fontSize: 12,
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
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sewa Bulanan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${penghuni.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Tanggal Masuk',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      penghuni.tanggalMasuk,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
