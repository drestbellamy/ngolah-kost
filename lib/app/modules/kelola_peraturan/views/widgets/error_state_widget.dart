import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;

  const ErrorStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.body14
            .colored(const Color(0xFFB91C1C))
            .copyWith(height: 1.4),
      ),
    );
  }
}
