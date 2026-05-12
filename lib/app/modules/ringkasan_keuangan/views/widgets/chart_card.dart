import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import 'financial_chart.dart';

class ChartCard extends StatelessWidget {
  final List<double> pemasukanData;
  final List<double> pengeluaranData;
  final List<String> labels;

  const ChartCard({
    super.key,
    required this.pemasukanData,
    required this.pengeluaranData,
    required this.labels,
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grafik Keuangan Bulanan',
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
            const SizedBox(height: 20),
            // Chart
            Expanded(
              child: pemasukanData.isNotEmpty
                  ? FinancialChart(
                      pemasukanData: pemasukanData,
                      pengeluaranData: pengeluaranData,
                      labels: labels,
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B8E7A),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Pemasukan', const Color(0xFF10B981)),
                const SizedBox(width: 24),
                _buildLegend('Pengeluaran', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body14.colored(AppColors.textSecondary),
        ),
      ],
    );
  }
}
