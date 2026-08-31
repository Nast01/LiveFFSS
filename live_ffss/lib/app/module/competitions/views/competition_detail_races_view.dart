import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/filter_chip_bar.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

String _criterionKey(RaceFilter filter) => switch (filter) {
      RaceFilter.speciality => 'filter_speciality',
      RaceFilter.discipline => 'filter_discipline',
      RaceFilter.gender => 'filter_gender',
      RaceFilter.category => 'filter_category',
    };

class CompetitionDetailRacesView
    extends GetView<CompetitionDetailRacesController> {
  const CompetitionDetailRacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'no_races_found'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: controller.filteredRaces
                          .map((race) => _buildRaceItem(race: race))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Binds the shared chip bar onto this controller. The bar itself is the one
  /// the Structure overview uses — the two screens narrow long lists by the
  /// same four criteria, and keeping two copies in step by hand is how they
  /// drift apart.
  Widget _buildFilterTabs() {
    final controller = Get.find<CompetitionDetailRacesController>();

    return Obx(() => FilterChipBar(
          visibleCount: controller.filteredRaces.length,
          totalCount: controller.allRaces.length,
          hasActiveFilters: controller.hasActiveFilters,
          onClearAll: controller.clearFilters,
          criteria: [
            for (final filter in RaceFilter.values)
              FilterCriterion(
                labelKey: _criterionKey(filter),
                options: controller.optionsFor(filter),
                selectedCount: controller.selectedCount(filter),
                isSelected: (value) => controller.isSelected(filter, value),
                onToggle: (value) => controller.toggle(filter, value),
                onClear: () => controller.clear(filter),
              ),
          ],
        ));
  }

  Widget _buildRaceItem({required Race race}) {
    final type = race.specialityLabel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final controller = Get.find<CompetitionDetailRacesController>();
        Get.toNamed(
          Routes.raceDetail,
          arguments: {
            'race': race,
            'competition': controller.competition.value,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
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
                race.label,
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
