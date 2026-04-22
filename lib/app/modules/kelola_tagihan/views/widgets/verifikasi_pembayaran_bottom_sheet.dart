import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_tagihan_controller.dart';
import '../../models/tagihan_model.dart';

class VerifikasiPembayaranBottomSheet extends StatelessWidget {
  final TagihanModel tagihan;

  const VerifikasiPembayaranBottomSheet({super.key, required this.tagihan});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KelolaTagihanController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header - Fixed
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verifikasi Pembayaran',
                            style: AppTextStyles.header20.colored(const Color(0xFF2D3748)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tagihan.namaPenghuni} • ${tagihan.nomorKamar}',
                            style: AppTextStyles.header16.colored(AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bukti Transfer Label
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2A65A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tagihan.buktiPembayaranUrl != null
                                ? 'Bukti Transfer'
                                : 'Pembayaran Tunai',
                            style: AppTextStyles.header16.colored(const Color(0xFF2D3748)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Transfer Receipt Image or Cash Payment Info
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: tagihan.buktiPembayaranUrl != null
                              ? Image.network(
                                  tagihan.buktiPembayaranUrl!,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 400,
                                          padding: const EdgeInsets.all(40),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 400,
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 80,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Gagal memuat bukti pembayaran',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 200,
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.money,
                                          size: 48,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Pembayaran Tunai',
                                        style: AppTextStyles.header18.colored(const Color(0xFF2D3748)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Penghuni telah mengkonfirmasi pembayaran tunai.\nTidak ada bukti transfer yang diperlukan.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Payment Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF2A65A),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jumlah Tagihan',
                              style: AppTextStyles.header16.colored(AppColors.textGray),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${tagihan.jumlahTagihan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTextStyles.header20.weighted(FontWeight.w900).colored(AppColors.primary).copyWith(fontSize: 28),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Additional Info - Row Layout
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Batas Bayar',
                                    style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tagihan.batasPembayaran,
                                    style: AppTextStyles.header16.colored(const Color(0xFF2D3748)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jatuh Tempo',
                                    style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tagihan.tanggalJatuhTempo,
                                    style: AppTextStyles.header16.colored(const Color(0xFF2D3748)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Lokasi Kost
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi Kost',
                              style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tagihan.namaKost,
                              style: AppTextStyles.header16.colored(const Color(0xFF2D3748)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.tolakPembayaran(tagihan),
                        icon: const Icon(Icons.close, size: 20),
                        label: Text('Tolak', style: AppTextStyles.subtitle14.colored(Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.verifikasiPembayaran(tagihan),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: Text('Terima', style: AppTextStyles.subtitle14.colored(Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
