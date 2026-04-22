import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';
import 'base/helper_utilities.dart';

/// Repository for file storage operations (upload images, etc.)
class StorageRepository extends BaseRepository {
  @override
  String get repositoryName => 'StorageRepository';

  /// Upload QRIS image for metode pembayaran
  Future<String> uploadMetodePembayaranQrisImage({
    required Uint8List imageBytes,
    required String fileExt,
    required String kostId,
    required String namaMetode,
  }) async {
    if (imageBytes.isEmpty) {
      logWarning('Empty image bytes provided for QRIS upload');
      throw Exception('File QRIS tidak valid');
    }

    logInfo('Uploading QRIS image', {
      'kostId': kostId,
      'namaMetode': namaMetode,
      'fileExt': fileExt,
    });

    final extension = HelperUtilities.normalizeFileExtension(fileExt);
    final safeKostId = kostId.trim().isEmpty ? 'umum' : kostId.trim();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${HelperUtilities.slugify(namaMetode)}.$extension';
    final objectPath = '$safeKostId/$fileName';

    try {
      await supabase.storage
          .from(RepositoryConstants.metodePembayaranQrisBucket)
          .uploadBinary(
            objectPath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: HelperUtilities.contentTypeFromFileExtension(
                extension,
              ),
            ),
          );

      final url = supabase.storage
          .from(RepositoryConstants.metodePembayaranQrisBucket)
          .getPublicUrl(objectPath);

      logInfo('QRIS image uploaded successfully', {'url': url});
      return url;
    } on StorageException catch (e) {
      logError('Failed to upload QRIS image: ${formatStorageError(e)}');
      throw Exception(formatStorageError(e));
    } on PostgrestException catch (e) {
      logError('Failed to upload QRIS image: ${formatPostgrestError(e)}');
      throw Exception(formatPostgrestError(e));
    }
  }

  /// Upload bukti pembayaran
  Future<String> uploadBuktiPembayaran({
    required Uint8List imageBytes,
    required String fileExt,
    required String penghuniId,
  }) async {
    if (imageBytes.isEmpty) {
      logWarning('Empty image bytes provided for bukti pembayaran upload');
      throw Exception('File bukti pembayaran tidak valid');
    }

    logInfo('Uploading bukti pembayaran', {
      'penghuniId': penghuniId,
      'fileExt': fileExt,
    });

    final extension = HelperUtilities.normalizeFileExtension(fileExt);
    final fileName =
        'bukti_${penghuniId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      await supabase.storage
          .from(RepositoryConstants.buktiPembayaranBucket)
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: HelperUtilities.contentTypeFromFileExtension(
                extension,
              ),
            ),
          );

      final url = supabase.storage
          .from(RepositoryConstants.buktiPembayaranBucket)
          .getPublicUrl(fileName);

      logInfo('Bukti pembayaran uploaded successfully', {'url': url});
      return url;
    } on StorageException catch (e) {
      logError('Failed to upload bukti pembayaran: ${formatStorageError(e)}');
      throw Exception(formatStorageError(e));
    }
  }

  /// Upload foto profil admin
  Future<String> uploadFotoProfilAdmin({
    required Uint8List imageBytes,
    required String fileExt,
    required String userId,
  }) async {
    if (imageBytes.isEmpty) {
      logWarning('Empty image bytes provided for foto profil upload');
      throw Exception('File foto tidak valid');
    }

    logInfo('Uploading foto profil admin', {
      'userId': userId,
      'fileExt': fileExt,
    });

    final extension = HelperUtilities.normalizeFileExtension(fileExt);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$userId.$extension';
    final objectPath = 'admin/$fileName';

    try {
      await supabase.storage
          .from(RepositoryConstants.fotoProfilBucket)
          .uploadBinary(
            objectPath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: HelperUtilities.contentTypeFromFileExtension(
                extension,
              ),
            ),
          );

      final url = supabase.storage
          .from(RepositoryConstants.fotoProfilBucket)
          .getPublicUrl(objectPath);

      logInfo('Foto profil admin uploaded successfully', {'url': url});
      return url;
    } on StorageException catch (e) {
      logError('Failed to upload foto profil admin: ${formatStorageError(e)}');
      throw Exception(formatStorageError(e));
    } on PostgrestException catch (e) {
      logError(
        'Failed to upload foto profil admin: ${formatPostgrestError(e)}',
      );
      throw Exception(formatPostgrestError(e));
    }
  }
}
