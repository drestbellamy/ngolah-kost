import 'package:flutter/foundation.dart';

/// Log levels for filtering
enum LogLevel { debug, info, warning, error }

/// Centralized logging service
/// Replaces print statements with structured logging
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  static LoggerService get instance => _instance;

  LoggerService._internal();

  /// Minimum log level to output (configurable)
  LogLevel minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Log debug message (development only)
  void debug(String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.debug, message, metadata);
  }

  /// Log info message
  void info(String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.info, message, metadata);
  }

  /// Log warning message
  void warning(String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.warning, message, metadata);
  }

  /// Log error message
  void error(String message, [Map<String, dynamic>? metadata]) {
    _log(LogLevel.error, message, metadata);
  }

  void _log(LogLevel level, String message, Map<String, dynamic>? metadata) {
    if (level.index < minimumLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final metadataStr = metadata != null && metadata.isNotEmpty
        ? ' | ${metadata.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';

    final logMessage = '[$timestamp] $levelStr: $message$metadataStr';

    // In production, this could be sent to a logging service
    // For now, use debugPrint which is safe in production
    debugPrint(logMessage);
  }

  /// Set minimum log level (useful for testing)
  void setMinimumLevel(LogLevel level) {
    minimumLevel = level;
  }
}
