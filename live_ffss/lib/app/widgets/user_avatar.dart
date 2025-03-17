import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import '../data/services/user_service.dart';
import '../routes/app_pages.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = Get.find<UserService>();

    return Obx(() {
      final isLoggedIn = userService.isLoggedIn;
      final firstLetter = userService.userFirstLetter;

      return GestureDetector(
        onTap: () {
          if (isLoggedIn) {
            // Show user options menu
            _showUserMenu(context);
          } else {
            // Navigate to login page
            Get.toNamed(Routes.login);
          }
        },
        child: CircleAvatar(
          radius: size / 3,
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          child: isLoggedIn && firstLetter != null
              ? Text(
                  firstLetter,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: textColor ?? Colors.white,
                  size: size * 0.6,
                ),
        ),
      );
    });
  }

  void _showUserMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 8),
              Text('profile'.tr),
            ],
          ),
          onTap: () {
            // Navigate to profile
            Future.delayed(
              const Duration(seconds: 0),
              () => Get.toNamed(Routes.profile),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 8),
              Text('settings'.tr),
            ],
          ),
          onTap: () {
            // Navigate to settings
            Future.delayed(
              const Duration(seconds: 0),
              () => Get.toNamed(Routes.settings),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20),
              const SizedBox(width: 8),
              Text('logout'.tr),
            ],
          ),
          onTap: () {
            // Logout
            Future.delayed(
              const Duration(seconds: 0),
              () => Get.find<AuthController>().logout(),
            );
          },
        ),
      ],
    );
  }
}
