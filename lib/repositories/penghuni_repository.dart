import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';
import 'kost_repository.dart';
import 'kamar_repository.dart';

/// Repository for Penghuni (Tenant) management
class PenghuniRepository extends BaseRepository {
  final KostRepository _kostRepository;
  final KamarRepository _kamarRepository;

  PenghuniRepository({
    required KostRepository kostRepository,
    required KamarRepository kamarRepository,
  }) : _kostRepository = kostRepository,
       _kamarRepository = kamarRepository;

  @override
  String get repositoryName => 'PenghuniRepository';

  /// Create new penghuni
  Future<String> createPenghuni({
    String? userId,
    required String kamarId,
    required int durasiKontrak,
    int? sistemPembayaranBulan,
    required DateTime tanggalMasuk,
    required DateTime tanggalKeluar,
    String status = 'aktif',
  }) async {
    logInfo('Creating penghuni', {
      'kamarId': kamarId,
      'durasiKontrak': durasiKontrak,
      'status': status,
    });

    final payload = <String, dynamic>{
      'user_id': userId,
      'kamar_id': kamarId,
      'durasi_kontrak': durasiKontrak,
      'tanggal_masuk': tanggalMasuk.toIso8601String().split('T').first,
      'tanggal_keluar': tanggalKeluar.toIso8601String().split('T').first,
      'status': status,
    };

    if (sistemPembayaranBulan != null && sistemPembayaranBulan > 0) {
      payload['sistem_pembayaran_bulan'] = sistemPembayaranBulan;
    }

    dynamic inserted;
    try {
      inserted = await supabase
          .from(RepositoryConstants.penghuniTable)
          .insert(payload)
          .select('id')
          .single();
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility for DB schema that does not have sistem_pembayaran_bulan yet.
      if (payload.containsKey('sistem_pembayaran_bulan') &&
          message.contains('sistem_pembayaran_bulan')) {
        logWarning(
          'sistem_pembayaran_bulan column not found, retrying without it',
        );
        payload.remove('sistem_pembayaran_bulan');
        inserted = await supabase
            .from(RepositoryConstants.penghuniTable)
            .insert(payload)
            .select('id')
            .single();
      } else {
        logError('Failed to create penghuni: ${formatPostgrestError(e)}');
        rethrow;
      }
    }

    if (inserted is Map<String, dynamic>) {
      logInfo('Penghuni created successfully', {'id': inserted['id']});
      return (inserted['id'] ?? '').toString();
    }

    if (inserted is Map) {
      logInfo('Penghuni created successfully', {'id': inserted['id']});
      return (inserted['id'] ?? '').toString();
    }

    logError('Failed to create penghuni: unexpected response format');
    throw Exception('Gagal membuat data penghuni');
  }

  /// Get penghuni list by kamar ID
  Future<List<Map<String, dynamic>>> getPenghuniByKamarId(
    String kamarId, {
    bool onlyActive = false,
  }) async {
    logDebug('Fetching penghuni by kamarId', {
      'kamarId': kamarId,
      'onlyActive': onlyActive,
    });

    try {
      final response = await supabase.rpc(
        RepositoryConstants.getPenghuniByKamarSecureRpc,
        params: {'p_kamar_id': kamarId},
      );

      if (response is List) {
        var rows = response
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (onlyActive) {
          rows = rows.where((row) {
            final status = (row['status']?.toString() ?? '').toLowerCase();
            return status == RepositoryConstants.statusAktif;
          }).toList();
        }
        logInfo('Fetched ${rows.length} penghuni via RPC');
        return await _attachSistemPembayaranBulan(rows, kamarId);
      }
    } catch (e) {
      logWarning('RPC not available, using fallback query', {
        'error': e.toString(),
      });
      // Fallback to direct join query if RPC is not available yet.
    }

    dynamic fallbackQuery = supabase
        .from(RepositoryConstants.penghuniTable)
        .select(
          'id, user_id, kamar_id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, created_at, users:user_id(id, nama, no_tlpn, username)',
        )
        .eq('kamar_id', kamarId);

    if (onlyActive) {
      fallbackQuery = fallbackQuery.eq(
        'status',
        RepositoryConstants.statusAktif,
      );
    }

    final List<dynamic> fallback = await fallbackQuery.order(
      'created_at',
      ascending: false,
    );

    logInfo('Fetched ${fallback.length} penghuni via fallback query');
    return fallback.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Get single penghuni detail by ID (enriched)
  Future<Map<String, dynamic>?> getPenghuniDetailById(String penghuniId) async {
    if (penghuniId.trim().isEmpty) return null;

    logDebug('Fetching penghuni detail', {'penghuniId': penghuniId});

    try {
      final raw = await supabase
          .from(RepositoryConstants.penghuniTable)
          .select(
            'id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, users:user_id(nama, no_tlpn), kamar:kamar_id(no_kamar, harga, kost:kost_id(nama_kost))',
          )
          .eq('id', penghuniId)
          .maybeSingle();

      final map = asStringMap(raw);
      if (map != null && map.isNotEmpty) {
        final user = asStringMap(map['users']) ?? <String, dynamic>{};
        final kamar = asStringMap(map['kamar']) ?? <String, dynamic>{};
        final kost = asStringMap(kamar['kost']) ?? <String, dynamic>{};

        logInfo('Penghuni detail fetched successfully');
        return {
          'id': map['id']?.toString() ?? penghuniId,
          'nama': (user['nama'] ?? '').toString(),
          'no_tlpn': (user['no_tlpn'] ?? '').toString(),
          'durasi_kontrak': map['durasi_kontrak'],
          'sistem_pembayaran_bulan': map['sistem_pembayaran_bulan'],
          'tanggal_masuk': map['tanggal_masuk'],
          'tanggal_keluar': map['tanggal_keluar'],
          'status': map['status'],
          'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
          'harga': kamar['harga'],
          'nama_kost': (kost['nama_kost'] ?? '').toString(),
        };
      }
    } catch (e) {
      logWarning('Direct query failed, using fallback scan', {
        'error': e.toString(),
      });
      // Fall back to scan-based approach below.
    }

    // Fallback that reuses existing RLS-safe penghuni reader.
    final kosts = await _kostRepository.getKostList();
    for (final kost in kosts) {
      final kamarList = await _kamarRepository.getKamarByKostId(kost.id);
      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final rows = await getPenghuniByKamarId(kamarId);
        for (final row in rows) {
          final id = row['id']?.toString() ?? '';
          if (id != penghuniId) continue;

          final user = asStringMap(row['users']) ?? <String, dynamic>{};
          logInfo('Penghuni detail found via fallback scan');
          return {
            'id': id,
            'nama': (user['nama'] ?? row['nama'] ?? '').toString(),
            'no_tlpn': (user['no_tlpn'] ?? row['no_tlpn'] ?? '').toString(),
            'durasi_kontrak': row['durasi_kontrak'],
            'sistem_pembayaran_bulan': row['sistem_pembayaran_bulan'],
            'tanggal_masuk': row['tanggal_masuk'],
            'tanggal_keluar': row['tanggal_keluar'],
            'status': row['status'],
            'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
            'harga': kamar['harga'],
            'nama_kost': kost.name,
          };
        }
      }
    }

    logWarning('Penghuni detail not found', {'penghuniId': penghuniId});
    return null;
  }

  /// Get penghuni by user ID (for user profile)
  Future<Map<String, dynamic>?> getPenghuniByUserId(String userId) async {
    if (userId.trim().isEmpty) return null;

    logDebug('Fetching penghuni by userId', {'userId': userId});

    try {
      // Try using RPC first if available
      try {
        final rpcResult = await supabase.rpc(
          RepositoryConstants.getUserProfileDataRpc,
          params: {'p_user_id': userId},
        );

        if (rpcResult != null && rpcResult is List && rpcResult.isNotEmpty) {
          final data = Map<String, dynamic>.from(rpcResult.first as Map);
          logDebug('Profile data from RPC', {'data': data.keys.toList()});

          // If kost_id is not in RPC result, fetch it separately
          if (!data.containsKey('kost_id') || data['kost_id'] == null) {
            logDebug('kost_id not in RPC result, fetching separately');
            final penghuniId = data['id']?.toString() ?? '';
            if (penghuniId.isNotEmpty) {
              final penghuniRaw = await supabase
                  .from(RepositoryConstants.penghuniTable)
                  .select('kamar_id')
                  .eq('id', penghuniId)
                  .maybeSingle();

              if (penghuniRaw != null) {
                final kamarId = penghuniRaw['kamar_id']?.toString() ?? '';
                if (kamarId.isNotEmpty) {
                  final kamarRaw = await supabase
                      .from(RepositoryConstants.kamarTable)
                      .select('kost_id')
                      .eq('id', kamarId)
                      .maybeSingle();

                  if (kamarRaw != null) {
                    data['kost_id'] = kamarRaw['kost_id']?.toString() ?? '';
                    logDebug('Added kost_id to RPC result', {
                      'kost_id': data['kost_id'],
                    });
                  }
                }
              }
            }
          }

          logInfo('Penghuni profile fetched via RPC');
          return data;
        }
      } catch (rpcError) {
        logWarning('RPC not available, using fallback query', {
          'error': rpcError.toString(),
        });
      }

      // Fallback: Get penghuni with joined user data
      final raw = await supabase
          .from(RepositoryConstants.penghuniTable)
          .select('''
            id, 
            user_id, 
            durasi_kontrak, 
            sistem_pembayaran_bulan, 
            tanggal_masuk, 
            tanggal_keluar, 
            status, 
            kamar_id,
            users!inner(nama, no_tlpn)
            ''')
          .eq('user_id', userId)
          .eq('status', RepositoryConstants.statusAktif)
          .maybeSingle();

      final map = asStringMap(raw);
      if (map == null || map.isEmpty) {
        logWarning('No penghuni data found for userId', {'userId': userId});
        return null;
      }

      logDebug('Penghuni data fetched', {'penghuniId': map['id']});

      // Extract user data from joined result
      final userData = asStringMap(map['users']);
      final nama = userData?['nama']?.toString() ?? '';
      final noTlpn = userData?['no_tlpn']?.toString() ?? '';

      logDebug('User data from join', {'nama': nama, 'no_tlpn': noTlpn});

      // Get kamar data
      final kamarId = map['kamar_id']?.toString() ?? '';
      final kamarRaw = await supabase
          .from(RepositoryConstants.kamarTable)
          .select('no_kamar, harga, kost_id')
          .eq('id', kamarId)
          .maybeSingle();

      final kamar = asStringMap(kamarRaw) ?? <String, dynamic>{};
      logDebug('Kamar data fetched', {'kamarId': kamarId});

      // Get kost data
      final kostId = kamar['kost_id']?.toString() ?? '';
      final kostRaw = await supabase
          .from(RepositoryConstants.kostTable)
          .select('nama_kost')
          .eq('id', kostId)
          .maybeSingle();

      final kost = asStringMap(kostRaw) ?? <String, dynamic>{};
      logDebug('Kost data fetched', {'kostId': kostId});

      final result = {
        'id': map['id']?.toString() ?? '',
        'nama': nama,
        'no_tlpn': noTlpn,
        'durasi_kontrak': map['durasi_kontrak'],
        'sistem_pembayaran_bulan': map['sistem_pembayaran_bulan'],
        'tanggal_masuk': map['tanggal_masuk'],
        'tanggal_keluar': map['tanggal_keluar'],
        'status': map['status'],
        'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
        'harga': kamar['harga'],
        'kost_id': kostId,
        'nama_kost': (kost['nama_kost'] ?? '').toString(),
      };

      logInfo('Penghuni profile fetched via fallback');
      return result;
    } catch (e) {
      logError('Error fetching penghuni by userId', {'error': e.toString()});
      rethrow;
    }
  }

  /// Get penghuni count by kamar ID
  Future<int> getPenghuniCountByKamarId(
    String kamarId, {
    bool onlyActive = true,
  }) async {
    logDebug('Counting penghuni', {
      'kamarId': kamarId,
      'onlyActive': onlyActive,
    });

    dynamic query = supabase
        .from(RepositoryConstants.penghuniTable)
        .select('id')
        .eq('kamar_id', kamarId);

    if (onlyActive) {
      query = query.eq('status', RepositoryConstants.statusAktif);
    }

    final response = await query;

    if (response is List) {
      logInfo('Penghuni count: ${response.length}');
      return response.length;
    }

    return 0;
  }

  /// Update penghuni contract
  Future<void> updatePenghuniKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    String status = 'aktif',
  }) async {
    if (penghuniId.trim().isEmpty) {
      throw Exception('ID penghuni tidak valid');
    }
    if (durasiKontrakBulan <= 0) {
      throw Exception('Durasi kontrak harus lebih dari 0 bulan');
    }

    logInfo('Updating penghuni contract', {
      'penghuniId': penghuniId,
      'durasiKontrakBulan': durasiKontrakBulan,
    });

    final tanggalKeluar = DateTime(
      tanggalMasuk.year,
      tanggalMasuk.month + durasiKontrakBulan,
      tanggalMasuk.day,
    );

    final normalizedSiklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);

    final payload = <String, dynamic>{
      'tanggal_masuk': tanggalMasuk.toIso8601String().split('T').first,
      'tanggal_keluar': tanggalKeluar.toIso8601String().split('T').first,
      'durasi_kontrak': durasiKontrakBulan,
      'status': status,
      'sistem_pembayaran_bulan': normalizedSiklus,
    };

    try {
      await supabase
          .from(RepositoryConstants.penghuniTable)
          .update(payload)
          .eq('id', penghuniId);
      logInfo('Penghuni contract updated successfully');
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility if schema has not added sistem_pembayaran_bulan.
      if (message.contains('sistem_pembayaran_bulan')) {
        logWarning(
          'sistem_pembayaran_bulan column not found, retrying without it',
        );
        payload.remove('sistem_pembayaran_bulan');
        await supabase
            .from(RepositoryConstants.penghuniTable)
            .update(payload)
            .eq('id', penghuniId);
        logInfo(
          'Penghuni contract updated successfully (without sistem_pembayaran_bulan)',
        );
      } else {
        logError(
          'Failed to update penghuni contract: ${formatPostgrestError(e)}',
        );
        rethrow;
      }
    }
  }

  /// End penghuni contract
  Future<void> akhiriKontrakPenghuni({
    required String penghuniId,
    required Function(String) onDeleteUser,
  }) async {
    if (penghuniId.trim().isEmpty) {
      throw Exception('ID penghuni tidak valid');
    }

    logInfo('Ending penghuni contract', {'penghuniId': penghuniId});

    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;

    final raw = await supabase
        .from(RepositoryConstants.penghuniTable)
        .select('id, user_id, kamar_id')
        .eq('id', penghuniId)
        .maybeSingle();

    final row = asStringMap(raw);

    final userId = row?['user_id']?.toString() ?? '';
    final kamarId = row?['kamar_id']?.toString() ?? '';

    final penghuniPayload = <String, dynamic>{
      'status': 'berakhir',
      'tanggal_keluar': today,
      'user_id': null,
    };

    try {
      await supabase
          .from(RepositoryConstants.penghuniTable)
          .update(penghuniPayload)
          .eq('id', penghuniId);
      logInfo('Penghuni contract ended successfully');
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();
      if (message.contains('user_id')) {
        logWarning('user_id column issue, retrying without it');
        penghuniPayload.remove('user_id');
        await supabase
            .from(RepositoryConstants.penghuniTable)
            .update(penghuniPayload)
            .eq('id', penghuniId);
        logInfo(
          'Penghuni contract ended successfully (without user_id update)',
        );
      } else {
        logError('Failed to end penghuni contract: ${formatPostgrestError(e)}');
        rethrow;
      }
    }

    // Delete future unpaid bills
    final pending = await supabase
        .from(RepositoryConstants.tagihanTable)
        .select('id, bulan, tahun, status')
        .eq('penghuni_id', penghuniId)
        .eq('status', RepositoryConstants.statusBelumDibayar);

    for (final item in pending) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;

      final bulan = super.toInt(map['bulan']);
      final tahun = super.toInt(map['tahun']);
      final isFuture =
          tahun > now.year || (tahun == now.year && bulan > now.month);

      if (isFuture) {
        await supabase
            .from(RepositoryConstants.tagihanTable)
            .delete()
            .eq('id', id);
        logDebug('Deleted future tagihan', {'tagihanId': id});
      }
    }

    // Update kamar status
    if (kamarId.isNotEmpty) {
      final activeCount = await getPenghuniCountByKamarId(
        kamarId,
        onlyActive: true,
      );

      final kamarRaw = await supabase
          .from(RepositoryConstants.kamarTable)
          .select('kapasitas')
          .eq('id', kamarId)
          .maybeSingle();

      final kamarMap = asStringMap(kamarRaw);
      final kapasitas = super.toInt(kamarMap?['kapasitas']);

      await supabase
          .from(RepositoryConstants.kamarTable)
          .update({
            'status': _kamarRepository.kamarStatusByOccupancy(
              activeCount,
              kapasitas <= 0 ? 1 : kapasitas,
            ),
          })
          .eq('id', kamarId);
      logInfo('Kamar status updated', {'kamarId': kamarId});
    }

    // Delete user
    if (userId.isNotEmpty) {
      logInfo('Deleting user', {'userId': userId});
      onDeleteUser(userId);
    }
  }

  /// Build penghuni lookup map (for tagihan enrichment)
  Future<Map<String, Map<String, String>>> buildPenghuniLookup() async {
    logDebug('Building penghuni lookup map');
    final lookup = <String, Map<String, String>>{};

    final kosts = await _kostRepository.getKostList();
    for (final kost in kosts) {
      final kamarList = await _kamarRepository.getKamarByKostId(kost.id);

      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final penghuniRows = await getPenghuniByKamarId(
          kamarId,
          onlyActive: true,
        );
        for (final row in penghuniRows) {
          final penghuniId = row['id']?.toString() ?? '';
          if (penghuniId.isEmpty) continue;

          final user = row['users'] is Map
              ? Map<String, dynamic>.from(row['users'] as Map)
              : <String, dynamic>{};

          lookup[penghuniId] = {
            'nama': (user['nama'] ?? row['nama'] ?? 'Penghuni').toString(),
            'nomor_kamar': (kamar['no_kamar'] ?? '-').toString(),
            'nama_kost': kost.name,
          };
        }
      }
    }

    logInfo('Penghuni lookup map built', {'count': lookup.length});
    return lookup;
  }

  /// Build penghuni status lookup map
  Future<Map<String, Map<String, String?>>> buildPenghuniStatusLookup() async {
    logDebug('Building penghuni status lookup map');
    final lookup = <String, Map<String, String?>>{};

    try {
      final penghuniData = await supabase
          .from(RepositoryConstants.penghuniTable)
          .select('id, status, tanggal_keluar');

      for (final row in penghuniData) {
        final penghuniId = row['id']?.toString() ?? '';
        if (penghuniId.isNotEmpty) {
          lookup[penghuniId] = {
            'status': row['status']?.toString(),
            'tanggal_keluar': row['tanggal_keluar']?.toString(),
          };
        }
      }

      logInfo('Penghuni status lookup map built', {'count': lookup.length});
    } catch (e) {
      logError('Error building penghuni status lookup', {
        'error': e.toString(),
      });
    }

    return lookup;
  }

  // Helper methods
  Future<List<Map<String, dynamic>>> _attachSistemPembayaranBulan(
    List<Map<String, dynamic>> rows,
    String kamarId,
  ) async {
    if (rows.isEmpty) return rows;

    final hasColumnInRpc = rows.any(
      (row) => row.containsKey('sistem_pembayaran_bulan'),
    );
    if (hasColumnInRpc) return rows;

    try {
      final raw = await supabase
          .from(RepositoryConstants.penghuniTable)
          .select('id, sistem_pembayaran_bulan')
          .eq('kamar_id', kamarId);

      final byId = <String, int>{};
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final value = map['sistem_pembayaran_bulan'];
        if (value is int) {
          byId[id] = value;
        } else {
          byId[id] = int.tryParse(value?.toString() ?? '') ?? 0;
        }
      }

      return rows.map((row) {
        final id = row['id']?.toString() ?? '';
        if (id.isNotEmpty && byId.containsKey(id)) {
          row['sistem_pembayaran_bulan'] = byId[id];
        }
        return row;
      }).toList();
    } catch (_) {
      return rows;
    }
  }
}
