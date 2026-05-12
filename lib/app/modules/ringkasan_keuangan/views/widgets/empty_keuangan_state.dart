import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';

class EmptyKeuanganState extends StatelessWidget {
  const EmptyKeuanganState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data Keuangan',
              style: AppTextStyles.header16.colored(AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Data keuangan akan muncul setelah Anda\nmenambahkan properti kost pemasukan\nserta pengeluaran.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14
                  .colored(AppColors.textGray)
                  .copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
