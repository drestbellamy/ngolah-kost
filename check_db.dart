import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://dajiymvbdpmeijvrqdus.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0',
  );
  
  try {
    final response = await supabase.from('kost').select().limit(1);
    print(response);
  } catch (e) {
    print(e);
  }
}