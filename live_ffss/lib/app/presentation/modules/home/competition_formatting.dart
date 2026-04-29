import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

extension CompetitionFormatting on Competition {
  String get formattedBeginDate =>
      beginDate == null ? '' : DateFormat('dd/MM/yyyy').format(beginDate!);

  String get formattedEndDate =>
      endDate == null ? '' : DateFormat('dd/MM/yyyy').format(endDate!);

  String get formattedDayBeginDate =>
      beginDate == null ? '' : DateFormat('dd').format(beginDate!);

  String get formattedBeginDateMonth => beginDate == null
      ? ''
      : DateFormat('MMM').format(beginDate!).toUpperCase();

  String get dayDateBeginDate {
    if (beginDate == null) return '';
    final day = DateFormat('EEE').format(beginDate!).toUpperCase();
    final date = DateFormat('dd').format(beginDate!);
    return '$day $date';
  }

  bool get hasRefereePrincipal =>
      refereePrincipal != null && refereePrincipal!.isNotEmpty;

  EntryStatus get entryStatus {
    final start = beginEntryLimitDate;
    final end = endEntryLimitDate;
    if (start == null || end == null) return EntryStatus.unknown;
    final now = DateTime.now();
    if (now.isAfter(start) && now.isBefore(end)) return EntryStatus.open;
    if (now.isAfter(start)) return EntryStatus.closed;
    return EntryStatus.soon;
  }

  CompetitionStatus get phase {
    if (beginDate == null || endDate == null) return CompetitionStatus.unknown;
    final now = DateTime.now();
    if (now.isAfter(beginDate!) && now.isBefore(endDate!)) {
      return CompetitionStatus.onGoing;
    }
    if (now.isAfter(endDate!)) return CompetitionStatus.done;
    return CompetitionStatus.coming;
  }

  String get entryStatusLabel => switch (entryStatus) {
        EntryStatus.open => 'open'.tr,
        EntryStatus.closed => 'closed'.tr,
        EntryStatus.soon => 'soon'.tr,
        EntryStatus.unknown => 'unknown'.tr,
      };

  Color get entryStatusColor => switch (entryStatus) {
        EntryStatus.open => AppColors.statusFinished,
        EntryStatus.closed => AppColors.statusError,
        EntryStatus.soon => AppColors.statusWaiting,
        EntryStatus.unknown => AppColors.textMuted,
      };

  String get phaseLabel => switch (phase) {
        CompetitionStatus.coming => 'coming'.tr,
        CompetitionStatus.onGoing => 'on_going'.tr,
        CompetitionStatus.done => 'done'.tr,
        CompetitionStatus.unknown => 'unknown'.tr,
      };

  Color get phaseColor => switch (phase) {
        CompetitionStatus.onGoing => AppColors.statusInProgress,
        CompetitionStatus.done => AppColors.textMuted,
        CompetitionStatus.coming => AppColors.primary,
        CompetitionStatus.unknown => AppColors.textMuted,
      };

  bool get overlapsCurrentWeek {
    if (beginDate == null || endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return beginDate!.isBefore(weekEnd) && endDate!.isAfter(weekStart);
  }

  bool get isSwimming {
    final t = typeWater.toLowerCase();
    return t.contains('eau-plate') ||
        t.contains('eau plate') ||
        t.contains('swimming') ||
        t.contains('piscine');
  }

  bool get isBeach {
    final t = typeWater.toLowerCase();
    return t.contains('côtier') ||
        t.contains('cotier') ||
        t.contains('beach') ||
        t.contains('coastal');
  }
}
