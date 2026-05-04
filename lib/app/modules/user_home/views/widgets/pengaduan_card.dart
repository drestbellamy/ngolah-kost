import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../../../routes/app_routes.dart';

class PengaduanCard extends StatelessWidget {
  const PengaduanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Pengaduan',
          style: AppTextStyles.header18.colored(AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.userPengaduan),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporkan Kendala',
                        style: AppTextStyles.header16.colored(Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fasilitas kamar bermasalah? Laporkan sekarang',
                        style: AppTextStyles.body12.colored(
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
