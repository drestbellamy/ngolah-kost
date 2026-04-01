import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_peraturan_controller.dart';

class KelolaPeraturanView extends GetView<KelolaPeraturanController> {
  const KelolaPeraturanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Peraturan')),
      body: const Center(child: Text('Kelola Peraturan View')),
    );
  }
}
