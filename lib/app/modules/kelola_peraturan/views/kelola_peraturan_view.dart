import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../controllers/kelola_peraturan_controller.dart';

class KelolaPeraturanView extends GetView<KelolaPeraturanController> {
  const KelolaPeraturanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedGedung = controller.selectedGedung.value;
      return Scaffold(
        backgroundColor: const Color(0xFFF1F3F2),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(selectedGedung),
              Expanded(
                child: selectedGedung == null
                    ? _buildPilihGedungContent()
                    : _buildKelolaPeraturanContent(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(GedungKostModel? selectedGedung) {
    return CustomHeader(
      title: 'Kelola Peraturan',
      subtitle: selectedGedung?.nama ?? 'Kelola informasi peraturan kost',
      showBackButton: true,
      onBackPressed: () {
        if (selectedGedung != null) {
          controller.kembaliKePilihGedung();
          return;
        }
        Get.back();
      },
    );
  }

  Widget _buildPilihGedungContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: controller.gedungKostList
            .map(
              (gedung) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildGedungCard(gedung),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGedungCard(GedungKostModel gedung) {
    return InkWell(
      onTap: () => controller.pilihGedungKost(gedung),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E9E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.apartment_outlined,
                color: Color(0xFF6B8E7A),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gedung.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2F34),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 0.5),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF7A8292),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          gedung.alamat,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C7383),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EFE9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${gedung.totalKamar} Rooms',
                      style: const TextStyle(
                        color: Color(0xFF507562),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF7A8292),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKelolaPeraturanContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E7A),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: _showAddModal,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Tambah Kategori Peraturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoBannerModal(),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.kategoriList.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  'Belum ada kategori peraturan. Tambahkan kategori pertama untuk gedung kost ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.kategoriList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final kategori = controller.kategoriList[index];
                return _buildKategoriCard(kategori);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKategoriCard(PeraturanModel kategori) {
    final cleanedRules = kategori.deskripsi
        .split('\n')
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E5E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kategori.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2F34),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showEditModal(kategori),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF6B8E7A),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showDeleteModal(kategori),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF2D2D),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...cleanedRules.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B8E7A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C7383),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal() {
    controller.resetForm();
    Get.dialog(
      Dialog(
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
                  const Text(
                    'Tambah Peraturan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              _buildInfoBannerModal(),
              const SizedBox(height: 20),
              _buildLabel('Nama Kategori'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.namaController,
                decoration: _inputDecoration('Contoh: Jam Malam & Keamanan'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              TextField(
                onTap: controller.requestFocusToDeskripsi,
                controller: controller.deskripsiController,
                maxLines: 5,
                decoration: _inputDecoration('Masukan Deskripsi'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: controller.tambahKategori,
                      child: const Text(
                        'Tambah',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showEditModal(PeraturanModel kategori) {
    controller.namaController.text = kategori.nama;
    controller.deskripsiController.text = kategori.deskripsi;

    Get.dialog(
      Dialog(
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
                  const Text(
                    'Edit Peraturan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              _buildInfoBannerModal(),
              const SizedBox(height: 20),
              _buildLabel('Nama Kategori'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.namaController,
                decoration: _inputDecoration('Contoh: Jam Malam & Keamanan'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              TextField(
                onTap: controller.requestFocusToDeskripsi,
                controller: controller.deskripsiController,
                maxLines: 5,
                decoration: _inputDecoration('Masukan Deskripsi'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => controller.editKategori(kategori.id),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showDeleteModal(PeraturanModel kategori) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hapus Peraturan',
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
                'Apakah Anda yakin ingin menghapus peraturan ini? Tindakan ini tidak dapat dibatalkan.',
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
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => controller.hapusKategori(kategori.id),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Widget _buildInfoBannerModal() {
    final namaGedung = controller.selectedGedung.value?.nama;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FF),
        border: Border.all(color: const Color(0xFFD6E4FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              namaGedung == null
                  ? 'Peraturan akan diterapkan sesuai gedung kost yang dipilih.'
                  : 'Peraturan diterapkan untuk $namaGedung.',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B8E7A)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
