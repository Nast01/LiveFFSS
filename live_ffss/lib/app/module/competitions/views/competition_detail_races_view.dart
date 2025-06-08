import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';

class CompetitionDetailRacesView extends GetView<CompetitionDetailController> {
  const CompetitionDetailRacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    });
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
