import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../../../data/models/pengumuman_model.dart';

class PengumumanCard extends StatelessWidget {
  final PengumumanModel pengumuman;

  const PengumumanCard({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(16)),
      padding: context.allPadding(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: context.allPadding(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: const Color(0xFF6B8E7A),
                  size: context.iconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(12)),
              Expanded(
                child: Text(
                  pengumuman.judul,
                  style: AppTextStyles.header16.colored(
                    const Color(0xFF1F2937),
                  ).copyWith(fontSize: context.fontSize(16)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(12)),
          Text(
            pengumuman.isi,
            style: AppTextStyles.body14
                .colored(const Color(0xFF4B5563))
                .copyWith(height: 1.5, fontSize: context.fontSize(14)),
          ),
          SizedBox(height: context.spacing(16)),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: context.iconSize(14),
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(width: context.spacing(4)),
              Text(
                pengumuman.tanggal,
                style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)).copyWith(
                  fontSize: context.fontSize(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
