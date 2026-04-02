import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Profil View'),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 3),
    );
  }
}
