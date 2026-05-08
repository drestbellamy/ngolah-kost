import 'package:flutter/material.dart';

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBgColor;
  final Color? iconColor;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? const Color(0xFF6B8E7F),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
