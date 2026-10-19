import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
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

    /// La spécialité de la discipline ; nulle quand FFSS n'en donne pas une
    /// connue : l'épreuve n'est alors montrée nulle part.
    Discipline? discipline,
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

    /// Relient le participant au compte connecté (`CompetitionRoles`) et aux
    /// clubs dont il est référent.
    int? clubId,
    int? licenseeId,
    @Default(false) bool isGuest,
    @Default(<ParticipantEntry>[]) List<ParticipantEntry> entries,
  }) = _Participant;
}

/// Le résultat a été nagé : un temps, un statut autre qu'OK (DQ, forfait…)
/// ou un complément (`HT`, `FF`…). Une série publiée avant d'être courue
/// porte ses engagés sans rien de cela : pour la fiche d'un athlète, c'est une
/// course à courir. Plus large que le `_hasOutcome` du classement, qui ne
/// retient que ce qui décide qu'une finale est commencée (temps, DQ, forfait).
bool hasRun(EventResult result) =>
    result.time != null || result.status != 0 || result.complement.isNotEmpty;

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
