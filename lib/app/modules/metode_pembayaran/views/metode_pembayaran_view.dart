import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metode_pembayaran_controller.dart';
import '../models/metode_pembayaran_model.dart';
import '../../../core/values/values.dart';
import '../../../core/widgets/custom_header.dart';

class MetodePembayaranView extends GetView<MetodePembayaranController> {
  const MetodePembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Obx(
              () => CustomHeader(
                title: 'Metode Pembayaran',
                showBackButton: true,
                subtitleWidget: Text(
                  '${controller.totalAktif} metode aktif dari ${controller.totalMetode}',
                  style: AppTextStyles.body14.colored(AppColors.primaryLight),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter by Boarding House - Bottom Sheet Button
                        Text(
                          'Filter berdasarkan kost',
                          style: AppTextStyles.subtitle16.colored(
                            const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          return GestureDetector(
                            onTap: () => _showKostFilterBottomSheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.selectedKost.value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        Obx(() {
                          final message = controller.errorMessage.value;
                          if (message == null || message.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE5E5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Filter Chips
                        Obx(
                          () => Row(
                            children: [
                              Flexible(
                                child: _buildFilterChip(
                                  'Semua',
                                  controller.selectedFilter.value == 'Semua',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildFilterChip(
                                  'Bank',
                                  controller.selectedFilter.value == 'Bank',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildFilterChip(
                                  'QRIS',
                                  controller.selectedFilter.value == 'QRIS',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildFilterChip(
                                  'Cash',
                                  controller.selectedFilter.value == 'Cash',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid Metode Pembayaran (scrollable area)
                  Expanded(
                    child: Obx(() {
                      return RefreshIndicator(
                        onRefresh: controller.refreshList,
                        color: const Color(0xFF6B8E7A),
                        child: () {
                          if (controller.isLoading.value &&
                              controller.metodePembayaranList.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 260,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6B8E7A),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          if (controller.filteredList.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 30,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada metode pembayaran',
                                        style: AppTextStyles.body14.copyWith(
                                          color: const Color(0xFF6B7280),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.76,
                                ),
                            itemCount: controller.filteredList.length,
                            itemBuilder: (context, index) {
                              final metode = controller.filteredList[index];
                              return _buildMetodeCard(metode);
                            },
                          );
                        }(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.tambahMetode,
        backgroundColor: const Color(0xFF6B8E7A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setJenisFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B8E7A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B8E7A)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetodeCard(MetodePembayaranModel metode) {
    final isActive = metode.isActive;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Border Bar (Active Indicator)
            Container(
              width: double.infinity,
              height: 4,
              color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            ),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: metode.jenis == 'bank'
                                ? const Color(0xFFDCEEFF)
                                : metode.jenis == 'cash'
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7), // QRIS color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            metode.jenis == 'bank'
                                ? Icons.credit_card
                                : metode.jenis == 'cash'
                                ? Icons.money
                                : Icons.qr_code, // QRIS icon
                            color: metode.jenis == 'bank'
                                ? const Color(0xFF3B82F6)
                                : metode.jenis == 'cash'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B), // QRIS color
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: metode.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                metode.isActive
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 14,
                                color: metode.isActive
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                metode.isActive ? 'Aktif' : 'Non-aktif',
                                style: AppTextStyles.body10.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: metode.isActive
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Nama Bank
                    Text(
                      metode.jenis == 'cash' ? 'Tunai' : metode.nama,
                      style: AppTextStyles.subtitle16.copyWith(
                        color: isActive
                            ? const Color(0xFF2D3748)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Nama Kost
                    Text(
                      metode.namaKost,
                      style: AppTextStyles.body12.colored(
                        isActive
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFFD1D5DB),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    _buildRekeningInfo(metode, isActive),

                    const Spacer(),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          icon: metode.isActive
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          backgroundColor: isActive
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFF3F4F6),
                          iconColor: isActive
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF9CA3AF),
                          onTap: () => controller.toggleStatus(metode.id),
                        ),
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          backgroundColor: isActive
                              ? const Color(0xFFDCEEFF)
                              : const Color(0xFFF3F4F6),
                          iconColor: isActive
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF9CA3AF),
                          onTap: () => controller.editMetode(metode.id),
                        ),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          backgroundColor: isActive
                              ? const Color(0xFFFFE5E5)
                              : const Color(0xFFF3F4F6),
                          iconColor: isActive
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF9CA3AF),
                          onTap: () => controller.deleteMetode(metode.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekeningInfo(MetodePembayaranModel metode, bool isActive) {
    if (metode.jenis == 'qris') {
      return Text(
        'QR Code Pembayaran',
        style: AppTextStyles.body14.copyWith(
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        ),
      );
    }

    if (metode.jenis == 'cash') {
      return Text(
        'Pembayaran Tunai',
        style: AppTextStyles.body14.copyWith(
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        ),
      );
    }

    return Text(
      metode.nomorRekening,
      style: AppTextStyles.body14.copyWith(
        fontWeight: FontWeight.bold,
        color: isActive ? const Color(0xFF2D3748) : const Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  void _showKostFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Kost',
                    style: AppTextStyles.subtitle16.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Options List
            Obx(() {
              final options = controller.kostFilterOptions.isEmpty
                  ? const <String>['Semua Kost']
                  : controller.kostFilterOptions;

              return Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = controller.selectedKost.value == option;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF6B8E7A)
                              : const Color(0xFF374151),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6B8E7A),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        controller.setKostFilter(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            }),

            // Bottom padding for safe area
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
