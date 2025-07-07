import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_clubs_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_home_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_races_view.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';
import 'package:live_ffss/app/module/program/views/program_view.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class CompetitionDetailView extends GetView<CompetitionDetailController> {
  const CompetitionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final competition = controller.competition.value;
      if (competition == null) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'competition'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: Text(
              'no_competition_selected'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${competition.formattedBeginDate} - ${competition.formattedEndDate}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                competition.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Tab content
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.currentTabIndex.value,
                      children: [
                        const CompetitionDetailHomeView(),
                        const CompetitionDetailRacesView(),
                        _buildProgramView(competition),
                        const CompetitionDetailClubsView(),
                      ],
                    )),
              ),
            ],
          );
        }),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Obx(() => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                currentIndex: controller.currentTabIndex.value,
                onTap: (index) {
                  controller.changeTab(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: 'home'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.list),
                    label: 'races'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.schedule),
                    label: 'program'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.leaderboard),
                    label: 'rankings'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.groups),
                    label: 'clubs'.tr,
                  ),
                ],
              )),
        ),
      );
    });
  }

  Widget _buildProgramView(competition) {
    // Get or create ProgramController and set the competition
    final programController = Get.find<ProgramController>();
    programController.setCompetition(competition);

    return const ProgramView();
  }
}
