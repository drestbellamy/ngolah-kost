import 'package:supabase_flutter/supabase_flutter.dart';

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
}
