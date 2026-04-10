import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class AdminOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }

    if (!authController.isAdmin) {
      return const RouteSettings(name: Routes.userHome);
    }

    return null;
  }
}

class UserOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }

    if (!authController.isUser) {
      return const RouteSettings(name: Routes.home);
    }

    return null;
  }
}
