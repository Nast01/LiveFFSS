import 'package:get/get.dart';
import 'package:live_ffss/app/module/auth/bindings/auth_binding.dart';
import 'package:live_ffss/app/module/auth/bindings/profile_binding.dart';
import 'package:live_ffss/app/module/auth/bindings/user_binding.dart';
import 'package:live_ffss/app/module/auth/views/login_view.dart';
import 'package:live_ffss/app/module/auth/views/profile_view.dart';
import 'package:live_ffss/app/module/competitions/bindings/competition_detail_binding.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_view.dart';
import 'package:live_ffss/app/module/home/bindings/home_binding.dart';
import 'package:live_ffss/app/module/home/views/home_view.dart';
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
      page: () => const HomeView(),
      bindings: [
        HomeBinding(),
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
      bindings: [
        CompetitionDetailBinding(),
        ProgramBinding(), // Ensure ProgramBinding is included if needed
      ],
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
