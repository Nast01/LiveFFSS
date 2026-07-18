import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/structure_editor_controller.dart';

class StructureEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StructureEditorController>(
      () => StructureEditorController(Get.find<ProgrammeService>()),
    );
  }
}
