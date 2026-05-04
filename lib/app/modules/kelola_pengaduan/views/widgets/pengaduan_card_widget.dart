import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/pengaduan_admin_model.dart';

class PengaduanCardWidget extends StatelessWidget {
  final PengaduanAdminModel pengaduan;
  final VoidCallback onTap;

  const PengaduanCardWidget({
    super.key,
    required this.pengaduan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing(12)),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left colored indicator bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.borderRadius(16)),
                    bottomLeft: Radius.circular(context.borderRadius(16)),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: context.allPadding(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: context.iconSize(48),
                            height: context.iconSize(48),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius(12),
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: _getStatusColor(),
                              size: context.iconSize(24),
                            ),
                          ),
                          SizedBox(width: context.spacing(12)),

                          // Name & Kost
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pengaduan.namaPenghuni,
                                  style: AppTextStyles.subtitle16
                                      .colored(const Color(0xFF2D3748))
                                      .copyWith(
                                        fontSize: context.fontSize(16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: context.spacing(4)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: context.iconSize(14),
                                      color: const Color(0xFF718096),
                                    ),
                                    SizedBox(width: context.spacing(4)),
                                    Expanded(
                                      child: Text(
                                        pengaduan.namaKost,
                                        style: AppTextStyles.body12
                                            .colored(const Color(0xFF718096))
                                            .copyWith(
                                              fontSize: context.fontSize(12),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: context.symmetricPadding(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius(8),
                              ),
                            ),
                            child: Text(
                              _getStatusLabel(),
                              style: AppTextStyles.body12.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: context.fontSize(11),
                                color: _getStatusColor(),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: context.spacing(12)),

                      // Description
                      Text(
                        pengaduan.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body14
                            .colored(const Color(0xFF718096))
                            .copyWith(
                              fontSize: context.fontSize(13),
                              height: 1.5,
                            ),
                      ),

                      SizedBox(height: context.spacing(12)),

                      // Divider
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),

                      SizedBox(height: context.spacing(12)),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: context.iconSize(14),
                                color: const Color(0xFF9CA3AF),
                              ),
                              SizedBox(width: context.spacing(6)),
                              Text(
                                pengaduan.formattedDate,
                                style: AppTextStyles.body12
                                    .colored(const Color(0xFF9CA3AF))
                                    .copyWith(fontSize: context.fontSize(12)),
                              ),
                            ],
                          ),

                          // Photo count (if exists)
                          if (pengaduan.buktiFoto.isNotEmpty)
                            Container(
                              padding: context.symmetricPadding(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6B8E7A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  context.borderRadius(6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: context.iconSize(14),
                                    color: const Color(0xFF6B8E7A),
                                  ),
                                  SizedBox(width: context.spacing(4)),
                                  Text(
                                    '${pengaduan.buktiFoto.length}',
                                    style: AppTextStyles.body12
                                        .colored(const Color(0xFF6B8E7A))
                                        .copyWith(
                                          fontSize: context.fontSize(12),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (pengaduan.status.toUpperCase()) {
      case 'MENUNGGU':
        return const Color(0xFFFF9800); // Orange
      case 'DIPROSES':
        return const Color(0xFF2196F3); // Blue
      case 'SELESAI':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _getStatusLabel() {
    switch (pengaduan.status.toUpperCase()) {
      case 'MENUNGGU':
        return 'Menunggu';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return pengaduan.statusLabel;
    }
  }
}
