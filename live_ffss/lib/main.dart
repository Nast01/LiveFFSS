import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_ffss/src/controllers/competition_controller.dart';
import 'package:live_ffss/src/screens/home_screen.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();

  Get.put(CompetitionController());

  runApp(const FFSSApp());
  // runApp(GetMaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   home: HomeScreen(),
  // ));
  //runApp(MyApp(settingsController: settingsController));
}

class FFSSApp extends StatelessWidget {
  const FFSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme, // Ensure it adapts to the current theme
        ),
      ),
      home: HomeScreen(),
    );
  }
}
