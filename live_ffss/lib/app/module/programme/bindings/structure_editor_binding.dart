import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/structure_editor_controller.dart';

class StructureEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StructureEditorController>(
      () => StructureEditorController(
        Get.find<ProgrammeService>(),
        Get.find<RaceFormatRepository>(),
      ),
    );
  }
}
