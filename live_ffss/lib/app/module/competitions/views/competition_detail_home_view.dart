import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_races_view.dart';

class CompetitionDetailHomeView extends GetView<CompetitionDetailController> {
  const CompetitionDetailHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final competition = controller.competition.value;
        final limitedClubRankings = controller.clubRankingsLimited;

        if (competition == null) {
          return Center(
            child: Text(
              'no_competition_selected'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classement Clubs Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'clubs_ranking'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header row
                    Table(
                      children: [
                        TableRow(
                          decoration:
                              const BoxDecoration(color: Color(0xFFf8f9fe)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('rank'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('club'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('points'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        for (var i = 1; i <= limitedClubRankings.length; i++)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("$i"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Club $i",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign:
                                      TextAlign.left, // Align text to the left
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${100 * i}"),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Classement complet button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            controller.changeTab(3), // Navigate to club ranking
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0275FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(100, 36),
                        ),
                        child: Text(
                          'complete_ranking'.tr,
                          style: const TextStyle(
                            color: Color(0xFF0275FF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // EPREUVES Section
              const CompetitionDetailRacesView(),
            ],
          ),
        );
      },
    );
  }
}
