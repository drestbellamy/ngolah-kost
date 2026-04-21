import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/core/controllers/auth_controller.dart';
import 'app/core/controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  await Supabase.initialize(
    url: 'https://dajiymvbdpmeijvrqdus.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0',
  );

  final authController = Get.put(AuthController(), permanent: true);
  await authController.loadSession();

  // Initialize NotificationController after auth
  if (authController.currentUser != null) {
    Get.put(NotificationController(), permanent: true);
  }

  runApp(MyApp(initialRoute: authController.initialRoute));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    authController.startSessionGuard();
  });
}

// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ngolah Kost',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8E7A)),
        useMaterial3: true,
        textTheme: const TextTheme(
          // Headers - Helvetica Neue
          displayLarge: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 57, fontWeight: FontWeight.w400),
          displayMedium: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 45, fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 36, fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 32, fontWeight: FontWeight.w400),
          headlineMedium: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 28, fontWeight: FontWeight.w400),
          headlineSmall: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 24, fontWeight: FontWeight.w400),
          
          // Sub Judul - Helvetica Neue
          titleLarge: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 22, fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'Helvetica Neue', fontSize: 14, fontWeight: FontWeight.w500),
          
          // Deskripsi - SF Pro
          bodyLarge: TextStyle(fontFamily: 'SF Pro', fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'SF Pro', fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: 'SF Pro', fontSize: 12, fontWeight: FontWeight.w400),
          
          // Label - SF Pro
          labelLarge: TextStyle(fontFamily: 'SF Pro', fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontFamily: 'SF Pro', fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontFamily: 'SF Pro', fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      getPages: AppPages.routes,
    );
  }
}
