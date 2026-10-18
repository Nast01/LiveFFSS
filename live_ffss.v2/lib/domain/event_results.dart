import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/progression.dart';

part 'event_results.freezed.dart';

/// Une épreuve d'une compétition, comme `Event` dans FFSSCompetition V3 : une
/// discipline, un genre et une catégorie. FFSS en publie une par catégorie.
@freezed
abstract class CompetitionEvent with _$CompetitionEvent {
  const CompetitionEvent._();

  const factory CompetitionEvent({
    required int id,
    required int disciplineId,
    required String disciplineName,
    required Gender gender,
    required int categoryId,
    required String categoryName,
    required int teamSize,
  }) = _CompetitionEvent;

  bool get isRelay => teamSize > 1;
}

@freezed
abstract class ResultAthlete with _$ResultAthlete {
  const factory ResultAthlete({
    required int id,
    required String name,
    Gender? gender,
    @Default('') String club,
    String? nationality,
    @Default(false) bool isGuest,
  }) = _ResultAthlete;
}

/// Le résultat d'un engagement dans une série.
@freezed
abstract class EventResult with _$EventResult {
  const factory EventResult({
    required int id,
    required int entryId,
    required int eventId,
    required String categoryName,
    required int status,

    /// En centièmes ; nul sans temps (absent ou nul).
    int? time,
    @Default('') String complement,

    /// Le club du premier athlète, sinon celui de l'engagement.
    @Default('') String club,
    @Default(<ResultAthlete>[]) List<ResultAthlete> athletes,
  }) = _EventResult;
}

@freezed
abstract class EventSeries with _$EventSeries {
  const factory EventSeries({
    required int id,
    required int eventId,
    required int number,
    required String name,

    /// Heure locale du début, nulle tant que la série n'a pas démarré.
    DateTime? start,
    @Default(<EventResult>[]) List<EventResult> results,
  }) = _EventSeries;
}

@freezed
abstract class ParticipantEntry with _$ParticipantEntry {
  const factory ParticipantEntry({
    required int entryId,
    required int eventId,
    required String categoryName,
  }) = _ParticipantEntry;
}

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required int id,
    required String firstName,
    required String lastName,
    Gender? gender,
    @Default('') String club,
    @Default(false) bool isGuest,
    @Default(<ParticipantEntry>[]) List<ParticipantEntry> entries,
  }) = _Participant;
}

/// Le déroulement de [event] : même discipline, même genre, et la catégorie de
/// l'épreuve parmi les siennes. Nul sinon.
Progression? progressionOfEvent(
  List<Progression> progressions,
  CompetitionEvent event,
) {
  for (final progression in progressions) {
    if (progression.disciplineId == event.disciplineId &&
        progression.gender == event.gender &&
        progression.categories.contains(event.categoryName)) {
      return progression;
    }
  }
  return null;
}
