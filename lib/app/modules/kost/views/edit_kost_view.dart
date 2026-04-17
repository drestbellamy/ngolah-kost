import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../controllers/kost_controller.dart';

class EditKostView extends GetView<KostController> {
  const EditKostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Custom Header
            const CustomHeader(
              title: 'Edit Kost',
              subtitle: 'Perbarui informasi properti Anda',
              showBackButton: true,
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Kost
                      Row(
                        children: [
                          const Icon(
                            Icons.apartment,
                            size: 20,
                            color: Color(0xFF6B8E7F),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Nama Kost',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          hintText: 'Misal: Peaceful Haven Kost',
                          hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6B8E7F),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alamat Lengkap
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Color(0xFF6B8E7F),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Alamat Lengkap',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Location Buttons
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: controller.isLoadingLocation.value
                                    ? null
                                    : () {
                                        controller.getCurrentLocation();
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0ED),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFC4D5CE),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if (controller.isLoadingLocation.value)
                                        const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF6B8E7F),
                                          ),
                                        )
                                      else ...[
                                        const Icon(
                                          Icons.my_location,
                                          size: 28,
                                          color: Color(0xFF6B8E7F),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Lokasi Saat Ini',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF4A5568),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 14,
                                                color: Color(0xFF5B88E5),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Sesuaikan detail lokasi \n secara manual',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                  color: Color(0xFF5B88E5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.openMapPicker(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0ED),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFC4D5CE),
                                    ),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(
                                        Icons.map_outlined,
                                        size: 28,
                                        color: Color(0xFF6B8E7F),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Pilih di Peta',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4A5568),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 14,
                                              color: Color(0xFF5B88E5),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Sesuaikan detail lokasi \n secara manual',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFF5B88E5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Manual Address Input
                      TextField(
                        controller: controller.addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Atau ketik alamat lengkap secara\nmanual',
                          hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6B8E7F),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pastikan izin akses lokasi aktif di browser/perangkat Anda untuk menggunakan fitur ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA0AEC0),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jumlah Kamar
                      const Text(
                        'Jumlah Kamar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.roomCountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Misal: 10',
                          hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6B8E7F),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.updateKost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B8E7F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Kost',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
