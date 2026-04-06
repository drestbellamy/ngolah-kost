import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RingkasanKeuanganWidget extends StatelessWidget {
  const RingkasanKeuanganWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
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
              'Rp 3.2 Jt',
              const Color(0xFF10B981),
              Icons.trending_up,
            ),

            const SizedBox(height: 12),

            // Pengeluaran
            _buildFinancialItem(
              'Pengeluaran',
              'Rp 2.6 Jt',
              const Color(0xFFEF4444),
              Icons.trending_down,
            ),

            const SizedBox(height: 12),

            // Laba Bersih
            _buildFinancialItem(
              'Laba Bersih',
              'Rp 570 Rb',
              const Color(0xFF6B8E7A),
              Icons.attach_money,
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
