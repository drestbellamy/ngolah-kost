import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';

class PengajuanPindahCard extends StatelessWidget {
  const PengajuanPindahCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.userPengajuanPindah),
      child: Container(
        width: double.infinity,
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
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(context.borderRadius(12)),
              ),
              child: Icon(
                Icons.sync_alt_outlined,
                color: const Color(0xFFF2A65A),
                size: context.iconSize(28),
              ),
            ),
            SizedBox(width: context.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pindah Kamar',
                    style: AppTextStyles.header16
                        .colored(const Color(0xFF1F2937))
                        .copyWith(
                          fontSize: context.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    'Ajukan perpindahan kamar lain',
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
