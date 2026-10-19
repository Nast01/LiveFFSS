import 'package:live_ffss_v2/data/ffss/dtos/place_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_times.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';

String? _nonBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

extension PlaceMapper on PlaceDto {
  /// Nulle sans id ni numéro de couloir. Une place sans engagement reste
  /// utilisable : elle s'affiche comme couloir vide.
  LaneAssignment? toDomain() {
    final id = this.id;
    final lane = this.lane;
    if (id == null || lane == null) return null;
    final engagement = this.engagement;
    final result = this.result;
    final epreuveCategorie = engagement?.epreuveCategorie;
    return LaneAssignment(
      id: id,
      lane: lane,
      athletes: [
        for (final athlete in engagement?.athletes ?? const <PlaceAthleteDto>[])
          ?_nonBlank(athlete.publicLabel),
      ],
      club: _nonBlank(engagement?.clubLabel) ?? '',
      category: _nonBlank(epreuveCategorie?.categorie?.name),
      resultId: result?.id,
      entryId: engagement?.id,
      // Absent, il reste inconnu : la vue club ne dit jamais « pas forfait »
      // sans l'avoir lu.
      forfeit: engagement?.isForfeit,
      isRelay: epreuveCategorie?.epreuve?.discipline?.isRelay ?? false,
      performance: result == null
          ? null
          : Performance(
              time: _nonBlank(result.time),
              statusLabel: _nonBlank(result.statusLabel),
              timeHundredths: parseFfssTime(result.time),
              // Sur une DQ, FFSS sert le code dans `rangLabel` et laisse
              // `disqualificationCode` vide (place 2903 de la recette 1416).
              // Hors DQ, `rangLabel` est un rang, que l'app ne lit pas.
              disqualificationCode:
                  _nonBlank(result.disqualificationCode) ??
                  ((result.isDisqualified ?? false)
                      ? _nonBlank(result.rankLabel)
                      : null),
              isDisqualified: result.isDisqualified ?? false,
              isRecord: result.isRecord ?? false,
              isNationalRecord: result.isNationalRecord ?? false,
            ),
    );
  }
}
