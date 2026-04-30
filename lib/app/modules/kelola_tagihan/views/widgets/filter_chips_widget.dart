import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kelola_tagihan_controller.dart';

class FilterChipsWidget extends GetView<KelolaTagihanController> {
  const FilterChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Semua (${controller.getCountByStatus('semua')})',
              'semua',
              const Color(0xFF6B8E7F),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Menunggu (${controller.getCountByStatus('menunggu_verifikasi')})',
              'menunggu_verifikasi',
              const Color(0xFFF2A65A),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Belum Dibayar (${controller.getCountByStatus('belum_dibayar')})',
              'belum_dibayar',
              const Color(0xFFEF4444),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Lunas (${controller.getCountByStatus('lunas')})',
              'lunas',
              const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.changeFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
