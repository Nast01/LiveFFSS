import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';

class ProgramController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isCreatingMeeting = false.obs;

  // Form controllers for meeting creation
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Observable date and time values
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> beginTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay> endTime =
      TimeOfDay(hour: DateTime.now().hour + 1, minute: DateTime.now().minute)
          .obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List of meetings (if you need to display them)
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;

  void setCompetition(CompetitionModel? newCompetition) {
    competition.value = newCompetition;

    // If you need to fetch program-specific data when competition is set
    if (newCompetition != null) {
      loadMeetings();
    } else {
      meetings.clear();
    }
  }

  Future<void> loadMeetings() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loadedMeetings = await _apiService.getMeetings(
        competition.value?.id ?? 0,
      );

      // Sort competitions by begin date and then by name
      loadedMeetings.sort((a, b) {
        // First compare by date
        final dateA = a.date;
        final dateB = b.date;
        final dateComparison = dateA.compareTo(dateB);

        if (dateComparison != 0) {
          return dateComparison;
        }

        // If dates are the same, compare by beginHour
        final beginHourA = a.beginHour;
        final beginHourB = b.beginHour;
        return beginHourA.compareTo(beginHourB);
      });

      meetings.value = loadedMeetings;
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void onAddMeetingPressed() {
    resetForm();
    // The view will handle showing the dialog
  }

  // Business logic for date selection
  Future<DateTime?> selectDate(DateTime initialDate) async {
    return await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Business logic for time selection
  Future<TimeOfDay?> selectTime(TimeOfDay initialTime) async {
    return await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Business logic for creating meeting
  Future<bool> createMeeting() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isCreatingMeeting.value = true;
      // Create DateTime objects for begin and end hours
      final beginDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        beginTime.value.hour,
        beginTime.value.minute,
      );

      final endDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        endTime.value.hour,
        endTime.value.minute,
      );

      // Validate that end time is after begin time
      if (endDateTime.isBefore(beginDateTime)) {
        Get.snackbar(
          'error'.tr,
          'end_time_must_be_after_begin_time'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Create the meeting model
      final meeting = MeetingModel(
        id: 0, // Will be assigned by the server
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        beginHour: beginDateTime,
        endHour: endDateTime,
      );

      await _apiService.createMeeting(meeting, competition.value!.id);

      // Add to local list (if using local state)
      //meetings.add(meeting);

      // Close the dialog
      Get.back();

      Get.snackbar(
        'success'.tr,
        'meeting_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset the form
      resetForm();
      // Reload the meeting list
      await loadMeetings();

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_create_meeting'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreatingMeeting.value = false;
    }
  }

// Method to delete a meeting (alternative version)
  Future<void> deleteMeeting(MeetingModel meeting) async {
    if (competition.value == null) return;

    try {
      final success = await _apiService.deleteMeeting(meeting.id);

      if (success) {
        meetings.remove(meeting);

        Get.snackbar(
          'success'.tr,
          'meeting_deleted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to delete meeting');
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_meeting'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    selectedDate.value = DateTime.now();
    beginTime.value = TimeOfDay.now();
    endTime.value =
        TimeOfDay(hour: DateTime.now().hour + 1, minute: DateTime.now().minute);
  }

  // Helper method to get total slots count for timeline connection
  int get totalSlotsCount =>
      meetings.isNotEmpty ? meetings.first.slots.length : 0;
}
