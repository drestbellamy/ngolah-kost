import 'package:flutter/material.dart';

class TunaiInfo extends StatelessWidget {
  const TunaiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: Color(0xFF3B82F6), // blue-500
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Instruksi Pembayaran Tunai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A), // blue-900
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Silakan lakukan pembayaran langsung kepada pemilik atau pengelola kost. Pastikan Anda menerima konfirmasi setelah pembayaran.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1D4ED8), // blue-700
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
