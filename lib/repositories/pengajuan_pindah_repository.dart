import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/data/models/pengajuan_pindah_model.dart';
import 'base/base_repository.dart';

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
}
