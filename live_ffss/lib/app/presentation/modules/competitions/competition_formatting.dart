import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

/// Construire un `DateFormat` reparse son motif ; ces formats-là sont lus une
/// fois par carte de compétition affichée, à chaque rebuild. Les hisser hors
/// des getters ne change pas ce qu'ils rendent : rien ne pose
/// `Intl.defaultLocale`, donc la locale que résout `DateFormat` est celle du
/// device, fixée pour la durée du processus — et non la langue de l'app, qui
/// elle change à chaud.
final _dayFormat = DateFormat('dd');
final _monthFormat = DateFormat('MMM');
final _weekdayFormat = DateFormat('EEE');
final _rangeFormat = DateFormat('yyyy MMM dd');

extension CompetitionFormatting on Competition {
  String get formattedDayBeginDate =>
      beginDate == null ? '' : _dayFormat.format(beginDate!);

  String get formattedBeginDateMonth =>
      beginDate == null ? '' : _monthFormat.format(beginDate!).toUpperCase();

  String get dayDateBeginDate {
    if (beginDate == null) return '';
    final day = _weekdayFormat.format(beginDate!).toUpperCase();
    final date = _dayFormat.format(beginDate!);
    return '$day $date';
  }

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

  bool get isSwimming {
    final s = specialityLabel.toLowerCase();
    return s.contains('eau-plate') || s.contains('eau plate');
  }

  bool get isBeach {
    final s = specialityLabel.toLowerCase();
    return s.contains('côtier') || s.contains('cotier');
  }

  String get formattedDateRange {
    if (beginDate == null) return '';
    if (endDate == null || endDate!.isAtSameMomentAs(beginDate!)) {
      return _rangeFormat.format(beginDate!);
    }
    return '${_rangeFormat.format(beginDate!)}'
        ' - ${_dayFormat.format(endDate!)}';
  }
}
