import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import '../controllers/program_controller.dart';

class ProgramBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<ProgramController>(() => ProgramController());
  }
}
