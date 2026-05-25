import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_pengajuan_pindah_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import 'package:intl/intl.dart';

class AdminPengajuanPindahView extends GetView<AdminPengajuanPindahController> {
  const AdminPengajuanPindahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const CustomHeader(
              title: 'Pengajuan Pindah Kamar',
              subtitle: 'Verifikasi permintaan pindah kamar penghuni',
              showBackButton: true,
              backgroundImage: 'assets/images/dashboard_admin/header_admin.png',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchPengajuan,
                color: const Color(0xFF6B8E7A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau kamar...',
                            hintStyle: AppTextStyles.body14.colored(const Color(0xFFA0AEC0)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter Chips
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      // List View
                      Obx(() {
                        if (controller.isLoading.value && controller.listPengajuan.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.filteredList.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: controller.filteredList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = controller.filteredList[index];
                            return _buildPengajuanCard(context, item);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Semua (${controller.listPengajuan.length})',
              'semua',
              const Color(0xFF6B8E7F),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Menunggu (${controller.countMenunggu})',
              'menunggu',
              const Color(0xFFF2A65A),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Disetujui (${controller.countDisetujui})',
              'disetujui',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Ditolak (${controller.countDitolak})',
              'ditolak',
              const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: context.iconSize(64),
            color: Colors.grey[400],
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            'Tidak ada data pengajuan',
            style: AppTextStyles.subtitle16
                .colored(AppColors.textSecondary)
                .copyWith(fontSize: context.fontSize(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPengajuanCard(BuildContext context, dynamic item) {
    final statusColor = item.status == 'menunggu' 
        ? Colors.orange 
        : (item.status == 'disetujui' ? Colors.green : Colors.red);
        
    final statusText = item.status.toString().capitalizeFirst ?? '';
    
    final diajukanStr = DateFormat('dd MMM yyyy').format(item.createdAt);
    final pindahStr = DateFormat('dd MMM yyyy').format(item.tanggalPindah);

    IconData statusIcon = Icons.access_time;
    if (item.status == 'disetujui') statusIcon = Icons.check_circle_outline;
    if (item.status == 'ditolak') statusIcon = Icons.cancel_outlined;

    return InkWell(
      onTap: () => controller.showDetailBottomSheet(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.namaPenghuni ?? 'Penghuni',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Diajukan $diajukanStr',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dari', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          item.noKamarAsal ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                item.namaKostAsal ?? '-',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.chevron_right, color: Color(0xFF6B8E7A), size: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ke', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          item.noKamarTujuan ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                item.namaKostTujuan ?? '-',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                overflow: TextOverflow.ellipsis,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text('Tanggal pindah: ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      pindahStr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
