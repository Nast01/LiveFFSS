import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_result.freezed.dart';

/// Le résultat d'un engagement dans une série, avec tout ce que
/// `resultat/submit` attend : l'envoi renvoie chaque champ, et un champ omis
/// peut être remis à zéro côté FFSS (le statut retombe à 3).
@freezed
abstract class RaceResult with _$RaceResult {
  const factory RaceResult({
    /// Nul tant que le résultat n'existe pas : l'envoi le crée.
    int? id,
    required int seriesId,
    required int entryId,

    /// `Temps` : le temps du juge, en centièmes. Jamais modifié par la saisie.
    int? time,

    /// `TempsLive1..3` : les trois chronos, en centièmes ; nul = pas de chrono.
    @Default(<int?>[null, null, null]) List<int?> chronos,
    int? rank,

    /// 0 = OK, 1 = disqualifié, 2 = forfait, 3 = « F/DQ » (valeur de repli de
    /// FFSS quand l'envoi n'indique pas de statut).
    @Default(0) int status,

    /// Le code de disqualification, ou `F` pour un forfait.
    @Default('') String complement,
    int? points,
  }) = _RaceResult;
}

enum ResultMark { ok, disqualified, forfeit }

/// Ce que la saisie d'un officiel change sur un résultat.
@freezed
abstract class ResultChange with _$ResultChange {
  const factory ResultChange({
    /// Remplace les trois chronos d'un coup.
    List<int?>? chronos,
    ResultMark? mark,

    /// Le code de disqualification, pour [ResultMark.disqualified].
    String? code,
  }) = _ResultChange;
}

const int chronoCount = 3;
const int statusOk = 0;
const int statusDisqualified = 1;
const int statusForfeit = 2;

/// [current] modifié par [change]. `time`, `rank` et `points` ne bougent
/// jamais : ils sont au juge.
RaceResult applyChange(RaceResult current, ResultChange change) {
  var result = current;
  final chronos = change.chronos;
  if (chronos != null) {
    // Exactement trois : l'envoi renvoie TempsLive1..3 et rien d'autre.
    result = result.copyWith(
      chronos: [
        for (var i = 0; i < chronoCount; i++) chronos.elementAtOrNull(i),
      ],
    );
  }
  switch (change.mark) {
    case null:
      break;
    case ResultMark.ok:
      // Le complément reste tel quel : FFSS ne sait pas l'effacer, et l'envoyer
      // vide le conserve de toute façon. Il ne s'affiche que sur une DQ.
      result = result.copyWith(status: statusOk);
    case ResultMark.disqualified:
      result = result.copyWith(
        status: statusDisqualified,
        complement: change.code ?? result.complement,
      );
    case ResultMark.forfeit:
      result = result.copyWith(status: statusForfeit, complement: 'F');
  }
  return result;
}

/// Un temps non nul est celui du juge : la saisie devient lecture seule.
bool isValidatedByJudge(RaceResult result) {
  final time = result.time;
  return time != null && time > 0;
}
