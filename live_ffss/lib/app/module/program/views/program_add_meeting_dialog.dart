import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/program/controllers/program_controller.dart';

class ProgramAddMeetingDialog extends StatefulWidget {
  const ProgramAddMeetingDialog({super.key});

  @override
  State<ProgramAddMeetingDialog> createState() =>
      _ProgramAddMeetingDialogState();
}

class _ProgramAddMeetingDialogState extends State<ProgramAddMeetingDialog> {
  final _controller = Get.find<ProgramController>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _beginTime = TimeOfDay.now();
  late TimeOfDay _endTime = TimeOfDay(
    hour: (DateTime.now().hour + 1) % 24,
    minute: DateTime.now().minute,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(
    TimeOfDay current,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _controller.submitMeeting(
      name: _nameController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      beginTime: _beginTime,
      endTime: _endTime,
    );
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: Get.width * 0.9,
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _buildTextFormField(
                  controller: _nameController,
                  label: 'name'.tr,
                  hint: 'enter_name'.tr,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'name_required'.tr : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'description'.tr,
                  hint: 'enter_description'.tr,
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'description_required'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildTimeField(
                  label: 'begin_time'.tr,
                  current: _beginTime,
                  onPicked: (t) => _beginTime = t,
                ),
                const SizedBox(height: 16),
                _buildTimeField(
                  label: 'end_time'.tr,
                  current: _endTime,
                  onPicked: (t) => _endTime = t,
                ),
                const SizedBox(height: 24),
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
                        child: Text('cancel'.tr,
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: _controller.isCreatingMeeting.value
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _controller.isCreatingMeeting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
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
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay current,
    required void Function(TimeOfDay) onPicked,
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
        InkWell(
          onTap: () => _selectTime(current, onPicked),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
