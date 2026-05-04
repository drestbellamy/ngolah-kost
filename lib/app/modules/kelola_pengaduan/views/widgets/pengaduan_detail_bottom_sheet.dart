import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../controllers/kelola_pengaduan_controller.dart';
import '../../models/pengaduan_admin_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PengaduanDetailBottomSheet extends GetView<KelolaPengaduanController> {
  final PengaduanAdminModel pengaduan;

  const PengaduanDetailBottomSheet({super.key, required this.pengaduan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius(24)),
          topRight: Radius.circular(context.borderRadius(24)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: context.verticalPadding(12),
              width: context.width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(context.borderRadius(2)),
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: context.allPadding(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Detail Pengaduan',
                            style: AppTextStyles.header20
                                .colored(AppColors.textPrimary)
                                .copyWith(fontSize: context.fontSize(20)),
                          ),
                        ),
                        _buildStatusBadge(context),
                      ],
                    ),
                    SizedBox(height: context.spacing(20)),

                    // Kode Laporan
                    _buildInfoRow(
                      context,
                      'Kode Laporan',
                      pengaduan.kodeLaporan,
                      Icons.qr_code_outlined,
                    ),
                    SizedBox(height: context.spacing(12)),

                    // Tanggal
                    _buildInfoRow(
                      context,
                      'Tanggal',
                      pengaduan.formattedDate,
                      Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: context.spacing(12)),

                    // Penghuni
                    _buildInfoRow(
                      context,
                      'Penghuni',
                      pengaduan.namaPenghuni,
                      Icons.person_outline,
                    ),
                    SizedBox(height: context.spacing(12)),

                    // Kost
                    _buildInfoRow(
                      context,
                      'Kost',
                      pengaduan.namaKost,
                      Icons.home_outlined,
                    ),
                    SizedBox(height: context.spacing(20)),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: AppTextStyles.subtitle16
                          .colored(AppColors.textPrimary)
                          .copyWith(fontSize: context.fontSize(16)),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Container(
                      width: double.infinity,
                      padding: context.allPadding(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F8),
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(8),
                        ),
                      ),
                      child: Text(
                        pengaduan.deskripsi,
                        style: AppTextStyles.body14
                            .colored(AppColors.textPrimary)
                            .copyWith(fontSize: context.fontSize(14)),
                      ),
                    ),
                    SizedBox(height: context.spacing(20)),

                    // Bukti Foto
                    if (pengaduan.buktiFoto.isNotEmpty) ...[
                      Text(
                        'Bukti Foto (${pengaduan.buktiFoto.length})',
                        style: AppTextStyles.subtitle16
                            .colored(AppColors.textPrimary)
                            .copyWith(fontSize: context.fontSize(16)),
                      ),
                      SizedBox(height: context.spacing(12)),
                      SizedBox(
                        height: context.height * 0.15,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pengaduan.buktiFoto.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showFullImage(
                                context,
                                pengaduan.buktiFoto[index],
                              ),
                              child: Container(
                                width: context.width * 0.3,
                                margin: EdgeInsets.only(
                                  right: context.spacing(12),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius(8),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius(8),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: pengaduan.buktiFoto[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.error_outline,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: context.spacing(20)),
                    ],

                    // Action Buttons
                    Text(
                      'Ubah Status',
                      style: AppTextStyles.subtitle16
                          .colored(AppColors.textPrimary)
                          .copyWith(fontSize: context.fontSize(16)),
                    ),
                    SizedBox(height: context.spacing(12)),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusButton(
                            context,
                            'Menunggu',
                            'MENUNGGU',
                            const Color(0xFFF59E0B),
                          ),
                        ),
                        SizedBox(width: context.spacing(12)),
                        Expanded(
                          child: _buildStatusButton(
                            context,
                            'Diproses',
                            'DIPROSES',
                            const Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: context.spacing(12)),
                        Expanded(
                          child: _buildStatusButton(
                            context,
                            'Selesai',
                            'SELESAI',
                            const Color(0xFF10B981),
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
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.iconSize(20), color: AppColors.textSecondary),
        SizedBox(width: context.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body12
                    .colored(AppColors.textSecondary)
                    .copyWith(fontSize: context.fontSize(12)),
              ),
              SizedBox(height: context.spacing(4)),
              Text(
                value,
                style: AppTextStyles.body14
                    .colored(AppColors.textPrimary)
                    .copyWith(fontSize: context.fontSize(14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (pengaduan.status.toUpperCase()) {
      case 'MENUNGGU':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'DIPROSES':
        bgColor = const Color(0xFFDCEEFB);
        textColor = const Color(0xFF2563EB);
        break;
      case 'SELESAI':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing(12),
        vertical: context.spacing(6),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.borderRadius(8)),
      ),
      child: Text(
        pengaduan.statusLabel,
        style: AppTextStyles.body12
            .colored(textColor)
            .copyWith(
              fontSize: context.fontSize(12),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    String status,
    Color color,
  ) {
    final isCurrentStatus =
        pengaduan.status.toUpperCase() == status.toUpperCase();

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return ElevatedButton(
        onPressed: isCurrentStatus || isLoading
            ? null
            : () => controller.updateStatus(pengaduan.idLaporan, status),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentStatus ? color : Colors.white,
          foregroundColor: isCurrentStatus ? Colors.white : color,
          padding: context.verticalPadding(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius(8)),
            side: BorderSide(color: color, width: 1.5),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.fontSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
