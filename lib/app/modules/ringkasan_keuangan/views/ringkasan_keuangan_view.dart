import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/ringkasan_keuangan_controller.dart';

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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Color(0xFF6B8E7A)),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data keuangan...',
                            style: AppTextStyles.body14.colored(AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.errorMessage.value != null) {
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

                  if (controller.kostList.isEmpty) {
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
                                  Icons.home_work_outlined,
                                  size: 64,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada data kost',
                                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambahkan kost terlebih dahulu untuk melihat ringkasan keuangan',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body14.colored(AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Total Summary Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Obx(
                            () => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
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
                                  const Text(
                                    'Total Semua Kost',
                                    style: AppTextStyles.subtitle16,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFinancialItem(
                                    'Pemasukan',
                                    controller.formatCurrency(
                                      controller.totalPemasukan.value,
                                    ),
                                    const Color(0xFF10B981),
                                    Icons.trending_up,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFinancialItem(
                                    'Pengeluaran',
                                    controller.formatCurrency(
                                      controller.totalPengeluaran.value,
                                    ),
                                    const Color(0xFFEF4444),
                                    Icons.trending_down,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFinancialItem(
                                    controller.totalLabaBersih.value >= 0
                                        ? 'Laba Bersih'
                                        : 'Rugi Bersih',
                                    '${controller.totalLabaBersih.value >= 0 ? '+' : ''}${controller.formatCurrency(controller.totalLabaBersih.value)}',
                                    controller.totalLabaBersih.value >= 0
                                        ? const Color(0xFF8B5CF6)
                                        : const Color(0xFFEF4444),
                                    controller.totalLabaBersih.value >= 0
                                        ? Icons.savings
                                        : Icons.warning,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Pilih Rumah Kost',
                            style: AppTextStyles.header16.colored(AppColors.textPrimary),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Kost List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Obx(
                            () => ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.kostList.length,
                              itemBuilder: (context, index) {
                                final kost = controller.kostList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        '/detail-keuangan-kost',
                                        arguments: {
                                          'kostId': kost.kostId,
                                          'kostName': kost.kostName,
                                          'kostAddress': kost.kostAddress,
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6B8E7A),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.home_work,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  kost.kostName,
                                                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  kost.kostAddress,
                                                  style: AppTextStyles.body14.colored(AppColors.textSecondary),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                // Financial indicators in one row
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    _buildSmallIndicator(
                                                      Icons.trending_up,
                                                      controller.formatCurrency(
                                                        kost.pemasukan,
                                                      ),
                                                      const Color(0xFF10B981),
                                                    ),
                                                    _buildSmallIndicator(
                                                      Icons.trending_down,
                                                      controller.formatCurrency(
                                                        kost.pengeluaran,
                                                      ),
                                                      const Color(0xFFEF4444),
                                                    ),
                                                    _buildSmallIndicator(
                                                      kost.labaBersih >= 0
                                                          ? Icons.savings
                                                          : Icons.warning,
                                                      '${kost.labaBersih >= 0 ? '+' : ''}${controller.formatCurrency(kost.labaBersih)}',
                                                      kost.labaBersih >= 0
                                                          ? const Color(
                                                              0xFF8B5CF6,
                                                            )
                                                          : const Color(
                                                              0xFFEF4444,
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Arrow
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.subtitle14.colored(AppColors.textSecondary).weighted(FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.header20.copyWith(fontSize: 28).colored(AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIndicator(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.body12.weighted(FontWeight.w600).colored(color),
        ),
      ],
    );
  }
}
