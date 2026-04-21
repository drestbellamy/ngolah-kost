import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_profil_controller.dart';

class ContractInfoSection extends GetView<UserProfilController> {
  const ContractInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi Kontrak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Obx(() {
                final profile = controller.userProfile.value;
                final isActive = profile?.status == 'aktif';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Tidak Aktif',
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFFE5A83D),
            iconBgColor: const Color(0xFFFFF7E6),
            label: 'Harga per Bulan',
            value: _formatCurrency(controller.hargaPerBulan),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFFE5A83D),
            iconBgColor: const Color(0xFFFFF7E6),
            label: 'Durasi Kontrak',
            value: controller.durasiKontrak,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFFE5A83D),
            iconBgColor: const Color(0xFFFFF7E6),
            label: 'Sistem Pembayaran',
            value: controller.sistemPembayaran,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: Colors.grey,
            iconBgColor: const Color(0xFFF9F9F9),
            label: 'Periode Kontrak',
            value: controller.periodeKontrak,
            isExpanded: true,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    bool isExpanded = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: isExpanded ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Tagihan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tagihan:'),
              Text(
                '${controller.totalTagihan}x pembayaran',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Per Tagihan:', style: TextStyle(color: Colors.grey)),
              Text(
                _formatCurrency(controller.perTagihan),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Nilai Kontrak:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                _formatCurrency(controller.totalNilaiKontrak),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8E7A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
