import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_tagihan_controller.dart';

class KelolaTagihanView extends GetView<KelolaTagihanController> {
  const KelolaTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tagihan'),
      ),
      body: const Center(
        child: Text('Kelola Tagihan View'),
      ),
    );
  }
}
