import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/penghuni_controller.dart';

class PenghuniView extends GetView<PenghuniController> {
  const PenghuniView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penghuni'),
      ),
      body: const Center(
        child: Text('Penghuni View'),
      ),
    );
  }
}
