import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/keyboard_dismissible.dart';
import '../controllers/tambah_metode_pembayaran_controller.dart';
import '../../../core/values/values.dart';
import '../../../core/widgets/custom_header.dart';

class TambahMetodePembayaranView
    extends GetView<TambahMetodePembayaranController> {
  const TambahMetodePembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header
              Obx(
                () => CustomHeader(
                  title: controller.isEditMode.value
                      ? 'Edit Metode\nPembayaran'
                      : 'Tambah Metode\nPembayaran',
                  showBackButton: true,
                  subtitle: 'Pilih kost dan atur metode pembayaran',
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Pilih Kost
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Pilih Kost',
                              style: AppTextStyles.header18.colored(
                                const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Metode pembayaran akan berlaku untuk kost yang dipilih',
                              style: AppTextStyles.body12.colored(
                                const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Info inline untuk QRIS
                            Obx(() {
                              if (controller.selectedKostList.isEmpty &&
                                  controller.selectedTipe.value == 'qris') {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCEEFF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF3B82F6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.info_outline,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Pilih kost terlebih dahulu sebelum upload QRIS',
                                              style: AppTextStyles.labelMedium
                                                  .copyWith(
                                                    fontSize: 13,
                                                    color: const Color(
                                                      0xFF1E40AF,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }
                              return const SizedBox();
                            }),

                            // Button Pilih Kost
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: controller.showPilihKostBottomSheet,
                                icon: const Icon(Icons.add, size: 20),
                                label: Obx(() {
                                  final count =
                                      controller.selectedKostList.length;
                                  return Text(
                                    count == 0
                                        ? 'Pilih Kost'
                                        : 'Ubah Pilihan ($count kost)',
                                  );
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B8E7A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            // Selected Kost List
                            Obx(() {
                              if (controller.selectedKostList.isEmpty) {
                                return const SizedBox();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6B8E7A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kost Terpilih (${controller.selectedKostList.length})',
                                        style: AppTextStyles.body14.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...controller.selectedKostList
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final kost = entry.value;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7FAFC),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF6B8E7A),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kost['nama'],
                                                      style: AppTextStyles
                                                          .body14
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: const Color(
                                                              0xFF2D3748,
                                                            ),
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      kost['alamat'],
                                                      style: AppTextStyles
                                                          .body12
                                                          .colored(
                                                            const Color(
                                                              0xFF9CA3AF,
                                                            ),
                                                          ),
                                                    ),
                                                    Text(
                                                      '${kost['jumlahKamar']} kamar tersedia',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .colored(
                                                            const Color(
                                                              0xFF9CA3AF,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => controller
                                                    .removeKost(kost['id']),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Color(0xFFEF4444),
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section 2: Atur Metode Pembayaran
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2. Atur Metode Pembayaran',
                              style: AppTextStyles.header18.colored(
                                const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tipe Metode Pembayaran
                            Text(
                              'Tipe Metode Pembayaran',
                              style: AppTextStyles.body14.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Obx(
                              () => Row(
                                children: [
                                  Expanded(
                                    child: _buildTipeButton(
                                      icon: Icons.credit_card,
                                      label: 'Bank Transfer',
                                      isSelected:
                                          controller.selectedTipe.value ==
                                          'bank',
                                      onTap: () => controller.setTipe('bank'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTipeButton(
                                      icon: Icons.qr_code,
                                      label: 'QRIS',
                                      isSelected:
                                          controller.selectedTipe.value ==
                                          'qris',
                                      onTap: () => controller.setTipe('qris'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTipeButton(
                                      icon: Icons.money,
                                      label: 'Tunai',
                                      isSelected:
                                          controller.selectedTipe.value ==
                                          'cash',
                                      onTap: () => controller.setTipe('cash'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Form Fields
                            Obx(() {
                              if (controller.selectedTipe.value == 'bank') {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(
                                      label: 'Nama Bank',
                                      hint: 'Contoh: BCA, BRI, Mandiri',
                                      controller: controller.namaBankController,
                                      isRequired: true,
                                      maxLength: 50,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      label: 'Nomor Rekening',
                                      hint: '1234567890',
                                      controller:
                                          controller.nomorRekeningController,
                                      isRequired: true,
                                      keyboardType: TextInputType.number,
                                      maxLength: 20,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      label: 'Atas Nama',
                                      hint: 'Nama penerima',
                                      controller: controller.atasNamaController,
                                      isRequired: true,
                                      maxLength: 100,
                                    ),
                                  ],
                                );
                              } else if (controller.selectedTipe.value ==
                                  'cash') {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCEEFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF3B82F6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pembayaran cash berlaku untuk kost terpilih',
                                              style: AppTextStyles.body14
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF1E40AF,
                                                    ),
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Penghuni dapat membayar langsung kepada pemilik kost dengan metode tunai.',
                                              style: AppTextStyles.body12
                                                  .colored(
                                                    const Color(0xFF3B82F6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (controller.selectedTipe.value ==
                                  'qris') {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(
                                      label: 'Nama QRIS',
                                      hint: 'Contoh: QRIS Dana, QRIS GoPay',
                                      controller: controller.namaBankController,
                                      isRequired: true,
                                      maxLength: 50,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Upload Gambar QRIS',
                                      style: AppTextStyles.body14.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() {
                                      if (controller.isUploadingQris.value) {
                                        return Container(
                                          width: double.infinity,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Color(0xFF6B8E7A),
                                                    ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Mengupload gambar QRIS...',
                                                style: AppTextStyles.labelMedium
                                                    .copyWith(
                                                      fontSize: 13,
                                                      color: const Color(
                                                        0xFF6B7280,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      if (controller
                                          .selectedQrisImage
                                          .value
                                          .isEmpty) {
                                        return GestureDetector(
                                          onTap: controller.pickQrisImage,
                                          child: Container(
                                            width: double.infinity,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9FAFB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE5E7EB),
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 32,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Tap untuk upload gambar QRIS',
                                                  style: AppTextStyles.body14
                                                      .colored(
                                                        const Color(0xFF6B7280),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        final qrisUrl =
                                            controller.selectedQrisImage.value;
                                        final canPreview = qrisUrl.startsWith(
                                          'http',
                                        );

                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: canPreview
                                                      ? Image.network(
                                                          qrisUrl,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) =>
                                                                  _buildQrisUploadOkFallback(),
                                                        )
                                                      : _buildQrisUploadOkFallback(),
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: controller
                                                      .removeQrisImage,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFEF4444,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                );
                              }
                              return const SizedBox();
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.canSave ? controller.simpan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E7A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  controller.selectedKostList.isEmpty
                      ? 'Simpan'
                      : 'Simpan untuk ${controller.selectedKostList.length} Kost',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrisUploadOkFallback() {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 32, color: Color(0xFF10B981)),
          SizedBox(height: 8),
          Text(
            'Gambar QRIS berhasil diupload',
            style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildTipeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0ED) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B8E7A)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF6B8E7A)
                  : const Color(0xFF9CA3AF),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body12.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF6B8E7A)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body14.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B8E7A), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '', // Hide default counter
          ),
        ),
        if (maxLength != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maksimal $maxLength karakter',
                style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  final currentLength = value.text.length;
                  final isNearLimit = currentLength > (maxLength * 0.8);
                  final isAtLimit = currentLength >= maxLength;

                  return Text(
                    '$currentLength/$maxLength',
                    style: AppTextStyles.body12.copyWith(
                      color: isAtLimit
                          ? const Color(0xFFEF4444)
                          : isNearLimit
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF9CA3AF),
                      fontWeight: isNearLimit
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
