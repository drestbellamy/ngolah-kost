import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_pengumuman_controller.dart';
import 'info_banner_widget.dart';
import 'form_helpers.dart';

class AddPengumumanDialog extends GetView<KelolaPengumumanController> {
  const AddPengumumanDialog({super.key});

  static void show() {
    Get.dialog(
      const AddPengumumanDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();

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
                    'Tambah Pengumuman',
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
              InfoBannerWidget(
                namaGedung: controller.selectedGedung.value?.nama,
              ),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Judul *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: judulController,
                      maxLength: 80,
                      decoration: FormHelpers.inputDecoration(
                        'Contoh: Pemeliharaan Air',
                      ),
                      validator: FormHelpers.validateJudul,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Deskripsi *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: deskripsiController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: FormHelpers.inputDecoration(
                        'Tulis detail pengumuman...',
                      ),
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
                        onPressed: controller.isSavingPengumuman.value
                            ? null
                            : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
                        onPressed: controller.isSavingPengumuman.value
                            ? null
                            : () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (!(formKey.currentState?.validate() ??
                                    false))
                                  return;

                                try {
                                  final success = await controller
                                      .addPengumuman(
                                        judulController.text.trim(),
                                        deskripsiController.text.trim(),
                                      );
                                  if (success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Berhasil',
                                      'Pengumuman berhasil ditambahkan',
                                    );
                                  }
                                } catch (e) {
                                  FormHelpers.showFormException(
                                    e,
                                    'Terjadi kesalahan saat menambahkan pengumuman',
                                  );
                                }
                              },
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
                          controller.isSavingPengumuman.value
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
      ),
    );
  }
}
