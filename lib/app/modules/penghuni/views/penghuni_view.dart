import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/penghuni_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class PenghuniView extends GetView<PenghuniController> {
  const PenghuniView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Penghuni'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Penghuni View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 2),
    );
  }
}
