import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/favorites/views/favorites_view.dart';
import 'package:live_ffss/app/module/home/views/home_view.dart';
import 'package:live_ffss/app/module/main_shell/controllers/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static const _tabs = <Widget>[
    HomeView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: _tabs,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.setIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.star_border),
                activeIcon: const Icon(Icons.star),
                label: 'favorites'.tr,
              ),
            ],
          )),
    );
  }
}
