import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling and formatting
class ErrorHandler {
  /// Format PostgrestException to user-friendly message
  static String formatPostgrestError(PostgrestException error) {
    final dynamic raw = error;
    final code = (raw.code ?? '').toString().trim();
    final message = (raw.message ?? error.toString()).toString().trim();
    final details = (raw.details ?? '').toString().trim();
    final hintText = (raw.hint ?? '').toString().trim();

    final parts = <String>[];

    if (code.isNotEmpty && code != 'null') {
      parts.add('code=$code');
    }
    if (details.isNotEmpty && details.toLowerCase() != 'null') {
      parts.add('details=$details');
    }
    if (hintText.isNotEmpty && hintText.toLowerCase() != 'null') {
      parts.add('hint=$hintText');
    }

    if (parts.isEmpty) return message;
    return '$message (${parts.join(" | ")})';
  }

  /// Format StorageException to user-friendly message
  static String formatStorageError(StorageException error) {
    final message = error.message;
    final statusCode = error.statusCode;

    if (statusCode != null) {
      return '$message (status=$statusCode)';
    }
    return message;
  }

  /// Create domain-specific exception with context
  static Exception createException(
    String message, {
    String? context,
    dynamic originalError,
  }) {
    final parts = <String>[message];

    if (context != null && context.isNotEmpty) {
      parts.add('context=$context');
    }

    if (originalError != null) {
      if (originalError is PostgrestException) {
        parts.add(formatPostgrestError(originalError));
      } else if (originalError is StorageException) {
        parts.add(formatStorageError(originalError));
      } else {
        parts.add('error=${originalError.toString()}');
      }
    }

    return Exception(parts.join(' | '));
  }
}
