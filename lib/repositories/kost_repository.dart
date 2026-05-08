import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/kost/models/kost_model.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for Kost CRUD operations
class KostRepository extends BaseRepository {
  @override
  String get repositoryName => 'KostRepository';

  /// Get list of all kost
  Future<List<KostModel>> getKostList() async {
    logDebug('Getting kost list');

    try {
      final List<dynamic> response = await supabase
          .from(RepositoryConstants.kostTable)
          .select(
            'id, nama_kost, alamat, total_kamar, latitude, longitude, created_at',
          )
          .order('created_at', ascending: false);

      final kostList = response
          .map((item) => KostModel.fromMap(item as Map<String, dynamic>))
          .toList();

      logInfo('Successfully retrieved kost list', {'count': kostList.length});
      return kostList;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get kost list', {'error': errorMsg});
      rethrow;
    }
  }

  /// Create new kost
  Future<void> createKost({
    required String namaKost,
    required String alamat,
    required int totalKamar,
    double? latitude,
    double? longitude,
  }) async {
    logDebug('Creating kost', {'namaKost': namaKost, 'totalKamar': totalKamar});

    try {
      await supabase.from(RepositoryConstants.kostTable).insert({
        'nama_kost': namaKost,
        'alamat': alamat,
        'total_kamar': totalKamar,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      logInfo('Successfully created kost', {'namaKost': namaKost});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create kost', {
        'namaKost': namaKost,
        'error': errorMsg,
      });
      throw Exception('Gagal membuat kost: $errorMsg');
    }
  }

  /// Update existing kost
  Future<void> updateKost({
    required String id,
    required String namaKost,
    required String alamat,
    required int totalKamar,
    double? latitude,
    double? longitude,
  }) async {
    logDebug('Updating kost', {'id': id, 'namaKost': namaKost});

    try {
      await supabase
          .from(RepositoryConstants.kostTable)
          .update({
            'nama_kost': namaKost,
            'alamat': alamat,
            'total_kamar': totalKamar,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          })
          .eq('id', id);

      logInfo('Successfully updated kost', {'id': id, 'namaKost': namaKost});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update kost', {'id': id, 'error': errorMsg});
      throw Exception('Gagal mengupdate kost: $errorMsg');
    }
  }

  /// Delete kost by ID
  Future<void> deleteKost(String id) async {
    logDebug('Deleting kost', {'id': id});

    try {
      await supabase.from(RepositoryConstants.kostTable).delete().eq('id', id);

      logInfo('Successfully deleted kost', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete kost', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus kost: $errorMsg');
    }
  }

  /// Get kost list with room availability status
  ///
  /// Returns list of kost with calculated availability status based on room occupancy.
  /// Each kost includes:
  /// - available_rooms: Number of rooms that still have capacity
  /// - occupied_rooms: Number of rooms that are full
  /// - total_penghuni: Total number of active penghuni across all rooms
  /// - availability_status: Overall status (available/limited/full/unavailable)
  Future<List<Map<String, dynamic>>> getKostListWithStatus() async {
    logDebug('Getting kost list with status');

    try {
      // Get all kost with their rooms, kapasitas, and penghuni count
      final response = await supabase
          .from(RepositoryConstants.kostTable)
          .select('''
        id,
        nama_kost,
        alamat,
        total_kamar,
        latitude,
        longitude,
        created_at,
        kamar(
          id,
          kapasitas,
          penghuni(id)
        )
      ''')
          .order('created_at', ascending: false);

      // Calculate availability status for each kost
      final kostListWithStatus = <Map<String, dynamic>>[];

      for (final kostData in response) {
        final kost = Map<String, dynamic>.from(kostData);
        final kamarList = kost['kamar'] as List?;

        if (kamarList == null || kamarList.isEmpty) {
          // No rooms - mark as unavailable
          kost['availability_status'] = 'unavailable';
          kost['available_rooms'] = 0;
          kost['occupied_rooms'] = 0;
          kost['total_penghuni'] = 0;
        } else {
          int availableCount = 0;
          int occupiedCount = 0;
          int totalPenghuni = 0;

          for (final kamarData in kamarList) {
            final kamar = kamarData as Map<String, dynamic>;
            final penghuniList = kamar['penghuni'] as List?;
            final penghuniCount = penghuniList?.length ?? 0;

            // Add to total penghuni count
            totalPenghuni += penghuniCount;

            // Get kapasitas, default to 1 if not set
            final kapasitas = kamar['kapasitas'] is int
                ? kamar['kapasitas'] as int
                : int.tryParse(kamar['kapasitas']?.toString() ?? '1') ?? 1;

            // Check if room is full by comparing penghuni count with kapasitas
            if (penghuniCount >= kapasitas) {
              occupiedCount++;
            } else {
              availableCount++;
            }
          }

          kost['available_rooms'] = availableCount;
          kost['occupied_rooms'] = occupiedCount;
          kost['total_penghuni'] = totalPenghuni;

          // Determine availability status
          if (availableCount == 0) {
            kost['availability_status'] = 'full';
          } else if (availableCount < kamarList.length / 2) {
            kost['availability_status'] = 'limited';
          } else {
            kost['availability_status'] = 'available';
          }
        }

        // Remove nested kamar data to keep response clean
        kost.remove('kamar');
        kostListWithStatus.add(kost);
      }

      logInfo('Successfully retrieved kost list with status', {
        'count': kostListWithStatus.length,
      });
      return kostListWithStatus;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get kost list with status', {'error': errorMsg});
      throw Exception('Gagal mengambil data kost: $errorMsg');
    } catch (e) {
      logError('Unexpected error getting kost list with status', {
        'error': e.toString(),
      });
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
