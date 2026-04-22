import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../data/models/peraturan_model.dart';

class PeraturanCard extends StatelessWidget {
  final PeraturanModel peraturan;

  const PeraturanCard({super.key, required this.peraturan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF6B8E7A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  peraturan.judul,
                  style: AppTextStyles.header16.colored(const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            peraturan.isi,
            style: AppTextStyles.body14.colored(const Color(0xFF4B5563)).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
