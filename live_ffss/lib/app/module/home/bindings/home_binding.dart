import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
