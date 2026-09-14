import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/sites_controller.dart';

class SitesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SitesController>(
      () => SitesController(Get.find<ProgrammeService>()),
    );
  }
}
