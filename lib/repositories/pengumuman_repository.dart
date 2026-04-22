import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for announcement (pengumuman) operations
/// Handles CRUD operations for pengumuman with graceful degradation
/// for different database schema versions
class PengumumanRepository extends BaseRepository {
  @override
  String get repositoryName => 'PengumumanRepository';

  /// Get all pengumuman with optional filters
  ///
  /// Uses graceful degradation pattern with multiple select attempts
  /// to handle different database schema versions (judul/isi vs judul/deskripsi)
  ///
  /// Parameters:
  /// - [kostId]: Optional filter by kost ID
  /// - [isActive]: Optional filter by active status
  ///
  /// Returns list of pengumuman maps
  ///
  /// Throws [Exception] if all attempts fail
  Future<List<Map<String, dynamic>>> getPengumumanList({
    String? kostId,
    bool? isActive,
  }) async {
    logDebug('Getting pengumuman list', {
      'kostId': kostId,
      'isActive': isActive,
    });

    final attempts = <({String select, String kostField, String? orderField})>[
      (
        select:
            'id, kost_id, judul, isi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select:
            'id, id_kost, judul, isi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select:
            'id, kost_id, judul, deskripsi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select:
            'id, id_kost, judul, deskripsi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select: 'id, kost_id, judul, isi, tanggal, is_active',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select: 'id, id_kost, judul, isi, tanggal, is_active',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select: 'id, kost_id, judul, deskripsi, tanggal, is_active',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select: 'id, id_kost, judul, deskripsi, tanggal, is_active',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select: 'id, kost_id, judul, isi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, title, description, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, title, description, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, title, content, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, title, content, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (select: '*', kostField: 'kost_id', orderField: 'tanggal'),
      (select: '*', kostField: 'id_kost', orderField: 'tanggal'),
      (select: '*', kostField: 'kost_id', orderField: 'created_at'),
      (select: '*', kostField: 'id_kost', orderField: 'created_at'),
      (select: '*', kostField: 'kost_id', orderField: null),
      (select: '*', kostField: 'id_kost', orderField: null),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from(RepositoryConstants.pengumumanTable)
            .select(attempt.select);

        // Apply kost filter if provided
        if (kostId != null && kostId.trim().isNotEmpty) {
          query = query.eq(attempt.kostField, kostId.trim());
        }

        // Apply isActive filter if provided
        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }

        if (attempt.orderField != null) {
          query = query.order(attempt.orderField!, ascending: false);
        }

        final raw = await query;
        final result = raw
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        logInfo('Successfully retrieved pengumuman list', {
          'count': result.length,
          'select': attempt.select,
        });

        return result;
      } catch (e) {
        logDebug('Attempt failed, trying next shape', {
          'select': attempt.select,
          'error': e.toString(),
        });
        // Try next schema/column variation
      }
    }

    logError('All attempts to get pengumuman list failed');
    throw Exception('Gagal memuat data pengumuman');
  }

  /// Get pengumuman by ID
  ///
  /// Parameters:
  /// - [id]: Pengumuman ID
  ///
  /// Returns pengumuman map or null if not found
  ///
  /// Throws [Exception] on validation error or database error
  Future<Map<String, dynamic>?> getPengumumanById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    logDebug('Getting pengumuman by ID', {'id': id});

    final attempts = <String>[
      'id, kost_id, judul, isi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
      'id, id_kost, judul, isi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
      'id, kost_id, judul, deskripsi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
      'id, id_kost, judul, deskripsi, tanggal, tanggal_mulai, tanggal_selesai, is_active, created_at',
      'id, kost_id, judul, isi, tanggal, is_active',
      'id, kost_id, judul, deskripsi, tanggal, is_active',
      '*',
    ];

    for (final select in attempts) {
      try {
        final result = await supabase
            .from(RepositoryConstants.pengumumanTable)
            .select(select)
            .eq('id', id.trim())
            .maybeSingle();

        if (result == null) {
          logInfo('Pengumuman not found', {'id': id});
          return null;
        }

        logInfo('Successfully retrieved pengumuman', {'id': id});
        return Map<String, dynamic>.from(result);
      } catch (e) {
        logDebug('Attempt failed, trying next shape', {
          'select': select,
          'error': e.toString(),
        });
        // Try next schema variation
      }
    }

    logError('All attempts to get pengumuman by ID failed', {'id': id});
    throw Exception('Gagal memuat pengumuman');
  }

  /// Create new pengumuman
  ///
  /// Uses graceful degradation pattern with multiple payload attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [judul]: Announcement title (required)
  /// - [isi]: Announcement content (required)
  /// - [tanggalMulai]: Start date for announcement validity (optional)
  /// - [tanggalSelesai]: End date for announcement validity (optional)
  /// - [isActive]: Active status (defaults to true)
  ///
  /// Returns the created pengumuman ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<String> createPengumuman({
    required String kostId,
    required String judul,
    required String isi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool isActive = true,
  }) async {
    // Validation
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();
    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi pengumuman wajib diisi');
    }

    logDebug('Creating pengumuman', {
      'kostId': kostId,
      'judul': cleanJudul,
      'hasDateRange': tanggalMulai != null && tanggalSelesai != null,
    });

    final nowIso = DateTime.now().toIso8601String();
    final tanggalMulaiIso = tanggalMulai?.toIso8601String();
    final tanggalSelesaiIso = tanggalSelesai?.toIso8601String();

    // Build payloads with graceful degradation
    final payloads = <Map<String, dynamic>>[
      // With date range and is_active (kost_id, isi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        'is_active': isActive,
      },
      // With date range and is_active (id_kost, isi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        'is_active': isActive,
      },
      // With date range and is_active (kost_id, deskripsi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        'is_active': isActive,
      },
      // With date range and is_active (id_kost, deskripsi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        'is_active': isActive,
      },
      // Without date range but with is_active (kost_id, isi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
        'is_active': isActive,
      },
      // Without date range but with is_active (id_kost, isi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
        'is_active': isActive,
      },
      // Without date range but with is_active (kost_id, deskripsi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
        'is_active': isActive,
      },
      // Without date range but with is_active (id_kost, deskripsi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
        'is_active': isActive,
      },
      // Basic schema (kost_id, isi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
      },
      // Basic schema (id_kost, isi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal': nowIso,
      },
      // Basic schema (kost_id, deskripsi)
      {
        'kost_id': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
      },
      // Basic schema (id_kost, deskripsi)
      {
        'id_kost': kostId.trim(),
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal': nowIso,
      },
      // English column names (kost_id, description)
      {
        'kost_id': kostId.trim(),
        'title': cleanJudul,
        'description': cleanIsi,
        'tanggal': nowIso,
      },
      // English column names (id_kost, description)
      {
        'id_kost': kostId.trim(),
        'title': cleanJudul,
        'description': cleanIsi,
        'tanggal': nowIso,
      },
      // English column names (kost_id, content)
      {
        'kost_id': kostId.trim(),
        'title': cleanJudul,
        'content': cleanIsi,
        'tanggal': nowIso,
      },
      // English column names (id_kost, content)
      {
        'id_kost': kostId.trim(),
        'title': cleanJudul,
        'content': cleanIsi,
        'tanggal': nowIso,
      },
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        final result = await supabase
            .from(RepositoryConstants.pengumumanTable)
            .insert(payload)
            .select('id')
            .single();

        final id = result['id'] as String;

        logInfo('Successfully created pengumuman', {
          'id': id,
          'judul': cleanJudul,
        });

        return id;
      } on PostgrestException catch (e) {
        lastError = e;
        logDebug('Insert attempt failed, trying next payload', {
          'error': e.message,
        });
        // Try next payload variation
      }
    }

    if (lastError != null) {
      final errorMsg = formatPostgrestError(lastError);
      logError('Failed to create pengumuman', {'error': errorMsg});
      throw Exception('Gagal menambahkan pengumuman: $errorMsg');
    }

    logError('All attempts to create pengumuman failed');
    throw Exception('Gagal menambahkan pengumuman');
  }

  /// Update existing pengumuman
  ///
  /// Uses graceful degradation pattern with multiple payload attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [id]: Pengumuman ID (required)
  /// - [judul]: Announcement title (required)
  /// - [isi]: Announcement content (required)
  /// - [tanggalMulai]: Start date for announcement validity (optional)
  /// - [tanggalSelesai]: End date for announcement validity (optional)
  /// - [isActive]: Active status (optional)
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updatePengumuman({
    required String id,
    required String judul,
    required String isi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool? isActive,
  }) async {
    // Validation
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    final cleanJudul = judul.trim();
    final cleanIsi = isi.trim();
    if (cleanJudul.isEmpty || cleanIsi.isEmpty) {
      throw Exception('Judul dan isi pengumuman wajib diisi');
    }

    logDebug('Updating pengumuman', {
      'id': id,
      'judul': cleanJudul,
      'hasDateRange': tanggalMulai != null && tanggalSelesai != null,
    });

    final tanggalMulaiIso = tanggalMulai?.toIso8601String();
    final tanggalSelesaiIso = tanggalSelesai?.toIso8601String();

    // Build payloads with graceful degradation
    final payloads = <Map<String, dynamic>>[
      // With date range and is_active (isi)
      {
        'judul': cleanJudul,
        'isi': cleanIsi,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        if (isActive != null) 'is_active': isActive,
      },
      // With date range and is_active (deskripsi)
      {
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        'tanggal_mulai': tanggalMulaiIso,
        'tanggal_selesai': tanggalSelesaiIso,
        if (isActive != null) 'is_active': isActive,
      },
      // Without date range but with is_active (isi)
      {
        'judul': cleanJudul,
        'isi': cleanIsi,
        if (isActive != null) 'is_active': isActive,
      },
      // Without date range but with is_active (deskripsi)
      {
        'judul': cleanJudul,
        'deskripsi': cleanIsi,
        if (isActive != null) 'is_active': isActive,
      },
      // Basic schema (isi)
      {'judul': cleanJudul, 'isi': cleanIsi},
      // Basic schema (deskripsi)
      {'judul': cleanJudul, 'deskripsi': cleanIsi},
      // English column names (description)
      {'title': cleanJudul, 'description': cleanIsi},
      // English column names (content)
      {'title': cleanJudul, 'content': cleanIsi},
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase
            .from(RepositoryConstants.pengumumanTable)
            .update(payload)
            .eq('id', id.trim());

        logInfo('Successfully updated pengumuman', {
          'id': id,
          'judul': cleanJudul,
        });

        return;
      } on PostgrestException catch (e) {
        lastError = e;
        logDebug('Update attempt failed, trying next payload', {
          'error': e.message,
        });
        // Try next payload variation
      }
    }

    if (lastError != null) {
      final errorMsg = formatPostgrestError(lastError);
      logError('Failed to update pengumuman', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memperbarui pengumuman: $errorMsg');
    }

    logError('All attempts to update pengumuman failed', {'id': id});
    throw Exception('Gagal memperbarui pengumuman');
  }

  /// Delete pengumuman
  ///
  /// Parameters:
  /// - [id]: Pengumuman ID
  ///
  /// Throws [Exception] on validation error or database error
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
  ///
  /// Parameters:
  /// - [id]: Pengumuman ID
  /// - [isActive]: New active status
  ///
  /// Throws [Exception] on validation error or database error
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
  ///
  /// Parameters:
  /// - [kostId]: Kost ID
  ///
  /// Returns count of pengumuman for the specified kost
  Future<int> getPengumumanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) {
      logWarning('Empty kostId provided to getPengumumanCountByKostId');
      return 0;
    }

    logDebug('Getting pengumuman count by kost ID', {'kostId': kostId});

    final attempts = <String>['kost_id', 'id_kost'];

    for (final kostField in attempts) {
      try {
        final raw = await supabase
            .from(RepositoryConstants.pengumumanTable)
            .select('id')
            .eq(kostField, kostId.trim());

        final count = raw.length;
        logInfo('Successfully retrieved pengumuman count', {
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

    logWarning('All attempts to get pengumuman count failed', {
      'kostId': kostId,
    });
    return 0;
  }
}
