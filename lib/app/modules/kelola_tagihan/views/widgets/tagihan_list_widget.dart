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
          margin: const EdgeInsets.only(top: 70),
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.request_quote_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Tagihan',
                style: AppTextStyles.header16.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada data tagihan untuk saat ini.\nTagihan akan otomatis muncul saat siklus\npembayaran dimulai.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14
                    .colored(AppColors.textGray)
                    .copyWith(height: 1.5),
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
