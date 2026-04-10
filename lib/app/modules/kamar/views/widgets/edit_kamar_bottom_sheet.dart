import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditKamarBottomSheet extends StatefulWidget {
  final Map<String, dynamic> kamar;

  const EditKamarBottomSheet({super.key, required this.kamar});

  @override
  State<EditKamarBottomSheet> createState() => _EditKamarBottomSheetState();
}

class _EditKamarBottomSheetState extends State<EditKamarBottomSheet> {
  late final TextEditingController nomorKamarController;
  late final TextEditingController hargaController;
  late final TextEditingController kapasitasController;
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  String? nomorError;
  String? kapasitasError;
  String? hargaError;

  @override
  void initState() {
    super.initState();
    nomorKamarController = TextEditingController(text: widget.kamar['nomor']);
    final initialHarga = widget.kamar['harga'].toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    hargaController = TextEditingController(
      text: _formatRupiahInput(initialHarga),
    );
    kapasitasController = TextEditingController(
      text: (widget.kamar['kapasitas'] ?? 2).toString(),
    );
  }

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
                  const Text(
                    'Edit Kamar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
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
              const Text(
                'Nomor Kamar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
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
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                  ),
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
              const Text(
                'Kapasitas Penghuni',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
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
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                  ),
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
              const Text(
                'Harga per Bulan (IDR)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
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
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
