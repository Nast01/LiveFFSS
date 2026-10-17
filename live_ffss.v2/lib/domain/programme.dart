import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/progression.dart';

part 'programme.freezed.dart';

/// Ce que le bureau publie d'une compétition : ses réunions et le déroulement
/// de ses épreuves.
@freezed
abstract class Programme with _$Programme {
  const Programme._();

  const factory Programme({
    @Default(<Meeting>[]) List<Meeting> meetings,
    @Default(<Progression>[]) List<Progression> progressions,
  }) = _Programme;

  Progression? progressionOfStage(int stageId) {
    for (final progression in progressions) {
      if (progression.stageById(stageId) != null) return progression;
    }
    return null;
  }

  ({Meeting meeting, MeetingItem item})? findItem(int itemId) {
    for (final meeting in meetings) {
      for (final item in meeting.items) {
        if (item.id == itemId) return (meeting: meeting, item: item);
      }
    }
    return null;
  }
}

/// La liste des séries ne dit pas de quelle épreuve elles sont : la réunion les
/// publie sans `epreuve`. Le déroulement, lui, connaît la discipline, le sexe
/// et les parties ; on rattache donc chaque série à l'épreuve de sa partie.
/// Une course qui porte déjà son épreuve (forme de la v1) la garde.
List<Meeting> withRaces(
  List<Meeting> meetings,
  List<Progression> progressions,
) {
  if (progressions.isEmpty) return meetings;
  final lookup = Programme(progressions: progressions);

  return [
    for (final meeting in meetings)
      meeting.copyWith(
        items: [
          for (final item in meeting.items)
            switch (item.roundId == null
                ? null
                : lookup.progressionOfStage(item.roundId!)) {
              final progression? => item.copyWith(
                heats: [
                  for (final heat in item.heats)
                    heat.raceName.isNotEmpty
                        ? heat
                        : heat.copyWith(
                            raceId: progression.id,
                            raceName: progression.disciplineName,
                            gender: progression.gender,
                          ),
                ],
              ),
              _ => item,
            },
        ],
      ),
  ];
}
