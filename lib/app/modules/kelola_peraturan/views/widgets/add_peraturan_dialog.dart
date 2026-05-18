import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_peraturan_controller.dart';
import 'form_helpers.dart';
import 'info_banner_widget.dart';

class AddPeraturanDialog extends GetView<KelolaPeraturanController> {
  const AddPeraturanDialog({super.key});

  static void show() {
    final controller = Get.find<KelolaPeraturanController>();
    controller.resetForm();
    Get.dialog(
      const AddPeraturanDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Peraturan',
                  style: AppTextStyles.header18.colored(AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InfoBannerWidget(namaGedung: controller.selectedGedung.value?.nama),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormHelpers.requiredLabel('Nama Kategori'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.namaController,
                    maxLength: 80,
                    decoration: FormHelpers.inputDecoration(
                      'Contoh: Jam Malam & Keamanan',
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: FormHelpers.validateNama,
                  ),
                  const SizedBox(height: 6),
                  FormHelpers.requiredLabel('Deskripsi'),
                  const SizedBox(height: 8),
                  TextFormField(
                    onTap: controller.requestFocusToDeskripsi,
                    controller: controller.deskripsiController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: FormHelpers.inputDecoration(
                      'Masukan Deskripsi',
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: FormHelpers.validateDeskripsi,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
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
                        backgroundColor: const Color(0xFF6B8E7A),
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
                              FocusManager.instance.primaryFocus?.unfocus();
                              final isValid =
                                  formKey.currentState?.validate() ?? false;
                              if (!isValid) {
                                return;
                              }

                              final success = await controller.tambahKategori();
                              if (success) {
                                Get.back();
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                ToastHelper.showSuccess(
                                  'Peraturan berhasil ditambahkan',
                                );
                              }
                            },
                      child: Text(
                        controller.isSavingPeraturan.value
                            ? 'Menyimpan...'
                            : 'Tambah',
                        style: AppTextStyles.subtitle14.colored(Colors.white),
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
