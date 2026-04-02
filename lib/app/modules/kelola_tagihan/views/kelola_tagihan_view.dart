import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_tagihan_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class KelolaTagihanView extends GetView<KelolaTagihanController> {
  const KelolaTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Kelola Tagihan'),
      ),
      body: const Center(
        child: Text('Kelola Tagihan View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: -1),
    );
  }
}
