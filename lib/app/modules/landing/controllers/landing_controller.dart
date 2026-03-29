import 'package:get/get.dart';

class LandingController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  void navigateToLogin() {
    Get.toNamed('/login');
  }
}
