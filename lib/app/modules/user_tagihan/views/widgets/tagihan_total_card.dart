import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/user_tagihan_controller.dart';
import '../../../../core/values/values.dart';

class TagihanTotalCard extends GetView<UserTagihanController> {
  const TagihanTotalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            Text(
              'Total yang dibayar',
              style: AppTextStyles.subtitle16.colored(AppColors.textGray),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(controller.totalBayarTerpilih),
                style: AppTextStyles.displaySmall.colored(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
