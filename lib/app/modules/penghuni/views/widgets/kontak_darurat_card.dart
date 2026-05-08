import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';
import 'info_row_widget.dart';

class KontakDaruratCard extends StatelessWidget {
  final PenghuniModel penghuni;

  const KontakDaruratCard({super.key, required this.penghuni});

  @override
  Widget build(BuildContext context) {
    // Check if there's any emergency contact data
    final hasData =
        (penghuni.namaKontakDarurat != null &&
            penghuni.namaKontakDarurat!.isNotEmpty) ||
        (penghuni.teleponKontakDarurat != null &&
            penghuni.teleponKontakDarurat!.isNotEmpty);

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency_outlined, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Kontak Darurat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nama Kontak Darurat
          if (penghuni.namaKontakDarurat != null &&
              penghuni.namaKontakDarurat!.isNotEmpty)
            Column(
              children: [
                InfoRowWidget(
                  icon: Icons.person_outline,
                  label: 'Nama',
                  value: penghuni.namaKontakDarurat!,
                  iconBgColor: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFE57373),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Hubungan
          if (penghuni.hubunganKontakDarurat != null &&
              penghuni.hubunganKontakDarurat!.isNotEmpty)
            Column(
              children: [
                InfoRowWidget(
                  icon: Icons.family_restroom,
                  label: 'Hubungan',
                  value: penghuni.hubunganKontakDarurat!,
                  iconBgColor: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFE57373),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Nomor Telepon Darurat
          if (penghuni.teleponKontakDarurat != null &&
              penghuni.teleponKontakDarurat!.isNotEmpty)
            InfoRowWidget(
              icon: Icons.phone,
              label: 'Nomor Telepon',
              value: penghuni.teleponKontakDarurat!,
              iconBgColor: const Color(0xFFFFEBEE),
              iconColor: const Color(0xFFE57373),
            ),
        ],
      ),
    );
  }
}
