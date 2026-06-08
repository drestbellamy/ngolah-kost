import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/data/models/pengajuan_pindah_model.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

class PengajuanPindahRepository extends BaseRepository {
  @override
  String get repositoryName => 'PengajuanPindahRepository';

  final SupabaseClient _supabase;

  PengajuanPindahRepository([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch all rooms across all kosts
  Future<List<Map<String, dynamic>>> getSemuaKamar() async {
    try {
      logDebug('Fetching all rooms');
      final response = await _supabase
          .from('kamar')
          .select('''
            *,
            kost:kost_id (
              nama_kost,
              alamat
            )
          ''')
          .order('no_kamar');

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      logError('Failed to fetch all rooms', {'error': e.message});
      throw Exception(formatPostgrestError(e));
    } catch (e) {
      logError('Unexpected error fetching all rooms', {'error': e.toString()});
      throw Exception('Gagal memuat daftar kamar.');
    }
  }

  /// Get the active penghuni (contract) for a user
  Future<Map<String, dynamic>?> getActivePenghuniByUserId(String userId) async {
    try {
      logDebug('Fetching active penghuni for user', {'userId': userId});
      final response = await _supabase
          .from('penghuni')
          .select()
          .eq('user_id', userId)
          .eq('status', 'aktif')
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      logError('Failed to fetch active penghuni', {'error': e.message});
      throw Exception(formatPostgrestError(e));
    }
  }

  /// Submit a new move request
  Future<void> submitPengajuanPindah({
    required String penghuniId,
    required String kamarTujuanId,
    required DateTime tanggalPindah,
    String? alasan,
  }) async {
    try {
      logDebug('Submitting move request', {
        'penghuniId': penghuniId,
        'kamarTujuanId': kamarTujuanId,
      });

      await _supabase.from('pengajuan_pindah').insert({
        'penghuni_id': penghuniId,
        'kamar_tujuan_id': kamarTujuanId,
        'tanggal_pindah': tanggalPindah.toIso8601String().split('T').first,
        'alasan': alasan,
        'status': 'menunggu', // Default status
      });

      logInfo('Successfully submitted move request');
    } on PostgrestException catch (e) {
      logError('Failed to submit move request', {'error': e.message});
      throw Exception(formatPostgrestError(e));
    }
  }

  /// Get active (pending) move request for a penghuni
  Future<PengajuanPindahModel?> getPendingPengajuan(String penghuniId) async {
    try {
      logDebug('Fetching pending move request', {'penghuniId': penghuniId});
      final response = await _supabase
          .from('pengajuan_pindah')
          .select('''
            *,
            kamar:kamar_tujuan_id (
              no_kamar,
              kost:kost_id (nama_kost)
            )
          ''')
          .eq('penghuni_id', penghuniId)
          .eq('status', 'menunggu')
          .maybeSingle();

      if (response == null) return null;
      return PengajuanPindahModel.fromMap(response);
    } on PostgrestException catch (e) {
      logError('Failed to fetch pending move request', {'error': e.message});
      throw Exception(formatPostgrestError(e));
    }
  }

  /// Get all move requests for admin
  Future<List<PengajuanPindahModel>> getAllPengajuan() async {
    try {
      logDebug('Fetching all move requests');
      final response = await _supabase
          .from('pengajuan_pindah')
          .select('''
            *,
            kamar:kamar_tujuan_id (
              no_kamar,
              harga,
              kost:kost_id (nama_kost, alamat)
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => PengajuanPindahModel.fromMap(item))
          .toList();
    } on PostgrestException catch (e) {
      logError('Failed to fetch all move requests', {'error': e.message});
      throw Exception(formatPostgrestError(e));
    }
  }

  /// Update the status of a move request using RPC (NEW VERSION with Atomic Transaction)
  Future<Map<String, dynamic>> updateStatusPengajuan(
    String id,
    String status, {
    String? keteranganAdmin,
  }) async {
    try {
      logDebug('Updating move request status via RPC', {
        'id': id,
        'status': status,
      });

      // 🆕 Gunakan RPC function untuk proses perpindahan kamar
      // Semua operasi dalam 1 transaction atomic
      final result = await _supabase.rpc(
        RepositoryConstants.processRoomTransferRpc,
        params: {
          'p_pengajuan_id': id,
          'p_status': status,
          'p_keterangan_admin': keteranganAdmin,
        },
      );

      // Parse result dari RPC
      if (result is Map<String, dynamic>) {
        final success = result['success'] as bool? ?? false;
        final message = result['message'] as String? ?? '';
        final data = result['data'] as Map<String, dynamic>? ?? {};

        logInfo('Successfully processed move request via RPC', {
          'success': success,
          'message': message,
          'pengajuan_id': id,
        });

        // Log detail perpindahan untuk debugging
        if (data.isNotEmpty) {
          logDebug('Room transfer details', {
            'penghuni_id': data['penghuni_id'],
            'kamar_asal_id': data['kamar_asal_id'],
            'kamar_tujuan_id': data['kamar_tujuan_id'],
            'status_kamar_asal': data['status_kamar_asal'],
            'status_kamar_tujuan': data['status_kamar_tujuan'],
            'terisi_asal': data['terisi_asal'],
            'terisi_tujuan': data['terisi_tujuan'],
            'harga_lama': data['harga_lama'],
            'harga_baru': data['harga_baru'],
          });
        }

        return {'success': success, 'message': message, 'data': data};
      }

      // Jika result bukan Map (unexpected format)
      logWarning('Unexpected RPC result type', {
        'result_type': result.runtimeType.toString(),
      });

      return {
        'success': true,
        'message': 'Pengajuan berhasil diproses',
        'data': {},
      };
    } on PostgrestException catch (e) {
      logError('Failed to update move request status', {
        'error': e.message,
        'details': e.details,
        'hint': e.hint,
        'code': e.code,
      });

      // Parse error message untuk user-friendly message
      String errorMessage = e.message;

      // Cek error spesifik dari RPC function
      if (errorMessage.contains('Kamar tujuan sudah penuh')) {
        errorMessage = 'Kamar tujuan sudah penuh. Silakan pilih kamar lain.';
      } else if (errorMessage.contains('tidak ditemukan')) {
        errorMessage = 'Data tidak ditemukan. Silakan refresh halaman.';
      } else if (errorMessage.contains('tidak boleh sama')) {
        errorMessage = 'Kamar asal dan tujuan tidak boleh sama.';
      } else if (errorMessage.contains('tidak boleh NULL')) {
        errorMessage = 'Data tidak lengkap. Silakan periksa kembali.';
      } else if (errorMessage.toLowerCase().contains('permission denied') ||
          errorMessage.toLowerCase().contains('rls')) {
        errorMessage = 'Anda tidak memiliki izin untuk melakukan operasi ini.';
      } else {
        // Ambil pesan error yang lebih spesifik jika ada
        final details = e.details?.toString() ?? '';
        if (details.isNotEmpty) {
          errorMessage = '$errorMessage\nDetail: $details';
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      logError('Unexpected error updating move request', {
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
      });

      throw Exception('Gagal memproses pengajuan: ${e.toString()}');
    }
  }
}
