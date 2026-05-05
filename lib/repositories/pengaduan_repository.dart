import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/modules/user_pengaduan/models/pengaduan_model.dart';
import '../app/core/controllers/auth_controller.dart';

class PengaduanRepository {
  PengaduanRepository(this._client);

  final SupabaseClient _client;

  // Get current penghuni ID from user_id via penghuni table
  Future<String?> get _currentPenghuniId async {
    if (Get.isRegistered<AuthController>()) {
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) return null;

      try {
        // Get penghuni_id from penghuni table where user_id matches
        final response = await _client
            .from('penghuni')
            .select('id')
            .eq('user_id', userId)
            .eq('status', 'aktif')
            .maybeSingle();

        if (response != null) {
          return response['id']?.toString();
        }
      } catch (e) {
        print('Error getting penghuni_id: $e');
      }
    }
    return null;
  }

  Future<List<PengaduanModel>> fetchPengaduan() async {
    // Get current penghuni ID
    final penghuniId = await _currentPenghuniId;

    if (penghuniId == null) {
      throw Exception('Penghuni not found. Please contact administrator.');
    }

    print('=== FETCH PENGADUAN ===');
    print('Penghuni ID: $penghuniId');
    print('=======================');

    // Fetch pengaduan created by current penghuni OR legacy data (penghuni_id is null)
    // This allows viewing old reports while migrating data
    final response = await _client
        .from('pengaduan')
        .select()
        .or('penghuni_id.eq.$penghuniId,penghuni_id.is.null')
        .order('tanggal', ascending: false);

    return (response as List).map((e) => PengaduanModel.fromJson(e)).toList();
  }

  Future<void> submitPengaduan({
    required String kodeKost,
    required String deskripsi,
    List<File>? imageFiles,
  }) async {
    // Get current penghuni ID
    final penghuniId = await _currentPenghuniId;

    print('=== DEBUG AUTH ===');
    print('Penghuni ID: $penghuniId');
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      print('Current User: ${authController.currentUser?.username}');
      print('Is Logged In: ${authController.isLoggedIn}');
    }
    print('==================');

    if (penghuniId == null) {
      throw Exception('Penghuni not found. Please contact administrator.');
    }

    List<String> imageUrls = [];

    // Upload all images
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (final imageFile in imageFiles) {
        final originalName = imageFile.path.split(Platform.pathSeparator).last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$originalName';

        await _client.storage
            .from('pengaduan_images')
            .upload(fileName, imageFile);

        final imageUrl = _client.storage
            .from('pengaduan_images')
            .getPublicUrl(fileName);

        imageUrls.add(imageUrl);
      }
    }

    // Get nama kost from penghuni's kamar
    String namaKost = 'KOST';
    try {
      // Direct query to get nama kost from penghuni
      print('Getting nama kost for penghuni_id: $penghuniId');

      final penghuniData = await _client
          .from('penghuni')
          .select('kamar:kamar_id(kost:kost_id(nama_kost))')
          .eq('id', penghuniId)
          .maybeSingle();

      print('Penghuni data: $penghuniData');

      if (penghuniData != null &&
          penghuniData['kamar'] != null &&
          penghuniData['kamar']['kost'] != null) {
        namaKost = penghuniData['kamar']['kost']['nama_kost'] ?? 'KOST';
        print('Nama kost found: $namaKost');
      } else {
        print('Nama kost not found, using default: KOST');
      }
    } catch (e) {
      // If query fails, fallback to default 'KOST'
      print('Failed to get kost name: $e');
    }

    // Create abbreviation from nama kost
    final abbreviation = _createAbbreviation(namaKost);
    print('Abbreviation created: $abbreviation (from: $namaKost)');

    // Get count of today's reports for sequential number
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayReports = await _client
        .from('pengaduan')
        .select('id_laporan')
        .gte('tanggal', startOfDay.toIso8601String())
        .lt('tanggal', endOfDay.toIso8601String())
        .count();

    final sequenceNumber = (todayReports.count + 1).toString().padLeft(3, '0');
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final pengaduan = PengaduanModel(
      kodeLaporan: '$abbreviation-$sequenceNumber-$dateStr',
      tanggal: DateTime.now(),
      deskripsi: deskripsi,
      status: 'MENUNGGU',
      buktiFoto: imageUrls.isNotEmpty ? imageUrls : null,
      buktiLaporan: imageUrls.isNotEmpty
          ? imageUrls.first
          : null, // Legacy support
      penghuniId: penghuniId, // Use penghuni_id
    );

    final jsonData = pengaduan.toJson();
    print('=== SUBMITTING PENGADUAN ===');
    print('Penghuni ID: $penghuniId');
    print('Photo count: ${imageUrls.length}');
    print('Photo URLs: $imageUrls');
    print('JSON data: $jsonData');
    print('===========================');

    await _client.from('pengaduan').insert(jsonData);
  }

  /// Create abbreviation from kost name (same logic as username generation)
  /// Example: "Ngolah Kost" -> "NK", "Kost Mawar Indah" -> "KMI"
  /// Max 5 characters, removes special characters
  String _createAbbreviation(String namaKost) {
    final words = namaKost
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'KOST';

    // Take first letter of each word, remove special characters
    final initials = words.map((word) {
      final first = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      if (first.isEmpty) return '';
      return first[0].toUpperCase();
    }).join();

    final abbreviation = initials.isEmpty ? 'KOST' : initials;

    // Max 5 characters (consistent with username generation)
    return abbreviation.length > 5
        ? abbreviation.substring(0, 5)
        : abbreviation;
  }

  // ===== ADMIN METHODS =====

  /// Fetch all pengaduan for admin (from all penghuni)
  /// Uses RPC function to bypass RLS restrictions
  Future<List<Map<String, dynamic>>> fetchAllPengaduanForAdmin() async {
    print('=== FETCH ALL PENGADUAN FOR ADMIN ===');

    try {
      // Call RPC function that has SECURITY DEFINER
      final response = await _client.rpc('get_all_pengaduan_for_admin');

      print('RPC response: $response');

      if (response == null) {
        print('RPC returned null');
        return [];
      }

      final pengaduanList = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      print('Total pengaduan fetched: ${pengaduanList.length}');

      // Enrich each pengaduan with proper structure for model
      final enrichedList = <Map<String, dynamic>>[];

      for (final pengaduan in pengaduanList) {
        print('Processing pengaduan: ${pengaduan['kode_laporan']}');
        print('  Nama: ${pengaduan['nama_penghuni']}');
        print('  Kost: ${pengaduan['nama_kost']}');

        // Create enriched structure that matches PengaduanAdminModel
        final enrichedPengaduan = Map<String, dynamic>.from(pengaduan);

        // Add nested structure for compatibility with model
        enrichedPengaduan['penghuni_data'] = {
          'nama': pengaduan['nama_penghuni'] ?? 'Penghuni',
        };
        enrichedPengaduan['kost_data'] = {
          'nama_kost': pengaduan['nama_kost'] ?? '-',
        };

        enrichedList.add(enrichedPengaduan);
      }

      print('Total pengaduan enriched: ${enrichedList.length}');
      return enrichedList;
    } catch (e) {
      print('✗ ERROR fetching pengaduan via RPC: $e');
      print('Stack trace: ${StackTrace.current}');

      // Fallback: return empty list
      return [];
    }
  }

  /// Update status pengaduan by admin
  Future<void> updateStatusPengaduan({
    required int idLaporan,
    required String newStatus,
  }) async {
    print('=== UPDATE STATUS PENGADUAN ===');
    print('ID Laporan: $idLaporan');
    print('New Status: $newStatus');

    await _client
        .from('pengaduan')
        .update({'status': newStatus})
        .eq('id_laporan', idLaporan);

    print('Status updated successfully');
  }
}
