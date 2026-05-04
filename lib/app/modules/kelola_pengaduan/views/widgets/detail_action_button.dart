import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/pengaduan_admin_model.dart';
import '../../controllers/kelola_pengaduan_controller.dart';

class DetailActionButton extends StatelessWidget {
  final PengaduanAdminModel pengaduan;
  final KelolaPengaduanController controller;

  const DetailActionButton({
    super.key,
    required this.pengaduan,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _showStatusDialog(context);
            },
            style: OutlinedButton.styleFrom(
              padding: context.verticalPadding(16),
              side: const BorderSide(color: Color(0xFF6B8E7A), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.borderRadius(12)),
              ),
            ),
            child: Text(
              'Ubah Status',
              style: AppTextStyles.buttonMedium
                  .colored(const Color(0xFF6B8E7A))
                  .copyWith(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius(20)),
          ),
          child: Padding(
            padding: context.allPadding(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon & Title
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: context.iconSize(32),
                    color: const Color(0xFF6B8E7A),
                  ),
                ),
                SizedBox(height: context.spacing(16)),
                Text(
                  'Ubah Status Pengaduan',
                  style: AppTextStyles.subtitle16
                      .colored(AppColors.textPrimary)
                      .copyWith(
                        fontSize: context.fontSize(18),
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(8)),
                Text(
                  'Pilih status baru untuk pengaduan ini',
                  style: AppTextStyles.body14
                      .colored(AppColors.textSecondary)
                      .copyWith(fontSize: context.fontSize(14)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(24)),

                // Status Options
                _buildStatusOption(
                  context,
                  'Menunggu',
                  'MENUNGGU',
                  const Color(0xFFFF9800),
                  Icons.schedule_rounded,
                ),
                SizedBox(height: context.spacing(12)),
                _buildStatusOption(
                  context,
                  'Diproses',
                  'DIPROSES',
                  const Color(0xFF2196F3),
                  Icons.autorenew_rounded,
                ),
                SizedBox(height: context.spacing(12)),
                _buildStatusOption(
                  context,
                  'Selesai',
                  'SELESAI',
                  const Color(0xFF4CAF50),
                  Icons.check_circle_rounded,
                ),
                SizedBox(height: context.spacing(16)),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: context.verticalPadding(12),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.buttonMedium
                        .colored(AppColors.textSecondary)
                        .copyWith(
                          fontSize: context.fontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final isCurrentStatus = pengaduan.status.toUpperCase() == value;

    return InkWell(
      onTap: isCurrentStatus
          ? null
          : () async {
              Navigator.pop(context);
              await controller.updateStatus(pengaduan.idLaporan, value);
              Get.back(); // Back to list
            },
      borderRadius: BorderRadius.circular(context.borderRadius(12)),
      child: Container(
        padding: context.allPadding(16),
        decoration: BoxDecoration(
          color: isCurrentStatus
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
          border: Border.all(
            color: isCurrentStatus ? color : color.withValues(alpha: 0.3),
            width: isCurrentStatus ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: context.iconSize(20), color: color),
            ),
            SizedBox(width: context.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.subtitle16
                        .colored(color)
                        .copyWith(
                          fontSize: context.fontSize(15),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (isCurrentStatus) ...[
                    SizedBox(height: context.spacing(2)),
                    Text(
                      'Status saat ini',
                      style: AppTextStyles.body12
                          .colored(color.withValues(alpha: 0.8))
                          .copyWith(fontSize: context.fontSize(11)),
                    ),
                  ],
                ],
              ),
            ),
            if (isCurrentStatus)
              Icon(
                Icons.check_circle,
                color: color,
                size: context.iconSize(24),
              ),
          ],
        ),
      ),
    );
  }
}
