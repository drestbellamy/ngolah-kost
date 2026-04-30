import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kelola_pengumuman_controller.dart';
import 'form_helpers.dart';

class DeletePengumumanDialog extends GetView<KelolaPengumumanController> {
  final String pengumumanId;

  const DeletePengumumanDialog({super.key, required this.pengumumanId});

  static void show(String pengumumanId) {
    Get.dialog(
      DeletePengumumanDialog(pengumumanId: pengumumanId),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hapus Pengumuman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              'Apakah Anda yakin ingin menghapus pengumuman ini? Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextButton(
                      onPressed: controller.isSavingPengumuman.value
                          ? null
                          : () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF7F7F7),
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSavingPengumuman.value
                          ? null
                          : () async {
                              try {
                                final success = await controller
                                    .deletePengumuman(pengumumanId);
                                if (success) {
                                  Get.back();
                                  Get.snackbar(
                                    'Berhasil',
                                    'Pengumuman berhasil dihapus',
                                  );
                                }
                              } catch (e) {
                                FormHelpers.showFormException(
                                  e,
                                  'Terjadi kesalahan saat menghapus pengumuman',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        controller.isSavingPengumuman.value
                            ? 'Menghapus...'
                            : 'Delete',
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
