import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/values/values.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyStateWidget({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ) // Animasi floating buat empty state ini
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -3,
                end: 3,
                duration: 1200.ms,
                curve: Curves.easeInOut,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Pengumuman',
            style: AppTextStyles.header16.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Buat pengumuman baru untuk memberitahu\npenghuni mengenai info penting.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14
                .colored(AppColors.textGray)
                .copyWith(height: 1.5),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buat Pengumuman',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
