import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/login/models/login_user_model.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for authentication and user management
class AuthRepository extends BaseRepository {
  @override
  String get repositoryName => 'AuthRepository';

  /// Login user with username and password
  Future<LoginUserModel?> login(String username, String password) async {
    logDebug('Attempting login', {'username': username});

    final response = await supabase.rpc(
      RepositoryConstants.loginUserSecureRpc,
      params: {'p_username': username, 'p_password': password},
    );

    if (response is! List || response.isEmpty) {
      logInfo('Login failed - no user found', {'username': username});
      return null;
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    final user = LoginUserModel.fromMap(row);

    logInfo('Login successful', {
      'username': username,
      'userId': user.id,
      'role': user.role,
    });

    return user;
  }

  /// Get all users
  Future<List<dynamic>> getUsers() async {
    logDebug('Getting all users');

    try {
      final result = await supabase
          .from(RepositoryConstants.usersTable)
          .select();

      logInfo('Successfully retrieved users', {'count': result.length});
      return result;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get users', {'error': errorMsg});
      rethrow;
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (userId.trim().isEmpty) {
      logWarning('getUserById called with empty userId');
      return null;
    }

    logDebug('Getting user by ID', {'userId': userId});

    try {
      // Try using RPC function first (bypass RLS)
      try {
        final result = await supabase.rpc(
          RepositoryConstants.getUserByIdRpc,
          params: {'p_user_id': userId},
        );

        if (result is List && result.isNotEmpty) {
          logInfo('User retrieved via RPC', {'userId': userId});
          return Map<String, dynamic>.from(result.first);
        }
      } catch (rpcError) {
        logDebug('RPC not available, trying direct query', {
          'error': rpcError.toString(),
        });
      }

      // Fallback to direct query
      final raw = await supabase
          .from(RepositoryConstants.usersTable)
          .select('id, username, nama, no_tlpn, role, foto_profil, is_active')
          .eq('id', userId)
          .maybeSingle();

      if (raw == null) {
        logInfo('User not found', {'userId': userId});
        return null;
      }

      logInfo('User retrieved via direct query', {'userId': userId});
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      logError('Error getting user by ID', {
        'userId': userId,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create user for penghuni (secure via RPC)
  Future<String> createPenghuniUserSecure({
    required String nama,
    required String noTlpn,
    required String username,
    required String password,
    String? kostPrefix,
  }) async {
    logDebug('Creating penghuni user', {
      'nama': nama,
      'username': username,
      'kostPrefix': kostPrefix,
    });

    final baseParams = {
      'p_nama': nama,
      'p_no_tlpn': noTlpn,
      'p_username': username,
      'p_password': password,
      'p_role': RepositoryConstants.roleUser,
    };

    dynamic response;
    try {
      final paramsWithPrefix = Map<String, dynamic>.from(baseParams);
      if (kostPrefix != null && kostPrefix.trim().isNotEmpty) {
        paramsWithPrefix['p_prefix'] = kostPrefix.trim().toUpperCase();
      }

      response = await supabase.rpc(
        RepositoryConstants.createUserSecureRpc,
        params: paramsWithPrefix,
      );
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();

      // Backward compatibility if DB function still uses old signature.
      if (message.contains('p_prefix') || message.contains('function')) {
        logDebug('Retrying without prefix parameter');
        response = await supabase.rpc(
          RepositoryConstants.createUserSecureRpc,
          params: baseParams,
        );
      } else {
        logError('Failed to create penghuni user', {
          'error': formatPostgrestError(e),
        });
        rethrow;
      }
    }

    if (response is List && response.isNotEmpty) {
      final row = Map<String, dynamic>.from(response.first as Map);
      final userId = (row['id'] ?? '').toString();

      logInfo('Successfully created penghuni user', {
        'userId': userId,
        'username': username,
      });

      return userId;
    }

    if (response is Map<String, dynamic>) {
      final userId = (response['id'] ?? '').toString();

      logInfo('Successfully created penghuni user', {
        'userId': userId,
        'username': username,
      });

      return userId;
    }

    logError('Failed to create penghuni user - invalid response');
    throw Exception('Gagal membuat user penghuni');
  }

  /// Delete user by ID
  Future<void> deleteUserById(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    logDebug('Deleting user', {'userId': userId});

    try {
      try {
        await supabase.rpc(
          RepositoryConstants.deleteUserByIdRpc,
          params: {'p_user_id': userId},
        );

        logInfo('User deleted via RPC', {'userId': userId});
        return;
      } catch (rpcError) {
        logDebug('RPC not available, trying direct delete', {
          'error': rpcError.toString(),
        });
      }

      await supabase
          .from(RepositoryConstants.usersTable)
          .delete()
          .eq('id', userId);

      logInfo('User deleted via direct query', {'userId': userId});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete user', {'userId': userId, 'error': errorMsg});
      throw Exception(errorMsg);
    }
  }

  /// Verify user password
  Future<void> verifyPassword({
    required String userId,
    required String password,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    logDebug('Verifying password', {'userId': userId});

    try {
      final result = await supabase.rpc(
        RepositoryConstants.verifyUserPasswordRpc,
        params: {'p_user_id': userId, 'p_password': password},
      );

      if (result == false || result == 0) {
        logWarning('Password verification failed', {'userId': userId});
        throw Exception('Password tidak sesuai');
      }

      logInfo('Password verified successfully', {'userId': userId});
    } on PostgrestException catch (e) {
      if (e.message.contains('not find the function')) {
        logError('Password verification RPC not available');
        throw Exception(
          'Fitur verifikasi password belum tersedia. Hubungi administrator.',
        );
      }

      final errorMsg = formatPostgrestError(e);
      logError('Password verification failed', {
        'userId': userId,
        'error': errorMsg,
      });
      throw Exception(errorMsg);
    }
  }

  /// Update username
  Future<void> updateUsername({
    required String userId,
    required String newUsername,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (newUsername.trim().isEmpty) {
      throw Exception('Username tidak boleh kosong');
    }

    logDebug('Updating username', {
      'userId': userId,
      'newUsername': newUsername,
    });

    try {
      // Check if username already exists
      final existing = await supabase
          .from(RepositoryConstants.usersTable)
          .select('id')
          .eq('username', newUsername)
          .neq('id', userId)
          .maybeSingle();

      if (existing != null) {
        logWarning('Username already exists', {'username': newUsername});
        throw Exception('Username sudah digunakan');
      }

      // Try using RPC function first
      try {
        await supabase.rpc(
          RepositoryConstants.updateUserUsernameRpc,
          params: {'p_user_id': userId, 'p_new_username': newUsername},
        );

        logInfo('Username updated via RPC', {
          'userId': userId,
          'newUsername': newUsername,
        });
        return;
      } catch (rpcError) {
        logDebug('RPC not available, trying direct update', {
          'error': rpcError.toString(),
        });
      }

      // Fallback to direct update
      await supabase
          .from(RepositoryConstants.usersTable)
          .update({'username': newUsername})
          .eq('id', userId);

      logInfo('Username updated via direct query', {
        'userId': userId,
        'newUsername': newUsername,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update username', {
        'userId': userId,
        'error': errorMsg,
      });
      throw Exception(errorMsg);
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (newPassword.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    logDebug('Updating password', {'userId': userId});

    try {
      // Verify old password first
      await verifyPassword(userId: userId, password: oldPassword);

      // Try using RPC function first
      try {
        await supabase.rpc(
          RepositoryConstants.updateUserPasswordRpc,
          params: {'p_user_id': userId, 'p_new_password': newPassword},
        );

        logInfo('Password updated successfully', {'userId': userId});
        return;
      } catch (rpcError) {
        logError('RPC not available for password update', {
          'error': rpcError.toString(),
        });
        throw Exception(
          'Fitur ubah password belum tersedia. Hubungi administrator.',
        );
      }
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update password', {
        'userId': userId,
        'error': errorMsg,
      });
      throw Exception(errorMsg);
    }
  }

  /// Update foto profil user
  Future<void> updateFotoProfilUser({
    required String userId,
    String? fotoProfilUrl,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    logDebug('Updating foto profil', {
      'userId': userId,
      'hasUrl': fotoProfilUrl != null,
    });

    try {
      // Try using RPC function first (if available)
      try {
        await supabase.rpc(
          RepositoryConstants.updateUserFotoProfilRpc,
          params: {'p_user_id': userId, 'p_foto_profil_url': fotoProfilUrl},
        );

        logInfo('Foto profil updated via RPC', {'userId': userId});
        return;
      } catch (rpcError) {
        logDebug('RPC not available, trying direct update', {
          'error': rpcError.toString(),
        });
      }

      // Fallback to direct update
      await supabase
          .from(RepositoryConstants.usersTable)
          .update({'foto_profil': fotoProfilUrl})
          .eq('id', userId);

      logInfo('Foto profil updated via direct query', {'userId': userId});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update foto profil', {
        'userId': userId,
        'error': errorMsg,
      });
      throw Exception(errorMsg);
    }
  }
}
