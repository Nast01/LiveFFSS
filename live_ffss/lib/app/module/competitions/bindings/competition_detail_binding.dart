import 'package:get/get.dart';
import '../controllers/competition_detail_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionDetailController>(
        () => CompetitionDetailController());
  }
}
