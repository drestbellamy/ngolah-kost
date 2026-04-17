import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/kelola_kontrak_controller.dart';

// Custom input formatter to limit max value
class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final intValue = int.tryParse(newValue.text);
    if (intValue == null) {
      return oldValue;
    }

    if (intValue > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}

class KelolaKontrakBottomSheet extends StatelessWidget {
  const KelolaKontrakBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KelolaKontrakController>();

    // Check if penghuni is null
    if (controller.penghuni == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(
          child: Text('Error: Data penghuni tidak ditemukan'),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kelola Kontrak',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content yang bisa di-scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Info Kontrak Saat Ini
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kontrak Saat Ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Berakhir pada:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  controller.currentEndDateLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sisa waktu:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  controller.remainingTimeLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        controller.remainingTimeLabel ==
                                            'Sudah berakhir'
                                        ? Colors.red.shade600
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tabs
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildTab('Perpanjang', 0, controller),
                              _buildTab('Edit', 1, controller),
                              _buildTab('Akhiri', 2, controller),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content
                      Obx(() {
                        Widget content;
                        switch (controller.selectedTab.value) {
                          case 0:
                            content = _buildPerpanjangContent(controller);
                            break;
                          case 1:
                            content = _buildEditContent(controller);
                            break;
                          case 2:
                            content = _buildAkhiriContent(controller);
                            break;
                          default:
                            content = const SizedBox();
                        }
                        return content;
                      }),

                      // Padding minimal untuk button tidak terpotong
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    String label,
    int index,
    KelolaKontrakController controller,
  ) {
    final isSelected = controller.selectedTab.value == index;
    Color bgColor;
    Color textColor;

    if (index == 0) {
      bgColor = isSelected ? const Color(0xFF6B8E7F) : Colors.transparent;
      textColor = isSelected ? Colors.white : const Color(0xFF6B7280);
    } else if (index == 1) {
      bgColor = isSelected ? const Color(0xFFF2A65A) : Colors.transparent;
      textColor = isSelected ? Colors.white : const Color(0xFF6B7280);
    } else {
      bgColor = isSelected ? const Color(0xFFEF4444) : Colors.transparent;
      textColor = isSelected ? Colors.white : const Color(0xFF6B7280);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerpanjangContent(KelolaKontrakController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambahan Durasi *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.tambahanDurasiController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
            _MaxValueTextInputFormatter(KelolaKontrakController.maxTambahanDurasiBulan),
          ],
          onChanged: (value) {
            final intValue = int.tryParse(value) ?? 0;
            if (intValue > KelolaKontrakController.maxTambahanDurasiBulan) {
              controller.tambahanDurasiController.text = 
                KelolaKontrakController.maxTambahanDurasiBulan.toString();
              controller.tambahanDurasiController.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.tambahanDurasiController.text.length),
              );
            }
          },
          decoration: InputDecoration(
            hintText:
                'Masukkan tambahan durasi (maks ${KelolaKontrakController.maxTambahanDurasiBulan} bulan)',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: controller.tambahanDurasiController.text.isNotEmpty &&
                    (int.tryParse(controller.tambahanDurasiController.text) ?? 0) >
                        KelolaKontrakController.maxTambahanDurasiBulan
                ? 'Maksimal ${KelolaKontrakController.maxTambahanDurasiBulan} bulan'
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Maksimal ${KelolaKontrakController.maxTambahanDurasiBulan} bulan',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sistem Pembayaran *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          controller.previewTick.value;
          final options = controller.perpanjangSistemPembayaranOptions;
          final isEnabled = options.isNotEmpty;
          final note = controller.paidCoverageConstraintNote;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSistemPembayaranPickerField(
                controller: controller.sistemPembayaranPerpanjangController,
                hintText: isEnabled
                    ? 'Pilih sistem pembayaran'
                    : 'Tambahkan durasi dulu',
                isEnabled: isEnabled,
                onTap: isEnabled
                    ? () => _showSistemPembayaranPicker(
                        title: 'Pilih Sistem Pembayaran :',
                        options: options,
                        onSelected: controller.pilihSistemPembayaranPerpanjang,
                        controller: controller,
                      )
                    : null,
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEEBFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0052CC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF0052CC),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0052CC),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (controller.showAutoChangeNotification.value) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_fix_high,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.autoChangeMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kontrak Baru',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF2A65A),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                controller.previewTick.value;
                final duration = controller.calculateNewDuration();
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Berakhir pada:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          controller.newEndDateLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total tagihan baru:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '$duration x @ Rp ${controller.penghuni?.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') ?? '0'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF2A65A),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          try {
                            HapticFeedback.lightImpact();
                          } catch (_) {
                            // Ignore haptic errors
                          }
                          controller.perpanjangKontrak();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    controller.isLoading.value ? 'Menyimpan...' : 'Perpanjang',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditContent(KelolaKontrakController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Mulai Sewa *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.tanggalMulaiController,
          readOnly: true,
          onTap: () => controller.pickStartDate(),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal mulai sewa',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Durasi Kontrak *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.durasiKontrakController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
            _MaxValueTextInputFormatter(KelolaKontrakController.maxDurasiKontrakBulan),
          ],
          onChanged: (value) {
            final intValue = int.tryParse(value) ?? 0;
            if (intValue > KelolaKontrakController.maxDurasiKontrakBulan) {
              controller.durasiKontrakController.text = 
                KelolaKontrakController.maxDurasiKontrakBulan.toString();
              controller.durasiKontrakController.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.durasiKontrakController.text.length),
              );
            }
          },
          decoration: InputDecoration(
            hintText: 'Masukkan durasi kontrak (maks ${KelolaKontrakController.maxDurasiKontrakBulan} bulan / 12 tahun)',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Maksimal ${KelolaKontrakController.maxDurasiKontrakBulan} bulan (12 tahun)',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sistem Pembayaran *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          controller.previewTick.value;
          final options = controller.editSistemPembayaranOptions;
          final isEnabled = options.isNotEmpty;
          final note = controller.paidCoverageConstraintNote;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSistemPembayaranPickerField(
                controller: controller.sistemPembayaranEditController,
                hintText: isEnabled
                    ? 'Pilih sistem pembayaran'
                    : 'Isi durasi kontrak dulu',
                isEnabled: isEnabled,
                onTap: isEnabled
                    ? () => _showSistemPembayaranPicker(
                        title: 'Pilih Sistem Pembayaran :',
                        options: options,
                        onSelected: controller.pilihSistemPembayaranEdit,
                        controller: controller,
                      )
                    : null,
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEEBFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0052CC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF0052CC),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0052CC),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (controller.showAutoChangeNotification.value) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_fix_high,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.autoChangeMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          controller.previewTick.value;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Berakhir Kontrak',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.editEndDateLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Pembayaran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF2A65A),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                controller.previewTick.value;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total tagihan:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          controller.editTotalTagihanLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF2A65A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total nilai kontrak:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          controller.editTotalNilaiKontrakLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          try {
                            HapticFeedback.lightImpact();
                          } catch (_) {
                            // Ignore haptic errors
                          }
                          controller.editKontrak();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    controller.isLoading.value ? 'Menyimpan...' : 'Simpan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A65A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSistemPembayaranPickerField({
    required TextEditingController controller,
    required String hintText,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      showCursor: false,
      enableInteractiveSelection: false,
      style: TextStyle(
        color: isEnabled ? const Color(0xFF2D3748) : const Color(0xFF9CA3AF),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
        filled: true,
        fillColor: isEnabled
            ? const Color(0xFFF7FAFC)
            : const Color(0xFFE5E7EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down,
          color: isEnabled ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }

  void _showSistemPembayaranPicker({
    required String title,
    required List<int> options,
    required ValueChanged<int> onSelected,
    required KelolaKontrakController controller,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 20),
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        onSelected(option);
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          controller.formatSistemPembayaranOption(option),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    if (index < options.length - 1) const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAkhiriContent(KelolaKontrakController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perhatian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Penghuni akan kehilangan akses ke kamar',
                      style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Data kontrak akan diarsipkan',
                      style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Akun penghuni akan dinonaktifkan',
                      style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          try {
                            HapticFeedback.lightImpact();
                          } catch (_) {
                            // Ignore haptic errors
                          }
                          controller.akhiriKontrak();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cancel, size: 20),
                  label: Text(
                    controller.isLoading.value
                        ? 'Memproses...'
                        : 'Akhiri Kontrak',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
