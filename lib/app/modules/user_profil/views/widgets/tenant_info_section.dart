import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_profil_controller.dart';

class TenantInfoSection extends GetView<UserProfilController> {
  const TenantInfoSection({super.key});

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
          const Text(
            'Informasi Penghuni',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Nama',
            value: controller.userName,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.call_outlined,
            label: 'Telepon',
            value: controller.userPhone,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Username',
            value: controller.username.value,
          ),
          const SizedBox(height: 16),
          _buildPasswordRow(),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Masuk',
            value: controller.tanggalMasuk,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    // Define colors based on icon type
    Color iconColor;
    Color iconBgColor;

    if (icon == Icons.person_outline) {
      iconColor = const Color(0xFF6B8E7A);
      iconBgColor = const Color(0xFFF0F5F2);
    } else if (icon == Icons.call_outlined) {
      iconColor = const Color(0xFF3B82F6);
      iconBgColor = const Color(0xFFEFF6FF);
    } else if (icon == Icons.account_circle_outlined) {
      iconColor = const Color(0xFF8B5CF6);
      iconBgColor = const Color(0xFFF5F3FF);
    } else if (icon == Icons.calendar_today_outlined) {
      iconColor = const Color(0xFFE5A83D);
      iconBgColor = const Color(0xFFFFF7E6);
    } else {
      iconColor = Colors.grey;
      iconBgColor = const Color(0xFFF9F9F9);
    }

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
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '••••••••',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
