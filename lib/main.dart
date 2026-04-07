import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dajiymvbdpmeijvrqdus.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0',
  );

  runApp(MyApp());
}

// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ngolah Kost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8E7A)),
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
