import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/live_result_model.dart';
import 'package:live_ffss/app/data/models/run_model.dart';
import 'package:live_ffss/app/data/models/slot_model.dart';
import 'package:live_ffss/app/module/slot/controllers/slot_controller.dart';

class SlotView extends GetView<SlotController> {
  const SlotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slot = controller.slot.value;

      if (slot == null) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: controller.goBack,
            ),
            title: Text(
              'slot_details'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: Text(
              'no_slot_selected'.tr,
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
            onPressed: controller.goBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.slotTimeRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                controller.slotTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: controller.refreshResults,
              icon: const Icon(Icons.refresh, color: Colors.black),
            ),
          ],
          bottom: slot.runs.isNotEmpty
              ? TabBar(
                  controller: controller.tabController,
                  onTap: controller.onTabChanged,
                  isScrollable: slot.runs.length > 3,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: slot.runs
                      .map((run) => Tab(
                            text: run.label,
                          ))
                      .toList(),
                )
              : null,
        ),
        body:
            slot.runs.isEmpty ? _buildEmptyRunsView() : _buildMainContent(slot),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: controller.currentBottomTabIndex.value,
          onTap: controller.onBottomTabChanged,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events),
              label: 'results'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: 'athletes'.tr,
            ),
          ],
        ));
  }

  Widget _buildMainContent(SlotModel slot) {
    return Obx(() {
      switch (controller.currentBottomTabIndex.value) {
        case 0:
          return _buildResultsContent(slot);
        case 1:
          return _buildAthletesContent();
        default:
          return _buildResultsContent(slot);
      }
    });
  }

  Widget _buildResultsContent(SlotModel slot) {
    return slot.runs.isEmpty ? _buildEmptyRunsView() : _buildTabBarView();
  }

  Widget _buildAthletesContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.allAthletes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'no_athletes_found'.tr,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshResults,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allAthletes.length,
          itemBuilder: (context, index) {
            final athlete = controller.allAthletes[index];
            return _buildAthleteCard(athlete);
          },
        ),
      );
    });
  }

  Widget _buildAthleteCard(AthleteModel athlete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Athlete avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  athlete.firstName.isNotEmpty
                      ? athlete.firstName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Athlete information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (athlete.club != null)
                      Text(
                        athlete.club!.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (athlete.licenseeNumber.isNotEmpty) ...[
                          Icon(Icons.badge, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            athlete.licenseeNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          athlete.year.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Gender and nationality indicators
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: athlete.gender == 'M'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            athlete.gender == 'M' ? Colors.blue : Colors.pink,
                      ),
                    ),
                    child: Text(
                      athlete.gender,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            athlete.gender == 'M' ? Colors.blue : Colors.pink,
                      ),
                    ),
                  ),
                  if (athlete.nationalityCode.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      athlete.nationalityCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),

              // Withdraw button
              const SizedBox(width: 12),
              Obx(() => IconButton(
                    onPressed: controller.isWithdrawingAthlete.value
                        ? null
                        : () => controller.showWithdrawAthleteDialog(athlete),
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: controller.isWithdrawingAthlete.value
                          ? Colors.grey
                          : Colors.red,
                    ),
                    tooltip: 'withdraw_athlete'.tr,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRunsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_runs_available'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: controller.tabController,
      children: controller.slot.value!.runs.map((run) {
        final runIndex = controller.slot.value!.runs.indexOf(run);
        return _buildRunTab(run, runIndex);
      }).toList(),
    );
  }

  Widget _buildRunTab(RunModel run, int runIndex) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'error_loading_results'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshResults,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshResults,
        child: Column(
          children: [
            _buildRunInfoHeader(run),
            if (controller.isBeachDiscipline || controller.isSwimmingDiscipline)
              _buildResultEntryButton(),
            Expanded(
              child: _buildResultsList(runIndex),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultEntryButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Obx(() => ElevatedButton.icon(
            onPressed: controller.isUpdatingResults.value
                ? null
                : controller.openResultEntryDialog,
            icon: Icon(
              controller.isBeachDiscipline
                  ? Icons.format_list_numbered
                  : Icons.timer,
            ),
            label: Text(
              controller.isBeachDiscipline
                  ? 'enter_rankings'.tr
                  : 'enter_times'.tr,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )),
    );
  }

  Widget _buildRunInfoHeader(RunModel run) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  run.fullLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(run.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  run.localizedStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                run.timeRange,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                run.formattedDuration,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                run.site,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(int runIndex) {
    return Obx(() {
      final results = controller.runResults[runIndex] ?? [];

      if (results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'no_results_available'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'results_will_appear_here'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _buildResultCard(result, index + 1);
        },
      );
    });
  }

  Widget _buildResultCard(LiveResultModel result, int position) {
    final hasResult = result.result != null;
    final isDisqualified = result.isDisqualified;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Position/Lane number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDisqualified
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDisqualified ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    result.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDisqualified ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Athlete information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.entry?.athletes.isNotEmpty == true) ...[
                      Text(
                        result.entry!.athletes
                            .map((a) => a.fullName)
                            .join(' / '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (result.entry!.athletes.first.club != null)
                        Text(
                          result.entry!.athletes.first.club!.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ],
                ),
              ),

              // Result information
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasResult && !isDisqualified) ...[
                    // Rank
                    if (result.currentRank != null && result.currentRank! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRankColor(result.currentRank!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${result.currentRank}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Time
                    if (result.currentTimeLabel != null)
                      Text(
                        result.currentTimeLabel!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                  ] else if (isDisqualified) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DSQ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'no_result'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Waiting
      case 1:
        return Colors.blue; // Marshalling
      case 2:
        return Colors.amber; // In progress
      default:
        return Colors.green; // Finished
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[600]!; // Bronze
      default:
        return Colors.blue[600]!; // Others
    }
  }
}
