import 'package:get/get.dart';
import 'package:live_ffss/app/module/auth/bindings/auth_binding.dart';
import 'package:live_ffss/app/module/auth/views/login_view.dart';
import 'package:live_ffss/app/module/home/bindings/home_binding.dart';
import 'package:live_ffss/app/module/home/views/home_view.dart';
// Import other views and bindings as needed

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    // Add other routes here
  ];
}
