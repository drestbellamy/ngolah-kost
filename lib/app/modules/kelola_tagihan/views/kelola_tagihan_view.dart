import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/kelola_tagihan_controller.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chips_widget.dart';
import 'widgets/combined_filters_widget.dart';
import 'widgets/tagihan_list_widget.dart';

class KelolaTagihanView extends GetView<KelolaTagihanController> {
  const KelolaTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            CustomHeader(
              title: 'Kelola Tagihan',
              showBackButton: true,
              subtitleWidget: Obx(
                () => Text(
                  '${controller.getTotalTagihan()} tagihan',
                  style: AppTextStyles.body14.colored(const Color(0xFFA8D5BA)),
                ),
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTagihanData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      SearchBarWidget(
                        controller: controller.searchController,
                        onChanged: controller.searchTagihan,
                      ),

                      const SizedBox(height: 16),

                      // Filter Chips
                      const FilterChipsWidget(),

                      const SizedBox(height: 10),

                      // Combined Filters (Month & Kost) in One Row
                      const CombinedFiltersWidget(),

                      // Tagihan List
                      const TagihanListWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
