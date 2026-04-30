import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_tagihan_controller.dart';
import 'tagihan_card_widget.dart';
import 'tagihan_shimmer_widget.dart';

class TagihanListWidget extends GetView<KelolaTagihanController> {
  const TagihanListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        // Shimmer loading tanpa gap
        return const TagihanShimmerWidget();
      }

      if (controller.errorMessage.value != null) {
        return Container(
          margin: const EdgeInsets.only(top: 8), // Konsisten dengan card
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECACA), width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFB91C1C),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.errorMessage.value!,
                  style: AppTextStyles.body14.colored(const Color(0xFFB91C1C)),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.filteredTagihanList.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(top: 8), // Konsisten dengan card
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Belum ada data tagihan',
                style: AppTextStyles.header16.colored(const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              Text(
                'Data tagihan akan muncul di sini',
                style: AppTextStyles.body12.colored(AppColors.textGray),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Hilangkan padding default
        itemCount: controller.filteredTagihanList.length,
        itemBuilder: (context, index) {
          final tagihan = controller.filteredTagihanList[index];
          return TagihanCardWidget(tagihan: tagihan, index: index);
        },
      );
    });
  }
}
