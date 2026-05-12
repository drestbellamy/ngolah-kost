import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../models/ringkasan_keuangan_model.dart';

class KostListItem extends StatelessWidget {
  final RingkasanKeuanganModel kost;
  final String Function(double) formatCurrency;

  const KostListItem({
    super.key,
    required this.kost,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              color: Colors.black.withValues(alpha: 0.05),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.home_work, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kost.kostName,
                    style: AppTextStyles.header16.colored(
                      AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kost.kostAddress,
                    style: AppTextStyles.body14.colored(
                      AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Financial indicators in one row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildSmallIndicator(
                        Icons.trending_up,
                        formatCurrency(kost.pemasukan),
                        const Color(0xFF10B981),
                      ),
                      _buildSmallIndicator(
                        Icons.trending_down,
                        formatCurrency(kost.pengeluaran),
                        const Color(0xFFEF4444),
                      ),
                      _buildSmallIndicator(
                        kost.labaBersih >= 0 ? Icons.savings : Icons.warning,
                        '${kost.labaBersih >= 0 ? '+' : ''}${formatCurrency(kost.labaBersih)}',
                        kost.labaBersih >= 0
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIndicator(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
