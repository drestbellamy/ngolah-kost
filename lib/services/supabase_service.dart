import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/login/models/login_user_model.dart';

/// Minimal SupabaseService - Legacy methods for backward compatibility
///
/// This service contains only essential methods that are still in use by:
/// - LoginController (login method)
/// - KostMapController (getKostListWithStatus - pending KostRepository migration)
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

  /// Get kost list with room availability status
  ///
  /// Returns list of kost with calculated availability status based on room occupancy
  ///
  /// TODO: Migrate to KostRepository.getKostListWithStatus() when method is added
  Future<List<Map<String, dynamic>>> getKostListWithStatus() async {
    try {
      // Get all kost with their rooms and penghuni count
      final response = await supabase
          .from('kost')
          .select('''
        id,
        nama_kost,
        alamat,
        total_kamar,
        latitude,
        longitude,
        created_at,
        kamar(
          id,
          penghuni(id)
        )
      ''')
          .order('created_at', ascending: false);

      // Calculate availability status for each kost
      final kostListWithStatus = <Map<String, dynamic>>[];

      for (final kostData in response) {
        final kost = Map<String, dynamic>.from(kostData);
        final kamarList = kost['kamar'] as List?;

        if (kamarList == null || kamarList.isEmpty) {
          // No rooms - mark as unavailable
          kost['availability_status'] = 'unavailable';
          kost['available_rooms'] = 0;
          kost['occupied_rooms'] = 0;
        } else {
          int availableCount = 0;
          int occupiedCount = 0;

          for (final kamarData in kamarList) {
            final kamar = kamarData as Map<String, dynamic>;
            final penghuniList = kamar['penghuni'] as List?;
            final isOccupied = penghuniList != null && penghuniList.isNotEmpty;

            if (isOccupied) {
              occupiedCount++;
            } else {
              availableCount++;
            }
          }

          kost['available_rooms'] = availableCount;
          kost['occupied_rooms'] = occupiedCount;

          // Determine availability status
          if (availableCount == 0) {
            kost['availability_status'] = 'full';
          } else if (availableCount < kamarList.length / 2) {
            kost['availability_status'] = 'limited';
          } else {
            kost['availability_status'] = 'available';
          }
        }

        // Remove nested kamar data to keep response clean
        kost.remove('kamar');
        kostListWithStatus.add(kost);
      }

      return kostListWithStatus;
    } catch (e) {
      print('Error getting kost list with status: $e');
      return [];
    }
  }
}
