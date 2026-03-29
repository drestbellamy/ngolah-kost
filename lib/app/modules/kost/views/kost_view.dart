import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kost_controller.dart';

class KostView extends GetView<KostController> {
  const KostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kost'),
      ),
      body: const Center(
        child: Text('Kost View'),
      ),
    );
  }
}
