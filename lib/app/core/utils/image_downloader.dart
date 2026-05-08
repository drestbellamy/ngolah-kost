import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/toast_helper.dart';

class ImageDownloader {
  static Future<bool> downloadImage(String imageUrl, String fileName) async {
    try {
      // Request storage permission based on Android version
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Android 13+ (API 33+) tidak perlu permission storage untuk download
        if (androidInfo.version.sdkInt < 33) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            ToastHelper.showWarning(
              'Izin penyimpanan diperlukan untuk download gambar',
              title: 'Izin Ditolak',
            );
            return false;
          }
        }
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // Navigate to Download folder
        String newPath = '';
        List<String> paths = directory!.path.split('/');
        for (int i = 1; i < paths.length; i++) {
          String folder = paths[i];
          if (folder != 'Android') {
            newPath += '/$folder';
          } else {
            break;
          }
        }
        newPath = '$newPath/Download';
        directory = Directory(newPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create directory if not exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download file
      final filePath = '${directory.path}/$fileName';
      final dio = Dio();

      await dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      ToastHelper.showSuccess(
        'QR Code berhasil disimpan di folder Download',
        title: 'Download Berhasil',
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('Error downloading image: $e');
      ToastHelper.showError(
        'Terjadi kesalahan saat download: ${e.toString()}',
        title: 'Download Gagal',
      );
      return false;
    }
  }
}
