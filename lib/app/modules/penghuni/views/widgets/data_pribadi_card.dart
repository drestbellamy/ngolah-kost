import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';
import 'info_row_widget.dart';

class DataPribadiCard extends StatelessWidget {
  final PenghuniModel penghuni;

  const DataPribadiCard({super.key, required this.penghuni});

  @override
  Widget build(BuildContext context) {
    // Check if there's any data to display
    final hasData =
        (penghuni.jenisKelamin != null && penghuni.jenisKelamin!.isNotEmpty) ||
        (penghuni.tanggalLahir != null && penghuni.tanggalLahir!.isNotEmpty) ||
        (penghuni.alamatAsal != null && penghuni.alamatAsal!.isNotEmpty);

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
              Icon(Icons.person_outline, size: 20, color: Color(0xFF6B8E7F)),
              SizedBox(width: 8),
              Text(
                'Data Pribadi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          if (penghuni.jenisKelamin != null &&
              penghuni.jenisKelamin!.isNotEmpty)
            Column(
              children: [
                InfoRowWidget(
                  icon: penghuni.jenisKelamin == 'Laki-laki'
                      ? Icons.male
                      : Icons.female,
                  label: 'Jenis Kelamin',
                  value: penghuni.jenisKelamin!,
                  iconBgColor: const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Tanggal Lahir
          if (penghuni.tanggalLahir != null &&
              penghuni.tanggalLahir!.isNotEmpty)
            Column(
              children: [
                InfoRowWidget(
                  icon: Icons.cake_outlined,
                  label: 'Tanggal Lahir',
                  value: penghuni.tanggalLahir!,
                  iconBgColor: const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Alamat Asal
          if (penghuni.alamatAsal != null && penghuni.alamatAsal!.isNotEmpty)
            InfoRowWidget(
              icon: Icons.home_outlined,
              label: 'Alamat Asal',
              value: penghuni.alamatAsal!,
              iconBgColor: const Color(0xFFE8F5E9),
            ),
        ],
      ),
    );
  }
}
