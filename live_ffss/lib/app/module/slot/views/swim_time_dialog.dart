import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/slot/controllers/slot_controller.dart';

class SwimmingTimesDialog extends GetView<SlotController> {
  const SwimmingTimesDialog({super.key});

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'enter_times'.tr,
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

            Text(
              'swimming_times_instructions'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Athletes list with time inputs
            Expanded(
              child: ListView.builder(
                itemCount: controller.currentRunResults.length,
                itemBuilder: (context, index) {
                  final result = controller.currentRunResults[index];
                  final laneNumber = int.tryParse(result.number) ?? (index + 1);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Lane number
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Center(
                                child: Text(
                                  result.number,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Athlete name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (result.entry?.athletes.isNotEmpty == true)
                                    Text(
                                      result.entry!.athletes
                                          .map((a) => a.fullName)
                                          .join(' / '),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Time inputs
                        Row(
                          children: List.generate(3, (timeIndex) {
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: timeIndex < 2 ? 8 : 0,
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: '${'time'.tr} ${timeIndex + 1}',
                                    hintText: 'mm:ss.cc',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    controller.updateSwimmingTime(
                                        laneNumber, timeIndex, value);
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isUpdatingResults.value
                            ? null
                            : controller.saveResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: controller.isUpdatingResults.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('save'.tr),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
