import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/keyboard_dismissible.dart';
import '../../../core/values/values.dart';
import '../controllers/tambah_penghuni_controller.dart';

class TambahPenghuniView extends GetView<TambahPenghuniController> {
  const TambahPenghuniView({super.key});

  static final RxBool _isPasswordHidden = true.obs;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        resizeToAvoidBottomInset: true,
        body: Column(
        children: [
          // Header with gradient
          SafeArea(
            top: false,
            child: Obx(
              () => CustomHeader(
                title: 'Tambah Penghuni',
                subtitle: 'Langkah ${controller.currentStep.value} dari 2',
                showBackButton: true,
                onBackPressed: controller.handleBack,
                progressIndicator: Row(
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
                ),
              ),
            ),
          ),

          // Fixed info card
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Container(
              width: double.infinity,
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
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.nomorKamar.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      controller.namaKost.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.hargaPerBulan.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B8E7A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form content (scrollable)
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Form content based on step
                  Obx(
                    () => controller.currentStep.value == 1
                        ? _buildStep1()
                        : _buildStep2(),
                  ),
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
            child: Obx(
              () => Row(
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
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.currentStep.value == 1
                                  ? 'Lanjut'
                                  : 'Tambahkan',
                              style: AppTextStyles.subtitle14.colored(Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.submitError.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      controller.submitError.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStep1() {
    return Obx(
      () => Column(
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
            maxLength: 50,
            helperText: 'Maksimal 50 karakter',
            errorText: controller.namaError.value,
            onChanged: controller.onNamaChanged,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Nomor Telepon',
            hint: '081234567890',
            controller: controller.teleponController,
            keyboardType: TextInputType.phone,
            isRequired: true,
            helperText: 'Isi 10-15 digit angka',
            errorText: controller.teleponError.value,
            onChanged: controller.onTeleponChanged,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const SizedBox(height: 24),

          // Akun Penghuni Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(Icons.lock_outline, 'Akun Penghuni'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Otomatis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B8E7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Username',
            hint: 'Username otomatis (bisa diubah)',
            controller: controller.usernameController,
            isRequired: false,
            helperText: 'Otomatis dari nama kost + no kamar. Bisa diubah.',
            errorText: controller.usernameError.value,
            onChanged: controller.onUsernameChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]')),
              LengthLimitingTextInputFormatter(20),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Password',
            hint: 'Minimal 6 karakter',
            controller: controller.passwordController,
            isPassword: true,
            isPasswordHidden: _isPasswordHidden.value,
            onTogglePassword: () {
              _isPasswordHidden.value = !_isPasswordHidden.value;
            },
            isRequired: true,
            helperText: 'Panjang 6-32 karakter',
            errorText: controller.passwordError.value,
            onChanged: controller.onPasswordChanged,
            inputFormatters: [LengthLimitingTextInputFormatter(32)],
          ),
          const SizedBox(height: 8),

          Text(
            'Password akan digunakan untuk login penghuni',
            style: AppTextStyles.body12.colored(AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informasi Kontrak Section
          _buildSectionHeader(
            Icons.calendar_today_outlined,
            'Informasi Kontrak',
          ),
          const SizedBox(height: 16),

          // Tanggal Mulai Masuk
          _buildLabel('Tanggal Mulai Masuk', isRequired: true),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.tanggalMasukError.value != null
                      ? Colors.red
                      : const Color(0xFFE5E7EB),
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
                    style: AppTextStyles.body14.colored(
                      controller.tanggalMasuk.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppColors.textPrimary,
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
          ),
          if (controller.tanggalMasukError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                controller.tanggalMasukError.value!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),

          // Durasi Kontrak
          _buildLabel('Durasi Kontrak', isRequired: true),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showDurasiKontrakPicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.durasiKontrakError.value != null
                      ? Colors.red
                      : const Color(0xFFE5E7EB),
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
                    style: AppTextStyles.body14.colored(
                      controller.durasiKontrak.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppColors.textPrimary,
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
          ),
          if (controller.durasiKontrakError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                controller.durasiKontrakError.value!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),

          // Sistem Pembayaran
          _buildLabel('Sistem Pembayaran', isRequired: true),
          const SizedBox(height: 8),
          GestureDetector(
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
                  color: controller.sistemPembayaranError.value != null
                      ? Colors.red
                      : const Color(0xFFE5E7EB),
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
                    style: AppTextStyles.body14.colored(
                      controller.sistemPembayaran.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppColors.textPrimary,
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
          ),
          if (controller.sistemPembayaranError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                controller.sistemPembayaranError.value!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),

          Text(
            'Frekuensi pembayaran sewa oleh penghuni',
            style: AppTextStyles.body12.colored(AppColors.textGray),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                          style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
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
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B8E7A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.header16.colored(AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
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
    bool isPasswordHidden = true,
    VoidCallback? onTogglePassword,
    Widget? suffixIcon,
    bool isRequired = false,
    String? errorText,
    String? helperText,
    int? maxLength,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? isPasswordHidden : false,
          scrollPadding: const EdgeInsets.only(bottom: 220),
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
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
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                    ),
                  )
                : suffixIcon,
            helperText: helperText,
            errorText: errorText,
            counterText: '',
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
          style: isBold 
              ? AppTextStyles.subtitle14.colored(AppColors.textGray)
              : AppTextStyles.body14.colored(AppColors.textGray),
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.subtitle14.weighted(FontWeight.w700).colored(valueColor ?? AppColors.textPrimary)
              : AppTextStyles.subtitle14.colored(valueColor ?? AppColors.textPrimary),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Durasi Kontrak :',
                style: AppTextStyles.header18.colored(AppColors.textPrimary),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.2,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Sistem Pembayaran :',
                style: AppTextStyles.header18.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              ...controller.sistemPembayaranOptions.asMap().entries.map((
                entry,
              ) {
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.2,
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
