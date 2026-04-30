import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_tagihan_controller.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
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
        padding: EdgeInsets.fromLTRB(
          context.spacing(24),
          0,
          context.spacing(24),
          context.spacing(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: AppTextStyles.subtitle16.colored(AppColors.textGray).copyWith(
                fontSize: context.fontSize(16),
              ),
            ),
            SizedBox(height: context.spacing(16)),

            // Loading state for payment methods
            Obx(() {
              if (controller.isLoadingMetodePembayaran.value) {
                return Center(
                  child: Padding(
                    padding: context.allPadding(20),
                    child: const CircularProgressIndicator(color: Color(0xFF6B8E7A)),
                  ),
                );
              }

              if (controller.metodePembayaranList.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: context.allPadding(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(context.borderRadius(12)),
                    border: Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: const Color(0xFFD97706),
                        size: context.iconSize(24),
                      ),
                      SizedBox(height: context.spacing(8)),
                      Text(
                        'Metode Pembayaran Belum Tersedia',
                        style: AppTextStyles.subtitle14.colored(const Color(0xFFD97706)).copyWith(
                          fontSize: context.fontSize(14),
                        ),
                      ),
                      SizedBox(height: context.spacing(4)),
                      Text(
                        'Silakan hubungi pengelola kost untuk informasi pembayaran.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body12.colored(const Color(0xFFD97706)).copyWith(
                          fontSize: context.fontSize(12),
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
                        SizedBox(height: context.spacing(12)),
                      ],
                    );
                  }),
                ],
              );
            }),

            SizedBox(height: context.spacing(32)),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: context.buttonHeight(50),
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
                      borderRadius: BorderRadius.circular(context.borderRadius(12)),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isUploadingBukti.value
                      ? SizedBox(
                          height: context.iconSize(20),
                          width: context.iconSize(20),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.metodePembayaran.value.toLowerCase() ==
                                  'tunai'
                              ? 'Konfirmasi Pembayaran Tunai'
                              : 'Kirim Bukti Pembayaran',
                          style: AppTextStyles.subtitle16.colored(Colors.white).copyWith(
                            fontSize: context.fontSize(16),
                          ),
                        ),
                );
              }),
            ),
            SizedBox(height: context.spacing(40)),
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
