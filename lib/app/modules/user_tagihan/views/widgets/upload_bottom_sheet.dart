import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../controllers/user_tagihan_controller.dart';

void showUploadBottomSheet() {
  final controller = Get.find<UserTagihanController>();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  Get.bottomSheet(
    Obx(() {
      if (selectedImage.value == null) {
        // Step 1: Show image picker options
        return Container(
          padding: EdgeInsets.symmetric(horizontal: Get.context!.spacing(24), vertical: Get.context!.spacing(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Get.context!.borderRadius(20))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Get.context!.spacing(40),
                height: Get.context!.spacing(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(2)),
                ),
              ),
              SizedBox(height: Get.context!.spacing(24)),
              Text(
                'Unggah Bukti Pembayaran',
                style: TextStyle(
                  fontSize: Get.context!.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: Get.context!.spacing(24)),
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    selectedImage.value = image;
                  }
                },
                child: Container(
                  padding: Get.context!.allPadding(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: Get.context!.allPadding(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(Get.context!.borderRadius(10)),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: const Color(0xFFF59E0B),
                          size: Get.context!.iconSize(20),
                        ),
                      ),
                      SizedBox(width: Get.context!.spacing(16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih dari Galeri',
                            style: TextStyle(
                              fontSize: Get.context!.fontSize(14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Pilih foto yang sudah ada',
                            style: TextStyle(
                              fontSize: Get.context!.fontSize(12),
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: EdgeInsets.symmetric(vertical: Get.context!.spacing(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: Get.context!.fontSize(14),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
            ],
          ),
        );
      } else {
        // Step 2: Show image preview with confirm/cancel buttons
        return Container(
          padding: EdgeInsets.symmetric(horizontal: Get.context!.spacing(24), vertical: Get.context!.spacing(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Get.context!.borderRadius(20))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Get.context!.spacing(40),
                height: Get.context!.spacing(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(2)),
                ),
              ),
              SizedBox(height: Get.context!.spacing(24)),
              Text(
                'Preview Bukti Pembayaran',
                style: TextStyle(
                  fontSize: Get.context!.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
              // Image Preview
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: Get.context!.spacing(300)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                  child: Image.file(
                    File(selectedImage.value!.path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
              // Change Image Button
              TextButton.icon(
                onPressed: () {
                  selectedImage.value = null;
                },
                icon: Icon(Icons.refresh, size: Get.context!.iconSize(18)),
                label: const Text('Ganti Gambar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B8E7A),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: Get.context!.buttonHeight(48),
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.confirmUploadBuktiPembayaran(
                      selectedImage.value!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                    ),
                  ),
                  child: Text(
                    'Kirim Bukti Pembayaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Get.context!.fontSize(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.context!.spacing(12)),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: EdgeInsets.symmetric(vertical: Get.context!.spacing(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Get.context!.borderRadius(12)),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: Get.context!.fontSize(14),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.context!.spacing(16)),
            ],
          ),
        );
      }
    }),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
  );
}
