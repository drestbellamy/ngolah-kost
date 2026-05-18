import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_peraturan_controller.dart';

class DeletePeraturanDialog extends GetView<KelolaPeraturanController> {
  final PeraturanModel kategori;

  const DeletePeraturanDialog({super.key, required this.kategori});

  static void show(PeraturanModel kategori) {
    Get.dialog(
      DeletePeraturanDialog(kategori: kategori),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hapus Peraturan',
                  style: AppTextStyles.header18.colored(AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Apakah Anda yakin ingin menghapus peraturan ini? '
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: controller.isSavingPeraturan.value
                          ? null
                          : () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: controller.isSavingPeraturan.value
                          ? null
                          : () async {
                              final success = await controller.hapusKategori(
                                kategori.id,
                              );
                              if (success) {
                                Get.back();
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                ToastHelper.showSuccess(
                                  'Peraturan berhasil dihapus',
                                );
                              }
                            },
                      child: Text(
                        controller.isSavingPeraturan.value
                            ? 'Menghapus...'
                            : 'Hapus',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
