import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tambah_penghuni_controller.dart';

class TambahPenghuniView extends GetView<TambahPenghuniController> {
  const TambahPenghuniView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6B8E7A),
                  Color(0xFF8FAA9F),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tambah Penghuni',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      'Langkah ${controller.currentStep.value} dari 2',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA8D5BA),
                      ),
                    )),
                    const SizedBox(height: 16),
                    
                    // Progress indicator
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: controller.currentStep.value == 2
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Info Card
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menambahkan penghuni ke:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                            controller.nomorKamar.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F2F2F),
                            ),
                          )),
                          Obx(() => Text(
                            controller.namaKost.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            controller.hargaPerBulan.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B8E7A),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Form content based on step
                  Obx(() => controller.currentStep.value == 1
                      ? _buildStep1()
                      : _buildStep2()),
                ],
              ),
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.handleBack,
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
                      controller.currentStep.value == 1 ? 'Batal' : 'Kembali',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.handleNext,
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
                      controller.currentStep.value == 1 ? 'Lanjut' : 'Tambahkan',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data Pribadi Section
        _buildSectionHeader(Icons.person_outline, 'Data Pribadi'),
        const SizedBox(height: 16),
        
        _buildTextField(
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          controller: controller.namaController,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          label: 'Nomor Telepon',
          hint: '081234567890',
          controller: controller.teleponController,
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        const SizedBox(height: 24),
        
        // Akun Penghuni Section
        _buildSectionHeader(Icons.lock_outline, 'Akun Penghuni'),
        const SizedBox(height: 16),
        
        _buildTextField(
          label: 'Username',
          hint: 'Pilih username',
          controller: controller.usernameController,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          label: 'Password',
          hint: 'Minimal 6 karakter',
          controller: controller.passwordController,
          isPassword: true,
          isRequired: true,
        ),
        const SizedBox(height: 8),
        
        const Text(
          'Password akan digunakan untuk login penghuni',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informasi Kontrak Section
        _buildSectionHeader(Icons.calendar_today_outlined, 'Informasi Kontrak'),
        const SizedBox(height: 16),
        
        // Tanggal Mulai Masuk
        _buildLabel('Tanggal Mulai Masuk', isRequired: true),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: () => _showDatePicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.tanggalMasuk.value.isEmpty
                      ? 'Pilih tanggal'
                      : controller.tanggalMasuk.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.tanggalMasuk.value.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF2F2F2F),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        
        // Durasi Kontrak
        _buildLabel('Durasi Kontrak', isRequired: true),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: () => _showDurasiKontrakPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.durasiKontrak.value.isEmpty
                      ? 'Pilih durasi'
                      : controller.durasiKontrak.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.durasiKontrak.value.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF2F2F2F),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        
        // Sistem Pembayaran
        _buildLabel('Sistem Pembayaran', isRequired: true),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: controller.durasiKontrak.value.isEmpty
              ? null
              : () => _showSistemPembayaranPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: controller.durasiKontrak.value.isEmpty
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.sistemPembayaran.value.isEmpty
                      ? 'Pilih sistem pembayaran'
                      : controller.sistemPembayaran.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.sistemPembayaran.value.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF2F2F2F),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: controller.durasiKontrak.value.isEmpty
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 8),
        
        const Text(
          'Frekuensi pembayaran sewa oleh penghuni',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tanggal Berakhir Kontrak
        Obx(() {
          if (controller.tanggalBerakhir.value.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Tanggal Berakhir Kontrak'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.tanggalBerakhir.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2F2F2F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        
        // Ringkasan Pembayaran
        Obx(() {
          if (controller.sistemPembayaran.value.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF2A65A).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total Kontrak:',
                    controller.totalKontrak.value,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Sistem Pembayaran:',
                    controller.sistemPembayaranLabel.value,
                  ),
                  const Divider(height: 24, color: Color(0xFFF2A65A)),
                  _buildSummaryRow(
                    'Akan generate:',
                    controller.jumlahTagihan.value,
                    valueColor: const Color(0xFFF2A65A),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Per tagihan:',
                    controller.perTagihan.value,
                    valueColor: const Color(0xFFF2A65A),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Nilai Kontrak:',
                    controller.totalNilaiKontrak.value,
                    isBold: true,
                    valueColor: const Color(0xFF6B8E7A),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B8E7A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F2F2F),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
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
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF2F2F2F),
          ),
        ),
      ],
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B8E7A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2F2F2F),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      controller.setTanggalMasuk(picked);
    }
  }

  void _showDurasiKontrakPicker() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Durasi Kontrak :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 20),
              ...controller.durasiOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.setDurasiKontrak(option);
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
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    if (index < controller.durasiOptions.length - 1)
                      const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showSistemPembayaranPicker() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sistem Pembayaran :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 20),
              ...controller.sistemPembayaranOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.setSistemPembayaran(option);
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
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    if (index < controller.sistemPembayaranOptions.length - 1)
                      const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
