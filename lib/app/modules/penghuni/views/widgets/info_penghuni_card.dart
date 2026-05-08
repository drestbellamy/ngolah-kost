import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';

class InfoPenghuniCard extends StatelessWidget {
  final PenghuniModel penghuni;
  final ({String label, Color backgroundColor, Color textColor}) contractBadge;

  const InfoPenghuniCard({
    super.key,
    required this.penghuni,
    required this.contractBadge,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      penghuni.nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 16,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          penghuni.noTelepon,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.home,
                          size: 16,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Kamar ${penghuni.nomorKamar} • ${penghuni.namaKost}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: contractBadge.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: contractBadge.textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contractBadge.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: contractBadge.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
