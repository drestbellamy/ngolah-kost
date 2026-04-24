import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for announcement (pengumuman) operations
/// Handles CRUD operations for pengumuman
class PengumumanRepository extends BaseRepository {
  @override
  String get repositoryName => 'PengumumanRepository';

  /// Get all pengumuman with optional filters
  ///
  /// Parameters:
  /// - [kostId]: Optional filter by kost ID
  /// - [isActive]: Optional filter by active status
  ///
  /// Returns list of pengumuman maps ordered by tanggal
  Future<List<Map<String, dynamic>>> getPengumumanList({
    String? kostId,
    bool? isActive,
  }) async {
    logDebug('Getting pengumuman list', {
      'kostId': kostId,
      'isActive': isActive,
    });

    try {
      var query = supabase
          .from(RepositoryConstants.pengumumanTable)
          .select('*');

      if (kostId != null && kostId.trim().isNotEmpty) {
        query = query.eq('kost_id', kostId.trim());
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('tanggal', ascending: false);

      final result = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      logInfo('Successfully retrieved pengumuman list', {
        'count': result.length,
      });
      return result;
    } catch (e) {
      logError('Failed to get pengumuman list', {'error': e.toString()});

      // Fallback: try without ordering
      try {
        var query = supabase
            .from(RepositoryConstants.pengumumanTable)
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

        logInfo('Retrieved pengumuman list without ordering', {
          'count': result.length,
        });
        return result;
      } catch (e2) {
        logError('All attempts failed', {'error': e2.toString()});
        throw Exception('Gagal memuat data pengumuman');
      }
    }
  }

  /// Get pengumuman by ID
  Future<Map<String, dynamic>?> getPengumumanById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    logDebug('Getting pengumuman by ID', {'id': id});

    try {
      final result = await supabase
          .from(RepositoryConstants.pengumumanTable)
          .select('*')
          .eq('id', id.trim())
          .maybeSingle();

      if (result == null) {
        logInfo('Pengumuman not found', {'id': id});
        return null;
      }

      logInfo('Successfully retrieved pengumuman', {'id': id});
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get pengumuman by ID', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memuat pengumuman: $errorMsg');
    }
  }

  /// Create new pengumuman
  Future<String> createPengumuman({
    required String kostId,
    required String judul,
    required String isi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool isActive = true,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();
    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi pengumuman wajib diisi');
    }

    logDebug('Creating pengumuman', {'kostId': kostId, 'judul': cleanJudul});

    final nowIso = DateTime.now().toIso8601String();

    try {
      final result = await supabase
          .from(RepositoryConstants.pengumumanTable)
          .insert({
            'kost_id': kostId.trim(),
            'judul': cleanJudul,
            'isi': cleanIsi,
            'tanggal': nowIso,
          })
          .select('id')
          .single();

      final id = result['id'] as String;

      logInfo('Successfully created pengumuman', {
        'id': id,
        'judul': cleanJudul,
      });

      return id;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create pengumuman', {'error': errorMsg});
      throw Exception('Gagal menambahkan pengumuman: $errorMsg');
    }
  }

  /// Update existing pengumuman
  Future<void> updatePengumuman({
    required String id,
    required String judul,
    required String isi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool? isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();
    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi pengumuman wajib diisi');
    }

    logDebug('Updating pengumuman', {'id': id, 'judul': cleanJudul});

    try {
      await supabase
          .from(RepositoryConstants.pengumumanTable)
          .update({'judul': cleanJudul, 'isi': cleanIsi})
          .eq('id', id.trim());

      logInfo('Successfully updated pengumuman', {
        'id': id,
        'judul': cleanJudul,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update pengumuman', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memperbarui pengumuman: $errorMsg');
    }
  }

  /// Delete pengumuman
  Future<void> deletePengumuman(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    logDebug('Deleting pengumuman', {'id': id});

    try {
      await supabase
          .from(RepositoryConstants.pengumumanTable)
          .delete()
          .eq('id', id.trim());

      logInfo('Successfully deleted pengumuman', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete pengumuman', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus pengumuman: $errorMsg');
    }
  }

  /// Update pengumuman status
  Future<void> updatePengumumanStatus({
    required String id,
    required bool isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    logDebug('Updating pengumuman status', {'id': id, 'isActive': isActive});

    try {
      await supabase
          .from(RepositoryConstants.pengumumanTable)
          .update({'is_active': isActive})
          .eq('id', id.trim());

      logInfo('Successfully updated pengumuman status', {
        'id': id,
        'isActive': isActive,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update pengumuman status', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal mengupdate status pengumuman: $errorMsg');
    }
  }

  /// Get count of pengumuman by kost ID
  Future<int> getPengumumanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) {
      logWarning('Empty kostId provided to getPengumumanCountByKostId');
      return 0;
    }

    logDebug('Getting pengumuman count by kost ID', {'kostId': kostId});

    try {
      final response = await supabase
          .from(RepositoryConstants.pengumumanTable)
          .select('id')
          .eq('kost_id', kostId.trim());

      final count = (response as List).length;
      logInfo('Successfully retrieved pengumuman count', {
        'kostId': kostId,
        'count': count,
      });
      return count;
    } catch (e) {
      logWarning('Failed to get pengumuman count', {
        'kostId': kostId,
        'error': e.toString(),
      });
      return 0;
    }
  }
}
