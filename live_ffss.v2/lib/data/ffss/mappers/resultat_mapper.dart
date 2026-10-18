import 'package:live_ffss_v2/data/ffss/dtos/resultat_dto.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

/// FFSS stocke un chrono vidé comme 0 : lu comme « pas de chrono ».
int? chronoOrNull(int? value) => value != null && value > 0 ? value : null;

extension ResultatMapper on ResultatDto {
  /// Les trois chronos, 0 lu comme vide.
  List<int?> get chronos =>
      [chrono1, chrono2, chrono3].map(chronoOrNull).toList();

  /// Nulle sans id, série, engagement ni statut : un statut deviné renverrait
  /// un faux statut à FFSS à l'envoi.
  RaceResult? toDomain() {
    final id = this.id;
    final seriesId = series?.id;
    final entryId = entry?.id;
    final status = this.status;
    if (id == null || seriesId == null || entryId == null || status == null) {
      return null;
    }
    return RaceResult(
      id: id,
      seriesId: seriesId,
      entryId: entryId,
      time: time,
      chronos: chronos,
      rank: rank ?? 0,
      status: status,
      complement: complement?.toString() ?? '',
      points: points,
    );
  }
}
