import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../models/tagihan_model.dart';
import 'verifikasi_pembayaran_bottom_sheet.dart';

class TagihanCardWidget extends StatelessWidget {
  final TagihanModel tagihan;
  final int index;

  const TagihanCardWidget({
    super.key,
    required this.tagihan,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (tagihan.status) {
      case 'lunas':
        statusColor = const Color(0xFF10B981);
        statusText = 'Lunas';
        break;
      case 'menunggu_verifikasi':
        statusColor = const Color(0xFFF2A65A);
        statusText = 'Menunggu Verifikasi';
        break;
      case 'belum_dibayar':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Belum Dibayar';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusText = 'Unknown';
    }

    return Container(
      margin: EdgeInsets.only(
        top: index == 0 ? 12 : 0, // 8px top margin for first card
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tagihan.namaPenghuni,
                  style: AppTextStyles.header16.colored(AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.subtitle12.colored(statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.home_work, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tagihan.namaKost,
                  style: AppTextStyles.body12.colored(AppColors.textGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tagihan.nomorKamar,
                      style: AppTextStyles.body14.colored(
                        const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tagihan.tanggalJatuhTempo,
                    style: AppTextStyles.body14.colored(
                      const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah Tagihan',
                style: AppTextStyles.body12.colored(AppColors.textGray),
              ),
              Text(
                'Rp ${tagihan.jumlahTagihan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: AppTextStyles.header16.colored(AppColors.primary),
              ),
            ],
          ),
          if (tagihan.status == 'menunggu_verifikasi') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    VerifikasiPembayaranBottomSheet(tagihan: tagihan),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Verifikasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A65A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
