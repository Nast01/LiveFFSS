import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

/// `Genre` FFSS : H (homme), F (femme), M (mixte).
Gender? parseGender(String? genre) => switch (genre?.trim().toUpperCase()) {
  'H' => Gender.male,
  'F' => Gender.female,
  'M' => Gender.mixed,
  _ => null,
};

extension ReunionMapper on ReunionDto {
  /// Nulle sans id ni jour lisible : les heures des séries se posent sur ce
  /// jour.
  Meeting? toDomain() {
    final id = this.id;
    final day = parseFfssDay(this.day);
    if (id == null || day == null) return null;
    return Meeting(
      id: id,
      name: name?.trim() ?? '',
      day: day,
      startTime: atFfssTime(day, start),
      endTime: atFfssTime(day, end),
      items: [for (final creneau in creneaus) ?creneau.toDomain(day)],
    );
  }
}

extension CreneauMapper on CreneauDto {
  MeetingItem? toDomain(DateTime day) {
    final id = this.id;
    if (id == null) return null;
    return MeetingItem(
      id: id,
      name: name?.trim() ?? '',
      roundId: partie?.id,
      startTime: atFfssTime(day, start),
      endTime: atFfssTime(day, end),
      heats: [for (final course in courses) ?course.toDomain(day)],
    );
  }
}

// Le site FFSS n'a pas de champ « validé » : seul le libellé de la série le dit.
// Libellé saisi à la main : accent perdu, capitales ou espaces doublés ne
// doivent pas faire passer une série temporaire pour validée.
final _provisionalMarker = RegExp(
  r'r[ée]sultats\s+temporaires',
  caseSensitive: false,
  unicode: true,
);

extension CourseMapper on CourseDto {
  Heat? toDomain(DateTime day) {
    final id = this.id;
    if (id == null) return null;
    final epreuve = serie?.epreuve;
    final label = serie?.label;
    // Les listes de réunions ne servent pas `Numero` : le nom de la course
    // finit par le numéro (`Série 3`).
    final nameNumber = RegExp(r'(\d+)\s*$').firstMatch(name ?? '')?.group(1);
    return Heat(
      id: id,
      name: name?.trim() ?? '',
      number: serie?.number ?? int.tryParse(nameNumber ?? '') ?? 0,
      status: RunStatus.fromCode(status),
      plannedStart: atFfssTime(day, start),
      plannedEnd: atFfssTime(day, end),
      raceId: epreuve?.id,
      raceName: epreuve?.discipline?.name?.trim() ?? '',
      gender: parseGender(epreuve?.gender),
      placeIds: [for (final place in places) ?place.id],
      seriesId: serie?.id,
      resultsProvisional: label == null || _provisionalMarker.hasMatch(label),
    );
  }
}
