import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';

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
                      'races'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter tabs
                    _buildFilterTabs(),

                    const SizedBox(height: 16),
                    // Races list
                    if (controller.filteredRaces.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No races',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: controller.filteredRaces.map((race) {
                          return _buildRaceItem(race.label, race.raceType);
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    final controller = Get.find<CompetitionDetailController>();

    return Obx(() {
      return Container(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterTab('all'.tr, 0, controller.selectedFilterIndex.value),
            const SizedBox(width: 8),
            _buildFilterTab(
                'beach'.tr, 1, controller.selectedFilterIndex.value),
            const SizedBox(width: 8),
            _buildFilterTab(
                'swimming'.tr, 2, controller.selectedFilterIndex.value),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTab(String title, int index, int selectedIndex) {
    final controller = Get.find<CompetitionDetailController>();
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        controller.setFilterIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRaceItem(String name, String type) {
    return GestureDetector(
      onTap: () {
        // Navigate to epreuve details or switch to epreuves tab
        Get.find<CompetitionDetailController>().changeTab(1);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Purple circle avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    type == 'Eau-plate' ? Colors.blue[100] : Colors.yellow[100],
                shape: BoxShape.circle,
                border: Border.all(
                    color: type == 'Eau-plate'
                        ? Colors.blue[300]!
                        : Colors.yellow[300]!,
                    width: 2),
              ),
              child: Icon(
                type == 'Eau-plate' ? Icons.pool : Icons.kayaking,
                color:
                    type == 'Eau-plate' ? Colors.blue[700] : Colors.yellow[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Epreuve name
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
