import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';

class ProgramAddMeetingDialog extends GetView<ProgramController> {
  const ProgramAddMeetingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: Get.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_meeting'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name Field
                _buildTextFormField(
                  controller: controller.nameController,
                  label: 'name'.tr,
                  hint: 'enter_name'.tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'name_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                _buildTextFormField(
                  controller: controller.descriptionController,
                  label: 'description'.tr,
                  hint: 'enter_description'.tr,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'description_required'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Field
                _buildDateField(),
                const SizedBox(height: 16),

                // Begin Time Field
                _buildTimeField(
                  label: 'begin_time'.tr,
                  timeValue: controller.beginTime,
                  onTimeSelected: (time) => controller.beginTime.value = time,
                ),
                const SizedBox(height: 16),

                // End Time Field
                _buildTimeField(
                  label: 'end_time'.tr,
                  timeValue: controller.endTime,
                  onTimeSelected: (time) => controller.endTime.value = time,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isCreatingMeeting.value
                                ? null
                                : _handleCreateMeeting,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: controller.isCreatingMeeting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text('create'.tr),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'date'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required Rx<TimeOfDay> timeValue,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
              onTap: () => _selectTime(timeValue, onTimeSelected),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${timeValue.value.hour.toString().padLeft(2, '0')}:${timeValue.value.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, color: Colors.grey),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked =
        await controller.selectDate(controller.selectedDate.value);
    if (picked != null) {
      controller.selectedDate.value = picked;
    }
  }

  Future<void> _selectTime(
      Rx<TimeOfDay> timeValue, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await controller.selectTime(timeValue.value);
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  Future<void> _handleCreateMeeting() async {
    final success = await controller.createMeeting();
    if (success) {
      Get.back(); // Close the dialog
    }
  }
}
