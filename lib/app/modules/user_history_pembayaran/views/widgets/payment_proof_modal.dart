import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../../models/payment_detail_model.dart';
import '../../../../core/values/values.dart';

class PaymentProofModal extends StatelessWidget {
  final PaymentDetail detail;

  const PaymentProofModal({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    bool isSuccess = detail.status.toLowerCase().contains('lunas') || 
                     detail.status.toLowerCase().contains('berhasil') || 
                     detail.status.toLowerCase().contains('terima') ||
                     detail.status.toLowerCase().contains('terverifikasi');
    bool isRejected = detail.status.toLowerCase().contains('ditolak');
    bool isCash = detail.paymentMethod.toLowerCase().contains('cash') || 
                  detail.paymentMethod.toLowerCase().contains('tunai');
    
    Color statusColor = isSuccess ? const Color(0xFF6B8E7A) : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFF59E0B));
    Color statusBgColor = isSuccess ? const Color(0xFFE8F5E9) : (isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFFEF3C7));
    IconData statusIcon = isSuccess ? Icons.check : (isRejected ? Icons.close : Icons.access_time);

    String statusText = isSuccess ? 'Berhasil Lunas' : (isRejected ? 'Ditolak' : 'Menunggu Konfirmasi');

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pembayaran',
                  style: AppTextStyles.header20.colored(AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSuccess ? const Color.fromARGB(255, 70, 126, 72) : (isRejected ? const Color(0xFFFECACA) : const Color(0xFFFDE68A)), width: 2),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Status Pembayaran',
                    style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: AppTextStyles.header20.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.04),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Bulan Tagihan', detail.month),
                        const SizedBox(height: 16),
                        _buildInfoRow('Metode Pembayaran', detail.paymentMethod),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Tanggal Pembayaran',
                          DateFormat('dd MMM yyyy', 'id_ID').format(detail.paymentDate),
                          isMultiLine: true,
                        ),
                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Nominal',
                              style: AppTextStyles.body14.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(detail.amount),
                              style: AppTextStyles.body16.copyWith(
                                color: const Color(0xFF6B8E7A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (!isCash) ...[
                    // Image Section
                    Row(
                      children: [
                        Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Foto Bukti Pembayaran',
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Proof Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: detail.proofImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: detail.proofImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                height: 450,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6B8E7A),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 450,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 450,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bukti pembayaran tidak tersedia',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],

                  // Rejection reason if any
                  if (detail.rejectionReason != null &&
                      detail.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alasan Penolakan',
                                  style: AppTextStyles.body14.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  detail.rejectionReason!,
                                  style: AppTextStyles.body14.copyWith(
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body14.colored(AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
              ),
            );
          }),
        );
      },
    );
  }
}