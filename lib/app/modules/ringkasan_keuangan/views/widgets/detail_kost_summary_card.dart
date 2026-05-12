import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import 'compact_financial_item.dart';

class DetailKostSummaryCard extends StatelessWidget {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double labaBersih;
  final String Function(double) formatCurrency;

  const DetailKostSummaryCard({
    super.key,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.labaBersih,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Keuangan Kost',
                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CompactFinancialItem(
              label: 'Pemasukan',
              value: formatCurrency(totalPemasukan),
              color: const Color(0xFF10B981),
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 10),
            CompactFinancialItem(
              label: 'Pengeluaran',
              value: formatCurrency(totalPengeluaran),
              color: const Color(0xFFEF4444),
              icon: Icons.trending_down,
            ),
            const SizedBox(height: 10),
            CompactFinancialItem(
              label: labaBersih >= 0 ? 'Laba Bersih' : 'Rugi Bersih',
              value:
                  '${labaBersih >= 0 ? '+' : ''}${formatCurrency(labaBersih)}',
              color: labaBersih >= 0
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFEF4444),
              icon: labaBersih >= 0 ? Icons.savings : Icons.warning,
            ),
          ],
        ),
      ),
    );
  }
}
