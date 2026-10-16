import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

extension EvenementMapper on EvenementDto {
  /// Nulle quand la ligne n'a ni id, ni nom, ni date de début lisible :
  /// sans date, la compétition ne peut être placée nulle part sur l'accueil.
  CompetitionSummary? toDomain() {
    final id = this.id;
    final name = this.name?.trim();
    final start = parseFfssDay(startDate);
    if (id == null || name == null || name.isEmpty || start == null) {
      return null;
    }
    final end = parseFfssDay(endDate);
    return CompetitionSummary(
      id: id,
      name: name,
      startDate: start,
      endDate: end == null || end.isBefore(start) ? start : end,
      disciplines: _disciplines(speciality, specialityLabel),
      organizer: _nonEmpty(organisme?.name) ?? _nonEmpty(organisme?.label),
      location: _nonEmpty(location),
    );
  }
}

/// La règle de `ParseEventDisciplines` dans V3 : 1 côtier, 3 mixte, sinon eau
/// plate ; sans code, le libellé fait foi.
Set<Discipline> _disciplines(int? code, String? label) {
  final text = label?.trim() ?? '';
  if (code == 1 || (code == null && text.toUpperCase().startsWith('C'))) {
    return {Discipline.coastal};
  }
  if (code == 3 || text.toLowerCase() == 'mixte') {
    return {Discipline.flatWater, Discipline.coastal};
  }
  return {Discipline.flatWater};
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
