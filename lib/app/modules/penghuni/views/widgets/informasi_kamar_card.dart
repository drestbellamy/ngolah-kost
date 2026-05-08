import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';
import 'info_row_widget.dart';

class InformasiKamarCard extends StatelessWidget {
  final PenghuniModel penghuni;

  const InformasiKamarCard({super.key, required this.penghuni});

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.home_outlined, size: 20, color: Color(0xFFF2A65A)),
              SizedBox(width: 8),
              Text(
                'Informasi Kamar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoRowWidget(
            icon: Icons.meeting_room,
            label: 'Nomor Kamar',
            value: penghuni.nomorKamar,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFF2A65A),
          ),
          const SizedBox(height: 12),
          InfoRowWidget(
            icon: Icons.location_on,
            label: 'Nama Kost',
            value: penghuni.namaKost,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFF2A65A),
          ),
          const SizedBox(height: 12),
          InfoRowWidget(
            icon: Icons.attach_money,
            label: 'Harga Sewa (per bulan)',
            value:
                'Rp ${penghuni.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFF2A65A),
          ),
        ],
      ),
    );
  }
}
