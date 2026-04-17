import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../controllers/kelola_pengumuman_controller.dart';

class KelolaPengumumanView extends GetView<KelolaPengumumanController> {
  const KelolaPengumumanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedGedung = controller.selectedGedung.value;
      return Scaffold(
        backgroundColor: const Color(0xFFF1F3F2),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(selectedGedung),
              Expanded(
                child: selectedGedung == null
                    ? _buildPilihGedungContent()
                    : _buildKelolaPengumumanContent(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(GedungKostModel? selectedGedung) {
    return CustomHeader(
      title: 'Kelola Pengumuman',
      subtitle: selectedGedung?.nama ?? 'Kelola informasi pengumuman kost',
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
    if (controller.isLoadingGedung.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.gedungKostList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            controller.errorMessage.value ?? 'Belum ada data kost.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: controller.gedungKostList
            .map(
              (gedung) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildGedungCard(gedung),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGedungCard(GedungKostModel gedung) {
    final totalPengumuman = controller.getPengumumanCountForKost(gedung.id);
    final hasPengumuman = totalPengumuman > 0;

    return InkWell(
      onTap: () {
        controller.pilihGedungKost(gedung);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.apartment_outlined,
                color: Color(0xFF6B8E7A),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gedung.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2F34),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFF7A8292),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          gedung.alamat,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF6C7383),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EFE9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${gedung.totalKamar} Rooms',
                          style: const TextStyle(
                            color: Color(0xFF507562),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasPengumuman
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFFEF3F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          hasPengumuman
                              ? '$totalPengumuman Pengumuman'
                              : '0 Pengumuman',
                          style: TextStyle(
                            color: hasPengumuman
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFFB42318),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right,
                size: 22,
                color: Color(0xFF7A8292),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKelolaPengumumanContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshPengumumanAktif,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              onPressed: controller.isSavingPengumuman.value
                  ? null
                  : _showAddPengumumanDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Pengumuman',
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
            if (controller.isLoadingPengumuman.value)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              )
            else if (controller.errorMessage.value != null)
              _buildErrorCard(controller.errorMessage.value!)
            else if (controller.pengumumanList.isEmpty)
              _buildEmptyCard()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.pengumumanList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = controller.pengumumanList[index];
                  return _buildPengumumanCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'Belum ada pengumuman untuk gedung kost ini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.4),
      ),
    );
  }

  Widget _buildPengumumanCard(PengumumanModel item) {
    return InkWell(
      onTap: () => _showDetailPengumumanDialog(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2F34),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _showEditPengumumanDialog(item),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF6B8E7A),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _showDeletePengumumanDialog(item.id),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF2D2D),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FractionallySizedBox(
              widthFactor: 0.80,
              alignment: Alignment.centerLeft,
              child: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6C7383),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.home_work_outlined,
                        size: 15,
                        color: Color(0xFF6C7383),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.kostName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6C7383),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF6C7383),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.date,
                      style: const TextStyle(
                        color: Color(0xFF6C7383),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailPengumumanDialog(PengumumanModel item) {
    Get.dialog(
      Dialog(
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
                    const Text(
                      'Detail Pengumuman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                _buildInfoBannerModal(),
                const SizedBox(height: 20),
                const Text(
                  'Judul',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.home_work_outlined,
                      size: 16,
                      color: Color(0xFF6C7383),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.kostName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C7383),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: Color(0xFF6C7383),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7383),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E7A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showAddPengumumanDialog() {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();

    Get.dialog(
      Dialog(
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
                    const Text(
                      'Tambah Pengumuman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                _buildInfoBannerModal(),
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
                        decoration: _inputDecoration(
                          'Contoh: Pemeliharaan Air',
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Judul pengumuman wajib diisi';
                          }
                          if (text.length < 5) {
                            return 'Minimal 5 karakter';
                          }
                          return null;
                        },
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
                        decoration: _inputDecoration(
                          'Tulis detail pengumuman...',
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Deskripsi pengumuman wajib diisi';
                          }
                          if (text.length < 10) {
                            return 'Minimal 10 karakter';
                          }
                          return null;
                        },
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
                                  final judul = judulController.text.trim();
                                  final deskripsi = deskripsiController.text
                                      .trim();

                                  final isValid =
                                      formKey.currentState?.validate() ?? false;
                                  if (!isValid) {
                                    return;
                                  }

                                  try {
                                    final success = await controller
                                        .addPengumuman(judul, deskripsi);
                                    if (success) {
                                      Get.back();
                                      Get.snackbar(
                                        'Berhasil',
                                        'Pengumuman berhasil ditambahkan',
                                      );
                                    }
                                  } catch (e) {
                                    _showFormException(
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showEditPengumumanDialog(PengumumanModel item) {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController(text: item.title);
    final deskripsiController = TextEditingController(text: item.description);

    Get.dialog(
      Dialog(
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
                    const Text(
                      'Edit Pengumuman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                _buildInfoBannerModal(),
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
                        decoration: _inputDecoration(
                          'Contoh: Pemeliharaan Air',
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Judul pengumuman wajib diisi';
                          }
                          if (text.length < 5) {
                            return 'Minimal 5 karakter';
                          }
                          return null;
                        },
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
                        decoration: _inputDecoration(
                          'Tulis detail pengumuman...',
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Deskripsi pengumuman wajib diisi';
                          }
                          if (text.length < 10) {
                            return 'Minimal 10 karakter';
                          }
                          return null;
                        },
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
                                  final judul = judulController.text.trim();
                                  final deskripsi = deskripsiController.text
                                      .trim();

                                  final isValid =
                                      formKey.currentState?.validate() ?? false;
                                  if (!isValid) {
                                    return;
                                  }

                                  try {
                                    final success = await controller
                                        .editPengumuman(
                                          item.id,
                                          judul,
                                          deskripsi,
                                        );
                                    if (success) {
                                      Get.back();
                                      Get.snackbar(
                                        'Berhasil',
                                        'Pengumuman berhasil diperbarui',
                                      );
                                    }
                                  } catch (e) {
                                    _showFormException(
                                      e,
                                      'Terjadi kesalahan saat memperbarui pengumuman',
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
                                : 'Simpan',
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  void _showDeletePengumumanDialog(String id) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hapus Pengumuman',
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
                'Apakah Anda yakin ingin menghapus pengumuman ini? Tindakan ini tidak dapat dibatalkan.',
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
                    child: Obx(
                      () => TextButton(
                        onPressed: controller.isSavingPengumuman.value
                            ? null
                            : () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF7F7F7),
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
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
                                try {
                                  final success = await controller
                                      .deletePengumuman(id);
                                  if (success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Berhasil',
                                      'Pengumuman berhasil dihapus',
                                    );
                                  }
                                } catch (e) {
                                  _showFormException(
                                    e,
                                    'Terjadi kesalahan saat menghapus pengumuman',
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          controller.isSavingPengumuman.value
                              ? 'Menghapus...'
                              : 'Delete',
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                  ? 'Pengumuman akan diterapkan sesuai gedung kost yang dipilih.'
                  : 'Pengumuman diterapkan untuk $namaGedung.',
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

  void _showFormException(Object error, String fallbackMessage) {
    final raw = error.toString().trim();
    var message = raw;

    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }

    if (message.isEmpty) {
      message = fallbackMessage;
    }

    Get.snackbar('Error', message);
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
