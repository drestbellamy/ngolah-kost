import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for peraturan (rules) operations
/// Handles CRUD operations for kost rules including ordering management
class PeraturanRepository extends BaseRepository {
  @override
  String get repositoryName => 'PeraturanRepository';

  /// Get all peraturan with optional filters
  ///
  /// Uses graceful degradation pattern with multiple select attempts
  /// to handle different database schema versions (judul/isi vs judul/deskripsi)
  ///
  /// Parameters:
  /// - [kostId]: Optional filter by kost ID
  /// - [isActive]: Optional filter by active status
  ///
  /// Returns list of peraturan maps ordered by urutan (if available) or created_at
  ///
  /// Throws [Exception] if all attempts fail
  Future<List<Map<String, dynamic>>> getPeraturanList({
    String? kostId,
    bool? isActive,
  }) async {
    logDebug('Getting peraturan list', {
      'kostId': kostId,
      'isActive': isActive,
    });

    final attempts = <({String select, String kostField, String? orderField})>[
      (
        select: 'id, kost_id, judul, isi, urutan, is_active, created_at',
        kostField: 'kost_id',
        orderField: 'urutan',
      ),
      (
        select: 'id, id_kost, judul, isi, urutan, is_active, created_at',
        kostField: 'id_kost',
        orderField: 'urutan',
      ),
      (
        select: 'id, kost_id, judul, deskripsi, urutan, is_active, created_at',
        kostField: 'kost_id',
        orderField: 'urutan',
      ),
      (
        select: 'id, id_kost, judul, deskripsi, urutan, is_active, created_at',
        kostField: 'id_kost',
        orderField: 'urutan',
      ),
      (
        select: 'id, kost_id, judul, isi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, judul, isi, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, judul, deskripsi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, judul, deskripsi, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (select: '*', kostField: 'kost_id', orderField: 'urutan'),
      (select: '*', kostField: 'id_kost', orderField: 'urutan'),
      (select: '*', kostField: 'kost_id', orderField: 'created_at'),
      (select: '*', kostField: 'id_kost', orderField: 'created_at'),
      (select: '*', kostField: 'kost_id', orderField: null),
      (select: '*', kostField: 'id_kost', orderField: null),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from(RepositoryConstants.peraturanTable)
            .select(attempt.select);

        // Apply kost filter if provided
        if (kostId != null && kostId.trim().isNotEmpty) {
          query = query.eq(attempt.kostField, kostId.trim());
        }

        // Apply isActive filter if provided
        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }

        // Apply ordering if available
        if (attempt.orderField != null) {
          query = query.order(attempt.orderField!, ascending: false);
        }

        final raw = await query;
        final result = raw
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        logInfo('Successfully retrieved peraturan list', {
          'count': result.length,
          'select': attempt.select,
        });

        return result;
      } catch (e) {
        logDebug('Attempt failed, trying next shape', {
          'select': attempt.select,
          'error': e.toString(),
        });
        // Try next shape in case schema differs between environments
      }
    }

    logError('All attempts to get peraturan list failed');
    throw Exception('Gagal memuat data peraturan');
  }

  /// Get peraturan by ID
  ///
  /// Parameters:
  /// - [id]: Peraturan ID
  ///
  /// Returns peraturan map or null if not found
  ///
  /// Throws [Exception] on validation error or database error
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
  ///
  /// Uses graceful degradation pattern with multiple payload attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [judul]: Rule title (required)
  /// - [isi]: Rule content (required)
  /// - [urutan]: Display order (defaults to 0)
  /// - [isActive]: Active status (defaults to true)
  ///
  /// Returns the created peraturan ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<String> createPeraturan({
    required String kostId,
    required String judul,
    required String isi,
    int urutan = 0,
    bool isActive = true,
  }) async {
    // Validation
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();

    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    logDebug('Creating peraturan', {
      'kostId': kostId,
      'judul': cleanJudul,
      'urutan': urutan,
    });

    final nowIso = DateTime.now().toIso8601String();

    final payloads = <Map<String, dynamic>>[
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'urutan': urutan,
        'is_active': isActive,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'urutan': urutan,
        'is_active': isActive,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'urutan': urutan,
        'is_active': isActive,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'urutan': urutan,
        'is_active': isActive,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'created_at': nowIso,
      },
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        final result = await supabase
            .from(RepositoryConstants.peraturanTable)
            .insert(payload)
            .select('id')
            .single();

        final id = result['id'] as String;

        logInfo('Successfully created peraturan', {
          'id': id,
          'judul': cleanJudul,
        });

        return id;
      } on PostgrestException catch (e) {
        lastError = e;
        logDebug('Payload attempt failed, trying next', {
          'payload': payload.keys.toList(),
          'error': e.message,
        });
      }
    }

    if (lastError != null) {
      final errorMsg = formatPostgrestError(lastError);
      logError('Failed to create peraturan', {'error': errorMsg});
      throw Exception('Gagal menambahkan peraturan: $errorMsg');
    }

    throw Exception('Gagal menambahkan peraturan');
  }

  /// Update existing peraturan
  ///
  /// Uses graceful degradation pattern with multiple payload attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [id]: Peraturan ID (required)
  /// - [judul]: Rule title (required)
  /// - [isi]: Rule content (required)
  /// - [urutan]: Display order (optional)
  /// - [isActive]: Active status (optional)
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updatePeraturan({
    required String id,
    required String judul,
    required String isi,
    int? urutan,
    bool? isActive,
  }) async {
    // Validation
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();

    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    logDebug('Updating peraturan', {
      'id': id,
      'judul': cleanJudul,
      'urutan': urutan,
    });

    final payloads = <Map<String, dynamic>>[
      {
        'judul': cleanJudul,
        'isi': cleanIsi,
        if (urutan != null) 'urutan': urutan,
        if (isActive != null) 'is_active': isActive,
      },
      {
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        if (urutan != null) 'urutan': urutan,
        if (isActive != null) 'is_active': isActive,
      },
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase
            .from(RepositoryConstants.peraturanTable)
            .update(payload)
            .eq('id', id.trim());

        logInfo('Successfully updated peraturan', {
          'id': id,
          'judul': cleanJudul,
        });

        return;
      } on PostgrestException catch (e) {
        lastError = e;
        logDebug('Payload attempt failed, trying next', {
          'payload': payload.keys.toList(),
          'error': e.message,
        });
      }
    }

    if (lastError != null) {
      final errorMsg = formatPostgrestError(lastError);
      logError('Failed to update peraturan', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memperbarui peraturan: $errorMsg');
    }

    throw Exception('Gagal memperbarui peraturan');
  }

  /// Delete peraturan
  ///
  /// Parameters:
  /// - [id]: Peraturan ID
  ///
  /// Throws [Exception] on validation error or database error
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
  ///
  /// Parameters:
  /// - [id]: Peraturan ID
  /// - [isActive]: New active status
  ///
  /// Throws [Exception] on validation error or database error
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
  ///
  /// Accepts a list of peraturan IDs in the desired order and updates
  /// their urutan field accordingly (starting from 1)
  ///
  /// Parameters:
  /// - [orderedIds]: List of peraturan IDs in desired display order
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> reorderPeraturan(List<String> orderedIds) async {
    if (orderedIds.isEmpty) {
      throw Exception('Daftar ID peraturan tidak boleh kosong');
    }

    logDebug('Reordering peraturan', {
      'count': orderedIds.length,
      'ids': orderedIds,
    });

    try {
      // Update each peraturan with its new urutan value
      for (int i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i].trim();
        if (id.isEmpty) continue;

        final urutan = i + 1; // Start from 1

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
  ///
  /// Parameters:
  /// - [kostId]: Kost ID
  ///
  /// Returns count of peraturan for the specified kost
  Future<int> getPeraturanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) {
      logWarning('Empty kostId provided to getPeraturanCountByKostId');
      return 0;
    }

    logDebug('Getting peraturan count by kost ID', {'kostId': kostId});

    final attempts = <String>['kost_id', 'id_kost'];

    for (final kostField in attempts) {
      try {
        final raw = await supabase
            .from(RepositoryConstants.peraturanTable)
            .select('id')
            .eq(kostField, kostId.trim());

        final count = raw.length;
        logInfo('Successfully retrieved peraturan count', {
          'kostId': kostId,
          'count': count,
        });
        return count;
      } catch (e) {
        logDebug('Attempt failed, trying next field', {
          'kostField': kostField,
          'error': e.toString(),
        });
        // Try next field variation
      }
    }

    logWarning('All attempts to get peraturan count failed', {
      'kostId': kostId,
    });
    return 0;
  }
}
