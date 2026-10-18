import 'package:live_ffss_v2/data/ffss/dtos/resultat_dto.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

/// FFSS stocke un chrono vidé comme 0 : lu comme « pas de chrono ».
int? chronoOrNull(int? value) => value != null && value > 0 ? value : null;

/// Un entier exact, ou rien. [_invalid] distingue une valeur présente mais
/// illisible (`8.5`, `"17577.0"`, `"abc"`) d'une valeur absente.
const Object _invalid = Object();

Object? _strictInt(Object? raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw.trim()) ?? _invalid;
  return _invalid;
}

/// FFSS sert le complément en chaîne, ou en nombre quand c'est un code.
String _complement(Object? raw) {
  if (raw is String) return raw;
  if (raw is num && raw == raw.truncate()) return raw.toInt().toString();
  return '';
}

extension ResultatMapper on ResultatDto {
  /// Les trois chronos, 0 lu comme vide.
  List<int?> get chronos =>
      [chrono1, chrono2, chrono3].map(chronoOrNull).toList();

  /// Nulle sans id, série, engagement ni statut, ou si `Temps`, `Rang` ou
  /// `points` est présent sans être un entier exact : cette lecture sert
  /// l'envoi, qui renvoie ces champs au juge et ne doit jamais les dégrader.
  /// Un statut deviné renverrait de même un faux statut. Les chronos seuls
  /// (`chronos`, utilisés pour l'affichage d'une série) restent tolérants.
  RaceResult? toDomain() {
    final id = this.id;
    final seriesId = series?.id;
    final entryId = entry?.id;
    final status = this.status;
    if (id == null || seriesId == null || entryId == null || status == null) {
      return null;
    }
    final time = _strictInt(this.time);
    final rank = _strictInt(this.rank);
    final points = _strictInt(this.points);
    if (identical(time, _invalid) ||
        identical(rank, _invalid) ||
        identical(points, _invalid)) {
      return null;
    }
    return RaceResult(
      id: id,
      seriesId: seriesId,
      entryId: entryId,
      time: time as int?,
      chronos: chronos,
      rank: rank as int?,
      status: status,
      complement: _complement(complement),
      points: points as int?,
    );
  }
}
