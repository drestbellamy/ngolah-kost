import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/kost/models/kost_model.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // LOGIN
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .eq('password', password)
        .maybeSingle();

    return data;
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
}
