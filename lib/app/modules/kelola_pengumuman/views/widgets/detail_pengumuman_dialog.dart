import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_pengumuman_controller.dart';
import 'info_banner_widget.dart';

class DetailPengumumanDialog extends StatelessWidget {
  final PengumumanModel item;

  const DetailPengumumanDialog({super.key, required this.item});

  static void show(PengumumanModel item) {
    Get.dialog(
      DetailPengumumanDialog(item: item),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Pengumuman',
                    style: AppTextStyles.header18.colored(
                      AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InfoBannerWidget(namaGedung: item.kostName),
              const SizedBox(height: 20),
              const Text(
                'Judul',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.title,
                  style: AppTextStyles.body14.colored(const Color(0xFF374151)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.description,
                  style: AppTextStyles.body14
                      .colored(const Color(0xFF4B5563))
                      .copyWith(height: 1.45),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    size: 16,
                    color: Color(0xFF6C7383),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.kostName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7383),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Color(0xFF6C7383),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.date,
                    style: AppTextStyles.body12.colored(
                      const Color(0xFF6C7383),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tutup',
                    style: AppTextStyles.subtitle14.colored(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
