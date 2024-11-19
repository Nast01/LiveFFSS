import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/src/screens/home_screen.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
  //runApp(MyApp(settingsController: settingsController));
}
