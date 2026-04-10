import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/kost/models/kost_model.dart';
import '../app/modules/login/models/login_user_model.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // CREATE USER PENGHUNI (secure via RPC)
  Future<String> createPenghuniUserSecure({
    required String nama,
    required String noTlpn,
    required String username,
    required String password,
    String? kostPrefix,
  }) async {
    final baseParams = {
      'p_nama': nama,
      'p_no_tlpn': noTlpn,
      'p_username': username,
      'p_password': password,
      'p_role': 'user',
    };

    dynamic response;
    try {
      final paramsWithPrefix = Map<String, dynamic>.from(baseParams);
      if (kostPrefix != null && kostPrefix.trim().isNotEmpty) {
        paramsWithPrefix['p_prefix'] = kostPrefix.trim().toUpperCase();
      }

      response = await supabase.rpc(
        'create_user_secure',
        params: paramsWithPrefix,
      );
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();

      // Backward compatibility if DB function still uses old signature.
      if (message.contains('p_prefix') || message.contains('function')) {
        response = await supabase.rpc('create_user_secure', params: baseParams);
      } else {
        rethrow;
      }
    }

    if (response is List && response.isNotEmpty) {
      final row = Map<String, dynamic>.from(response.first as Map);
      return (row['id'] ?? '').toString();
    }

    if (response is Map<String, dynamic>) {
      return (response['id'] ?? '').toString();
    }

    throw Exception('Gagal membuat user penghuni');
  }

  // LOGIN
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

  // GET USERS
  Future<List<dynamic>> getUsers() async {
    return await supabase.from('users').select();
  }

  // GET KOST
  Future<List<KostModel>> getKostList() async {
    final List<dynamic> response = await supabase
        .from('kost')
        .select('id, nama_kost, alamat, total_kamar, created_at')
        .order('created_at', ascending: false);

    return response
        .map((item) => KostModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // INSERT KOST
  Future<void> createKost({
    required String namaKost,
    required String alamat,
    required int totalKamar,
  }) async {
    await supabase.from('kost').insert({
      'nama_kost': namaKost,
      'alamat': alamat,
      'total_kamar': totalKamar,
    });
  }

  // UPDATE KOST
  Future<void> updateKost({
    required String id,
    required String namaKost,
    required String alamat,
    required int totalKamar,
  }) async {
    await supabase
        .from('kost')
        .update({
          'nama_kost': namaKost,
          'alamat': alamat,
          'total_kamar': totalKamar,
        })
        .eq('id', id);
  }

  // DELETE KOST
  Future<void> deleteKost(String id) async {
    await supabase.from('kost').delete().eq('id', id);
  }

  // GET KAMAR BY KOST
  Future<List<Map<String, dynamic>>> getKamarByKostId(String kostId) async {
    final List<dynamic> response = await supabase
        .from('kamar')
        .select('id, kost_id, no_kamar, harga, kapasitas, status, created_at')
        .eq('kost_id', kostId)
        .order('created_at', ascending: false);

    return response.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // INSERT KAMAR
  Future<void> createKamar({
    required String kostId,
    required String noKamar,
    required int harga,
    required int kapasitas,
    String status = 'kosong',
  }) async {
    await supabase.from('kamar').insert({
      'kost_id': kostId,
      'no_kamar': noKamar,
      'harga': harga,
      'kapasitas': kapasitas,
      'status': status,
    });
  }

  // UPDATE KAMAR
  Future<void> updateKamar({
    required String id,
    required String noKamar,
    required int harga,
    required int kapasitas,
    required String status,
  }) async {
    await supabase
        .from('kamar')
        .update({
          'no_kamar': noKamar,
          'harga': harga,
          'kapasitas': kapasitas,
          'status': status,
        })
        .eq('id', id);
  }

  // DELETE KAMAR
  Future<void> deleteKamar(String id) async {
    await supabase.from('kamar').delete().eq('id', id);
  }

  // UPDATE STATUS KAMAR
  Future<void> updateKamarStatus({
    required String id,
    required String status,
  }) async {
    await supabase.from('kamar').update({'status': status}).eq('id', id);
  }

  // INSERT PENGHUNI
  Future<String> createPenghuni({
    String? userId,
    required String kamarId,
    required int durasiKontrak,
    int? sistemPembayaranBulan,
    required DateTime tanggalMasuk,
    required DateTime tanggalKeluar,
    String status = 'aktif',
  }) async {
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
          .from('penghuni')
          .insert(payload)
          .select('id')
          .single();
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility for DB schema that does not have
      // sistem_pembayaran_bulan yet.
      if (payload.containsKey('sistem_pembayaran_bulan') &&
          message.contains('sistem_pembayaran_bulan')) {
        payload.remove('sistem_pembayaran_bulan');
        inserted = await supabase
            .from('penghuni')
            .insert(payload)
            .select('id')
            .single();
      } else {
        rethrow;
      }
    }

    if (inserted is Map<String, dynamic>) {
      return (inserted['id'] ?? '').toString();
    }

    if (inserted is Map) {
      return (inserted['id'] ?? '').toString();
    }

    throw Exception('Gagal membuat data penghuni');
  }

  // GET PENGHUNI BY KAMAR
  Future<List<Map<String, dynamic>>> getPenghuniByKamarId(
    String kamarId,
  ) async {
    try {
      final response = await supabase.rpc(
        'get_penghuni_by_kamar_secure',
        params: {'p_kamar_id': kamarId},
      );

      if (response is List) {
        final rows = response
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        return await _attachSistemPembayaranBulan(rows, kamarId);
      }
    } catch (_) {
      // Fallback to direct join query if RPC is not available yet.
    }

    final List<dynamic> fallback = await supabase
        .from('penghuni')
        .select(
          'id, user_id, kamar_id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, created_at, users:user_id(id, nama, no_tlpn, username)',
        )
        .eq('kamar_id', kamarId)
        .order('created_at', ascending: false);

    return fallback.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // GET SINGLE PENGHUNI DETAIL (enriched for detail page refresh)
  Future<Map<String, dynamic>?> getPenghuniDetailById(String penghuniId) async {
    if (penghuniId.trim().isEmpty) return null;

    try {
      final raw = await supabase
          .from('penghuni')
          .select(
            'id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, users:user_id(nama, no_tlpn), kamar:kamar_id(no_kamar, harga, kost:kost_id(nama_kost))',
          )
          .eq('id', penghuniId)
          .maybeSingle();

      final map = _asStringMap(raw);
      if (map != null && map.isNotEmpty) {
        final user = _asStringMap(map['users']) ?? <String, dynamic>{};
        final kamar = _asStringMap(map['kamar']) ?? <String, dynamic>{};
        final kost = _asStringMap(kamar['kost']) ?? <String, dynamic>{};

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
    } catch (_) {
      // Fall back to scan-based approach below.
    }

    // Fallback that reuses existing RLS-safe penghuni reader.
    final kosts = await getKostList();
    for (final kost in kosts) {
      final kamarList = await getKamarByKostId(kost.id);
      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final rows = await getPenghuniByKamarId(kamarId);
        for (final row in rows) {
          final id = row['id']?.toString() ?? '';
          if (id != penghuniId) continue;

          final user = _asStringMap(row['users']) ?? <String, dynamic>{};
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

    return null;
  }

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
          .from('penghuni')
          .select('id, sistem_pembayaran_bulan')
          .eq('kamar_id', kamarId);

      if (raw is! List) return rows;

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

  // GET PENGHUNI COUNT BY KAMAR
  Future<int> getPenghuniCountByKamarId(String kamarId) async {
    final response = await supabase
        .from('penghuni')
        .select('id')
        .eq('kamar_id', kamarId);

    if (response is List) {
      return response.length;
    }

    return 0;
  }

  // UPDATE KONTRAK PENGHUNI
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
      await supabase.from('penghuni').update(payload).eq('id', penghuniId);
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility if schema has not added sistem_pembayaran_bulan.
      if (message.contains('sistem_pembayaran_bulan')) {
        payload.remove('sistem_pembayaran_bulan');
        await supabase.from('penghuni').update(payload).eq('id', penghuniId);
      } else {
        rethrow;
      }
    }
  }

  // SINKRON TAGIHAN BERDASARKAN KONTRAK (idempotent)
  Future<void> sinkronTagihanKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.trim().isEmpty || durasiKontrakBulan <= 0) return;
    if (hargaBulanan <= 0) return;

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);
    final totalTagihan = (durasiKontrakBulan / siklus).ceil();
    final jumlahPerTagihan = hargaBulanan * siklus;

    final payload = <Map<String, dynamic>>[];

    for (var i = 0; i < totalTagihan; i++) {
      final periode = DateTime(
        tanggalMasuk.year,
        tanggalMasuk.month + (i * siklus),
        1,
      );

      payload.add({
        'penghuni_id': penghuniId,
        'bulan': periode.month,
        'tahun': periode.year,
        'jumlah': jumlahPerTagihan,
        'status': 'belum_dibayar',
      });
    }

    // Rebuild unpaid schedule from scratch so old periods don't linger in kelola tagihan.
    await supabase
        .from('tagihan')
        .delete()
        .eq('penghuni_id', penghuniId)
        .neq('status', 'lunas');

    if (payload.isEmpty) return;

    await supabase
        .from('tagihan')
        .upsert(
          payload,
          onConflict: 'penghuni_id,bulan,tahun',
          ignoreDuplicates: true,
        );
  }

  // AKHIRI KONTRAK PENGHUNI
  Future<void> akhiriKontrakPenghuni({required String penghuniId}) async {
    if (penghuniId.trim().isEmpty) {
      throw Exception('ID penghuni tidak valid');
    }

    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;

    final raw = await supabase
        .from('penghuni')
        .select('id, kamar_id')
        .eq('id', penghuniId)
        .maybeSingle();

    final row = _asStringMap(raw);

    final kamarId = row?['kamar_id']?.toString() ?? '';

    await supabase
        .from('penghuni')
        .update({'status': 'berakhir', 'tanggal_keluar': today})
        .eq('id', penghuniId);

    final pending = await supabase
        .from('tagihan')
        .select('id, bulan, tahun, status')
        .eq('penghuni_id', penghuniId)
        .eq('status', 'belum_dibayar');

    if (pending is List) {
      for (final item in pending) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final bulan = _toInt(map['bulan']);
        final tahun = _toInt(map['tahun']);
        final isFuture =
            tahun > now.year || (tahun == now.year && bulan > now.month);

        if (isFuture) {
          await supabase.from('tagihan').delete().eq('id', id);
        }
      }
    }

    if (kamarId.isNotEmpty) {
      final activeRows = await supabase
          .from('penghuni')
          .select('id')
          .eq('kamar_id', kamarId)
          .eq('status', 'aktif');

      final activeCount = activeRows is List ? activeRows.length : 0;

      final kamarRaw = await supabase
          .from('kamar')
          .select('kapasitas')
          .eq('id', kamarId)
          .maybeSingle();

      final kamarMap = _asStringMap(kamarRaw);
      final kapasitas = _toInt(kamarMap?['kapasitas']);

      await supabase
          .from('kamar')
          .update({
            'status': _kamarStatusByOccupancy(
              activeCount,
              kapasitas <= 0 ? 1 : kapasitas,
            ),
          })
          .eq('id', kamarId);
    }
  }

  // INSERT TAGIHAN OTOMATIS BERDASARKAN KONTRAK
  Future<void> createTagihanOtomatis({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.isEmpty || durasiKontrakBulan <= 0 || hargaBulanan <= 0) {
      return;
    }

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);
    final totalTagihan = (durasiKontrakBulan / siklus).ceil();
    final jumlahPerTagihan = hargaBulanan * siklus;

    final payload = <Map<String, dynamic>>[];
    for (var i = 0; i < totalTagihan; i++) {
      final periode = DateTime(
        tanggalMasuk.year,
        tanggalMasuk.month + (i * siklus),
        1,
      );

      payload.add({
        'penghuni_id': penghuniId,
        'bulan': periode.month,
        'tahun': periode.year,
        'jumlah': jumlahPerTagihan,
        'status': 'belum_dibayar',
      });
    }

    if (payload.isEmpty) return;
    await supabase
        .from('tagihan')
        .upsert(
          payload,
          onConflict: 'penghuni_id,bulan,tahun',
          ignoreDuplicates: true,
        );
  }

  // GET TAGIHAN (enriched with penghuni, kamar, and kost labels)
  Future<List<Map<String, dynamic>>> getTagihanList() async {
    final raw = await supabase
        .from('tagihan')
        .select('id, penghuni_id, bulan, tahun, jumlah, status, created_at')
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) return [];

    final rows = raw.map((item) => Map<String, dynamic>.from(item)).toList();
    if (rows.isEmpty) return rows;

    final penghuniLookup = await _buildPenghuniLookup();

    return rows.map((row) {
      final penghuniId = row['penghuni_id']?.toString() ?? '';
      final info = penghuniLookup[penghuniId] ?? const <String, String>{};

      row['nama_penghuni'] = info['nama'] ?? 'Penghuni';
      row['nomor_kamar'] = info['nomor_kamar'] ?? '-';
      row['nama_kost'] = info['nama_kost'] ?? '-';
      return row;
    }).toList();
  }

  // GET TAGIHAN BY PENGHUNI
  Future<List<Map<String, dynamic>>> getTagihanByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) return [];

    final raw = await supabase
        .from('tagihan')
        .select('id, penghuni_id, bulan, tahun, jumlah, status, created_at')
        .eq('penghuni_id', penghuniId)
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) return [];
    return raw.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, Map<String, String>>> _buildPenghuniLookup() async {
    final lookup = <String, Map<String, String>>{};

    final kosts = await getKostList();
    for (final kost in kosts) {
      final kamarList = await getKamarByKostId(kost.id);

      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final penghuniRows = await getPenghuniByKamarId(kamarId);
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

    return lookup;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is! Map) return null;

    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  String _kamarStatusByOccupancy(int terisi, int kapasitas) {
    if (terisi <= 0) return 'kosong';
    if (terisi >= kapasitas) return 'penuh';
    return 'terisi';
  }
}
