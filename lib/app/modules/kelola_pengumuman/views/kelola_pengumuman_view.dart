import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengumuman_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class KelolaPengumumanView extends GetView<KelolaPengumumanController> {
  const KelolaPengumumanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Kelola Pengumuman'),
      ),
      body: const Center(
        child: Text('Kelola Pengumuman View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: -1),
    );
  }
}
