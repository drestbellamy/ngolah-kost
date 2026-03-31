import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  final showContent = false.obs;
  final showDescription = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() {
    // Start logo animation after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      showContent.value = true;
    });
    
    // Show description after logo animation completes (1.5s + 0.8s animation)
    Future.delayed(const Duration(milliseconds: 2400), () {
      showDescription.value = true;
    });
  }

  void navigateToLogin() {
    Get.toNamed(Routes.login);
  }
}
