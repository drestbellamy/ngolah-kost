import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/pengumuman_repository.dart';
import '../../../../repositories/peraturan_repository.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../data/models/pengumuman_model.dart';
import '../../../data/models/peraturan_model.dart';

class UserInfoController extends GetxController with WidgetsBindingObserver {
  // Repository dependencies with dependency injection support
  final PenghuniRepository _penghuniRepo;
  final PengumumanRepository _pengumumanRepo;
  final PeraturanRepository _peraturanRepo;
  final AuthController _authController = Get.find<AuthController>();

  // Constructor with optional repository injection for testing
  UserInfoController({
    PenghuniRepository? penghuniRepository,
    PengumumanRepository? pengumumanRepository,
    PeraturanRepository? peraturanRepository,
  }) : _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _pengumumanRepo =
           pengumumanRepository ??
           RepositoryFactory.instance.pengumumanRepository,
       _peraturanRepo =
           peraturanRepository ??
           RepositoryFactory.instance.peraturanRepository;

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PengumumanModel> pengumumanList = <PengumumanModel>[].obs;
  final RxList<PeraturanModel> peraturanList = <PeraturanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadData();
    _markInfoAsSeen();

    // Auto refresh disabled - user can manually refresh with pull-to-refresh
  }

  void _markInfoAsSeen() {
    // Mark info as seen when page is opened
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      // Immediately hide badge for better UX
      notificationController.hasInfoNotification.value = false;
      // Then update database in background
      notificationController.markInfoAsSeen();
    }
  }

  @override
  void onClose() {
    // No timer to cancel
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data saat app kembali ke foreground
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user ID from AuthController
      final userId = _authController.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      // Get penghuni data to find kost_id
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);

      if (penghuniData == null) {
        // User belum terdaftar sebagai penghuni
        pengumumanList.value = [];
        peraturanList.value = [];
        isLoading.value = false;
        return;
      }

      final kostId = penghuniData['kost_id']?.toString() ?? '';
      if (kostId.isEmpty) {
        throw Exception('Data kost tidak ditemukan');
      }

      // Fetch pengumuman dan peraturan
      await Future.wait([_loadPengumuman(kostId), _loadPeraturan(kostId)]);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPengumuman(String kostId) async {
    try {
      final data = await _pengumumanRepo.getPengumumanList(kostId: kostId);
      pengumumanList.value = data
          .map((item) => PengumumanModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error loading pengumuman: $e');
    }
  }

  Future<void> _loadPeraturan(String kostId) async {
    try {
      final data = await _peraturanRepo.getPeraturanList(kostId: kostId);
      peraturanList.value = data
          .map((item) => PeraturanModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error loading peraturan: $e');
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  @override
  Future<void> refresh() async {
    await loadData();
  }
}
