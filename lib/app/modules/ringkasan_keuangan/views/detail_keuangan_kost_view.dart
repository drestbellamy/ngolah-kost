import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/detail_keuangan_kost_controller.dart';
import 'widgets/chart_card.dart';
import 'widgets/detail_kost_summary_card.dart';
import 'widgets/tambah_pengeluaran_bottom_sheet.dart';
import 'widgets/detail_keuangan_shimmer_widget.dart';

class DetailKeuanganKostView extends GetView<DetailKeuanganKostController> {
  const DetailKeuanganKostView({super.key});

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
                title: controller.kostName.value,
                subtitle: controller.kostAddress.value.isNotEmpty
                    ? controller.kostAddress.value
                    : 'Detail keuangan kost',
                showBackButton: true,
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadKeuanganData,
                color: const Color(0xFF6B8E7A),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const DetailKeuanganShimmerWidget();
                  }

                  return _buildContent(context);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Periode Picker
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periode Laporan',
                      style: AppTextStyles.header16.colored(
                        AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: controller.previousMonth,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_left,
                                size: 20,
                                color: Color(0xFF6B8E7A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final monthStr = [
                              '',
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'Mei',
                              'Jun',
                              'Jul',
                              'Ags',
                              'Sep',
                              'Okt',
                              'Nov',
                              'Des',
                            ][controller.selectedMonth.value.month];
                            return Text(
                              '$monthStr ${controller.selectedMonth.value.year}',
                              style: AppTextStyles.body14
                                  .colored(AppColors.textPrimary)
                                  .weighted(FontWeight.w600),
                            );
                          }),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: controller.nextMonth,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Color(0xFF6B8E7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),

          const SizedBox(height: 16),

          // Swipeable Cards (Grafik & Ringkasan)
          SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: controller.pageController,
                        onPageChanged: (index) {
                          controller.currentPage.value = index;
                        },
                        children: [
                          // Page 1: Grafik Keuangan Bulanan
                          Obx(
                            () => ChartCard(
                              pemasukanData: controller.pemasukanChartData
                                  .toList(),
                              pengeluaranData: controller.pengeluaranChartData
                                  .toList(),
                              labels: controller.chartLabels.toList(),
                            ),
                          ),

                          // Page 2: Ringkasan Keuangan Kost
                          Obx(
                            () => DetailKostSummaryCard(
                              totalPemasukan: controller.totalPemasukan.value,
                              totalPengeluaran:
                                  controller.totalPengeluaran.value,
                              labaBersih: controller.labaBersih.value,
                              formatCurrency: controller.formatCurrency,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Page Indicator
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          2,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: controller.currentPage.value == index
                                ? 24
                                : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == index
                                  ? const Color(0xFF6B8E7A)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),

          const SizedBox(height: 16),

          // Pemasukan dari Penghuni
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pemasukan dari Penghuni',
                            style: AppTextStyles.header16.colored(
                              AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Sync button untuk debug
                      GestureDetector(
                        onTap: controller.sinkronisasiPemasukan,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6B8E7A,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.sync,
                            color: Color(0xFF6B8E7A),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.pemasukanList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Belum ada data pemasukan',
                            style: AppTextStyles.body14.colored(
                              const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      );
                    }

                    // Tampilkan maksimal 5 data terbaru
                    final displayList = controller.pemasukanList
                        .take(5)
                        .toList();
                    final hasMore = controller.pemasukanList.length > 5;

                    return Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            final jumlah = item['jumlah'];
                            final amount = jumlah is int
                                ? jumlah.toDouble()
                                : (jumlah is double
                                      ? jumlah
                                      : double.tryParse(
                                              jumlah?.toString() ?? '0',
                                            ) ??
                                            0.0);

                            final namaPenghuni =
                                item['nama_penghuni']?.toString() ?? '-';
                            final keterangan =
                                item['keterangan']?.toString() ?? '';

                            return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              namaPenghuni,
                                              style: AppTextStyles.subtitle14
                                                  .weighted(FontWeight.w600)
                                                  .colored(
                                                    AppColors.textPrimary,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 11,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  controller.formatDate(
                                                    item['tanggal'],
                                                  ),
                                                  style: AppTextStyles.body12
                                                      .colored(
                                                        AppColors.textSecondary,
                                                      ),
                                                ),
                                                if (keterangan.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '• $keterangan',
                                                      style: AppTextStyles
                                                          .body12
                                                          .colored(
                                                            AppColors
                                                                .textSecondary,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '+${controller.formatCurrency(amount)}',
                                        style: AppTextStyles.subtitle14
                                            .weighted(FontWeight.bold)
                                            .colored(const Color(0xFF10B981)),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                )
                                .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                          },
                        ),
                        if (hasMore)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton(
                              onPressed: () {
                                // TODO: Navigate to full list
                                Get.snackbar(
                                  'Info',
                                  'Menampilkan ${controller.pemasukanList.length} data pemasukan',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF6B8E7A),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 8,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Semua (${controller.pemasukanList.length})',
                                    style: AppTextStyles.body12
                                        .colored(const Color(0xFF6B8E7A))
                                        .weighted(FontWeight.w600),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Color(0xFF6B8E7A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Daftar Pengeluaran
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Daftar Pengeluaran',
                            style: AppTextStyles.header16.colored(
                              AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Get.bottomSheet(
                            TambahPengeluaranBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );

                          if (result != null) {
                            controller.addPengeluaran(result);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B8E7A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.pengeluaranList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Belum ada data pengeluaran',
                            style: AppTextStyles.body14.colored(
                              const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      );
                    }

                    // Tampilkan maksimal 5 data terbaru
                    final displayList = controller.pengeluaranList
                        .take(5)
                        .toList();
                    final hasMore = controller.pengeluaranList.length > 5;

                    return Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            final jumlah = item['jumlah'];
                            final amount = jumlah is int
                                ? jumlah.toDouble()
                                : (jumlah is double
                                      ? jumlah
                                      : double.tryParse(
                                              jumlah?.toString() ?? '0',
                                            ) ??
                                            0.0);

                            return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['nama']?.toString() ??
                                                  'Pengeluaran',
                                              style: AppTextStyles.subtitle14
                                                  .weighted(FontWeight.w600)
                                                  .colored(
                                                    AppColors.textPrimary,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 11,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  controller.formatDate(
                                                    item['tanggal'],
                                                  ),
                                                  style: AppTextStyles.body12
                                                      .colored(
                                                        AppColors.textSecondary,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '• ${item['deskripsi']?.toString() ?? '-'}',
                                                    style: AppTextStyles.body12
                                                        .colored(
                                                          AppColors
                                                              .textSecondary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '-${controller.formatCurrency(amount)}',
                                            style: AppTextStyles.subtitle14
                                                .weighted(FontWeight.bold)
                                                .colored(
                                                  const Color(0xFFEF4444),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await Get.bottomSheet(
                                                        TambahPengeluaranBottomSheet(
                                                          initialData: item,
                                                        ),
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                      );

                                                  if (result != null) {
                                                    controller.editPengeluaran(
                                                      index,
                                                      result,
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () {
                                                  Get.dialog(
                                                    AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      title: Text(
                                                        'Hapus Pengeluaran',
                                                        style: AppTextStyles
                                                            .header18
                                                            .colored(
                                                              AppColors
                                                                  .textPrimary,
                                                            ),
                                                      ),
                                                      content: Text(
                                                        'Apakah Anda yakin ingin menghapus "${item['nama']?.toString() ?? 'pengeluaran ini'}"?',
                                                        style: AppTextStyles
                                                            .body14
                                                            .colored(
                                                              AppColors
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          style:
                                                              TextButton.styleFrom(
                                                                foregroundColor:
                                                                    const Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                              ),
                                                          child: const Text(
                                                            'Batal',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Get.back();
                                                            controller
                                                                .deletePengeluaran(
                                                                  index,
                                                                );
                                                          },
                                                          style:
                                                              TextButton.styleFrom(
                                                                foregroundColor:
                                                                    const Color(
                                                                      0xFFEF4444,
                                                                    ),
                                                              ),
                                                          child: const Text(
                                                            'Hapus',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                )
                                .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                          },
                        ),
                        if (hasMore)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton(
                              onPressed: () {
                                // TODO: Navigate to full list
                                Get.snackbar(
                                  'Info',
                                  'Menampilkan ${controller.pengeluaranList.length} data pengeluaran',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF6B8E7A),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 8,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Semua (${controller.pengeluaranList.length})',
                                    style: AppTextStyles.body12
                                        .colored(const Color(0xFF6B8E7A))
                                        .weighted(FontWeight.w600),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Color(0xFF6B8E7A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
