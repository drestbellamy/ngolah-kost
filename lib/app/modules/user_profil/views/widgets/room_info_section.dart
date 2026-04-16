import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_profil_controller.dart';

class RoomInfoSection extends GetView<UserProfilController> {
  const RoomInfoSection({super.key});

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
            'Informasi Kost',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.home_outlined,
            iconColor: const Color(0xFF6B8E7A),
            iconBgColor: const Color(0xFFF0F5F2),
            label: 'Nama Kost',
            value: controller.namaKost.value,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.door_front_door_outlined,
            iconColor: const Color(0xFF6B8E7A),
            iconBgColor: const Color(0xFFF0F5F2),
            label: 'Nomor Kamar',
            value: controller.nomorKamar,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFEF4444),
            iconBgColor: const Color(0xFFFEF2F2),
            label: 'Alamat',
            value: controller.alamatKost.value,
            isExpanded: true,
          ),
          const SizedBox(height: 8),
          Obx(() {
            final hasAddress =
                controller.alamatKost.value.isNotEmpty &&
                controller.alamatKost.value != '-';
            if (!hasAddress) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(left: 42),
              child: OutlinedButton.icon(
                onPressed: () => controller.openMap(),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('Buka di Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B8E7A),
                  side: const BorderSide(color: Color(0xFF6B8E7A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            );
          }),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: Colors.black,
                ),
                maxLines: isExpanded ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
