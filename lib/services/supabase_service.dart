import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/login/models/login_user_model.dart';

/// Minimal SupabaseService - Legacy methods for backward compatibility
///
/// This service contains only essential methods that are still in use by:
/// - LoginController (login method)
/// - Direct Supabase queries in some controllers (pending repository migration)
///
/// All other functionality has been migrated to the repository pattern.
/// See lib/repositories/ for the new architecture.
class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Login user with username and password
  ///
  /// Uses RPC function 'login_user_secure' for secure authentication
  ///
  /// Returns [LoginUserModel] if login successful, null otherwise
  ///
  /// TODO: Migrate to AuthRepository when LoginController is refactored
  Future<LoginUserModel?> login(String username, String password) async {
    final response = await supabase.rpc(
      'login_user_secure',
      params: {'p_username': username, 'p_password': password},
    );

    if (response is! List || response.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return LoginUserModel.fromMap(row);
  }

  /// Check if username exists in database
  ///
  /// Uses RPC function 'check_username_exists' to bypass RLS
  ///
  /// Returns true if username exists, false otherwise
  Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await supabase.rpc(
        'check_username_exists',
        params: {'p_username': username},
      );
      return response == true;
    } catch (e) {
      // If RPC function doesn't exist or error, return true to avoid false positives
      return true;
    }
  }
}
