import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';

extension EpreuveMapper on EpreuveDto {
  /// Nulle sans id, sans genre ou sans catégorie lisibles : une épreuve est
  /// une catégorie, la première de `categories`.
  CompetitionEvent? toDomain() {
    final id = this.id;
    final gender = parseGender(this.gender);
    final category = categories.isEmpty ? null : categories.first;
    final categoryId = category?.id;
    if (id == null || gender == null || categoryId == null) return null;
    final label = discipline?.label?.trim();
    return CompetitionEvent(
      id: id,
      disciplineId: disciplineId ?? 0,
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
    final athletes = [for (final athlete in this.athletes) ?athlete.toDomain()];
    final time = this.time;
    return EventResult(
      id: id,
      entryId: entryId,
      eventId: entry?.eventId ?? eventId,
      categoryName: entry?.category?.name?.trim() ?? '',
      status: status ?? 0,
      time: time == null || time <= 0 ? null : time,
      complement: complement?.trim() ?? '',
      club: athletes.isNotEmpty
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
      results: [for (final result in results) ?result.toDomain(eventId)],
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
      entries: [
        for (final entry in entries)
          if (entry.id != null && entry.event?.id != null)
            ParticipantEntry(
              entryId: entry.id!,
              eventId: entry.event!.id!,
              categoryName: entry.category?.label?.trim() ?? '',
            ),
      ],
    );
  }
}
