import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';

class LanguageSelector extends GetWidget<HomeController> {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String languageCode) {
        controller.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en_US',
          child: Row(
            children: [
              const Text('🇺🇸 '),
              Text('english'.tr),
              if (controller.currentLanguage.value == 'en_US')
                const Icon(Icons.check, size: 18),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr_FR',
          child: Row(
            children: [
              const Text('🇫🇷 '),
              Text('french'.tr),
              if (controller.currentLanguage.value == 'fr_FR')
                const Icon(Icons.check, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
