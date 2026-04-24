import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for peraturan (rules) operations
/// Handles CRUD operations for kost rules
class PeraturanRepository extends BaseRepository {
  @override
  String get repositoryName => 'PeraturanRepository';

  /// Get all peraturan with optional filters
  ///
  /// Parameters:
  /// - [kostId]: Optional filter by kost ID
  /// - [isActive]: Optional filter by active status
  ///
  /// Returns list of peraturan maps ordered by created_at
  Future<List<Map<String, dynamic>>> getPeraturanList({
    String? kostId,
    bool? isActive,
  }) async {
    logDebug('Getting peraturan list', {
      'kostId': kostId,
      'isActive': isActive,
    });

    try {
      var query = supabase.from(RepositoryConstants.peraturanTable).select('*');

      if (kostId != null && kostId.trim().isNotEmpty) {
        query = query.eq('kost_id', kostId.trim());
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('created_at', ascending: false);

      final result = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      logInfo('Successfully retrieved peraturan list', {
        'count': result.length,
      });
      return result;
    } catch (e) {
      logError('Failed to get peraturan list', {'error': e.toString()});

      // Fallback: try without ordering
      try {
        var query = supabase
            .from(RepositoryConstants.peraturanTable)
            .select('*');

        if (kostId != null && kostId.trim().isNotEmpty) {
          query = query.eq('kost_id', kostId.trim());
        }

        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }

        final response = await query;

        final result = (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        logInfo('Retrieved peraturan list without ordering', {
          'count': result.length,
        });
        return result;
      } catch (e2) {
        logError('All attempts failed', {'error': e2.toString()});
        throw Exception('Gagal memuat data peraturan');
      }
    }
  }

  /// Get peraturan by ID
  Future<Map<String, dynamic>?> getPeraturanById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    logDebug('Getting peraturan by ID', {'id': id});

    try {
      final result = await supabase
          .from(RepositoryConstants.peraturanTable)
          .select('*')
          .eq('id', id.trim())
          .maybeSingle();

      if (result == null) {
        logInfo('Peraturan not found', {'id': id});
        return null;
      }

      logInfo('Successfully retrieved peraturan', {'id': id});
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get peraturan by ID', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memuat peraturan: $errorMsg');
    }
  }

  /// Create new peraturan
  Future<String> createPeraturan({
    required String kostId,
    required String judul,
    required String isi,
    int urutan = 0,
    bool isActive = true,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();

    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    logDebug('Creating peraturan', {'kostId': kostId, 'judul': cleanJudul});

    try {
      final result = await supabase
          .from(RepositoryConstants.peraturanTable)
          .insert({
            'kost_id': kostId.trim(),
            'judul': cleanJudul,
            'isi': cleanIsi,
          })
          .select('id')
          .single();

      final id = result['id'] as String;

      logInfo('Successfully created peraturan', {
        'id': id,
        'judul': cleanJudul,
      });

      return id;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create peraturan', {'error': errorMsg});
      throw Exception('Gagal menambahkan peraturan: $errorMsg');
    }
  }

  /// Update existing peraturan
  Future<void> updatePeraturan({
    required String id,
    required String judul,
    required String isi,
    int? urutan,
    bool? isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();

    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    logDebug('Updating peraturan', {'id': id, 'judul': cleanJudul});

    try {
      await supabase
          .from(RepositoryConstants.peraturanTable)
          .update({'judul': cleanJudul, 'isi': cleanIsi})
          .eq('id', id.trim());

      logInfo('Successfully updated peraturan', {
        'id': id,
        'judul': cleanJudul,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update peraturan', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memperbarui peraturan: $errorMsg');
    }
  }

  /// Delete peraturan
  Future<void> deletePeraturan(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    logDebug('Deleting peraturan', {'id': id});

    try {
      await supabase
          .from(RepositoryConstants.peraturanTable)
          .delete()
          .eq('id', id.trim());

      logInfo('Successfully deleted peraturan', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete peraturan', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus peraturan: $errorMsg');
    }
  }

  /// Update peraturan status
  Future<void> updatePeraturanStatus({
    required String id,
    required bool isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    logDebug('Updating peraturan status', {'id': id, 'isActive': isActive});

    try {
      await supabase
          .from(RepositoryConstants.peraturanTable)
          .update({'is_active': isActive})
          .eq('id', id.trim());

      logInfo('Successfully updated peraturan status', {
        'id': id,
        'isActive': isActive,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update peraturan status', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal mengupdate status peraturan: $errorMsg');
    }
  }

  /// Reorder peraturan by updating urutan field
  Future<void> reorderPeraturan(List<String> orderedIds) async {
    if (orderedIds.isEmpty) {
      throw Exception('Daftar ID peraturan tidak boleh kosong');
    }

    logDebug('Reordering peraturan', {
      'count': orderedIds.length,
      'ids': orderedIds,
    });

    try {
      for (int i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i].trim();
        if (id.isEmpty) continue;

        final urutan = i + 1;

        await supabase
            .from(RepositoryConstants.peraturanTable)
            .update({'urutan': urutan})
            .eq('id', id);

        logDebug('Updated peraturan order', {'id': id, 'urutan': urutan});
      }

      logInfo('Successfully reordered peraturan', {'count': orderedIds.length});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to reorder peraturan', {'error': errorMsg});
      throw Exception('Gagal mengatur ulang urutan peraturan: $errorMsg');
    }
  }

  /// Get count of peraturan by kost ID
  Future<int> getPeraturanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) {
      logWarning('Empty kostId provided to getPeraturanCountByKostId');
      return 0;
    }

    logDebug('Getting peraturan count by kost ID', {'kostId': kostId});

    try {
      final response = await supabase
          .from(RepositoryConstants.peraturanTable)
          .select('id')
          .eq('kost_id', kostId.trim());

      final count = (response as List).length;
      logInfo('Successfully retrieved peraturan count', {
        'kostId': kostId,
        'count': count,
      });
      return count;
    } catch (e) {
      logWarning('Failed to get peraturan count', {
        'kostId': kostId,
        'error': e.toString(),
      });
      return 0;
    }
  }
}
