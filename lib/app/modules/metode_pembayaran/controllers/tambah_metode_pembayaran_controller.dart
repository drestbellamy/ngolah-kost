import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kost_repository.dart';
import '../../../../repositories/metode_pembayaran_repository.dart';
import '../models/metode_pembayaran_model.dart';

class TambahMetodePembayaranController extends GetxController {
  final KostRepository _kostRepo;
  final MetodePembayaranRepository _metodeRepo;

  TambahMetodePembayaranController({
    KostRepository? kostRepository,
    MetodePembayaranRepository? metodePembayaranRepository,
  }) : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _metodeRepo =
           metodePembayaranRepository ??
           RepositoryFactory.instance.metodePembayaranRepository;

  final selectedKostList = <Map<String, dynamic>>[].obs;
  final selectedTipe = ''.obs;
  final selectedQrisImage = ''.obs; // For QRIS image path
  final isUploadingQris = false.obs;
  final isLoadingKost = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  final namaBankController = TextEditingController();
  final nomorRekeningController = TextEditingController();
  final atasNamaController = TextEditingController();

  // Edit mode
  final isEditMode = false.obs;
  MetodePembayaranModel? editingMetode;

  final availableKostList = <Map<String, dynamic>>[].obs;

  bool get canSave {
    if (isSaving.value) return false;
    if (isUploadingQris.value) return false;
    if (selectedKostList.isEmpty) return false;
    if (selectedTipe.value.isEmpty) return false;

    if (selectedTipe.value == 'bank') {
      return namaBankController.text.isNotEmpty &&
          nomorRekeningController.text.isNotEmpty &&
          atasNamaController.text.isNotEmpty;
    } else if (selectedTipe.value == 'cash') {
      return true;
    } else if (selectedTipe.value == 'qris') {
      return namaBankController.text.isNotEmpty &&
          selectedQrisImage.value.isNotEmpty;
    }

    return false;
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is MetodePembayaranModel) {
      isEditMode.value = true;
      editingMetode = Get.arguments as MetodePembayaranModel;
      selectedTipe.value = editingMetode!.jenis;

      if (editingMetode!.jenis == 'bank') {
        namaBankController.text = editingMetode!.nama;
        nomorRekeningController.text = editingMetode!.nomorRekening;
        atasNamaController.text = editingMetode!.atasNama;
      } else if (editingMetode!.jenis == 'qris') {
        namaBankController.text = editingMetode!.nama;
        selectedQrisImage.value = editingMetode!.qrisImagePath ?? '';
      }

      final previewKostId = editingMetode!.kostId;
      selectedKostList.value = [
        {
          'id': previewKostId,
          'nama': editingMetode!.namaKost,
          'alamat': '-',
          'jumlahKamar': 0,
        },
      ];
    }

    namaBankController.addListener(_updateState);
    nomorRekeningController.addListener(_updateState);
    atasNamaController.addListener(_updateState);

    loadAvailableKost();
  }

  Future<void> loadAvailableKost() async {
    isLoadingKost.value = true;
    errorMessage.value = null;

    try {
      final kosts = await _kostRepo.getKostList();
      final mapped = kosts
          .map(
            (kost) => <String, dynamic>{
              'id': kost.id,
              'nama': kost.name.trim().isEmpty ? 'Kost' : kost.name.trim(),
              'alamat': kost.address.trim().isEmpty ? '-' : kost.address.trim(),
              'jumlahKamar': kost.roomCount,
            },
          )
          .toList();

      availableKostList.assignAll(mapped);
      _syncSelectedKostAfterLoad();
      selectedKostList.refresh();
    } catch (e) {
      availableKostList.clear();
      errorMessage.value = _resolveErrorMessage(e, 'Gagal memuat daftar kost.');
      Get.snackbar(
        'Error',
        errorMessage.value ?? 'Gagal memuat daftar kost.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingKost.value = false;
    }
  }

  void _syncSelectedKostAfterLoad() {
    if (selectedKostList.isEmpty || availableKostList.isEmpty) return;

    final selectedIds = selectedKostList
        .map((item) => (item['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (selectedIds.isNotEmpty) {
      final matchedById = availableKostList
          .where((item) => selectedIds.contains((item['id'] ?? '').toString()))
          .toList();

      if (matchedById.isNotEmpty) {
        selectedKostList.assignAll(matchedById);
        return;
      }
    }

    final selectedNames = selectedKostList
        .map((item) => (item['nama'] ?? '').toString())
        .where((name) => name.trim().isNotEmpty)
        .toSet();

    final matchedByName = availableKostList
        .where(
          (item) => selectedNames.contains((item['nama'] ?? '').toString()),
        )
        .toList();

    if (matchedByName.isNotEmpty) {
      selectedKostList.assignAll(matchedByName);
    }
  }

  String _resolveErrorMessage(Object error, String fallback) {
    var message = error.toString().trim();
    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }
    if (message.length > 180) {
      message = '${message.substring(0, 180)}...';
    }
    return message.isEmpty ? fallback : message;
  }

  void _updateState() {
    selectedKostList.refresh();
  }

  @override
  void onClose() {
    namaBankController.dispose();
    nomorRekeningController.dispose();
    atasNamaController.dispose();
    super.onClose();
  }

  void setTipe(String tipe) {
    selectedTipe.value = tipe;
    selectedKostList.refresh();
  }

  void showPilihKostBottomSheet() {
    if (isLoadingKost.value) {
      Get.snackbar(
        'Info',
        'Daftar kost sedang dimuat, tunggu sebentar.',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (availableKostList.isEmpty) {
      Get.snackbar(
        'Info',
        'Belum ada data kost yang bisa dipilih.',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final tempSelected = <String>[
      ...selectedKostList
          .map((k) => (k['id'] ?? '').toString())
          .where((id) => id.isNotEmpty),
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Kost',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tempSelected.length} dari ${availableKostList.length} dipilih',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
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

                const Divider(height: 1),

                // Pilih Semua Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (tempSelected.length == availableKostList.length) {
                            tempSelected.clear();
                          } else {
                            tempSelected.clear();
                            tempSelected.addAll(
                              availableKostList
                                  .map((k) => (k['id'] ?? '').toString())
                                  .where((id) => id.isNotEmpty),
                            );
                          }
                        });
                      },
                      icon: Icon(
                        tempSelected.length == availableKostList.length
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                      ),
                      label: Text(
                        tempSelected.length == availableKostList.length
                            ? 'Batalkan Semua'
                            : 'Pilih Semua',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B8E7A),
                        side: const BorderSide(color: Color(0xFF6B8E7A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                // Kost List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: availableKostList.length,
                    itemBuilder: (context, index) {
                      final kost = availableKostList[index];
                      final kostId = (kost['id'] ?? '').toString();
                      final isSelected = tempSelected.contains(kostId);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              tempSelected.remove(kostId);
                            } else {
                              tempSelected.add(kostId);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8F0ED)
                                : const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6B8E7A)
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Custom Radio Button
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6B8E7A)
                                        : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                  color: Colors.white,
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF6B8E7A),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kost['nama'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kost['alamat'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    Text(
                                      '${kost['jumlahKamar']} kamar',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Button
                Container(
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempSelected.isEmpty
                          ? null
                          : () {
                              selectedKostList.value = availableKostList
                                  .where(
                                    (k) => tempSelected.contains(
                                      (k['id'] ?? '').toString(),
                                    ),
                                  )
                                  .toList();
                              Get.back();
                            },
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
                        'Simpan Pilihan (${tempSelected.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void removeKost(String id) {
    selectedKostList.removeWhere((k) => (k['id'] ?? '').toString() == id);
  }

  Future<void> simpan() async {
    // Tutup keyboard sebelum proses simpan
    FocusManager.instance.primaryFocus?.unfocus();

    if (!canSave || isSaving.value || isUploadingQris.value) return;

    final selectedKostIds = selectedKostList
        .map((item) => (item['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (selectedKostIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih minimal satu kost terlebih dahulu',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final tipe = MetodePembayaranModel.normalizeJenis(selectedTipe.value);
    final nama = tipe == 'cash' ? 'Tunai' : namaBankController.text.trim();
    final noRek = tipe == 'bank' ? nomorRekeningController.text.trim() : '-';
    final atasNama = tipe == 'bank' ? atasNamaController.text.trim() : null;
    final qrImage = tipe == 'qris' ? selectedQrisImage.value.trim() : null;

    try {
      isSaving.value = true;

      if (isEditMode.value && editingMetode != null) {
        await _metodeRepo.updateMetodePembayaran(
          id: editingMetode!.id,
          kostId: selectedKostIds.first,
          tipe: tipe,
          nama: nama,
          noRek: noRek,
          atasNama: atasNama,
          qrImage: qrImage,
          isActive: editingMetode!.isActive,
        );

        Get.back(result: true);
        Get.snackbar(
          'Berhasil',
          'Metode pembayaran berhasil diperbarui',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      for (final kostId in selectedKostIds) {
        await _metodeRepo.createMetodePembayaran(
          kostId: kostId,
          tipe: tipe,
          nama: nama,
          noRek: noRek,
          atasNama: atasNama,
          qrImage: qrImage,
          isActive: true,
        );
      }

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran berhasil ditambahkan untuk ${selectedKostIds.length} kost',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menyimpan metode pembayaran'),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickQrisImage() async {
    if (isUploadingQris.value) return;

    String? selectedKostId;
    for (final item in selectedKostList) {
      final id = (item['id'] ?? '').toString();
      if (id.trim().isNotEmpty) {
        selectedKostId = id;
        break;
      }
    }

    if (selectedKostId == null) {
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null) {
      return;
    }

    final metodeName = namaBankController.text.trim().isEmpty
        ? 'qris'
        : namaBankController.text.trim();

    final fileName = file.name.trim();
    final ext = fileName.contains('.')
        ? fileName.split('.').last.trim().toLowerCase()
        : 'jpg';

    try {
      isUploadingQris.value = true;

      final bytes = await file.readAsBytes();
      final publicUrl = await _metodeRepo.uploadQrisImage(
        imageBytes: bytes,
        fileExt: ext,
        kostId: selectedKostId,
        namaMetode: metodeName,
      );

      selectedQrisImage.value = publicUrl;
      selectedKostList.refresh();

      Get.snackbar(
        'Berhasil',
        'Gambar QRIS berhasil diupload',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal upload gambar QRIS'),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUploadingQris.value = false;
      selectedKostList.refresh();
    }
  }

  void removeQrisImage() {
    selectedQrisImage.value = '';
  }
}
