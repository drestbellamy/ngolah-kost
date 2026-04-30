import 'package:flutter/material.dart';

class InfoBannerWidget extends StatelessWidget {
  final String? namaGedung;

  const InfoBannerWidget({super.key, this.namaGedung});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FF),
        border: Border.all(color: const Color(0xFFD6E4FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              namaGedung == null
                  ? 'Pengumuman akan diterapkan sesuai gedung kost yang dipilih.'
                  : 'Pengumuman diterapkan untuk $namaGedung.',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
