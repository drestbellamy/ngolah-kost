import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';
import 'base/helper_utilities.dart';
import 'storage_repository.dart';

/// Repository for payment method operations
/// Handles CRUD operations for metode pembayaran including QRIS image upload
class MetodePembayaranRepository extends BaseRepository {
  final StorageRepository _storageRepository;

  MetodePembayaranRepository({required StorageRepository storageRepository})
    : _storageRepository = storageRepository;

  @override
  String get repositoryName => 'MetodePembayaranRepository';

  /// Get all metode pembayaran with optional kost filter
  ///
  /// Uses graceful degradation pattern with multiple select attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [kostId]: Optional filter by kost ID
  ///
  /// Returns list of metode pembayaran maps
  ///
  /// Throws [Exception] if all attempts fail
  Future<List<Map<String, dynamic>>> getMetodePembayaranList({
    String? kostId,
  }) async {
    logDebug('Getting metode pembayaran list', {'kostId': kostId});

    final attempts = <({String select, bool orderByCreatedAt})>[
      (
        select:
            'id, kost_id, tipe, nama, no_rek, atas_nama, qr_image, is_active, created_at, kost:kost_id(id, nama_kost)',
        orderByCreatedAt: true,
      ),
      (
        select:
            'id, kost_id, tipe, nama, no_rek, atas_nama, qr_image, is_active, created_at',
        orderByCreatedAt: true,
      ),
      (select: '*', orderByCreatedAt: true),
      (select: '*', orderByCreatedAt: false),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from(RepositoryConstants.metodePembayaranTable)
            .select(attempt.select);

        // Apply kost filter if provided
        if (kostId != null && kostId.trim().isNotEmpty) {
          query = query.eq('kost_id', kostId.trim());
        }

        if (attempt.orderByCreatedAt) {
          query = query.order('created_at', ascending: false);
        }

        final raw = await query;
        if (raw is! List) {
          logWarning('Query returned non-list result', {
            'select': attempt.select,
          });
          continue;
        }

        final result = raw
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        logInfo('Successfully retrieved metode pembayaran list', {
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

    logError('All attempts to get metode pembayaran list failed');
    throw Exception('Gagal memuat metode pembayaran');
  }

  /// Get metode pembayaran by ID
  ///
  /// Parameters:
  /// - [id]: Metode pembayaran ID
  ///
  /// Returns metode pembayaran map or null if not found
  ///
  /// Throws [Exception] on database error
  Future<Map<String, dynamic>?> getMetodePembayaranById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    logDebug('Getting metode pembayaran by ID', {'id': id});

    try {
      final result = await supabase
          .from(RepositoryConstants.metodePembayaranTable)
          .select(
            'id, kost_id, tipe, nama, no_rek, atas_nama, qr_image, is_active, created_at',
          )
          .eq('id', id.trim())
          .maybeSingle();

      if (result == null) {
        logInfo('Metode pembayaran not found', {'id': id});
        return null;
      }

      logInfo('Successfully retrieved metode pembayaran', {'id': id});
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get metode pembayaran by ID', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal memuat metode pembayaran: $errorMsg');
    }
  }

  /// Create new metode pembayaran
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [tipe]: Payment type (transfer_bank, qris, tunai) (required)
  /// - [nama]: Payment method name (required)
  /// - [noRek]: Account number (optional, defaults to '-')
  /// - [atasNama]: Account holder name (optional)
  /// - [qrImage]: QR code image URL (optional)
  /// - [isActive]: Active status (defaults to true)
  ///
  /// Returns the created metode pembayaran ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<String> createMetodePembayaran({
    required String kostId,
    required String tipe,
    required String nama,
    String? noRek,
    String? atasNama,
    String? qrImage,
    bool isActive = true,
  }) async {
    // Validation
    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama metode pembayaran wajib diisi');
    }

    final normalizedTipe = HelperUtilities.normalizeMetodePembayaranTipe(tipe);

    logDebug('Creating metode pembayaran', {
      'kostId': kostId,
      'tipe': normalizedTipe,
      'nama': cleanNama,
    });

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'tipe': normalizedTipe,
      'nama': cleanNama,
      'no_rek': (noRek ?? '').trim().isEmpty ? '-' : noRek!.trim(),
      'atas_nama': (atasNama ?? '').trim().isEmpty ? null : atasNama!.trim(),
      'qr_image': (qrImage ?? '').trim().isEmpty ? null : qrImage!.trim(),
      'is_active': isActive,
    };

    try {
      final result = await supabase
          .from(RepositoryConstants.metodePembayaranTable)
          .insert(payload)
          .select('id')
          .single();

      final id = result['id'] as String;

      logInfo('Successfully created metode pembayaran', {
        'id': id,
        'nama': cleanNama,
      });

      return id;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create metode pembayaran', {
        'error': errorMsg,
        'payload': payload,
      });
      throw Exception('Gagal membuat metode pembayaran: $errorMsg');
    }
  }

  /// Update existing metode pembayaran
  ///
  /// Parameters:
  /// - [id]: Metode pembayaran ID (required)
  /// - [kostId]: Kost ID (required)
  /// - [tipe]: Payment type (required)
  /// - [nama]: Payment method name (required)
  /// - [noRek]: Account number (optional)
  /// - [atasNama]: Account holder name (optional)
  /// - [qrImage]: QR code image URL (optional)
  /// - [isActive]: Active status (optional)
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updateMetodePembayaran({
    required String id,
    required String kostId,
    required String tipe,
    required String nama,
    String? noRek,
    String? atasNama,
    String? qrImage,
    bool? isActive,
  }) async {
    // Validation
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama metode pembayaran wajib diisi');
    }

    final normalizedTipe = HelperUtilities.normalizeMetodePembayaranTipe(tipe);

    logDebug('Updating metode pembayaran', {
      'id': id,
      'kostId': kostId,
      'tipe': normalizedTipe,
      'nama': cleanNama,
    });

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'tipe': normalizedTipe,
      'nama': cleanNama,
      'no_rek': (noRek ?? '').trim().isEmpty ? '-' : noRek!.trim(),
      'atas_nama': (atasNama ?? '').trim().isEmpty ? null : atasNama!.trim(),
      'qr_image': (qrImage ?? '').trim().isEmpty ? null : qrImage!.trim(),
    };

    if (isActive != null) {
      payload['is_active'] = isActive;
    }

    try {
      await supabase
          .from(RepositoryConstants.metodePembayaranTable)
          .update(payload)
          .eq('id', id.trim());

      logInfo('Successfully updated metode pembayaran', {
        'id': id,
        'nama': cleanNama,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update metode pembayaran', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal mengupdate metode pembayaran: $errorMsg');
    }
  }

  /// Delete metode pembayaran
  ///
  /// Parameters:
  /// - [id]: Metode pembayaran ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> deleteMetodePembayaran(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    logDebug('Deleting metode pembayaran', {'id': id});

    try {
      await supabase
          .from(RepositoryConstants.metodePembayaranTable)
          .delete()
          .eq('id', id.trim());

      logInfo('Successfully deleted metode pembayaran', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete metode pembayaran', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal menghapus metode pembayaran: $errorMsg');
    }
  }

  /// Update metode pembayaran status
  ///
  /// Parameters:
  /// - [id]: Metode pembayaran ID
  /// - [isActive]: New active status
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updateMetodePembayaranStatus({
    required String id,
    required bool isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    logDebug('Updating metode pembayaran status', {
      'id': id,
      'isActive': isActive,
    });

    try {
      await supabase
          .from(RepositoryConstants.metodePembayaranTable)
          .update({'is_active': isActive})
          .eq('id', id.trim());

      logInfo('Successfully updated metode pembayaran status', {
        'id': id,
        'isActive': isActive,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update metode pembayaran status', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal mengupdate status metode pembayaran: $errorMsg');
    }
  }

  /// Upload QRIS image with storage integration
  ///
  /// Delegates to StorageRepository for actual upload operation
  ///
  /// Parameters:
  /// - [imageBytes]: Image file bytes
  /// - [fileExt]: File extension (jpg, png, etc.)
  /// - [kostId]: Kost ID for organizing files
  /// - [namaMetode]: Payment method name for file naming
  ///
  /// Returns public URL of uploaded image
  ///
  /// Throws [Exception] on validation error or upload error
  Future<String> uploadQrisImage({
    required Uint8List imageBytes,
    required String fileExt,
    required String kostId,
    required String namaMetode,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('File QRIS tidak valid');
    }

    logDebug('Uploading QRIS image', {
      'kostId': kostId,
      'namaMetode': namaMetode,
      'fileExt': fileExt,
      'size': imageBytes.length,
    });

    try {
      final publicUrl = await _storageRepository
          .uploadMetodePembayaranQrisImage(
            imageBytes: imageBytes,
            fileExt: fileExt,
            kostId: kostId,
            namaMetode: namaMetode,
          );

      logInfo('Successfully uploaded QRIS image', {
        'kostId': kostId,
        'namaMetode': namaMetode,
        'url': publicUrl,
      });

      return publicUrl;
    } catch (e) {
      logError('Failed to upload QRIS image', {
        'kostId': kostId,
        'namaMetode': namaMetode,
        'error': e.toString(),
      });
      throw Exception('Gagal mengupload gambar QRIS: ${e.toString()}');
    }
  }
}
