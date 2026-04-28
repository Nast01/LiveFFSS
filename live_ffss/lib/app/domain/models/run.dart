import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/heat.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

part 'run.freezed.dart';
part 'run.g.dart';

enum RunStatus { waiting, marshalling, inProgress, finished, unknown }

@freezed
class Run with _$Run {
  const factory Run({
    required int id,
    required String name,
    required String label,
    required String fullLabel,
    required RunStatus status,
    required String statusLabel,
    required String site,
    required DateTime beginTime,
    required DateTime endTime,
    Heat? heat,
    @Default(<LiveResult>[]) List<LiveResult> liveResults,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);
}

extension RunStatusX on int {
  RunStatus get asRunStatus => switch (this) {
        0 => RunStatus.waiting,
        1 => RunStatus.marshalling,
        2 => RunStatus.inProgress,
        3 => RunStatus.finished,
        _ => RunStatus.unknown,
      };
}
