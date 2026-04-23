import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/storage_repository.dart';

class UserProfilController extends GetxController {
  // Repository dependencies with dependency injection support
  final AuthRepository _authRepo;
  final PenghuniRepository _penghuniRepo;
  final StorageRepository _storageRepo;
  final _authController = Get.find<AuthController>();
  final imagePicker = ImagePicker();

  // Constructor with optional repository injection for testing
  UserProfilController({
    AuthRepository? authRepository,
    PenghuniRepository? penghuniRepository,
    StorageRepository? storageRepository,
  }) : _authRepo = authRepository ?? RepositoryFactory.instance.authRepository,
       _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _storageRepo =
           storageRepository ?? RepositoryFactory.instance.storageRepository;

  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final fotoProfilUrl = Rxn<String>();
  final isUploadingPhoto = false.obs;
  final namaKost = ''.obs;
  final alamatKost = ''.obs;
  final latitudeKost = Rx<double?>(null);
  final longitudeKost = Rx<double?>(null);
  final username = ''.obs;

  // Computed properties
  String get userName => userProfile.value?.nama ?? '';
  String get userPhone => userProfile.value?.noTelepon ?? '';
  String get nomorKamar => userProfile.value?.nomorKamar ?? '';
  int get hargaPerBulan => userProfile.value?.hargaPerBulan ?? 0;
  String get tanggalMasuk =>
      _formatTanggal(userProfile.value?.tanggalMasuk ?? '');
  String get durasiKontrak => userProfile.value?.durasiKontrakText ?? '';
  String get sistemPembayaran => userProfile.value?.sistemPembayaranText ?? '';
  String get periodeKontrak => _getPeriodeKontrak();
  int get totalTagihan => userProfile.value?.totalTagihan ?? 0;
  int get perTagihan => userProfile.value?.jumlahPerTagihan ?? 0;
  int get totalNilaiKontrak => userProfile.value?.totalNilaiKontrak ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  @override
  void onReady() {
    super.onReady();
    // Load profile lagi saat halaman siap
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _authController.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      print('Fetching profile for user_id: $userId'); // Debug log

      // Fetch user data untuk foto profil dan username
      final userData = await _authRepo.getUserById(userId);
      if (userData != null) {
        fotoProfilUrl.value = userData['foto_profil']?.toString();
        username.value = userData['username']?.toString() ?? '';
        print('Foto profil loaded: ${fotoProfilUrl.value}');
        print('Username loaded: ${username.value}');
      }

      // Fetch data penghuni berdasarkan user_id
      final data = await _penghuniRepo.getPenghuniByUserId(userId);

      print('Fetched data: $data'); // Debug log

      if (data == null) {
        // Jika data tidak ditemukan, set profile dengan data kosong
        userProfile.value = UserProfileModel.fromMap({
          'nama': 'Data tidak tersedia',
          'no_telepon': '-',
          'nomor_kamar': '-',
          'harga_per_bulan': 0,
          'tanggal_masuk': '',
          'tanggal_keluar': '',
          'durasi_kontrak': 0,
          'sistem_pembayaran': 'bulanan',
          'status': 'tidak_aktif',
          'total_tagihan': 0,
          'jumlah_per_tagihan': 0,
          'total_nilai_kontrak': 0,
        });

        namaKost.value = 'Kost tidak tersedia';
        alamatKost.value = '-';

        // Set error message untuk ditampilkan di bagian bawah
        errorMessage.value =
            'Data penghuni tidak ditemukan. Pastikan admin sudah menambahkan data kontrak Anda.';
        return;
      }

      userProfile.value = UserProfileModel.fromMap(data);

      // Get nama kost dan alamat
      final kostId = data['kost_id']?.toString() ?? '';
      if (kostId.isNotEmpty) {
        // Direct query since KostRepository doesn't have getKostById yet
        final kostData = await Supabase.instance.client
            .from('kost')
            .select('nama_kost, alamat, latitude, longitude')
            .eq('id', kostId)
            .maybeSingle();

        if (kostData != null) {
          namaKost.value = kostData['nama_kost']?.toString() ?? '';
          alamatKost.value = kostData['alamat']?.toString() ?? '';
          if (kostData['latitude'] != null) {
            final lat = double.tryParse(kostData['latitude'].toString());
            if (lat != null && lat.isFinite) latitudeKost.value = lat;
          }
          if (kostData['longitude'] != null) {
            final lng = double.tryParse(kostData['longitude'].toString());
            if (lng != null && lng.isFinite) longitudeKost.value = lng;
          }
          print(
            'Kost loaded: ${namaKost.value}, ${alamatKost.value}, lat: ${latitudeKost.value}, lng: ${longitudeKost.value}',
          );
        }
      }

      print('Profile loaded: ${userProfile.value?.nama}'); // Debug log
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error in fetchUserProfile: $e'); // Debug log
      ToastHelper.showError(
        'Gagal memuat profil: ${e.toString()}',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTanggal(String tanggal) {
    if (tanggal.isEmpty) return '';
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  String _getPeriodeKontrak() {
    final profile = userProfile.value;
    if (profile == null) return '';

    try {
      final mulai = DateTime.parse(profile.tanggalMasuk);
      final selesai = DateTime.parse(profile.tanggalKeluar);

      final mulaiStr = DateFormat('d MMMM yyyy', 'id_ID').format(mulai);
      final selesaiStr = DateFormat('d MMMM yyyy', 'id_ID').format(selesai);

      return '$mulaiStr - $selesaiStr';
    } catch (e) {
      return '';
    }
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadPhoto(image);
      }
    } catch (e) {
      ToastHelper.showError('Gagal mengambil foto: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadPhoto(image);
      }
    } catch (e) {
      ToastHelper.showError('Gagal memilih foto: $e');
    }
  }

  Future<void> uploadPhoto(XFile image) async {
    final userId = _authController.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ToastHelper.showError('User tidak ditemukan');
      return;
    }

    try {
      isUploadingPhoto.value = true;
      Get.back(); // Close bottom sheet

      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;

      print('=== UPLOAD PHOTO DEBUG ===');
      print('User ID: $userId');

      // Upload to storage
      final photoUrl = await _storageRepo.uploadFotoProfilAdmin(
        imageBytes: bytes,
        fileExt: fileExt,
        userId: userId,
      );

      print('Photo uploaded to storage: $photoUrl');

      // Update database
      await _authRepo.updateFotoProfilUser(
        userId: userId,
        fotoProfilUrl: photoUrl,
      );

      fotoProfilUrl.value = photoUrl;

      ToastHelper.showSuccess('Foto profil berhasil diperbarui');
    } catch (e) {
      print('❌ Upload photo error: $e');
      ToastHelper.showError('Gagal mengupload foto: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> deletePhoto() async {
    final userId = _authController.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ToastHelper.showError('User tidak ditemukan');
      return;
    }

    try {
      Get.back(); // Close bottom sheet

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Hapus Foto Profil'),
          content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isUploadingPhoto.value = true;

      // Update database to set foto_profil to null
      await _authRepo.updateFotoProfilUser(userId: userId, fotoProfilUrl: null);

      fotoProfilUrl.value = null;

      ToastHelper.showSuccess('Foto profil berhasil dihapus');
    } catch (e) {
      ToastHelper.showError('Gagal menghapus foto: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // Open map with address or coordinates
  Future<void> openMap() async {
    final address = alamatKost.value;
    final lat = latitudeKost.value;
    final lng = longitudeKost.value;

    if (address.isEmpty || address == '-') {
      ToastHelper.showInfo('Alamat tidak tersedia');
      return;
    }

    try {
      Uri url;

      // If we have exact coordinates, use them for the pin
      if (lat != null && lng != null) {
        // query=$lat,$lng places a pin exactly there
        url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
      } else {
        // Fallback to text address search
        final encodedAddress = Uri.encodeComponent(address);
        url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
        );
      }

      // Launch URL
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ToastHelper.showError('Tidak dapat membuka peta');
      }
    } catch (e) {
      print('Error opening map: $e');
      ToastHelper.showError('Gagal membuka peta: $e');
    }
  }
}
