/// Shared utility functions for repositories
class HelperUtilities {
  /// Safe integer conversion with default value
  static int toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safe double conversion with default value
  static double toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safe map conversion
  static Map<String, dynamic>? asStringMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  /// Normalize file extension (remove leading dot, lowercase)
  static String normalizeFileExtension(String ext) {
    var normalized = ext.trim().toLowerCase();
    if (normalized.startsWith('.')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  /// Get content type from file extension
  static String contentTypeFromFileExtension(String ext) {
    final normalized = normalizeFileExtension(ext);
    switch (normalized) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Slugify string for safe file names
  static String slugify(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Normalize metode pembayaran type
  static String normalizeMetodePembayaranTipe(String tipe) {
    final normalized = tipe.trim().toLowerCase();
    switch (normalized) {
      case 'transfer':
      case 'transfer_bank':
      case 'bank':
        return 'transfer_bank';
      case 'qris':
      case 'qr':
        return 'qris';
      case 'tunai':
      case 'cash':
        return 'tunai';
      default:
        return normalized;
    }
  }
}
