import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditKamarBottomSheet extends StatelessWidget {
  final Map<String, dynamic> kamar;

  const EditKamarBottomSheet({super.key, required this.kamar});

  @override
  Widget build(BuildContext context) {
    final nomorKamarController = TextEditingController(text: kamar['nomor']);
    final hargaController = TextEditingController(
      text: kamar['harga'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final kapasitasController = TextEditingController(
      text: (kamar['kapasitas'] ?? 2).toString(),
    );

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
                decoration: InputDecoration(
                  hintText: 'Masukkan harga bulanan',
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
                      onPressed: () {
                        final kapasitas = int.tryParse(
                          kapasitasController.text,
                        );

                        if (nomorKamarController.text.isEmpty ||
                            hargaController.text.isEmpty ||
                            kapasitasController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Mohon lengkapi semua field',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (kapasitas == null || kapasitas <= 0) {
                          Get.snackbar(
                            'Error',
                            'Kapasitas penghuni harus lebih dari 0',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Get.back(
                          result: {
                            'nomor': nomorKamarController.text,
                            'harga': hargaController.text,
                            'kapasitas': kapasitas,
                          },
                        );
                      },
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
