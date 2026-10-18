import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';

/// Décode chaque ligne seule : une ligne qui n'est pas un objet, mal typée
/// (`TypeError`) ou que [toDomain] rejette est écartée sans emporter les autres.
List<T> decodeRows<D, T>(
  List<Object?> rows,
  D Function(Map<String, dynamic>) fromJson,
  T? Function(D) toDomain,
) {
  final result = <T>[];
  for (final row in rows) {
    if (row is! Map<String, dynamic>) continue;
    final D dto;
    try {
      dto = fromJson(row);
    } on TypeError {
      continue;
    }
    final item = toDomain(dto);
    if (item != null) result.add(item);
  }
  return result;
}

extension EpreuveMapper on EpreuveDto {
  /// Nulle sans id, sans genre ou sans catégorie lisibles : une épreuve est
  /// une catégorie, la première de `categories`.
  CompetitionEvent? toDomain() {
    final id = this.id;
    final gender = parseGender(this.gender);
    final category = categories.isEmpty ? null : categories.first;
    final categoryId = category?.id;
    final disciplineId = this.disciplineId;
    if (id == null ||
        gender == null ||
        categoryId == null ||
        disciplineId == null) {
      return null;
    }
    final label = discipline?.label?.trim();
    return CompetitionEvent(
      id: id,
      disciplineId: disciplineId,
      disciplineName: label != null && label.isNotEmpty
          ? label
          : discipline?.name?.trim() ?? '',
      gender: gender,
      categoryId: categoryId,
      categoryName: category?.name?.trim() ?? '',
      teamSize: discipline?.teamSize ?? 1,
    );
  }
}

extension AthleteResultMapper on AthleteResultDto {
  ResultAthlete? toDomain() {
    final id = this.id;
    if (id == null) return null;
    return ResultAthlete(
      id: id,
      name: label?.trim() ?? '',
      gender: parseGender(gender),
      club: club?.trim() ?? '',
      nationality: nationality?.trim(),
      isGuest: isGuest ?? false,
    );
  }
}

extension ResultatSerieMapper on ResultatSerieDto {
  /// Nulle sans id ni engagement. [eventId] sert quand l'engagement ne porte
  /// pas son épreuve.
  EventResult? toDomain(int eventId) {
    final id = this.id;
    final entry = this.entry;
    final entryId = entry?.id;
    if (id == null || entryId == null) return null;
    final athletes = decodeRows(
      this.athletes,
      AthleteResultDto.fromJson,
      (AthleteResultDto dto) => dto.toDomain(),
    );
    final time = this.time;
    return EventResult(
      id: id,
      entryId: entryId,
      eventId: entry?.eventId ?? eventId,
      categoryName: entry?.category?.name?.trim() ?? '',
      // V3 envoie toujours `Statut` : 0 (OK) n'est qu'un repli défensif.
      status: status ?? 0,
      time: time == null || time <= 0 ? null : time,
      complement: complement?.trim() ?? '',
      club: athletes.isNotEmpty && athletes.first.club.isNotEmpty
          ? athletes.first.club
          : entry?.club?.trim() ?? '',
      athletes: athletes,
    );
  }
}

extension SerieResultsMapper on SerieResultsDto {
  /// Nulle sans id ni épreuve. [fallbackEventId] est l'épreuve demandée, pour
  /// une série qui ne porte pas la sienne.
  EventSeries? toDomain({int? fallbackEventId}) {
    final id = this.id;
    final eventId = event?.id ?? fallbackEventId;
    if (id == null || eventId == null) return null;
    final start = this.start;
    return EventSeries(
      id: id,
      eventId: eventId,
      number: number ?? 0,
      name: name?.trim() ?? '',
      // `yyyy-MM-dd HH:mm:ss` sans fuseau : `tryParse` le lit en heure locale.
      start: start == null ? null : DateTime.tryParse(start.trim()),
      results: decodeRows(
        results,
        ResultatSerieDto.fromJson,
        (ResultatSerieDto dto) => dto.toDomain(eventId),
      ),
    );
  }
}

extension ParticipantMapper on ParticipantDto {
  /// Nul sans id. Un engagement sans épreuve est écarté seul.
  Participant? toDomain() {
    final id = this.id;
    if (id == null) return null;
    return Participant(
      id: id,
      firstName: firstName?.trim() ?? '',
      lastName: lastName?.trim() ?? '',
      gender: parseGender(gender),
      club: club?.trim() ?? '',
      isGuest: isGuest ?? false,
      entries: decodeRows(entries, ParticipantEngagementDto.fromJson, (
        ParticipantEngagementDto entry,
      ) {
        final entryId = entry.id;
        final eventId = entry.event?.id;
        if (entryId == null || eventId == null) return null;
        return ParticipantEntry(
          entryId: entryId,
          eventId: eventId,
          categoryName: entry.category?.label?.trim() ?? '',
        );
      }),
    );
  }
}
