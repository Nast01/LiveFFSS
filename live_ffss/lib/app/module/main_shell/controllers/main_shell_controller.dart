import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void setIndex(int index) => selectedIndex.value = index;
}
