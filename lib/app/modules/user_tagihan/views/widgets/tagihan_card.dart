import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/tagihan_user_model.dart';
import '../../controllers/user_tagihan_controller.dart';

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
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        hasPendingPayment ? Icons.schedule : Icons.receipt_long,
                        color: hasPendingPayment
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF6B8E7A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tagihan Bulanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            tagihan.nomorKamar,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasPendingPayment
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasPendingPayment
                            ? 'Menunggu Verifikasi'
                            : tagihan.status,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Periode Penagihan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      tagihan.periodePenagihan,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tanggal Jatuh Tempo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(tagihan.jatuhTempo),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444), // Merah
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Checkbox visual untuk simulasi selection
                        Container(
                          width: 20,
                          height: 20,
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
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : hasPendingPayment
                              ? const Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: Color(0xFF9CA3AF),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Jumlah Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E7A),
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
