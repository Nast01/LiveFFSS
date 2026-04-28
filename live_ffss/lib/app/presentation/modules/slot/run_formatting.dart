import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/run.dart';

extension RunFormatting on Run {
  String get formattedBeginTime =>
      '${beginTime.hour.toString().padLeft(2, '0')}:${beginTime.minute.toString().padLeft(2, '0')}';

  String get formattedEndTime =>
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get timeRange => '$formattedBeginTime - $formattedEndTime';

  Duration get duration => endTime.difference(beginTime);

  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}min';
    return '${minutes}min';
  }

  String get localizedStatus => switch (status) {
        RunStatus.waiting => 'waiting'.tr,
        RunStatus.marshalling => 'marshalling'.tr,
        RunStatus.inProgress => 'in_progress'.tr,
        RunStatus.finished => 'finished'.tr,
        RunStatus.unknown => 'unknown'.tr,
      };

  Color get statusColor => switch (status) {
        RunStatus.waiting => AppColors.statusWaiting,
        RunStatus.marshalling => AppColors.statusMarshalling,
        RunStatus.inProgress => AppColors.statusInProgress,
        RunStatus.finished => AppColors.statusFinished,
        RunStatus.unknown => AppColors.textMuted,
      };
}
