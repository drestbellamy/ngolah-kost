import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengumuman_controller.dart';

class KelolaPengumumanView extends GetView<KelolaPengumumanController> {
  const KelolaPengumumanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengumuman'),
      ),
      body: const Center(
        child: Text('Kelola Pengumuman View'),
      ),
    );
  }
}
