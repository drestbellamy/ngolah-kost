import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kost_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class KostView extends GetView<KostController> {
  const KostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Kost'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Kost View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }
}
