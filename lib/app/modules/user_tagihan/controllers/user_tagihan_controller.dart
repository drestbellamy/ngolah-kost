import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/tagihan_user_model.dart';
import '../../../data/models/metode_pembayaran_model.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../../../../repositories/pembayaran_repository.dart';
import '../../../../repositories/metode_pembayaran_repository.dart';
import '../../../../repositories/storage_repository.dart';
import 'package:intl/intl.dart';

class UserTagihanController extends GetxController {
  // Repository dependencies with dependency injection support
  final PenghuniRepository _penghuniRepo;
  final TagihanRepository _tagihanRepo;
  final PembayaranRepository _pembayaranRepo;
  final MetodePembayaranRepository _metodePembayaranRepo;
  final StorageRepository _storageRepo;

  final authController = Get.find<AuthController>();
  final _imagePicker = ImagePicker();

  // Constructor with optional repository injection for testing
  UserTagihanController({
    PenghuniRepository? penghuniRepository,
    TagihanRepository? tagihanRepository,
    PembayaranRepository? pembayaranRepository,
    MetodePembayaranRepository? metodePembayaranRepository,
    StorageRepository? storageRepository,
  }) : _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _tagihanRepo =
           tagihanRepository ?? RepositoryFactory.instance.tagihanRepository,
       _pembayaranRepo =
           pembayaranRepository ??
           RepositoryFactory.instance.pembayaranRepository,
       _metodePembayaranRepo =
           metodePembayaranRepository ??
           RepositoryFactory.instance.metodePembayaranRepository,
       _storageRepo =
           storageRepository ?? RepositoryFactory.instance.storageRepository;

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
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
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
      final tagihanList = await _tagihanRepo.getTagihanByPenghuniId(
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

          // Get jatuh tempo from database or fallback to 20th of the month
          DateTime jatuhTempo;
          if (item['tanggal_jatuh_tempo'] != null) {
            jatuhTempo =
                DateTime.tryParse(item['tanggal_jatuh_tempo'].toString()) ??
                DateTime(tahun, bulan, 20);
          } else {
            jatuhTempo = DateTime(tahun, bulan, 20);
          }

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
      final pembayaranList = await _pembayaranRepo.getPembayaranByPenghuniId(
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
      final metodePembayaranData = await _metodePembayaranRepo
          .getMetodePembayaranList(kostId: userKostId.value);
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

  // Submit cash payment without image upload
  Future<void> submitCashPayment() async {
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

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi Pembayaran Tunai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Anda akan mengkonfirmasi pembayaran tunai untuk:'),
              const SizedBox(height: 12),
              ...tagihanTerpilih.map(
                (tagihan) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${tagihan.periodePenagihan}'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalBayarTerpilih)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pembayaran akan dikirim ke admin untuk verifikasi.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isUploadingBukti.value = true;

      // Create pembayaran record for each tagihan without bukti_pembayaran_url
      for (final tagihan in tagihanTerpilih) {
        print('=== Creating cash payment ===');
        print('Penghuni ID: ${penghuniId.value}');
        print('Tagihan ID: ${tagihan.id}');
        print('Jumlah: ${tagihan.totalBayar}');
        print('Metode ID: ${selectedMethods.first.id}');
        print('Payment Type: Cash (no image required)');

        await _pembayaranRepo.createPembayaran(
          penghuniId: penghuniId.value,
          tagihanId: tagihan.id,
          totalJumlah: tagihan.totalBayar,
          metodeId: selectedMethods.first.id,
          buktiPembayaranUrl: null, // No image for cash payments
        );

        print('✅ Cash payment created successfully');
      }

      Get.snackbar(
        'Berhasil',
        'Pembayaran tunai berhasil dikonfirmasi. Menunggu verifikasi admin.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Clear selection
      tagihanTerpilih.clear();
      metodePembayaran.value = '';

      // Refresh data
      await refreshData();
    } catch (e) {
      print('Error submit cash payment: $e');
      Get.snackbar(
        'Error',
        'Gagal mengkonfirmasi pembayaran tunai: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingBukti.value = false;
    }
  }

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
      final buktiUrl = await _storageRepo.uploadBuktiPembayaran(
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

        await _pembayaranRepo.createPembayaran(
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
      final buktiUrl = await _storageRepo.uploadBuktiPembayaran(
        imageBytes: imageBytes,
        fileExt: fileExt,
        penghuniId: penghuniId.value,
      );

      // Create pembayaran record for each tagihan
      for (final tagihan in tagihanTerpilih) {
        await _pembayaranRepo.createPembayaran(
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
