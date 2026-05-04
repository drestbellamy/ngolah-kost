import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengaduan_model.dart';
import '../../../../repositories/pengaduan_repository.dart';

class UserPengaduanController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final pengaduanList = <PengaduanModel>[].obs;
  final searchQuery = ''.obs;
  final _repository = PengaduanRepository(Supabase.instance.client);

  @override
  void onInit() {
    super.onInit();
    fetchPengaduan();
  }

  List<PengaduanModel> get filteredPengaduanList {
    if (searchQuery.value.isEmpty) {
      return pengaduanList;
    }

    final query = searchQuery.value.toLowerCase();
    return pengaduanList.where((item) {
      return item.kodeLaporan.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> fetchPengaduan() async {
    try {
      isLoading(true);
      pengaduanList
        ..clear()
        ..addAll(await _repository.fetchPengaduan());
    } catch (e) {
      // Error will be handled by view
      print('Error fetching pengaduan: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> submitPengaduan(
    String kodeKost,
    String deskripsi,
    List<File>? imageFiles,
  ) async {
    if (deskripsi.trim().isEmpty) {
      return false;
    }

    try {
      isSubmitting(true);
      await _repository.submitPengaduan(
        kodeKost: kodeKost,
        deskripsi: deskripsi,
        imageFiles: imageFiles,
      );

      // Refresh list
      await fetchPengaduan();

      return true;
    } catch (e) {
      // Re-throw to be handled by view with toast
      rethrow;
    } finally {
      isSubmitting(false);
    }
  }
}
