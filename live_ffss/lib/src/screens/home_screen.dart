import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/src/controllers/competition_controller.dart';
import 'package:live_ffss/src/model/competition.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final CompetitionController controller = Get.find<CompetitionController>();

  Widget buildListItem(BuildContext context, Competition competition) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // First part: Rounded container with texts
          Container(
            width: 80,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.MMM().format(competition.beginDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis, // Ensure no overflow issues
                ),
                Text(
                  competition.beginDate.day.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis, // Ensure no overflow issues
                ),
              ],
            ),
          ),

          // Second part: Two wrapped texts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    competition.location ?? "",
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black87,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Third part: Circle with green background
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.all(4),
          ),

          // Fourth part: Right arrow icon
          Container(
            width: 50,
            child: const Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // First Row: Logo and Title
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                  Image.asset(
                    'assets/images/logo_ffss.png', // Replace with your logo URL or asset
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 16), // Space between logo and title
                  // Title
                  const Text(
                    "LIVE FFSS!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Second Row: List of Competitions
            Expanded(
              child: Obx(() {
                if (controller.competitionList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune compétition...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.competitionList.length,
                  itemBuilder: (context, index) {
                    final competition = controller.competitionList[index];
                    return buildListItem(context, competition);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
