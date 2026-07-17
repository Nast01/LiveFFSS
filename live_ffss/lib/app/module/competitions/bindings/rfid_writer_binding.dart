import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import '../controllers/rfid_writer_controller.dart';

class RfidWriterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RfidWriterController>(
      () => RfidWriterController(
        Get.find<ClubRepository>(),
        Get.find<RfidWriter>(),
      ),
    );
  }
}
