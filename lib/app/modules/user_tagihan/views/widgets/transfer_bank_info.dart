import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/metode_pembayaran_model.dart';

class TransferBankInfo extends StatelessWidget {
  final List<MetodePembayaranModel> methods;

  const TransferBankInfo({super.key, required this.methods});

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) {
      return Container(
        padding: context.allPadding(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
        ),
        child: Text(
          'Belum ada rekening bank yang tersedia.',
          style: TextStyle(fontSize: context.fontSize(12), color: const Color(0xFFD97706)),
        ),
      );
    }

    return Column(
      children: [
        // Display all available bank accounts
        ...methods.map(
          (metode) => Container(
            margin: EdgeInsets.only(bottom: context.spacing(12)),
            padding: context.allPadding(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(context.borderRadius(12)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metode.nama,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: context.spacing(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'No. Rekening:',
                      style: TextStyle(fontSize: context.fontSize(12), color: const Color(0xFF6B7280)),
                    ),
                    Text(
                      metode.noRek,
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                if (metode.atasNama != null && metode.atasNama!.isNotEmpty) ...[
                  SizedBox(height: context.spacing(4)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Atas Nama:',
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        metode.atasNama!,
                        style: TextStyle(
                          fontSize: context.fontSize(12),
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
