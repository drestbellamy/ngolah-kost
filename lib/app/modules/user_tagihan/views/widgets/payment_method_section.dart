import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_tagihan_controller.dart';
import 'payment_method_option.dart';
import 'transfer_bank_info.dart';
import 'qris_info.dart';
import 'tunai_info.dart';
import 'upload_bottom_sheet.dart';

class PaymentMethodSection extends GetView<UserTagihanController> {
  const PaymentMethodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 16),

            // Loading state for payment methods
            Obx(() {
              if (controller.isLoadingMetodePembayaran.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
                  ),
                );
              }

              if (controller.metodePembayaranList.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Color(0xFFD97706),
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Metode Pembayaran Belum Tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Silakan hubungi pengelola kost untuk informasi pembayaran.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Display payment methods grouped by type
              final availableTypes = controller.availablePaymentTypes;

              return Column(
                children: [
                  ...availableTypes.map((tipe) {
                    return Column(
                      children: [
                        Obx(
                          () => PaymentMethodOption(
                            title: tipe,
                            icon: _getIconForTipe(tipe),
                            isSelected:
                                controller.metodePembayaran.value == tipe,
                            onTap: () =>
                                controller.selectMetodePembayaran(tipe),
                            isExpanded:
                                controller.metodePembayaran.value == tipe,
                            expandedContent: _buildExpandedContent(tipe),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() {
                bool isEnabled =
                    controller.tagihanTerpilih.isNotEmpty &&
                    controller.metodePembayaran.value.isNotEmpty &&
                    !controller.isUploadingBukti.value;

                return ElevatedButton(
                  onPressed: isEnabled
                      ? () {
                          // Check if payment method is cash (tunai)
                          if (controller.metodePembayaran.value.toLowerCase() ==
                              'tunai') {
                            // For cash payments, submit directly without image upload
                            controller.submitCashPayment();
                          } else {
                            // For other payment methods, show upload bottom sheet
                            showUploadBottomSheet();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    disabledBackgroundColor: const Color(
                      0xFFFBBF24,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isUploadingBukti.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.metodePembayaran.value.toLowerCase() ==
                                  'tunai'
                              ? 'Konfirmasi Pembayaran Tunai'
                              : 'Kirim Bukti Pembayaran',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTipe(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'transfer':
        return Icons.account_balance;
      case 'qris':
        return Icons.qr_code_2;
      case 'tunai':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  Widget _buildExpandedContent(String tipe) {
    final methods = controller.getMethodsByType(tipe);

    switch (tipe.toLowerCase()) {
      case 'transfer':
        return TransferBankInfo(methods: methods);
      case 'qris':
        return QrisInfo(methods: methods);
      case 'tunai':
        return const TunaiInfo();
      default:
        return TransferBankInfo(methods: methods);
    }
  }
}
