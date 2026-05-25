import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class PengajuanPindahCard extends StatelessWidget {
  const PengajuanPindahCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.userPengajuanPindah),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Color(0xFF0D9488),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pindah Kamar/Kost',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ajukan perpindahan ke kamar lain',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
