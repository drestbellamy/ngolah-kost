import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import 'widgets/pengaduan_list_widget.dart';
import 'widgets/pengaduan_shimmer_widget.dart';

class KelolaPengaduanView extends GetView<KelolaPengaduanController> {
  const KelolaPengaduanView({super.key});

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
              title: 'Laporan Pengaduan',
              subtitle: 'Daftar laporan kendala dari penghuni',
              showBackButton: true,
              backgroundImage: 'assets/images/dashboard_admin/header_admin.png',
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadPengaduanData,
                color: const Color(0xFF6B8E7A),
                child: Column(
                  children: [
                    SizedBox(height: context.spacing(16)),

                    // Search Bar
                    Padding(
                      padding: context.horizontalPadding(16),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchPengaduan,
                        decoration: InputDecoration(
                          hintText: 'Cari penghuni atau laporan...',
                          hintStyle: AppTextStyles.body14
                              .colored(AppColors.textSecondary)
                              .copyWith(fontSize: context.fontSize(14)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
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
                          contentPadding: context.allPadding(16),
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing(16)),

                    // Filter Tabs (Status)
                    Padding(
                      padding: context.horizontalPadding(16),
                      child: Obx(() {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(context, 'Semua', 'semua'),
                              SizedBox(width: context.spacing(8)),
                              _buildFilterChip(
                                context,
                                'Menunggu',
                                'MENUNGGU',
                                color: const Color(0xFFFF9800),
                              ),
                              SizedBox(width: context.spacing(8)),
                              _buildFilterChip(
                                context,
                                'Diproses',
                                'DIPROSES',
                                color: const Color(0xFF2196F3),
                              ),
                              SizedBox(width: context.spacing(8)),
                              _buildFilterChip(
                                context,
                                'Selesai',
                                'SELESAI',
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: context.spacing(16)),

                    // Bulan & Kost Filter Dropdowns
                    Padding(
                      padding: context.horizontalPadding(16),
                      child: Row(
                        children: [
                          // Bulan Filter Dropdown
                          Expanded(
                            child: Obx(() {
                              return GestureDetector(
                                onTap: () =>
                                    _showBulanFilterBottomSheet(context),
                                child: Container(
                                  padding: EdgeInsets.all(context.spacing(12)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      context.borderRadius(12),
                                    ),
                                    border: Border.all(
                                      color:
                                          controller.selectedBulan.value !=
                                              'semua'
                                          ? const Color(0xFF6B8E7A)
                                          : const Color(0xFFE5E7EB),
                                      width:
                                          controller.selectedBulan.value !=
                                              'semua'
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color:
                                            controller.selectedBulan.value !=
                                                'semua'
                                            ? const Color(0xFF6B8E7A)
                                            : const Color(0xFF9CA3AF),
                                        size: context.iconSize(20),
                                      ),
                                      SizedBox(width: context.spacing(8)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Bulan',
                                              style: AppTextStyles.body12
                                                  .colored(
                                                    const Color(0xFF9CA3AF),
                                                  )
                                                  .copyWith(
                                                    fontSize: context.fontSize(
                                                      10,
                                                    ),
                                                  ),
                                            ),
                                            SizedBox(
                                              height: context.spacing(2),
                                            ),
                                            Text(
                                              _getBulanLabel(
                                                controller.selectedBulan.value,
                                              ),
                                              style: AppTextStyles.body14
                                                  .colored(
                                                    controller
                                                                .selectedBulan
                                                                .value !=
                                                            'semua'
                                                        ? const Color(
                                                            0xFF6B8E7A,
                                                          )
                                                        : const Color(
                                                            0xFF2D3748,
                                                          ),
                                                  )
                                                  .copyWith(
                                                    fontSize: context.fontSize(
                                                      13,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color:
                                            controller.selectedBulan.value !=
                                                'semua'
                                            ? const Color(0xFF6B8E7A)
                                            : const Color(0xFF9CA3AF),
                                        size: context.iconSize(20),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                          SizedBox(width: context.spacing(12)),

                          // Kost Filter Dropdown
                          Expanded(
                            child: Obx(() {
                              return GestureDetector(
                                onTap: () =>
                                    _showKostFilterBottomSheet(context),
                                child: Container(
                                  padding: EdgeInsets.all(context.spacing(12)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      context.borderRadius(12),
                                    ),
                                    border: Border.all(
                                      color:
                                          controller.selectedKostId.value !=
                                              'semua'
                                          ? const Color(0xFF6B8E7A)
                                          : const Color(0xFFE5E7EB),
                                      width:
                                          controller.selectedKostId.value !=
                                              'semua'
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.apartment,
                                        color:
                                            controller.selectedKostId.value !=
                                                'semua'
                                            ? const Color(0xFF6B8E7A)
                                            : const Color(0xFF9CA3AF),
                                        size: context.iconSize(20),
                                      ),
                                      SizedBox(width: context.spacing(8)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Kost',
                                              style: AppTextStyles.body12
                                                  .colored(
                                                    const Color(0xFF9CA3AF),
                                                  )
                                                  .copyWith(
                                                    fontSize: context.fontSize(
                                                      10,
                                                    ),
                                                  ),
                                            ),
                                            SizedBox(
                                              height: context.spacing(2),
                                            ),
                                            Text(
                                              controller.selectedKostId.value ==
                                                      'semua'
                                                  ? 'Semua Kost'
                                                  : controller
                                                        .selectedKostId
                                                        .value,
                                              style: AppTextStyles.body14
                                                  .colored(
                                                    controller
                                                                .selectedKostId
                                                                .value !=
                                                            'semua'
                                                        ? const Color(
                                                            0xFF6B8E7A,
                                                          )
                                                        : const Color(
                                                            0xFF2D3748,
                                                          ),
                                                  )
                                                  .copyWith(
                                                    fontSize: context.fontSize(
                                                      13,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color:
                                            controller.selectedKostId.value !=
                                                'semua'
                                            ? const Color(0xFF6B8E7A)
                                            : const Color(0xFF9CA3AF),
                                        size: context.iconSize(20),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.spacing(16)),

                    // List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const PengaduanShimmerWidget();
                        }

                        if (controller.errorMessage.value != null) {
                          return Center(
                            child: Padding(
                              padding: context.allPadding(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: context.iconSize(64),
                                    color: Colors.red[300],
                                  ),
                                  SizedBox(height: context.spacing(16)),
                                  Text(
                                    controller.errorMessage.value!,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body14
                                        .colored(AppColors.textSecondary)
                                        .copyWith(
                                          fontSize: context.fontSize(14),
                                        ),
                                  ),
                                  SizedBox(height: context.spacing(16)),
                                  ElevatedButton(
                                    onPressed: controller.loadPengaduanData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B8E7A),
                                      padding: context.allPadding(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.borderRadius(12),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Coba Lagi',
                                      style: AppTextStyles.buttonMedium
                                          .colored(Colors.white)
                                          .copyWith(
                                            fontSize: context.fontSize(14),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const PengaduanListWidget();
                      }),
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

  void _showKostFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.borderRadius(20)),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: context.allPadding(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Kost',
                style: AppTextStyles.body16
                    .colored(AppColors.textPrimary)
                    .copyWith(
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: context.spacing(16)),
              Obx(() {
                final kostList = controller.kostFilterList;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Semua Kost',
                        style: AppTextStyles.body14
                            .colored(AppColors.textPrimary)
                            .copyWith(fontSize: context.fontSize(14)),
                      ),
                      leading: Radio<String>(
                        value: 'semua',
                        groupValue: controller.selectedKostId.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeKostFilter(value);
                            Navigator.pop(context);
                          }
                        },
                        activeColor: const Color(0xFF6B8E7A),
                      ),
                      onTap: () {
                        controller.changeKostFilter('semua');
                        Navigator.pop(context);
                      },
                    ),
                    ...kostList.map((kost) {
                      return ListTile(
                        title: Text(
                          kost['name']!,
                          style: AppTextStyles.body14
                              .colored(AppColors.textPrimary)
                              .copyWith(fontSize: context.fontSize(14)),
                        ),
                        leading: Radio<String>(
                          value: kost['id']!,
                          groupValue: controller.selectedKostId.value,
                          onChanged: (value) {
                            if (value != null) {
                              controller.changeKostFilter(value);
                              Navigator.pop(context);
                            }
                          },
                          activeColor: const Color(0xFF6B8E7A),
                        ),
                        onTap: () {
                          controller.changeKostFilter(kost['id']!);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBulanFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.borderRadius(20)),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: context.allPadding(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Bulan',
                style: AppTextStyles.body16
                    .colored(AppColors.textPrimary)
                    .copyWith(
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: context.spacing(16)),
              Obx(() {
                final bulanList = controller.bulanFilterList;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Semua Bulan',
                        style: AppTextStyles.body14
                            .colored(AppColors.textPrimary)
                            .copyWith(fontSize: context.fontSize(14)),
                      ),
                      leading: Radio<String>(
                        value: 'semua',
                        groupValue: controller.selectedBulan.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeBulanFilter(value);
                            Navigator.pop(context);
                          }
                        },
                        activeColor: const Color(0xFF6B8E7A),
                      ),
                      onTap: () {
                        controller.changeBulanFilter('semua');
                        Navigator.pop(context);
                      },
                    ),
                    ...bulanList.map((bulan) {
                      return ListTile(
                        title: Text(
                          bulan['name']!,
                          style: AppTextStyles.body14
                              .colored(AppColors.textPrimary)
                              .copyWith(fontSize: context.fontSize(14)),
                        ),
                        leading: Radio<String>(
                          value: bulan['id']!,
                          groupValue: controller.selectedBulan.value,
                          onChanged: (value) {
                            if (value != null) {
                              controller.changeBulanFilter(value);
                              Navigator.pop(context);
                            }
                          },
                          activeColor: const Color(0xFF6B8E7A),
                        ),
                        onTap: () {
                          controller.changeBulanFilter(bulan['id']!);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getBulanLabel(String bulanId) {
    if (bulanId == 'semua') return 'Semua Bulan';
    final bulanList = controller.bulanFilterList;
    final bulan = bulanList.firstWhere(
      (b) => b['id'] == bulanId,
      orElse: () => {'id': bulanId, 'name': 'Semua Bulan'},
    );
    return bulan['name']!;
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    final isSelected = controller.selectedFilter.value == value;

    return GestureDetector(
      onTap: () => controller.changeFilter(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing(16),
          vertical: context.spacing(10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? const Color(0xFF6B8E7A)) : Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(20)),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF6B8E7A))
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body14
              .colored(isSelected ? Colors.white : AppColors.textPrimary)
              .copyWith(
                fontSize: context.fontSize(14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
