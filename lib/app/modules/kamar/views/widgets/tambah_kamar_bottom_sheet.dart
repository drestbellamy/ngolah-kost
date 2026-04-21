import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/values.dart';

class TambahKamarBottomSheet extends StatefulWidget {
  const TambahKamarBottomSheet({super.key});

  @override
  State<TambahKamarBottomSheet> createState() => _TambahKamarBottomSheetState();
}

class _TambahKamarBottomSheetState extends State<TambahKamarBottomSheet> {
  final TextEditingController nomorKamarController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController kapasitasController = TextEditingController();
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  String? nomorError;
  String? kapasitasError;
  String? hargaError;

  @override
  void dispose() {
    nomorKamarController.dispose();
    hargaController.dispose();
    kapasitasController.dispose();
    super.dispose();
  }

  String _formatRupiahInput(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '';

    final number = int.parse(digitsOnly);
    return _formatter.format(number);
  }

  void _onHargaChanged(TextEditingController controller, String value) {
    final formatted = _formatRupiahInput(value);
    if (controller.text != formatted) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (hargaError != null) {
      setState(() {
        hargaError = formatted.isEmpty ? 'Harga per bulan wajib diisi' : null;
      });
    }
  }

  void _submit() {
    // Tutup keyboard sebelum submit
    FocusManager.instance.primaryFocus?.unfocus();
    
    final nomorKamar = nomorKamarController.text.trim();
    final kapasitasText = kapasitasController.text.trim();
    final hargaText = hargaController.text.trim();
    final kapasitas = int.tryParse(kapasitasText);

    setState(() {
      nomorError = nomorKamar.isEmpty
          ? 'Nomor kamar wajib diisi'
          : nomorKamar.length > 20
          ? 'Nomor kamar maksimal 20 karakter'
          : null;

      kapasitasError = kapasitasText.isEmpty
          ? 'Kapasitas wajib diisi'
          : kapasitas == null || kapasitas <= 0
          ? 'Kapasitas harus lebih dari 0'
          : kapasitas > 20
          ? 'Kapasitas maksimal 20 penghuni'
          : null;

      hargaError = hargaText.isEmpty ? 'Harga per bulan wajib diisi' : null;
    });

    final hasError =
        nomorError != null || kapasitasError != null || hargaError != null;
    if (hasError) return;

    Get.back(
      result: {'nomor': nomorKamar, 'harga': hargaText, 'kapasitas': kapasitas},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Kamar Baru',
                    style: AppTextStyles.header18.colored(AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nomor Kamar
              Text(
                'Nomor Kamar',
                style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nomorKamarController,
                maxLength: 20,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                onChanged: (_) {
                  if (nomorError != null) {
                    setState(() {
                      final value = nomorKamarController.text.trim();
                      nomorError = value.isEmpty
                          ? 'Nomor kamar wajib diisi'
                          : value.length > 20
                          ? 'Nomor kamar maksimal 20 karakter'
                          : null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'misalnya, A-101, 201, R-01',
                  hintStyle: AppTextStyles.body14.colored(const Color(0xFFD1D5DB)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B8E7A),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  counterText: '',
                  helperText: 'Maksimal 20 karakter',
                  errorText: nomorError,
                ),
              ),
              const SizedBox(height: 16),

              // Kapasitas Penghuni
              Text(
                'Kapasitas Penghuni',
                style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kapasitasController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (_) {
                  if (kapasitasError != null) {
                    setState(() {
                      final value = kapasitasController.text.trim();
                      final parsed = int.tryParse(value);
                      kapasitasError = value.isEmpty
                          ? 'Kapasitas wajib diisi'
                          : parsed == null || parsed <= 0
                          ? 'Kapasitas harus lebih dari 0'
                          : parsed > 20
                          ? 'Kapasitas maksimal 20 penghuni'
                          : null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah kapasitas penghuni',
                  hintStyle: AppTextStyles.body14.colored(const Color(0xFFD1D5DB)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B8E7A),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  helperText: 'Isi 1-20 penghuni',
                  errorText: kapasitasError,
                ),
              ),
              const SizedBox(height: 16),

              // Harga per Bulan
              Text(
                'Harga per Bulan (IDR)',
                style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _onHargaChanged(hargaController, value),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  hintText: 'Masukkan harga bulanan',
                  hintStyle: AppTextStyles.body14.colored(const Color(0xFFD1D5DB)),
                  prefixText: 'Rp ',
                  prefixStyle: AppTextStyles.subtitle14.colored(AppColors.textGray),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B8E7A),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  helperText: 'Contoh: Rp 1.500.000',
                  errorText: hargaError,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.subtitle14.colored(const Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Tambah',
                        style: AppTextStyles.subtitle14.colored(Colors.white),
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
