import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';
import 'error_handler.dart';
import 'helper_utilities.dart';

/// Abstract base class for all repositories in the application
///
/// Provides shared functionality including:
/// - Protected Supabase client access
/// - Consistent error handling and formatting
/// - Logging with repository context
/// - Type-safe utility methods
///
/// ## Usage
///
/// All repository classes should extend this base class:
///
/// ```dart
/// class MyRepository extends BaseRepository {
///   @override
///   String get repositoryName => 'MyRepository';
///
///   Future<List<Map<String, dynamic>>> getItems() async {
///     logDebug('Getting items');
///     try {
///       final result = await supabase.from('items').select();
///       logInfo('Successfully retrieved items', {'count': result.length});
///       return result;
///     } on PostgrestException catch (e) {
///       logError('Failed to get items', {'error': formatPostgrestError(e)});
///       throw Exception(formatPostgrestError(e));
///     }
///   }
/// }
/// ```
///
/// ## Error Handling
///
/// Use the provided error formatting methods for consistent error messages:
/// - [formatPostgrestError] for database errors
/// - [formatStorageError] for file storage errors
///
/// ## Logging
///
/// All logging methods automatically include the repository name for context:
/// - [logDebug] for development debugging
/// - [logInfo] for general information
/// - [logWarning] for non-critical issues
/// - [logError] for error conditions
///
/// ## Type Safety
///
/// Use the provided utility methods for safe type conversions:
/// - [toInt] for integer conversion with defaults
/// - [toDouble] for double conversion with defaults
/// - [asStringMap] for safe map conversion
///
/// ## RLS Considerations
///
/// When implementing repository methods, consider Row Level Security (RLS):
/// - Always filter by user context when appropriate
/// - Use proper authentication checks
/// - Validate user permissions before operations
/// - Log security-related operations
abstract class BaseRepository {
  /// Protected Supabase client instance
  @protected
  final SupabaseClient supabase = Supabase.instance.client;

  /// Protected logger instance
  @protected
  final LoggerService logger = LoggerService.instance;

  /// Repository name for logging context
  ///
  /// Must be implemented by all concrete repository classes.
  /// Used to provide context in log messages.
  ///
  /// Example: 'UserRepository', 'ProductRepository'
  String get repositoryName;

  /// Format PostgrestException to user-friendly message
  ///
  /// Extracts meaningful error information from Supabase database errors
  /// including error codes, messages, details, and hints.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await supabase.from('users').insert(data);
  /// } on PostgrestException catch (e) {
  ///   throw Exception(formatPostgrestError(e));
  /// }
  /// ```
  @protected
  String formatPostgrestError(PostgrestException error) {
    return ErrorHandler.formatPostgrestError(error);
  }

  /// Format StorageException to user-friendly message
  ///
  /// Handles file storage errors with appropriate status code mapping.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await supabase.storage.from('bucket').upload('file', bytes);
  /// } on StorageException catch (e) {
  ///   throw Exception(formatStorageError(e));
  /// }
  /// ```
  @protected
  String formatStorageError(StorageException error) {
    return ErrorHandler.formatStorageError(error);
  }

  /// Safe integer conversion with default value
  ///
  /// Converts various types to integer with fallback to default value.
  /// Handles null, int, double, and string inputs safely.
  ///
  /// Parameters:
  /// - [value]: The value to convert
  /// - [defaultValue]: Fallback value if conversion fails (default: 0)
  ///
  /// Example:
  /// ```dart
  /// final age = toInt(userData['age'], defaultValue: 18);
  /// ```
  @protected
  int toInt(dynamic value, {int defaultValue = 0}) {
    return HelperUtilities.toInt(value, defaultValue: defaultValue);
  }

  /// Safe double conversion with default value
  ///
  /// Converts various types to double with fallback to default value.
  /// Handles null, double, int, and string inputs safely.
  ///
  /// Parameters:
  /// - [value]: The value to convert
  /// - [defaultValue]: Fallback value if conversion fails (default: 0.0)
  ///
  /// Example:
  /// ```dart
  /// final price = toDouble(productData['price'], defaultValue: 0.0);
  /// ```
  @protected
  double toDouble(dynamic value, {double defaultValue = 0.0}) {
    return HelperUtilities.toDouble(value, defaultValue: defaultValue);
  }

  /// Safe map conversion
  ///
  /// Converts dynamic values to Map<String, dynamic> safely.
  /// Returns null if conversion is not possible.
  ///
  /// Example:
  /// ```dart
  /// final metadata = asStringMap(response['metadata']);
  /// if (metadata != null) {
  ///   // Use metadata safely
  /// }
  /// ```
  @protected
  Map<String, dynamic>? asStringMap(dynamic value) {
    return HelperUtilities.asStringMap(value);
  }

  /// Log debug message with repository context
  ///
  /// Use for development debugging and detailed tracing.
  /// Debug messages are suppressed in production builds.
  ///
  /// Parameters:
  /// - [message]: The debug message
  /// - [metadata]: Optional additional data for context
  ///
  /// Example:
  /// ```dart
  /// logDebug('Processing user data', {'userId': userId, 'step': 'validation'});
  /// ```
  @protected
  void logDebug(String message, [Map<String, dynamic>? metadata]) {
    logger.debug('[$repositoryName] $message', metadata);
  }

  /// Log info message with repository context
  ///
  /// Use for general operational information and successful operations.
  ///
  /// Parameters:
  /// - [message]: The info message
  /// - [metadata]: Optional additional data for context
  ///
  /// Example:
  /// ```dart
  /// logInfo('User created successfully', {'userId': newUserId});
  /// ```
  @protected
  void logInfo(String message, [Map<String, dynamic>? metadata]) {
    logger.info('[$repositoryName] $message', metadata);
  }

  /// Log warning message with repository context
  ///
  /// Use for non-critical issues that should be monitored.
  ///
  /// Parameters:
  /// - [message]: The warning message
  /// - [metadata]: Optional additional data for context
  ///
  /// Example:
  /// ```dart
  /// logWarning('Deprecated API used', {'endpoint': '/old-api', 'userId': userId});
  /// ```
  @protected
  void logWarning(String message, [Map<String, dynamic>? metadata]) {
    logger.warning('[$repositoryName] $message', metadata);
  }

  /// Log error message with repository context
  ///
  /// Use for error conditions and exceptions.
  ///
  /// Parameters:
  /// - [message]: The error message
  /// - [metadata]: Optional additional data for context
  ///
  /// Example:
  /// ```dart
  /// logError('Database connection failed', {'error': e.toString(), 'retryCount': 3});
  /// ```
  @protected
  void logError(String message, [Map<String, dynamic>? metadata]) {
    logger.error('[$repositoryName] $message', metadata);
  }
}
