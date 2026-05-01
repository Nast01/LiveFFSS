import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/module/main_shell/controllers/main_shell_controller.dart';

void main() {
  group('MainShellController', () {
    test('selectedIndex starts at 0', () {
      final controller = MainShellController();
      expect(controller.selectedIndex.value, 0);
    });

    test('setIndex updates selectedIndex', () {
      final controller = MainShellController();
      controller.setIndex(1);
      expect(controller.selectedIndex.value, 1);
      controller.setIndex(0);
      expect(controller.selectedIndex.value, 0);
    });
  });
}
