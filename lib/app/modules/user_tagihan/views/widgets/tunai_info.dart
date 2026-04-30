import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class TunaiInfo extends StatelessWidget {
  const TunaiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.allPadding(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
        border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: const Color(0xFF3B82F6), // blue-500
            size: context.iconSize(20),
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instruksi Pembayaran Tunai',
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A), // blue-900
                  ),
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  'Silakan lakukan pembayaran langsung kepada pemilik atau pengelola kost. Pastikan Anda menerima konfirmasi setelah pembayaran.',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: const Color(0xFF1D4ED8), // blue-700
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
