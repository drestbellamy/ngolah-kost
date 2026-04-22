import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';
import 'tagihan_repository.dart';

/// Repository for Pembayaran (Payment) management
class PembayaranRepository extends BaseRepository {
  // Note: TagihanRepository dependency kept for future extensibility
  // Currently using direct queries for performance
  final TagihanRepository _tagihanRepository;

  PembayaranRepository({required TagihanRepository tagihanRepository})
    : _tagihanRepository = tagihanRepository;

  @override
  String get repositoryName => 'PembayaranRepository';

  /// Create pembayaran with bukti (direct insert)
  Future<void> createPembayaran({
    required String penghuniId,
    required String tagihanId,
    required double totalJumlah,
    required String metodeId,
    String? buktiPembayaranUrl, // Optional for cash payments
  }) async {
    logInfo('Creating pembayaran', {
      'tagihanId': tagihanId,
      'penghuniId': penghuniId,
      'jumlah': totalJumlah,
      'metodeId': metodeId,
      'hasBukti': buktiPembayaranUrl != null,
    });

    try {
      // Prepare insert data
      final insertData = {
        'penghuni_id': penghuniId,
        'tagihan_id': tagihanId,
        'jumlah': totalJumlah.toInt(),
        'metode_id': metodeId,
        'status': RepositoryConstants.statusPending,
        'tanggal': DateTime.now().toIso8601String(),
      };

      // Only add bukti_pembayaran if it's not null (for non-cash payments)
      if (buktiPembayaranUrl != null) {
        insertData['bukti_pembayaran'] = buktiPembayaranUrl;
      }

      // Direct insert to pembayaran table
      final insertResult = await supabase
          .from(RepositoryConstants.pembayaranTable)
          .insert(insertData)
          .select();

      logDebug('Pembayaran inserted', {'result': insertResult});

      // Update status tagihan menjadi menunggu_verifikasi
      final updateResult = await supabase
          .from(RepositoryConstants.tagihanTable)
          .update({'status': RepositoryConstants.statusMenungguVerifikasi})
          .eq('id', tagihanId)
          .select();

      logDebug('Tagihan status updated to menunggu_verifikasi', {
        'result': updateResult,
      });

      // Verify the data
      final verifyPembayaran = await supabase
          .from(RepositoryConstants.pembayaranTable)
          .select('*')
          .eq('tagihan_id', tagihanId)
          .order('created_at', ascending: false)
          .limit(1);
      logDebug('Verified pembayaran', {'data': verifyPembayaran});

      final verifyTagihan = await supabase
          .from(RepositoryConstants.tagihanTable)
          .select('id, status')
          .eq('id', tagihanId)
          .single();
      logDebug('Verified tagihan', {'data': verifyTagihan});

      logInfo('Pembayaran created successfully');
    } on PostgrestException catch (e) {
      logError('Failed to create pembayaran: ${formatPostgrestError(e)}');
      throw Exception(formatPostgrestError(e));
    } catch (e) {
      logError('Error creating pembayaran', {'error': e.toString()});
      throw Exception('Gagal membuat pembayaran: ${e.toString()}');
    }
  }

  /// Verify pembayaran (accept)
  Future<void> verifikasiPembayaran({
    required String tagihanId,
    required String pembayaranId,
  }) async {
    logInfo('Verifying pembayaran', {
      'tagihanId': tagihanId,
      'pembayaranId': pembayaranId,
    });

    try {
      // Get data pembayaran dan tagihan untuk insert ke pemasukan
      final pembayaranData = await supabase
          .from(RepositoryConstants.pembayaranTable)
          .select('''
            id, 
            penghuni_id, 
            jumlah, 
            tanggal,
            tagihan:tagihan_id(
              bulan,
              tahun
            )
          ''')
          .eq('id', pembayaranId)
          .single();

      // Update status tagihan menjadi lunas
      await supabase
          .from(RepositoryConstants.tagihanTable)
          .update({'status': RepositoryConstants.statusLunas})
          .eq('id', tagihanId);

      // Update status pembayaran menjadi verified
      await supabase
          .from(RepositoryConstants.pembayaranTable)
          .update({'status': RepositoryConstants.statusVerified})
          .eq('id', pembayaranId);

      // Insert ke tabel pemasukan
      final tagihan = pembayaranData['tagihan'];
      final bulan = tagihan is Map ? tagihan['bulan'] : null;
      final tahun = tagihan is Map ? tagihan['tahun'] : null;

      String periodeBulan = '';
      if (bulan != null && tahun != null) {
        final bulanInt = super.toInt(bulan);
        final tahunInt = super.toInt(tahun);

        if (bulanInt >= 1 &&
            bulanInt <= 12 &&
            tahunInt > 0 &&
            bulanInt < RepositoryConstants.monthNames.length) {
          periodeBulan =
              '${RepositoryConstants.monthNames[bulanInt]} $tahunInt';
        }
      }

      await supabase.from(RepositoryConstants.pemasukanTable).insert({
        'penghuni_id': pembayaranData['penghuni_id'],
        'jumlah': pembayaranData['jumlah'],
        'tanggal': pembayaranData['tanggal'],
        'keterangan': 'Pembayaran kost periode $periodeBulan',
        'pembayaran_id': pembayaranId, // Referensi ke pembayaran
      });

      logInfo('Pembayaran verified and pemasukan created successfully');
    } on PostgrestException catch (e) {
      logError('Failed to verify pembayaran: ${formatPostgrestError(e)}');
      throw Exception(formatPostgrestError(e));
    } catch (e) {
      logError('Error verifying pembayaran', {'error': e.toString()});
      throw Exception('Gagal memverifikasi pembayaran: ${e.toString()}');
    }
  }

  /// Reject pembayaran
  Future<void> tolakPembayaran({
    required String tagihanId,
    required String pembayaranId,
  }) async {
    logInfo('Rejecting pembayaran', {
      'tagihanId': tagihanId,
      'pembayaranId': pembayaranId,
    });

    try {
      // Update status tagihan kembali ke belum_dibayar
      await supabase
          .from(RepositoryConstants.tagihanTable)
          .update({'status': RepositoryConstants.statusBelumDibayar})
          .eq('id', tagihanId);

      // Update status pembayaran menjadi rejected
      await supabase
          .from(RepositoryConstants.pembayaranTable)
          .update({'status': RepositoryConstants.statusRejected})
          .eq('id', pembayaranId);

      logInfo('Pembayaran rejected successfully');
    } on PostgrestException catch (e) {
      logError('Failed to reject pembayaran: ${formatPostgrestError(e)}');
      throw Exception(formatPostgrestError(e));
    } catch (e) {
      logError('Error rejecting pembayaran', {'error': e.toString()});
      throw Exception('Gagal menolak pembayaran: ${e.toString()}');
    }
  }

  /// Get pembayaran by kost ID (DEPRECATED - use getPemasukanByKostId instead)
  @Deprecated('Use KeuanganRepository.getPemasukanByKostId instead')
  Future<List<Map<String, dynamic>>> getPembayaranByKostId(
    String kostId,
  ) async {
    if (kostId.trim().isEmpty) {
      logWarning('Empty kostId provided');
      return [];
    }

    logDebug('Fetching pembayaran by kostId (deprecated)', {'kostId': kostId});

    try {
      final raw = await supabase
          .from(RepositoryConstants.pembayaranTable)
          .select('id, jumlah, tanggal, deskripsi, created_at')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false);

      final result = raw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      logInfo('Pembayaran by kostId fetched (deprecated)', {
        'count': result.length,
      });
      return result;
    } on PostgrestException catch (e) {
      logError(
        'Failed to get pembayaran by kostId: ${formatPostgrestError(e)}',
      );
      return [];
    }
  }

  /// Get pembayaran by penghuni ID
  Future<List<Map<String, dynamic>>> getPembayaranByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) {
      logWarning('Empty penghuniId provided');
      return [];
    }

    logDebug('Fetching pembayaran by penghuniId', {'penghuniId': penghuniId});

    try {
      final raw = await supabase
          .from(RepositoryConstants.pembayaranTable)
          .select('*')
          .eq('penghuni_id', penghuniId)
          .order('tanggal', ascending: false);

      final result = raw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      logInfo('Pembayaran by penghuniId fetched', {'count': result.length});
      return result;
    } on PostgrestException catch (e) {
      logError(
        'Failed to get pembayaran by penghuniId: ${formatPostgrestError(e)}',
      );
      return [];
    }
  }
}
