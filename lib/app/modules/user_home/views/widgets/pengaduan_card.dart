import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';

class PengaduanCard extends StatelessWidget {
  const PengaduanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.userPengaduan),
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
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(context.borderRadius(12)),
              ),
              child: Icon(
                Icons.build_outlined,
                color: const Color(0xFF2196F3),
                size: context.iconSize(28),
              ),
            ),
            SizedBox(width: context.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lapor Kendala',
                    style: AppTextStyles.header16
                        .colored(const Color(0xFF1F2937))
                        .copyWith(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    'Ada fasilitas yang rusak?',
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
