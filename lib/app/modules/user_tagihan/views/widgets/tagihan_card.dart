import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/tagihan_user_model.dart';
import '../../controllers/user_tagihan_controller.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';

class TagihanCard extends GetView<UserTagihanController> {
  final TagihanUserModel tagihan;

  const TagihanCard({super.key, required this.tagihan});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = controller.tagihanTerpilih.contains(tagihan);
      bool hasPendingPayment = !controller.canSelectTagihan(tagihan);

      return GestureDetector(
        onTap: () => controller.toggleTagihan(tagihan),
        child: Opacity(
          opacity: hasPendingPayment ? 0.6 : 1.0,
          child: Container(
            margin: EdgeInsets.only(bottom: context.spacing(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.borderRadius(16)),
              border: Border.all(
                color: hasPendingPayment
                    ? const Color(0xFFF59E0B)
                    : isSelected
                    ? const Color(0xFF6B8E7A)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: context.allPadding(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.iconSize(40),
                      height: context.iconSize(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(context.borderRadius(10)),
                      ),
                      child: Icon(
                        hasPendingPayment ? Icons.schedule : Icons.receipt_long,
                        color: hasPendingPayment
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF6B8E7A),
                        size: context.iconSize(20),
                      ),
                    ),
                    SizedBox(width: context.spacing(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan Bulanan',
                            style: AppTextStyles.header16.colored(AppColors.textPrimary).copyWith(
                              fontSize: context.fontSize(16),
                            ),
                          ),
                          Text(
                            tagihan.nomorKamar,
                            style: AppTextStyles.body12.colored(AppColors.textGray).copyWith(
                              fontSize: context.fontSize(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: context.symmetricPadding(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasPendingPayment
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(context.borderRadius(20)),
                      ),
                      child: Text(
                        hasPendingPayment
                            ? 'Menunggu Verifikasi'
                            : tagihan.status,
                        style: AppTextStyles.body10.weighted(FontWeight.w700).colored(const Color(0xFFD97706)).copyWith(
                          fontSize: context.fontSize(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periode Penagihan',
                      style: AppTextStyles.body12.colored(AppColors.textGray).copyWith(
                        fontSize: context.fontSize(12),
                      ),
                    ),
                    Text(
                      tagihan.periodePenagihan,
                      style: AppTextStyles.subtitle12.colored(AppColors.textPrimary).copyWith(
                        fontSize: context.fontSize(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: context.iconSize(14),
                          color: AppColors.textGray,
                        ),
                        SizedBox(width: context.spacing(4)),
                        Text(
                          'Tanggal Jatuh Tempo',
                          style: AppTextStyles.body12.colored(AppColors.textGray).copyWith(
                            fontSize: context.fontSize(12),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(tagihan.jatuhTempo),
                      style: AppTextStyles.subtitle12.colored(AppColors.errorLight).copyWith(
                        fontSize: context.fontSize(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Checkbox visual untuk simulasi selection
                        Container(
                          width: context.iconSize(20),
                          height: context.iconSize(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: hasPendingPayment
                                  ? const Color(0xFFD1D5DB)
                                  : isSelected
                                  ? const Color(0xFF6B8E7A)
                                  : const Color(0xFFD1D5DB),
                              width: 2,
                            ),
                            color: hasPendingPayment
                                ? const Color(0xFFD1D5DB)
                                : isSelected
                                ? const Color(0xFF6B8E7A)
                                : Colors.transparent,
                          ),
                          child: isSelected && !hasPendingPayment
                              ? Icon(
                                  Icons.check,
                                  size: context.iconSize(14),
                                  color: Colors.white,
                                )
                              : hasPendingPayment
                              ? Icon(
                                  Icons.schedule,
                                  size: context.iconSize(12),
                                  color: const Color(0xFF9CA3AF),
                                )
                              : null,
                        ),
                        SizedBox(width: context.spacing(8)),
                        Text(
                          'Jumlah Total',
                          style: AppTextStyles.subtitle14.colored(AppColors.textPrimary).copyWith(
                            fontSize: context.fontSize(14),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(tagihan.totalBayar),
                      style: AppTextStyles.header20.colored(AppColors.primary).copyWith(
                        fontSize: context.fontSize(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
