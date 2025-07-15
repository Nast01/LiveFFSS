import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/models/slot_model.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';
import 'package:live_ffss/app/module/program/views/program_add_meeting_dialog.dart';

class ProgramView extends GetView<ProgramController> {
  const ProgramView({super.key});

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
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_meetings_yet'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'tap_plus_to_add_meeting'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadMeetings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.meetings.length,
              itemBuilder: (context, index) {
                final meeting = controller.meetings[index];
                return _buildExpandableMeetingCard(meeting, index);
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle floating action button press
            _onFloatingActionButtonPressed();
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }

  void _onFloatingActionButtonPressed() {
    // Prepare the form in the controller
    controller.onAddMeetingPressed();
    // Show the dialog (UI responsibility)
    Get.dialog(
      const ProgramAddMeetingDialog(),
      barrierDismissible: false,
    );
  }

  Widget _buildExpandableMeetingCard(MeetingModel meeting, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(Get.context!).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    meeting.date.day.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    meeting.formattedDateMonth,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              meeting.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${meeting.formattedBeginTime} - ${meeting.formattedEndTime}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      meeting.formattedDuration,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (meeting.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    meeting.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) => _onMenuSelected(value, meeting),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('edit'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('delete'.tr),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              _buildSlotsSection(meeting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsSection(MeetingModel meeting) {
    // Check if meeting has slots
    if (meeting.slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'no_time_slots_available'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                '${'time_slots'.tr} (${meeting.slots.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...meeting.slots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return _buildSlotCard(slot, index);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSlotCard(SlotModel slot, int index) {
    final bool hasRuns = slot.runs.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              // Show connecting line if not the last item
              if (index < controller.totalSlotsCount - 1)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Time display - vertical layout
          Container(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatTimeHour(slot.beginHour),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  _formatTimeMinute(slot.beginHour),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Slot content - make it clickable if has runs
          Expanded(
            child: GestureDetector(
              onTap: () {}, //hasRuns ? () => _navigateToSlotRuns(slot) : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasRuns ? Colors.blue[200]! : Colors.grey[200]!,
                    width: hasRuns ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Slot details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(
                                    slot.endHour.difference(slot.beginHour)),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              // Show run count if has runs
                              if (hasRuns) ...[
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.panorama_horizontal_select_outlined,
                                  size: 14,
                                  color: Colors.blue[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${slot.runs.length} ${'runs'.tr}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status indicator and chevron
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'active'.tr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ),

                        // Show chevron if has runs
                        if (hasRuns) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeHour(DateTime time) {
    return time.hour.toString().padLeft(2, '0');
  }

  String _formatTimeMinute(DateTime time) {
    return time.minute.toString().padLeft(2, '0');
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  void _onMenuSelected(String value, MeetingModel meeting) {
    switch (value) {
      case 'edit':
        _editMeeting(meeting);
        break;
      case 'delete':
        _deleteMeeting(meeting);
        break;
    }
  }

  void _editMeeting(MeetingModel meeting) {
    // Populate the form with existing meeting data
    // controller.populateFormWithMeeting(meeting);

    // // Show the edit dialog
    // Get.dialog(
    //   const AddMeetingDialog(),
    //   barrierDismissible: false,
    // );
  }

  void _deleteMeeting(MeetingModel meeting) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_meeting'.tr),
        content: Text('${'confirm_delete_meeting'.tr}: ${meeting.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMeeting(meeting);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
