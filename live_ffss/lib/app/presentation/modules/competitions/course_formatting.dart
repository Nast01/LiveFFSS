/// Formats one row of a scored course from the two facts that decide how it
/// reads: the place it took, if any, and the withdrawal it carries, if any.
/// Shared by the entry screen (`race_course_view.dart`) and the Séries tab's
/// read-only recap (`race_structure_view.dart`), which must never disagree
/// about what a row shows.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';

/// The badge text: a mention for a withdrawal, the place otherwise, a dash
/// while the athlete has neither.
String courseBadgeLabel(int? place, CoursePenalty? penalty) =>
    switch (penalty?.kind) {
      CoursePenaltyKind.forfeit => 'forfeit_short'.tr,
      CoursePenaltyKind.disqualified => 'disqualified_short'.tr,
      _ => place?.toString() ?? '—',
    };

/// The badge colour: a withdrawal always reads as an error, a place as the
/// brand colour, and neither as muted.
Color courseBadgeColor(int? place, CoursePenalty? penalty) => penalty != null
    ? AppColors.statusError
    : place != null
        ? AppColors.primary
        : AppColors.textMuted;
