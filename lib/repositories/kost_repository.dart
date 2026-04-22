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
}
