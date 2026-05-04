import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/pengaduan_admin_model.dart';

class DetailInfoCard extends StatelessWidget {
  final PengaduanAdminModel pengaduan;

  const DetailInfoCard({super.key, required this.pengaduan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.allPadding(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.description,
                size: context.iconSize(20),
                color: const Color(0xFF6B8E7A),
              ),
              SizedBox(width: context.spacing(8)),
              Text(
                'Informasi Laporan',
                style: AppTextStyles.subtitle16
                    .colored(AppColors.textPrimary)
                    .copyWith(
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          SizedBox(height: context.spacing(20)),

          // Waktu Laporan
          _buildInfoRow(
            context,
            'Waktu Laporan',
            pengaduan.formattedDate,
            Icons.calendar_today,
          ),

          SizedBox(height: context.spacing(16)),

          // Kode Laporan
          _buildInfoRow(
            context,
            'Kode Laporan',
            pengaduan.kodeLaporan,
            Icons.qr_code,
          ),

          SizedBox(height: context.spacing(20)),

          // Deskripsi Lengkap
          Text(
            'Deskripsi Lengkap',
            style: AppTextStyles.body12
                .colored(AppColors.textSecondary)
                .copyWith(fontSize: context.fontSize(12)),
          ),
          SizedBox(height: context.spacing(8)),
          Container(
            padding: context.allPadding(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(context.borderRadius(12)),
            ),
            child: Text(
              pengaduan.deskripsi,
              style: AppTextStyles.body14
                  .colored(AppColors.textPrimary)
                  .copyWith(fontSize: context.fontSize(14), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body12
              .colored(AppColors.textSecondary)
              .copyWith(fontSize: context.fontSize(12)),
        ),
        SizedBox(height: context.spacing(8)),
        Row(
          children: [
            Icon(
              icon,
              size: context.iconSize(16),
              color: const Color(0xFFFF9800),
            ),
            SizedBox(width: context.spacing(8)),
            Text(
              value,
              style: AppTextStyles.subtitle16
                  .colored(AppColors.textPrimary)
                  .copyWith(
                    fontSize: context.fontSize(15),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
