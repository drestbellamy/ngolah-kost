import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for Kamar (Room) CRUD operations
class KamarRepository extends BaseRepository {
  @override
  String get repositoryName => 'KamarRepository';

  /// Get kamar list by kost ID
  Future<List<Map<String, dynamic>>> getKamarByKostId(String kostId) async {
    logDebug('Getting kamar list', {'kostId': kostId});

    try {
      final List<dynamic> response = await supabase
          .from(RepositoryConstants.kamarTable)
          .select('id, kost_id, no_kamar, harga, kapasitas, status, created_at')
          .eq('kost_id', kostId)
          .order('created_at', ascending: false);

      final kamarList = response
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      logInfo('Successfully retrieved kamar list', {
        'kostId': kostId,
        'count': kamarList.length,
      });

      return kamarList;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get kamar list', {
        'kostId': kostId,
        'error': errorMsg,
      });
      rethrow;
    }
  }

  /// Create new kamar
  Future<void> createKamar({
    required String kostId,
    required String noKamar,
    required int harga,
    required int kapasitas,
    String status = 'kosong',
  }) async {
    logDebug('Creating kamar', {
      'kostId': kostId,
      'noKamar': noKamar,
      'harga': harga,
      'kapasitas': kapasitas,
    });

    try {
      await supabase.from(RepositoryConstants.kamarTable).insert({
        'kost_id': kostId,
        'no_kamar': noKamar,
        'harga': harga,
        'kapasitas': kapasitas,
        'status': status,
      });

      logInfo('Successfully created kamar', {
        'kostId': kostId,
        'noKamar': noKamar,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create kamar', {
        'kostId': kostId,
        'noKamar': noKamar,
        'error': errorMsg,
      });
      throw Exception('Gagal membuat kamar: $errorMsg');
    }
  }

  /// Update existing kamar
  Future<void> updateKamar({
    required String id,
    required String noKamar,
    required int harga,
    required int kapasitas,
    required String status,
  }) async {
    logDebug('Updating kamar', {
      'id': id,
      'noKamar': noKamar,
      'status': status,
    });

    try {
      await supabase
          .from(RepositoryConstants.kamarTable)
          .update({
            'no_kamar': noKamar,
            'harga': harga,
            'kapasitas': kapasitas,
            'status': status,
          })
          .eq('id', id);

      logInfo('Successfully updated kamar', {'id': id, 'noKamar': noKamar});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update kamar', {'id': id, 'error': errorMsg});
      throw Exception('Gagal mengupdate kamar: $errorMsg');
    }
  }

  /// Delete kamar by ID
  Future<void> deleteKamar(String id) async {
    logDebug('Deleting kamar', {'id': id});

    try {
      await supabase.from(RepositoryConstants.kamarTable).delete().eq('id', id);

      logInfo('Successfully deleted kamar', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete kamar', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus kamar: $errorMsg');
    }
  }

  /// Update kamar status
  Future<void> updateKamarStatus({
    required String id,
    required String status,
  }) async {
    logDebug('Updating kamar status', {'id': id, 'status': status});

    try {
      await supabase
          .from(RepositoryConstants.kamarTable)
          .update({'status': status})
          .eq('id', id);

      logInfo('Successfully updated kamar status', {
        'id': id,
        'status': status,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update kamar status', {'id': id, 'error': errorMsg});
      throw Exception('Gagal mengupdate status kamar: $errorMsg');
    }
  }

  /// Helper: Determine kamar status by occupancy
  String kamarStatusByOccupancy(int terisi, int kapasitas) {
    if (terisi <= 0) return RepositoryConstants.statusKosong;
    if (terisi >= kapasitas) return RepositoryConstants.statusPenuh;
    return RepositoryConstants.statusTerisi;
  }
}
