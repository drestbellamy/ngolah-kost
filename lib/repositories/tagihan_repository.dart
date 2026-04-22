import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for Tagihan (Bills) management
class TagihanRepository extends BaseRepository {
  @override
  String get repositoryName => 'TagihanRepository';

  /// Create automatic tagihan based on contract
  Future<void> createTagihanOtomatis({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.isEmpty || durasiKontrakBulan <= 0 || hargaBulanan <= 0) {
      logWarning('Invalid parameters for createTagihanOtomatis', {
        'penghuniId': penghuniId,
        'durasiKontrakBulan': durasiKontrakBulan,
        'hargaBulanan': hargaBulanan,
      });
      return;
    }

    logInfo('Creating automatic tagihan', {
      'penghuniId': penghuniId,
      'durasiKontrakBulan': durasiKontrakBulan,
    });

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);
    final payload = _buildTagihanPayloadByKontrak(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      siklusPembayaranBulan: siklus,
      hargaBulanan: hargaBulanan,
    );

    if (payload.isEmpty) {
      logDebug('No tagihan payload to create');
      return;
    }

    try {
      await supabase
          .from(RepositoryConstants.tagihanTable)
          .upsert(
            payload,
            onConflict: 'penghuni_id,bulan,tahun',
            ignoreDuplicates: true,
          );
      logInfo('Automatic tagihan created successfully', {
        'count': payload.length,
      });
    } on PostgrestException catch (e) {
      logError(
        'Failed to create automatic tagihan: ${formatPostgrestError(e)}',
      );
      rethrow;
    }
  }

  /// Sync tagihan based on contract (idempotent)
  Future<void> sinkronTagihanKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.trim().isEmpty || durasiKontrakBulan <= 0) {
      logWarning('Invalid parameters for sinkronTagihanKontrak');
      return;
    }
    if (hargaBulanan <= 0) {
      logWarning('Invalid hargaBulanan for sinkronTagihanKontrak');
      return;
    }

    logInfo('Syncing tagihan contract', {
      'penghuniId': penghuniId,
      'durasiKontrakBulan': durasiKontrakBulan,
    });

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);

    final coveredByLunas = await _loadCoveredMonthlyKeysByLunasTagihan(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      hargaBulanan: hargaBulanan,
    );

    final payload = _buildTagihanPayloadByKontrak(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      siklusPembayaranBulan: siklus,
      hargaBulanan: hargaBulanan,
      excludedMonthlyKeys: coveredByLunas,
    );

    try {
      // Rebuild unpaid schedule from scratch so old periods don't linger
      await supabase
          .from(RepositoryConstants.tagihanTable)
          .delete()
          .eq('penghuni_id', penghuniId)
          .neq('status', RepositoryConstants.statusLunas);

      if (payload.isEmpty) {
        logDebug('No tagihan payload to sync');
        return;
      }

      await supabase
          .from(RepositoryConstants.tagihanTable)
          .upsert(
            payload,
            onConflict: 'penghuni_id,bulan,tahun',
            ignoreDuplicates: true,
          );

      logInfo('Tagihan contract synced successfully', {
        'count': payload.length,
      });
    } on PostgrestException catch (e) {
      logError('Failed to sync tagihan contract: ${formatPostgrestError(e)}');
      rethrow;
    }
  }

  /// Get all tagihan (enriched with penghuni, kamar, kost info)
  Future<List<Map<String, dynamic>>> getTagihanList({
    required Future<Map<String, Map<String, String>>> Function()
    getPenghuniLookup,
    required Future<Map<String, Map<String, String?>>> Function()
    getPenghuniStatusLookup,
  }) async {
    logDebug('Starting getTagihanList');

    try {
      final raw = await supabase
          .from(RepositoryConstants.tagihanTable)
          .select(
            'id, penghuni_id, bulan, tahun, jumlah, status, created_at, tanggal_jatuh_tempo, batas_pembayaran',
          )
          .order('tahun', ascending: false)
          .order('bulan', ascending: false)
          .order('created_at', ascending: false);

      final rows = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      logInfo('Total tagihan fetched', {'count': rows.length});

      if (rows.isEmpty) return rows;

      final penghuniLookup = await getPenghuniLookup();
      final penghuniStatusLookup = await getPenghuniStatusLookup();
      final now = DateTime.now();

      logDebug('Lookup maps loaded', {
        'penghuniLookupSize': penghuniLookup.length,
        'penghuniStatusLookupSize': penghuniStatusLookup.length,
      });

      final enrichedRows = <Map<String, dynamic>>[];
      for (final row in rows) {
        final tagihanId = row['id']?.toString() ?? '';
        final penghuniId = row['penghuni_id']?.toString() ?? '';
        final status = row['status']?.toString() ?? '';
        final info = penghuniLookup[penghuniId] ?? const <String, String>{};
        final penghuniStatus = penghuniStatusLookup[penghuniId];

        logDebug('Processing tagihan', {
          'tagihanId': tagihanId,
          'penghuniId': penghuniId,
        });

        // Skip if penghuni not found in active lookup
        if (info.isEmpty) {
          logDebug('Skipping tagihan - penghuni not in active lookup', {
            'tagihanId': tagihanId,
          });
          continue;
        }

        // Skip paid bills for ended contracts
        if (penghuniStatus != null &&
            (penghuniStatus['status'] == 'berakhir' ||
                penghuniStatus['status'] == 'tidak_aktif') &&
            status == RepositoryConstants.statusLunas) {
          logDebug('Skipping paid bill for ended contract', {
            'tagihanId': tagihanId,
            'penghuniStatus': penghuniStatus['status'],
          });
          continue;
        }

        // Skip old unpaid bills for ended contracts (>3 months)
        if (penghuniStatus != null &&
            (penghuniStatus['status'] == 'berakhir' ||
                penghuniStatus['status'] == 'tidak_aktif') &&
            penghuniStatus['tanggal_keluar'] != null) {
          final tanggalKeluar = DateTime.tryParse(
            penghuniStatus['tanggal_keluar']!,
          );
          if (tanggalKeluar != null) {
            final monthsSinceEnd = now.difference(tanggalKeluar).inDays / 30;
            if (monthsSinceEnd > 3 &&
                status == RepositoryConstants.statusBelumDibayar) {
              logDebug('Skipping old unpaid bill for ended contract', {
                'tagihanId': tagihanId,
                'monthsSinceEnd': monthsSinceEnd.toStringAsFixed(1),
              });
              continue;
            }
          }
        }

        row['nama_penghuni'] = info['nama'] ?? 'Penghuni';
        row['nomor_kamar'] = info['nomor_kamar'] ?? '-';
        row['nama_kost'] = info['nama_kost'] ?? '-';

        // Calculate late status
        final tanggalJatuhTempo = row['tanggal_jatuh_tempo'] != null
            ? DateTime.tryParse(row['tanggal_jatuh_tempo'].toString())
            : null;

        if (tanggalJatuhTempo != null &&
            status != RepositoryConstants.statusLunas) {
          final isLate = now.isAfter(tanggalJatuhTempo);
          row['is_terlambat'] = isLate;
          if (isLate) {
            row['hari_terlambat'] = now.difference(tanggalJatuhTempo).inDays;
          } else {
            row['hari_terlambat'] = 0;
          }
        } else {
          row['is_terlambat'] = false;
          row['hari_terlambat'] = 0;
        }

        // Get pembayaran data if status is menunggu_verifikasi or lunas
        if (status == RepositoryConstants.statusMenungguVerifikasi ||
            status == RepositoryConstants.statusLunas) {
          logDebug('Fetching pembayaran for tagihan', {'tagihanId': tagihanId});
          try {
            final pembayaranRaw = await supabase
                .from(RepositoryConstants.pembayaranTable)
                .select('id, bukti_pembayaran, tanggal, metode_id')
                .eq('tagihan_id', tagihanId)
                .order('created_at', ascending: false)
                .limit(1);

            if (pembayaranRaw.isNotEmpty) {
              final pembayaran = pembayaranRaw.first;
              row['pembayaran_id'] = pembayaran['id'];
              row['bukti_pembayaran_url'] = pembayaran['bukti_pembayaran'];
              row['tanggal_pembayaran'] = pembayaran['tanggal'];
              row['metode_pembayaran_id'] = pembayaran['metode_id'];
              logDebug('Pembayaran data found', {
                'pembayaranId': pembayaran['id'],
              });
            } else {
              logDebug('No pembayaran found', {'tagihanId': tagihanId});
            }
          } catch (e) {
            logWarning('Error fetching pembayaran', {
              'tagihanId': tagihanId,
              'error': e.toString(),
            });
          }
        }

        enrichedRows.add(row);
      }

      logInfo('Tagihan list enriched', {'enrichedCount': enrichedRows.length});
      return enrichedRows;
    } on PostgrestException catch (e) {
      logError('Failed to get tagihan list: ${formatPostgrestError(e)}');
      rethrow;
    }
  }

  /// Get tagihan by penghuni ID
  Future<List<Map<String, dynamic>>> getTagihanByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) {
      logWarning('Empty penghuniId provided');
      return [];
    }

    logDebug('Fetching tagihan by penghuniId', {'penghuniId': penghuniId});

    try {
      final raw = await supabase
          .from(RepositoryConstants.tagihanTable)
          .select(
            'id, penghuni_id, bulan, tahun, jumlah, status, created_at, tanggal_jatuh_tempo, batas_pembayaran',
          )
          .eq('penghuni_id', penghuniId)
          .order('tahun', ascending: false)
          .order('bulan', ascending: false)
          .order('created_at', ascending: false);

      final result = raw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      logInfo('Tagihan by penghuniId fetched', {'count': result.length});
      return result;
    } on PostgrestException catch (e) {
      logError(
        'Failed to get tagihan by penghuniId: ${formatPostgrestError(e)}',
      );
      rethrow;
    }
  }

  /// Get tagihan by ID
  Future<Map<String, dynamic>?> getTagihanById(String tagihanId) async {
    if (tagihanId.trim().isEmpty) {
      logWarning('Empty tagihanId provided');
      return null;
    }

    logDebug('Fetching tagihan by ID', {'tagihanId': tagihanId});

    try {
      final raw = await supabase
          .from(RepositoryConstants.tagihanTable)
          .select('*')
          .eq('id', tagihanId)
          .single();

      logInfo('Tagihan by ID fetched successfully');
      return Map<String, dynamic>.from(raw);
    } on PostgrestException catch (e) {
      logError('Failed to get tagihan by ID: ${formatPostgrestError(e)}');
      return null;
    }
  }

  List<Map<String, dynamic>> _buildTagihanPayloadByKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int siklusPembayaranBulan,
    required int hargaBulanan,
    Set<String> excludedMonthlyKeys = const <String>{},
  }) {
    final payload = <Map<String, dynamic>>[];

    if (penghuniId.trim().isEmpty ||
        durasiKontrakBulan <= 0 ||
        siklusPembayaranBulan <= 0 ||
        hargaBulanan <= 0) {
      logDebug('Invalid parameters for building tagihan payload');
      return payload;
    }

    var monthCursor = 0;
    while (monthCursor < durasiKontrakBulan) {
      final periode = DateTime(
        tanggalMasuk.year,
        tanggalMasuk.month + monthCursor,
        1,
      );
      final key = _billingMonthKey(periode.year, periode.month);

      if (excludedMonthlyKeys.contains(key)) {
        monthCursor += 1;
        continue;
      }

      var durasiTagihan = 0;
      var probe = monthCursor;
      while (probe < durasiKontrakBulan &&
          durasiTagihan < siklusPembayaranBulan) {
        final periodeProbe = DateTime(
          tanggalMasuk.year,
          tanggalMasuk.month + probe,
          1,
        );
        final probeKey = _billingMonthKey(
          periodeProbe.year,
          periodeProbe.month,
        );
        if (excludedMonthlyKeys.contains(probeKey)) {
          break;
        }
        durasiTagihan += 1;
        probe += 1;
      }

      if (durasiTagihan <= 0) {
        monthCursor += 1;
        continue;
      }

      payload.add({
        'penghuni_id': penghuniId,
        'bulan': periode.month,
        'tahun': periode.year,
        'jumlah': hargaBulanan * durasiTagihan,
        'status': RepositoryConstants.statusBelumDibayar,
      });

      monthCursor += durasiTagihan;
    }

    logDebug('Built tagihan payload', {'count': payload.length});
    return payload;
  }

  Future<Set<String>> _loadCoveredMonthlyKeysByLunasTagihan({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int hargaBulanan,
  }) async {
    final covered = <String>{};
    if (penghuniId.trim().isEmpty ||
        durasiKontrakBulan <= 0 ||
        hargaBulanan <= 0) {
      return covered;
    }

    final contractKeys = <String>{};
    for (var i = 0; i < durasiKontrakBulan; i++) {
      final period = DateTime(tanggalMasuk.year, tanggalMasuk.month + i, 1);
      contractKeys.add(_billingMonthKey(period.year, period.month));
    }

    try {
      final raw = await supabase
          .from(RepositoryConstants.tagihanTable)
          .select('bulan, tahun, jumlah')
          .eq('penghuni_id', penghuniId)
          .eq('status', RepositoryConstants.statusLunas);

      for (final item in raw) {
        final row = Map<String, dynamic>.from(item as Map);
        final bulan = super.toInt(row['bulan']);
        final tahun = super.toInt(row['tahun']);
        if (bulan < 1 || bulan > 12 || tahun <= 0) {
          continue;
        }

        final monthsCovered = _estimateMonthsCoveredByAmount(
          row['jumlah'],
          hargaBulanan,
        );

        for (var i = 0; i < monthsCovered; i++) {
          final period = DateTime(tahun, bulan + i, 1);
          final key = _billingMonthKey(period.year, period.month);
          if (contractKeys.contains(key)) {
            covered.add(key);
          }
        }
      }

      logDebug('Loaded covered monthly keys', {'count': covered.length});
    } catch (e) {
      logWarning('Error loading covered monthly keys', {'error': e.toString()});
      return covered;
    }

    return covered;
  }

  int _estimateMonthsCoveredByAmount(dynamic jumlah, int hargaBulanan) {
    if (hargaBulanan <= 0) return 1;
    final total = super.toInt(jumlah);
    if (total <= 0) return 1;

    final div = total ~/ hargaBulanan;
    final remainder = total % hargaBulanan;
    final months = remainder > 0 ? div + 1 : div;
    return months <= 0 ? 1 : months;
  }

  String _billingMonthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
