import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/club_model.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';

class CompetitionDetailClubsView
    extends GetView<CompetitionDetailClubsController> {
  const CompetitionDetailClubsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.filteredClubs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.group_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_clubs_found'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadClubs(),
          child: ListView.builder(
            itemCount: controller.filteredClubs.length,
            itemBuilder: (context, index) {
              final club = controller.filteredClubs[index];
              return buildClubCard(context, club);
            },
          ),
        );
      },
    );
  }

  Widget buildClubCard(BuildContext context, ClubModel club) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          child: club.logoUrl != null
              ? ClipOval(
                  child: Image.network(
                    club.logoUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.sports, color: Colors.blue);
                    },
                  ),
                )
              : const Icon(Icons.sports, color: Colors.blue),
        ),
        title: Text(
          club.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'athletes_and_referees'.trParams({
            'athleteCount': '${club.athletes.length}',
            'refereeCount': '${club.referees.length}',
          }),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        children: [
          if (club.athletes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'athletes_upper'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            ...club.athletes.map((athlete) => buildLicenseeTile(athlete)),
          ],
          if (club.referees.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'referees_upper'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            ...club.referees.map((referee) => buildLicenseeTile(referee)),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildLicenseeTile(var licensee) {
    bool isAthlete = licensee is AthleteModel;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: isAthlete == true
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        child: Icon(
          isAthlete == true ? Icons.pool : Icons.sports_score,
          color: isAthlete == true ? Colors.green : Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        isAthlete == true ? licensee.fullName : licensee.fullNameWithLevel,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      // subtitle: Text(
      //   'Licence: ${person.licenseNumber ?? 'N/A'}',
      //   style: TextStyle(
      //     fontSize: 12,
      //     color: Colors.grey[600],
      //   ),
      // ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isAthlete == true
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAthlete == true ? Colors.green : Colors.orange,
            width: 1,
          ),
        ),
        child: Text(
          isAthlete == true ? 'athlete_upper'.tr : 'referee_upper'.tr,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isAthlete == true ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}
