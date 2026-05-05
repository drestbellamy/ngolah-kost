import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/pengaduan_admin_model.dart';

class DetailProfileCard extends StatelessWidget {
  final PengaduanAdminModel pengaduan;
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const DetailProfileCard({
    super.key,
    required this.pengaduan,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

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
        children: [
          // Avatar & Name & Status Badge
          Row(
            children: [
              // Avatar - Default Profile Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: context.iconSize(32),
                  color: const Color(0xFF6B8E7A),
                ),
              ),
              SizedBox(width: context.spacing(16)),

              // Name
              Expanded(
                child: Text(
                  pengaduan.namaPenghuni,
                  style: AppTextStyles.subtitle16
                      .colored(AppColors.textPrimary)
                      .copyWith(
                        fontSize: context.fontSize(18),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              SizedBox(width: context.spacing(12)),

              // Status Badge (Clickable)
              GestureDetector(
                onTap: () => _showStatusDialog(context),
                child: _buildStatusBadge(context),
              ),
            ],
          ),

          SizedBox(height: context.spacing(20)),

          // Divider
          Container(height: 1, color: Colors.grey[200]),

          SizedBox(height: context.spacing(20)),

          // Kost
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          size: context.iconSize(16),
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: context.spacing(6)),
                        Text(
                          'Kost',
                          style: AppTextStyles.body12
                              .colored(AppColors.textSecondary)
                              .copyWith(fontSize: context.fontSize(12)),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing(6)),
                    Text(
                      pengaduan.namaKost,
                      style: AppTextStyles.subtitle16
                          .colored(AppColors.textPrimary)
                          .copyWith(
                            fontSize: context.fontSize(15),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;

    switch (selectedStatus.toUpperCase()) {
      case 'MENUNGGU':
        label = 'Menunggu';
        bgColor = const Color(0xFFFF9800);
        textColor = Colors.white;
        break;
      case 'DIPROSES':
        label = 'Diproses';
        bgColor = const Color(0xFF2196F3);
        textColor = Colors.white;
        break;
      case 'SELESAI':
        label = 'Selesai';
        bgColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        break;
      default:
        label = pengaduan.statusLabel;
        bgColor = const Color(0xFF9E9E9E);
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing(16),
        vertical: context.spacing(10),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body14
                .colored(textColor)
                .copyWith(
                  fontSize: context.fontSize(13),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
          SizedBox(width: context.spacing(6)),
          Icon(Icons.edit, size: context.iconSize(14), color: textColor),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
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
    final isSelected = selectedStatus.toUpperCase() == value;

    return InkWell(
      onTap: () {
        onStatusChanged(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(context.borderRadius(12)),
      child: Container(
        padding: context.allPadding(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
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
              child: Text(
                label,
                style: AppTextStyles.subtitle16
                    .colored(color)
                    .copyWith(
                      fontSize: context.fontSize(15),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (isSelected)
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
