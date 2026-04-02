import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_peraturan_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class KelolaPeraturanView extends GetView<KelolaPeraturanController> {
  const KelolaPeraturanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Kelola Peraturan'),
      ),
      body: const Center(
        child: Text('Kelola Peraturan View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: -1),
    );
  }
}
