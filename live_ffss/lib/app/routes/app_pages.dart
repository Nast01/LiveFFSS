import 'package:get/get.dart';
import 'package:live_ffss/app/module/auth/bindings/auth_binding.dart';
import 'package:live_ffss/app/module/auth/bindings/profile_binding.dart';
import 'package:live_ffss/app/module/auth/bindings/user_binding.dart';
import 'package:live_ffss/app/module/auth/views/login_view.dart';
import 'package:live_ffss/app/module/auth/views/profile_view.dart';
import 'package:live_ffss/app/module/competitions/bindings/competition_detail_binding.dart';
import 'package:live_ffss/app/module/competitions/bindings/race_detail_binding.dart';
import 'package:live_ffss/app/module/competitions/bindings/rfid_writer_binding.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_view.dart';
import 'package:live_ffss/app/module/competitions/views/race_detail_view.dart';
import 'package:live_ffss/app/module/competitions/views/rfid_writer_view.dart';
import 'package:live_ffss/app/module/favorites/bindings/favorites_binding.dart';
import 'package:live_ffss/app/module/home/bindings/home_binding.dart';
import 'package:live_ffss/app/module/main_shell/bindings/main_shell_binding.dart';
import 'package:live_ffss/app/module/main_shell/views/main_shell_view.dart';
import 'package:live_ffss/app/module/program/bindings/program_binding.dart';
import 'package:live_ffss/app/module/program/views/program_view.dart';
import 'package:live_ffss/app/module/slot/bindings/slot_binding.dart';
import 'package:live_ffss/app/module/slot/views/slot_view.dart';
// Import other views and bindings as needed

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const MainShellView(),
      bindings: [
        MainShellBinding(),
        HomeBinding(),
        FavoritesBinding(),
        UserBinding(),
      ],
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.competitionDetail,
      page: () => const CompetitionDetailView(),
      binding: CompetitionDetailBinding(),
    ),
    GetPage(
      name: Routes.raceDetail,
      page: () => const RaceDetailView(),
      binding: RaceDetailBinding(),
    ),
    GetPage(
      name: Routes.rfidWriter,
      page: () => const RfidWriterView(),
      binding: RfidWriterBinding(),
    ),
    GetPage(
      name: Routes.program,
      page: () => const ProgramView(),
      binding: ProgramBinding(),
    ),
    GetPage(
      name: Routes.slot,
      page: () => const SlotView(),
      binding: SlotBinding(),
    ),
  ];
}
