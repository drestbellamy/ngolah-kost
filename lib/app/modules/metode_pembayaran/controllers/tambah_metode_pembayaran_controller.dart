import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/metode_pembayaran_model.dart';

class TambahMetodePembayaranController extends GetxController {
  final selectedKostList = <Map<String, dynamic>>[].obs;
  final selectedTipe = ''.obs;
  final selectedQrisImage = ''.obs; // For QRIS image path

  final namaBankController = TextEditingController();
  final nomorRekeningController = TextEditingController();
  final atasNamaController = TextEditingController();

  // Edit mode
  final isEditMode = false.obs;
  MetodePembayaranModel? editingMetode;

  // Dummy data kost
  final availableKostList = [
    {
      'id': '1',
      'nama': 'Green Valley Kost',
      'alamat': 'Jl. Sudirman No. 123, Jakarta',
      'jumlahKamar': 12,
    },
    {
      'id': '2',
      'nama': 'Sunrise Boarding House',
      'alamat': 'Jl. Gatot Subroto No. 45, Jakarta',
      'jumlahKamar': 8,
    },
    {
      'id': '3',
      'nama': 'Peaceful Haven Kost',
      'alamat': 'Jl. Thamrin No. 67, Jakarta',
      'jumlahKamar': 10,
    },
    {
      'id': '4',
      'nama': 'Urban Residence',
      'alamat': 'Jl. HR Rasuna Said No. 89, Jakarta',
      'jumlahKamar': 15,
    },
    {
      'id': '5',
      'nama': 'Cozy Corner Kost',
      'alamat': 'Jl. Kuningan No. 34, Jakarta',
      'jumlahKamar': 6,
    },
  ];

  bool get canSave {
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

    // Check if edit mode
    if (Get.arguments != null && Get.arguments is MetodePembayaranModel) {
      isEditMode.value = true;
      editingMetode = Get.arguments as MetodePembayaranModel;

      // Pre-fill data
      selectedTipe.value = editingMetode!.jenis;

      if (editingMetode!.jenis == 'bank') {
        namaBankController.text = editingMetode!.nama;
        nomorRekeningController.text = editingMetode!.nomorRekening;
        atasNamaController.text =
            ''; // Atas nama tidak ada di model, bisa dikosongkan
      } else if (editingMetode!.jenis == 'qris') {
        namaBankController.text = editingMetode!.nama;
        selectedQrisImage.value = editingMetode!.qrisImagePath ?? '';
      }

      // Set selected kost
      final kost = availableKostList.firstWhere(
        (k) => k['nama'] == editingMetode!.namaKost,
        orElse: () => availableKostList[0],
      );
      selectedKostList.value = [kost];
    }

    // Listen to text changes to update button state
    namaBankController.addListener(_updateState);
    nomorRekeningController.addListener(_updateState);
    atasNamaController.addListener(_updateState);
  }

  void _updateState() {
    // Trigger rebuild for canSave getter
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
  }

  void showPilihKostBottomSheet() {
    final tempSelected = <String>[
      ...selectedKostList.map((k) => k['id'] as String),
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
                              availableKostList.map((k) => k['id'] as String),
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
                      final isSelected = tempSelected.contains(kost['id']);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              tempSelected.remove(kost['id']);
                            } else {
                              tempSelected.add(kost['id'] as String);
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
                                  .where((k) => tempSelected.contains(k['id']))
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
    selectedKostList.removeWhere((k) => k['id'] == id);
  }

  void simpan() {
    if (!canSave) return;

    Get.back();

    if (isEditMode.value) {
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran berhasil diperbarui',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran berhasil ditambahkan untuk ${selectedKostList.length} kost',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void pickQrisImage() {
    // Simulate image picker for UI/UX purposes
    selectedQrisImage.value = 'assets/images/qris_sample.png';
    Get.snackbar(
      'Berhasil',
      'Gambar QRIS berhasil dipilih',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void removeQrisImage() {
    selectedQrisImage.value = '';
  }
}
