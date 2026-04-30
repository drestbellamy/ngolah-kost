import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../../../data/models/peraturan_model.dart';

class PeraturanCard extends StatelessWidget {
  final PeraturanModel peraturan;

  const PeraturanCard({super.key, required this.peraturan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(16)),
      padding: context.allPadding(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
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
                padding: context.allPadding(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: const Color(0xFF6B8E7A),
                  size: context.iconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(12)),
              Expanded(
                child: Text(
                  peraturan.judul,
                  style: AppTextStyles.header16.colored(const Color(0xFF1F2937)).copyWith(
                    fontSize: context.fontSize(16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(12)),
          Text(
            peraturan.isi,
            style: AppTextStyles.body14.colored(const Color(0xFF4B5563)).copyWith(
              height: 1.5,
              fontSize: context.fontSize(14),
            ),
          ),
        ],
      ),
    );
  }
}
