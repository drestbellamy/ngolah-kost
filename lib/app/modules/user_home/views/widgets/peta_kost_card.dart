import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';

class PetaKostCard extends StatelessWidget {
  const PetaKostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.kostMap),
      child: Container(
        padding: context.allPadding(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: context.allPadding(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(context.borderRadius(12)),
              ),
              child: Icon(
                Icons.map_outlined,
                color: const Color(0xFF4CAF50),
                size: context.iconSize(28),
              ),
            ),
            SizedBox(width: context.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peta Lokasi Kost',
                    style: AppTextStyles.header16
                        .colored(const Color(0xFF1F2937))
                        .copyWith(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    'Lihat semua lokasi cabang kost',
                    style: AppTextStyles.body12
                        .colored(const Color(0xFF6B7280))
                        .copyWith(fontSize: context.fontSize(13)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF9CA3AF),
              size: context.iconSize(24),
            ),
          ],
        ),
      ),
    );
  }
}
