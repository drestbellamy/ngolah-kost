import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/ringkasan_keuangan_controller.dart';
import 'widgets/chart_card.dart';
import 'widgets/total_summary_card.dart';
import 'widgets/empty_keuangan_state.dart';
import 'widgets/kost_list_item.dart';
import 'widgets/ringkasan_keuangan_shimmer_widget.dart';

class RingkasanKeuanganView extends GetView<RingkasanKeuanganController> {
  const RingkasanKeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            CustomHeader(
              title: 'Kelola Keuangan',
              subtitle: 'Pilih kost untuk melihat detail',
              showBackButton: true,
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadKeuanganData,
                color: const Color(0xFF6B8E7A),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState(context);
                  }

                  if (controller.errorMessage.value != null) {
                    return _buildErrorState(context);
                  }

                  if (controller.kostList.isEmpty) {
                    return const EmptyKeuanganState();
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

  Widget _buildLoadingState(BuildContext context) {
    return const RingkasanKeuanganShimmerWidget();
  }

  Widget _buildErrorState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14.colored(AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.loadKeuanganData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Swipeable Cards (Grafik & Total)
          _buildSwipeableCards(context)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),

          const SizedBox(height: 16),

          // Section Title
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Pilih Rumah Kost',
                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideX(begin: -0.1, end: 0, duration: 500.ms),

          const SizedBox(height: 8),

          // Kost List
          _buildKostList(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSwipeableCards(BuildContext context) {
    return SizedBox(
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
                        pemasukanData: controller.pemasukanChartData.toList(),
                        pengeluaranData: controller.pengeluaranChartData
                            .toList(),
                        labels: controller.chartLabels.toList(),
                      ),
                    ),

                    // Page 2: Total Summary Card
                    Obx(
                      () => TotalSummaryCard(
                        totalPemasukan: controller.totalPemasukan.value,
                        totalPengeluaran: controller.totalPengeluaran.value,
                        totalLabaBersih: controller.totalLabaBersih.value,
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
                      width: controller.currentPage.value == index ? 24 : 8,
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
        .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildKostList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(
        () => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.kostList.length,
          itemBuilder: (context, index) {
            final kost = controller.kostList[index];
            return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KostListItem(
                    kost: kost,
                    formatCurrency: controller.formatCurrency,
                  ),
                )
                .animate()
                .fadeIn(delay: (400 + (index * 150)).ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0, duration: 500.ms);
          },
        ),
      ),
    );
  }
}
