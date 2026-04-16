import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/tagihan_user_model.dart';
import '../../../data/models/metode_pembayaran_model.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../../services/supabase_service.dart';
import 'package:intl/intl.dart';

class UserTagihanController extends GetxController {
  final _supabaseService = SupabaseService();
  final authController = Get.find<AuthController>();
  final _imagePicker = ImagePicker();

  final RxList<TagihanUserModel> semuaTagihan = <TagihanUserModel>[].obs;
  final RxList<TagihanUserModel> tagihanTerpilih = <TagihanUserModel>[].obs;
  final RxList<String> tagihanWithPendingPayment =
      <String>[].obs; // Track tagihan with pending payment
  final RxList<MetodePembayaranModel> metodePembayaranList =
      <MetodePembayaranModel>[].obs;
  final RxString metodePembayaran = ''.obs;
  final RxString userKostId = ''.obs; // Store user's kost_id
  final RxString penghuniId = ''.obs; // Store penghuni_id
  final Rxn<MetodePembayaranModel> selectedMetodePembayaran =
      Rxn<MetodePembayaranModel>();
  final isLoading = true.obs;
  final isLoadingMetodePembayaran = true.obs;
  final isUploadingBukti = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _markTagihanAsSeen();
  }

  void _markTagihanAsSeen() {
    // Mark tagihan as seen when page is opened
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      // Immediately hide badge for better UX
      notificationController.hasTagihanNotification.value = false;
      // Then update database in background
      notificationController.markTagihanAsSeen();
    }
  }

  Future<void> _initializeData() async {
    // Load tagihan first to get kost_id
    await loadTagihanData();
    // Then load metode pembayaran filtered by kost_id
    await loadMetodePembayaran();
  }

  Future<void> loadTagihanData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = authController.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User tidak ditemukan');
      }

      print('Loading tagihan for userId: $userId'); // Debug

      // Get penghuni data first
      final penghuniData = await _supabaseService.getPenghuniByUserId(userId);
      if (penghuniData == null) {
        throw Exception('Data penghuni tidak ditemukan');
      }

      final penghuniIdValue = penghuniData['id']?.toString() ?? '';
      final nomorKamar = penghuniData['nomor_kamar']?.toString() ?? '';
      final kostId = penghuniData['kost_id']?.toString() ?? '';

      print(
        'Penghuni ID: $penghuniIdValue, Nomor Kamar: $nomorKamar, Kost ID: $kostId',
      ); // Debug

      if (penghuniIdValue.isEmpty) {
        throw Exception('ID penghuni tidak valid');
      }

      // Store penghuni_id and kost_id
      penghuniId.value = penghuniIdValue;
      userKostId.value = kostId;

      // Get tagihan data
      final tagihanList = await _supabaseService.getTagihanByPenghuniId(
        penghuniIdValue,
      );
      print('Tagihan data fetched: ${tagihanList.length} items'); // Debug

      // Convert to TagihanUserModel
      final List<TagihanUserModel> tagihan = [];
      for (final item in tagihanList) {
        final bulan = item['bulan'] as int? ?? 0;
        final tahun = item['tahun'] as int? ?? 0;
        final jumlah = item['jumlah'] as int? ?? 0;
        final status = item['status']?.toString() ?? '';

        if (bulan > 0 && tahun > 0) {
          // Create periode string
          final periodeDate = DateTime(tahun, bulan, 1);
          final periodePenagihan = DateFormat(
            'MMMM yyyy',
            'id_ID',
          ).format(periodeDate);

          // Create jatuh tempo (assume 20th of the month)
          final jatuhTempo = DateTime(tahun, bulan, 20);

          // Convert status
          final displayStatus = status == 'lunas' ? 'Lunas' : 'Belum Dibayar';

          tagihan.add(
            TagihanUserModel(
              id: item['id']?.toString() ?? '',
              nomorKamar: nomorKamar,
              periodePenagihan: periodePenagihan,
              jatuhTempo: jatuhTempo,
              totalBayar: jumlah.toDouble(),
              status: displayStatus,
            ),
          );
        }
      }

      print('Converted tagihan: ${tagihan.length} items'); // Debug
      semuaTagihan.assignAll(tagihan);

      // Check for pending payments
      await checkPendingPayments();
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading tagihan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TagihanUserModel> get tagihanBelumDibayar =>
      semuaTagihan.where((t) => t.status == 'Belum Dibayar').toList();

  double get totalBayarTerpilih {
    return tagihanTerpilih.fold(0.0, (sum, item) => sum + item.totalBayar);
  }

  // Check if tagihan has pending payment
  Future<void> checkPendingPayments() async {
    try {
      if (penghuniId.value.isEmpty) return;

      // Get all pembayaran with pending status
      final pembayaranList = await _supabaseService.getPembayaranByPenghuniId(
        penghuniId.value,
      );

      // Extract tagihan IDs that have pending payment
      final pendingTagihanIds = pembayaranList
          .where((p) => p['status'] == 'pending')
          .map((p) => p['tagihan_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      tagihanWithPendingPayment.assignAll(pendingTagihanIds);
      print('Tagihan with pending payment: ${pendingTagihanIds.length}');
    } catch (e) {
      print('Error checking pending payments: $e');
    }
  }

  // Check if tagihan can be selected
  bool canSelectTagihan(TagihanUserModel tagihan) {
    return !tagihanWithPendingPayment.contains(tagihan.id);
  }

  void toggleTagihan(TagihanUserModel tagihan) {
    // Don't allow selection if tagihan has pending payment
    if (!canSelectTagihan(tagihan)) {
      Get.snackbar(
        'Tidak Dapat Dipilih',
        'Tagihan ini sudah memiliki pembayaran yang menunggu verifikasi',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (tagihanTerpilih.contains(tagihan)) {
      tagihanTerpilih.remove(tagihan);
    } else {
      tagihanTerpilih.add(tagihan);
    }
  }

  Future<void> refreshData() async {
    await loadTagihanData();
    await loadMetodePembayaran();
  }

  Future<void> loadMetodePembayaran() async {
    try {
      isLoadingMetodePembayaran.value = true;

      print('=== Loading Metode Pembayaran ==='); // Debug

      // Wait for kost_id to be available
      if (userKostId.value.isEmpty) {
        print('⚠️ Kost ID is empty, waiting...'); // Debug
        // If kost_id not available yet, wait a bit and retry
        await Future.delayed(const Duration(milliseconds: 500));
        if (userKostId.value.isEmpty) {
          print('❌ Kost ID still not available after waiting');
          return;
        }
      }

      print('✅ User Kost ID: ${userKostId.value}'); // Debug

      // Get metode pembayaran data
      final metodePembayaranData = await _supabaseService
          .getMetodePembayaranList();
      print(
        '📦 Total metode pembayaran from DB: ${metodePembayaranData.length}',
      ); // Debug

      // Debug: Print all metode pembayaran with their kost_id
      for (final item in metodePembayaranData) {
        print(
          '  - Metode: ${item['nama']}, Kost ID: ${item['kost_id']}, Active: ${item['is_active']}',
        );
      }

      // Convert to MetodePembayaranModel and filter by kost_id and active status
      final List<MetodePembayaranModel> metodeList = [];
      for (final item in metodePembayaranData) {
        final metode = MetodePembayaranModel.fromMap(item);
        print(
          '  Checking: ${metode.nama} - Kost ID: "${metode.kostId}" vs User Kost ID: "${userKostId.value}"',
        ); // Debug

        // Filter by kost_id and active status
        if (metode.isActive && metode.kostId == userKostId.value) {
          print('    ✅ MATCH! Adding ${metode.nama}'); // Debug
          metodeList.add(metode);
        } else {
          print(
            '    ❌ NO MATCH - Active: ${metode.isActive}, Kost Match: ${metode.kostId == userKostId.value}',
          ); // Debug
        }
      }

      print(
        '🎯 Filtered metode pembayaran for this kost: ${metodeList.length} items',
      ); // Debug

      metodePembayaranList.assignAll(metodeList);

      // Set default selection to 'Transfer' if available, otherwise first available type
      if (metodeList.isNotEmpty) {
        final transferMethods = metodeList
            .where(
              (m) =>
                  m.tipe.toLowerCase().contains('transfer') ||
                  m.tipe.toLowerCase().contains('bank'),
            )
            .toList();

        if (transferMethods.isNotEmpty) {
          metodePembayaran.value = 'Transfer';
        } else {
          final firstType = _normalizeType(metodeList.first.tipe);
          metodePembayaran.value = firstType;
        }
      }

      print('Active metode pembayaran: ${metodeList.length} items'); // Debug
    } catch (e) {
      print('Error loading metode pembayaran: $e');
    } finally {
      isLoadingMetodePembayaran.value = false;
    }
  }

  void selectMetodePembayaran(String tipe) {
    metodePembayaran.value = tipe;
  }

  String _normalizeType(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'transfer':
      case 'bank':
        return 'Transfer';
      case 'qris':
        return 'QRIS';
      case 'tunai':
      case 'cash':
        return 'Tunai';
      default:
        return 'Transfer';
    }
  }

  // Get methods by type
  List<MetodePembayaranModel> getMethodsByType(String tipe) {
    return metodePembayaranList.where((metode) {
      final normalizedTipe = _normalizeType(metode.tipe);
      return normalizedTipe == tipe;
    }).toList();
  }

  // Get available payment types
  List<String> get availablePaymentTypes {
    final types = <String>{};
    for (final metode in metodePembayaranList) {
      types.add(_normalizeType(metode.tipe));
    }
    return types.toList();
  }

  // Upload bukti pembayaran
  Future<void> uploadBuktiPembayaran() async {
    try {
      // Validasi
      if (tagihanTerpilih.isEmpty) {
        Get.snackbar(
          'Peringatan',
          'Pilih tagihan yang akan dibayar terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (metodePembayaran.value.isEmpty) {
        Get.snackbar(
          'Peringatan',
          'Pilih metode pembayaran terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get selected payment method
      final selectedMethods = getMethodsByType(metodePembayaran.value);
      if (selectedMethods.isEmpty) {
        Get.snackbar(
          'Error',
          'Metode pembayaran tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return; // User cancelled
      }

      isUploadingBukti.value = true;

      // Read image bytes
      final imageBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;

      // Upload to storage
      final buktiUrl = await _supabaseService.uploadBuktiPembayaran(
        imageBytes: imageBytes,
        fileExt: fileExt,
        penghuniId: penghuniId.value,
      );

      // Create pembayaran record for each tagihan
      for (final tagihan in tagihanTerpilih) {
        print('=== Creating pembayaran ===');
        print('Penghuni ID: ${penghuniId.value}');
        print('Tagihan ID: ${tagihan.id}');
        print('Jumlah: ${tagihan.totalBayar}');
        print('Metode ID: ${selectedMethods.first.id}');
        print('Bukti URL: $buktiUrl');

        await _supabaseService.createPembayaran(
          penghuniId: penghuniId.value,
          tagihanId: tagihan.id,
          totalJumlah: tagihan.totalBayar,
          metodeId: selectedMethods.first.id,
          buktiPembayaranUrl: buktiUrl,
        );

        print('✅ Pembayaran created successfully');
      }

      Get.snackbar(
        'Berhasil',
        'Bukti pembayaran berhasil diunggah. Menunggu verifikasi admin.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Clear selection
      tagihanTerpilih.clear();
      metodePembayaran.value = '';

      // Refresh data
      await refreshData();
    } catch (e) {
      print('Error upload bukti pembayaran: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunggah bukti pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingBukti.value = false;
    }
  }

  // Confirm and upload bukti pembayaran with selected image
  Future<void> confirmUploadBuktiPembayaran(XFile image) async {
    try {
      // Validasi
      if (tagihanTerpilih.isEmpty) {
        Get.snackbar(
          'Peringatan',
          'Pilih tagihan yang akan dibayar terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (metodePembayaran.value.isEmpty) {
        Get.snackbar(
          'Peringatan',
          'Pilih metode pembayaran terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get selected payment method
      final selectedMethods = getMethodsByType(metodePembayaran.value);
      if (selectedMethods.isEmpty) {
        Get.snackbar(
          'Error',
          'Metode pembayaran tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isUploadingBukti.value = true;

      // Read image bytes
      final imageBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;

      // Upload to storage
      final buktiUrl = await _supabaseService.uploadBuktiPembayaran(
        imageBytes: imageBytes,
        fileExt: fileExt,
        penghuniId: penghuniId.value,
      );

      // Create pembayaran record for each tagihan
      for (final tagihan in tagihanTerpilih) {
        await _supabaseService.createPembayaran(
          penghuniId: penghuniId.value,
          tagihanId: tagihan.id,
          totalJumlah: tagihan.totalBayar,
          metodeId: selectedMethods.first.id,
          buktiPembayaranUrl: buktiUrl,
        );
      }

      Get.snackbar(
        'Berhasil',
        'Bukti pembayaran berhasil diunggah',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Clear selection
      tagihanTerpilih.clear();
      metodePembayaran.value = '';

      // Navigate to history page
      Get.offNamed('/user-history-pembayaran');
    } catch (e) {
      print('Error upload bukti pembayaran: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunggah bukti pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingBukti.value = false;
    }
  }
}
