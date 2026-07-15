import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';

final _hhmm = DateFormat('HH:mm');

extension HeatFormatting on Heat {
  /// Heading shown next to the heat number (e.g. "Série 1 - 14").
  /// The "- 14" suffix is the lane count, but we don't have it from the API
  /// shape we ingest — fall back to the heat name.
  String get titleLabel => name.isNotEmpty ? name : 'heat'.tr;

  String get subtitleLabel {
    switch (liveStatus) {
      case HeatLiveStatus.official:
        if (endDate != null) {
          return 'finished_at'.trParams({'time': _hhmm.format(endDate!)});
        }
        return 'finished'.tr;
      case HeatLiveStatus.live:
        final start = startDate;
        if (start == null) return 'in_progress'.tr;
        final elapsed = DateTime.now().difference(start).inMinutes;
        return 'started_at_with_elapsed'.trParams({
          'time': _hhmm.format(start),
          'minutes': elapsed.toString(),
        });
      case HeatLiveStatus.unofficial:
        if (startDate != null) {
          return 'estimated_start_time'
              .trParams({'time': _hhmm.format(startDate!)});
        }
        return 'estimated_start_time_unknown'.tr;
    }
  }

  String get statusBadgeLabel => switch (liveStatus) {
        HeatLiveStatus.official => 'official'.tr,
        HeatLiveStatus.live => 'live'.tr,
        HeatLiveStatus.unofficial => 'unofficial'.tr,
      };
}
