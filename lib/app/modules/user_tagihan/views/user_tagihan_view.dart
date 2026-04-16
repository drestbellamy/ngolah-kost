import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../controllers/user_tagihan_controller.dart';
import 'widgets/tagihan_total_card.dart';
import 'widgets/tagihan_list_section.dart';
import 'widgets/payment_method_section.dart';

class UserTagihanView extends GetView<UserTagihanController> {
  const UserTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header melengkung persis gambar
          SafeArea(
            bottom: false,
            child: CustomHeader(
              title: 'Tagihan',
              subtitle: 'Lihat Semua Tagihan',
              showBackButton: false,
            ),
          ),

          // Total Card
          const TagihanTotalCard(),

          // List Tagihan List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshData(),
              color: const Color(0xFF6B8E7A),
              child: CustomScrollView(
                slivers: [
                  // Tagihan List Section
                  const TagihanListSection(),

                  // Payment Method Section
                  const PaymentMethodSection(),
                ], // end slivers array
              ), // end CustomScrollView
            ), // end RefreshIndicator
          ), // end Expanded
        ], // end Column children
      ), // end Column
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 1),
    );
  }
}
