import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../services/supabase_service.dart';

class RingkasanKeuanganWidgetController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

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
      final kosts = await _supabaseService.getKostList();
      double pemasukan = 0.0;
      double pengeluaran = 0.0;

      for (final kost in kosts) {
        final ringkasan = await _supabaseService.getRingkasanKeuanganByKostId(
          kost.id,
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
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
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
                Text(
                  'Ringkasan Keuangan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
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
                'Laba Bersih',
                controller.formatCurrency(controller.totalLabaBersih.value),
                const Color(0xFF6B8E7A),
                Icons.attach_money,
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
