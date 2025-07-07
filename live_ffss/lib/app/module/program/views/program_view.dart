import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
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
                return _buildMeetingCard(meeting, index);
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

  Widget _buildMeetingCard(MeetingModel meeting, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onMeetingTapped(meeting),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting icon and time info
                    Container(
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
                    const SizedBox(width: 12),

                    // Meeting details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meeting name
                          Text(
                            meeting.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Time and duration info (moved here)
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
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
                              Icon(Icons.timer,
                                  size: 14, color: Colors.grey[600]),
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
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),

                    // More actions button
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) => _onMenuSelected(value, meeting),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text('edit'.tr),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('delete'.tr),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Description if available
                if (meeting.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
          ),
        ),
      ),
    );
  }

  void _onMeetingTapped(MeetingModel meeting) {
    // Handle meeting tap - navigate to meeting details or show info
    Get.snackbar(
      'meeting_selected'.tr,
      meeting.name,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
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
