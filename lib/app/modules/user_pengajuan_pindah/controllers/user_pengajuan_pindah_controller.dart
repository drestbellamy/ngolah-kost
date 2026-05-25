import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../repositories/pengajuan_pindah_repository.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../data/models/pengajuan_pindah_model.dart';
import '../../../core/utils/toast_helper.dart';

class UserPengajuanPindahController extends GetxController {
  final PengajuanPindahRepository _repository;
  final authController = Get.find<AuthController>();

  UserPengajuanPindahController({PengajuanPindahRepository? repository})
    : _repository = repository ?? PengajuanPindahRepository();

  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  // Data
  final availableRooms = <Map<String, dynamic>>[].obs;
  final groupedKosts = <String, Map<String, dynamic>>{}.obs;
  final activePengajuan = Rxn<PengajuanPindahModel>();
  final penghuniId = ''.obs;

  // Form selections
  final selectedKostId = Rxn<String>();
  final selectedRoomId = Rxn<String>();
  final selectedDate = Rxn<DateTime>();
  final reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  Future<void> _initData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = authController.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // 1. Get active penghuni ID
      final penghuniData = await _repository.getActivePenghuniByUserId(userId);
      if (penghuniData == null) {
        errorMessage.value = 'Anda tidak memiliki kontrak kamar yang aktif.';
        return;
      }
      penghuniId.value = penghuniData['id'];

      // 2. Check if user already has a pending request
      final pending = await _repository.getPendingPengajuan(penghuniId.value);
      if (pending != null) {
        activePengajuan.value = pending;
        // If they already have a pending request, we don't need to load available rooms yet
        return;
      }

      // 3. Load available rooms
      await loadSemuaKamar();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSemuaKamar() async {
    try {
      final rooms = await _repository.getSemuaKamar();
      availableRooms.value = rooms;

      final groups = <String, Map<String, dynamic>>{};
      for (final room in rooms) {
        final kostId = room['kost_id']?.toString() ?? '';
        final kost = room['kost'] as Map<String, dynamic>?;
        if (kostId.isEmpty || kost == null) continue;

        if (!groups.containsKey(kostId)) {
          groups[kostId] = {
            'id': kostId,
            'nama_kost': kost['nama_kost'],
            'alamat': kost['alamat'],
            'rooms': <Map<String, dynamic>>[],
          };
        }
        (groups[kostId]!['rooms'] as List).add(room);
      }
      groupedKosts.value = groups;
    } catch (e) {
      errorMessage.value = 'Gagal memuat daftar kamar: ${e.toString()}';
    }
  }

  void selectKost(String kostId) {
    if (selectedKostId.value != kostId) {
      selectedKostId.value = kostId;
      selectedRoomId.value = null; // Reset room when changing kost
    }
  }

  void selectRoom(String roomId) {
    selectedRoomId.value = roomId;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> submitPengajuan() async {
    if (selectedRoomId.value == null) {
      ToastHelper.showError('Pilih kamar tujuan terlebih dahulu');
      return;
    }

    if (selectedDate.value == null) {
      ToastHelper.showError('Pilih tanggal pindah');
      return;
    }

    if (penghuniId.value.isEmpty) {
      ToastHelper.showError('Data kontrak tidak valid');
      return;
    }

    try {
      isSubmitting.value = true;

      await _repository.submitPengajuanPindah(
        penghuniId: penghuniId.value,
        kamarTujuanId: selectedRoomId.value!,
        tanggalPindah: selectedDate.value!,
        alasan: reasonController.text.trim(),
      );

      ToastHelper.showSuccess('Pengajuan pindah kamar berhasil dikirim');

      // Refresh state to show pending request
      await _initData();
    } catch (e) {
      ToastHelper.showError('Gagal mengirim pengajuan: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }
}
