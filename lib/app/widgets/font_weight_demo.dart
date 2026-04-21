import 'package:flutter/material.dart';
import '../core/values/values.dart';

/// Widget demo untuk menampilkan berbagai font weight
/// Gunakan untuk melihat perbedaan visual antara weight yang berbeda
class FontWeightDemo extends StatelessWidget {
  const FontWeightDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Weight Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro
            Text(
              'Font Weight Comparison',
              style: AppTextStyles.headlineSmall.colored(AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Lihat perbedaan visual antara berbagai font weight',
              style: AppTextStyles.body14.colored(AppColors.textTertiary),
            ),
            const SizedBox(height: 24),

            // Helvetica Neue Demo
            _buildSection(
              'Helvetica Neue',
              'Font untuk Header & Sub Judul',
              'Helvetica Neue',
            ),

            const SizedBox(height: 32),

            // SF Pro Demo
            _buildSection(
              'SF Pro',
              'Font untuk Deskripsi & Body Text',
              'SF Pro',
            ),

            const SizedBox(height: 32),

            // AppTextStyles Demo
            _buildAppStylesSection(),

            const SizedBox(height: 32),

            // Interactive Demo
            _buildInteractiveDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, String fontFamily) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.header18.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.body12.colored(AppColors.textTertiary),
          ),
          const SizedBox(height: 20),

          // Weight demos
          _buildWeightRow('w100 - Thin', FontWeight.w100, fontFamily),
          _buildWeightRow('w200 - Ultralight', FontWeight.w200, fontFamily),
          _buildWeightRow('w300 - Light', FontWeight.w300, fontFamily),
          _buildWeightRow('w400 - Regular', FontWeight.w400, fontFamily, highlight: true),
          _buildWeightRow('w500 - Medium', FontWeight.w500, fontFamily, highlight: true),
          _buildWeightRow('w600 - Semibold', FontWeight.w600, fontFamily),
          _buildWeightRow('w700 - Bold', FontWeight.w700, fontFamily, highlight: true),
          _buildWeightRow('w800 - Extra Bold', FontWeight.w800, fontFamily),
          _buildWeightRow('w900 - Black', FontWeight.w900, fontFamily),
        ],
      ),
    );
  }

  Widget _buildWeightRow(
    String label,
    FontWeight weight,
    String fontFamily, {
    bool highlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primaryLighter : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.body12.colored(
                highlight ? AppColors.primary : AppColors.textGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'The quick brown fox',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 16,
                fontWeight: weight,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppStylesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AppTextStyles Preview',
            style: AppTextStyles.header18.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Style yang sudah tersedia di aplikasi',
            style: AppTextStyles.body12.colored(AppColors.textTertiary),
          ),
          const SizedBox(height: 20),

          // Headers
          _buildStylePreview(
            'Headers (Bold)',
            [
              ('headlineSmall', AppTextStyles.headlineSmall, '24px'),
              ('header20', AppTextStyles.header20, '20px'),
              ('header18', AppTextStyles.header18, '18px'),
              ('header16', AppTextStyles.header16, '16px'),
            ],
          ),

          const Divider(height: 32),

          // Sub Judul
          _buildStylePreview(
            'Sub Judul (Medium)',
            [
              ('subtitle18', AppTextStyles.subtitle18, '18px'),
              ('titleMedium', AppTextStyles.titleMedium, '16px'),
              ('subtitle14', AppTextStyles.subtitle14, '14px'),
              ('subtitle12', AppTextStyles.subtitle12, '12px'),
            ],
          ),

          const Divider(height: 32),

          // Body
          _buildStylePreview(
            'Body Text (Regular)',
            [
              ('body16', AppTextStyles.body16, '16px'),
              ('body14', AppTextStyles.body14, '14px'),
              ('body12', AppTextStyles.body12, '12px'),
              ('body10', AppTextStyles.body10, '10px'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStylePreview(
    String category,
    List<(String, TextStyle, String)> styles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: AppTextStyles.subtitle14.colored(AppColors.textGray),
        ),
        const SizedBox(height: 12),
        ...styles.map((style) {
          final (name, textStyle, size) = style;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    name,
                    style: AppTextStyles.body10.colored(AppColors.textTertiary),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    size,
                    style: AppTextStyles.body10.colored(AppColors.textLight),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sample Text',
                    style: textStyle.colored(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInteractiveDemo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hierarki Font Weight',
            style: AppTextStyles.header18.colored(Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Dari paling tipis ke paling tebal',
            style: AppTextStyles.body12.colored(Colors.white70),
          ),
          const SizedBox(height: 20),

          // Visual hierarchy
          _buildHierarchyItem('Header', FontWeight.w700, 1.0),
          _buildHierarchyItem('Sub Judul', FontWeight.w500, 0.8),
          _buildHierarchyItem('Body Text', FontWeight.w400, 0.6),
          _buildHierarchyItem('Secondary', FontWeight.w300, 0.4),
        ],
      ),
    );
  }

  Widget _buildHierarchyItem(String label, FontWeight weight, double opacity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Helvetica Neue',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The quick brown fox jumps',
                  style: TextStyle(
                    fontFamily: 'Helvetica Neue',
                    fontSize: 16,
                    fontWeight: weight,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
