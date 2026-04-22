import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../repositories/repository_factory.dart';
import '../../../../../repositories/kost_repository.dart';
import '../../../../../repositories/keuangan_repository.dart';
import '../../../../../app/core/values/text_styles.dart';

class RingkasanKeuanganWidgetController extends GetxController {
  final KostRepository _kostRepo;
  final KeuanganRepository _keuanganRepo;

  RingkasanKeuanganWidgetController({
    KostRepository? kostRepository,
    KeuanganRepository? keuanganRepository,
  }) : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _keuanganRepo =
           keuanganRepository ?? RepositoryFactory.instance.keuanganRepository;

  final totalPemasukan = 0.0.obs;
  final totalPengeluaran = 0.0.obs;
  final totalLabaBersih = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRingkasanKeuangan();
  }

  Future<void> loadRingkasanKeuangan() async {
    isLoading.value = true;

    try {
      final kosts = await _kostRepo.getKostList();
      double pemasukan = 0.0;
      double pengeluaran = 0.0;

      for (final kost in kosts) {
        final ringkasan = await _keuanganRepo.getFinancialSummary(
          kostId: kost.id,
        );
        pemasukan += ringkasan['pemasukan'] ?? 0.0;
        pengeluaran += ringkasan['pengeluaran'] ?? 0.0;
      }

      totalPemasukan.value = pemasukan;
      totalPengeluaran.value = pengeluaran;
      totalLabaBersih.value = pemasukan - pengeluaran;
    } catch (e) {
      totalPemasukan.value = 0.0;
      totalPengeluaran.value = 0.0;
      totalLabaBersih.value = 0.0;
    } finally {
      isLoading.value = false;
    }
  }

  String formatCurrency(double amount) {
    final absAmount = amount.abs();
    String formatted;

    if (absAmount >= 1000000) {
      formatted = 'Rp ${(absAmount / 1000000).toStringAsFixed(1)} Jt';
    } else if (absAmount >= 1000) {
      formatted = 'Rp ${(absAmount / 1000).toStringAsFixed(0)} Rb';
    } else {
      formatted = 'Rp ${absAmount.toStringAsFixed(0)}';
    }

    return amount < 0 ? '-$formatted' : formatted;
  }
}

class RingkasanKeuanganWidget extends StatelessWidget {
  const RingkasanKeuanganWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RingkasanKeuanganWidgetController());

    return GestureDetector(
      onTap: () => Get.toNamed('/ringkasan-keuangan'),
      child: Container(
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Keuangan', style: AppTextStyles.header20),
                SizedBox(height: 20),
                Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ringkasan Keuangan',
                    style: AppTextStyles.header20,
                  ),
                  Icon(Icons.chevron_right, size: 28, color: Colors.grey[400]),
                ],
              ),

              const SizedBox(height: 20),

              // Pemasukan
              _buildFinancialItem(
                'Pemasukan',
                controller.formatCurrency(controller.totalPemasukan.value),
                const Color(0xFF10B981),
                Icons.trending_up,
              ),

              const SizedBox(height: 12),

              // Pengeluaran
              _buildFinancialItem(
                'Pengeluaran',
                controller.formatCurrency(controller.totalPengeluaran.value),
                const Color(0xFFEF4444),
                Icons.trending_down,
              ),

              const SizedBox(height: 12),

              // Laba Bersih
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
          );
        }),
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
                style: AppTextStyles.subtitle14.colored(Colors.grey[600]!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.header20.copyWith(
              fontSize: 26,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
