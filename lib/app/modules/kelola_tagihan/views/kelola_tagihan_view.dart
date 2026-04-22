import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/kelola_tagihan_controller.dart';
import '../models/tagihan_model.dart';
import 'widgets/verifikasi_pembayaran_bottom_sheet.dart';

class KelolaTagihanView extends GetView<KelolaTagihanController> {
  const KelolaTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            CustomHeader(
              title: 'Kelola Tagihan',
              showBackButton: true,
              subtitleWidget: Obx(
                () => Text(
                  '${controller.getTotalTagihan()} tagihan',
                  style: AppTextStyles.body14.colored(const Color(0xFFA8D5BA)),
                ),
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTagihanData,
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
                          onChanged: controller.searchTagihan,
                          decoration: InputDecoration(
                            hintText: 'Cari penghuni, kamar, atau kost...',
                            hintStyle: AppTextStyles.body14.colored(const Color(0xFFA0AEC0)),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                            ),
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
                      Obx(
                        () => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'Semua (${controller.getCountByStatus('semua')})',
                                'semua',
                                const Color(0xFF6B8E7F),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Menunggu (${controller.getCountByStatus('menunggu_verifikasi')})',
                                'menunggu_verifikasi',
                                const Color(0xFFF2A65A),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Belum Dibayar (${controller.getCountByStatus('belum_dibayar')})',
                                'belum_dibayar',
                                const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Lunas (${controller.getCountByStatus('lunas')})',
                                'lunas',
                                const Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Month Filter Trigger
                      _buildMonthFilterTrigger(context),

                      const SizedBox(height: 16),

                      // Tagihan List
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.errorMessage.value != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                controller.errorMessage.value!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body14.colored(const Color(0xFFB91C1C)),
                              ),
                            ),
                          );
                        }

                        if (controller.filteredTagihanList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'Belum ada data tagihan.',
                                style: AppTextStyles.body14.colored(AppColors.textGray),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.filteredTagihanList.length,
                          itemBuilder: (context, index) {
                            final tagihan =
                                controller.filteredTagihanList[index];
                            return _buildTagihanCard(tagihan);
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

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.changeFilter(value),
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

  Widget _buildMonthFilterTrigger(BuildContext context) {
    return Obx(() {
      final monthLabel = controller.getMonthFilterLabel(
        controller.selectedMonthKey.value,
      );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              size: 18,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bulan: $monthLabel',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showMonthFilterBottomSheet(context),
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('Filter'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B8E7F),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showMonthFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Obx(() {
            final monthKeys = controller.monthFilterKeys;
            final selected = controller.selectedMonthKey.value;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Filter Bulan Tagihan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih periode bulan yang ingin ditampilkan',
                    style: AppTextStyles.body12.colored(AppColors.textGray),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: monthKeys.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final key = monthKeys[index];
                        final isSelected = key == selected;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? const Color(0xFF6B8E7F)
                                : const Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          title: Text(
                            controller.getMonthFilterLabel(key),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                          onTap: () {
                            controller.changeMonthFilter(key);
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTagihanCard(TagihanModel tagihan) {
    Color statusColor;
    String statusText;

    switch (tagihan.status) {
      case 'lunas':
        statusColor = const Color(0xFF10B981);
        statusText = 'Lunas';
        break;
      case 'menunggu_verifikasi':
        statusColor = const Color(0xFFF2A65A);
        statusText = 'Menunggu Verifikasi';
        break;
      case 'belum_dibayar':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Belum Dibayar';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusText = 'Unknown';
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tagihan.namaPenghuni,
                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.subtitle12.colored(statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.home_work, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tagihan.namaKost,
                  style: AppTextStyles.body12.colored(AppColors.textGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tagihan.nomorKamar,
                      style: AppTextStyles.body14.colored(const Color(0xFF2D3748)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tagihan.tanggalJatuhTempo,
                    style: AppTextStyles.body14.colored(const Color(0xFF2D3748)),
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
              Text(
                'Jumlah Tagihan',
                style: AppTextStyles.body12.colored(AppColors.textGray),
              ),
              Text(
                'Rp ${tagihan.jumlahTagihan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: AppTextStyles.header16.colored(AppColors.primary),
              ),
            ],
          ),
          if (tagihan.status == 'menunggu_verifikasi') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    VerifikasiPembayaranBottomSheet(tagihan: tagihan),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Verifikasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A65A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
