import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/series_link.dart';

part 'event_ranking.freezed.dart';

/// Barème de V3 (données de référence), le même pour les relais.
const pointScale = [20, 18, 16, 14, 13, 12, 11, 10, 8, 7, 6, 5, 4, 3, 2, 1];

/// Points d'un rang ; 0 au-delà du barème.
int pointsFor(int rank) =>
    rank >= 1 && rank <= pointScale.length ? pointScale[rank - 1] : 0;

/// Places d'une finale quand le déroulement ne les donne pas : `MaxFinalists`
/// par défaut de V3.
const defaultFinalPlaces = 8;

enum Qualification { none, finalA, finalB }

/// Un résultat dans le classement d'une épreuve.
@freezed
abstract class RankingRow with _$RankingRow {
  const RankingRow._();

  const factory RankingRow({
    required EventResult result,

    /// Nul : non classé (DQ, forfait, hors temps, sans temps).
    int? rank,
    required int points,
    required Qualification qualification,

    /// La série rattachée d'où vient [result] : sa course, son tour.
    required LinkedSeries series,
  }) = _RankingRow;

  int get seriesNumber => series.series.number;

  EventRound get round => series.round;
}

@freezed
abstract class EventRanking with _$EventRanking {
  const factory EventRanking({
    required CompetitionEvent event,
    required List<RankingRow> rows,
    required int finishedSeries,
    required int totalSeries,
    required bool provisional,
  }) = _EventRanking;
}

/// Classement de [event] d'après ses séries rattachées, règles de V3
/// (`FlatWaterRanking.RankCategory`, `RacePoints.FlatWaterCategory`).
/// [finalStage] est la finale prévue au déroulement (`finalStageOf`) : son
/// nombre de courses fixe les points avant que les finales ne soient publiées.
EventRanking rankEvent(
  CompetitionEvent event,
  List<LinkedSeries> series, {
  Stage? finalStage,
}) {
  final plannedPlaces = finalStage?.placesPerHeat ?? 0;
  final places = plannedPlaces > 0 ? plannedPlaces : defaultFinalPlaces;
  final linkedFinals = {
    for (final one in series)
      if (one.round != EventRound.heats) one.round,
  }.length;
  final finalsCount = max(finalStage?.heatCount ?? 0, linkedFinals);

  final heats = _lines(series, EventRound.heats);
  final finalA = _lines(series, EventRound.finalA);
  final inFinalA = {for (final line in finalA) line.entryId};
  // Un engagement dans les deux finales n'en garde qu'une : la A, meilleure.
  final finalB = _lines(series, EventRound.finalB, skip: inFinalA);
  final inFinalB = {for (final line in finalB) line.entryId};

  // Un forfait pour la finale garde son temps de série, mais laisse sa place.
  Qualification qualificationOf(_Line line) => switch (line.result.complement) {
    'FF' => Qualification.none,
    'QFA' => Qualification.finalA,
    'QFB' => Qualification.finalB,
    _ when inFinalA.contains(line.entryId) => Qualification.finalA,
    _ when inFinalB.contains(line.entryId) => Qualification.finalB,
    _ => Qualification.none,
  };

  bool run(List<_Line> lines) => lines.any((l) => _hasOutcome(l.result));
  final finalsStarted = run(finalA) || run(finalB);

  final rows = <RankingRow>[];
  final finalists = <int>{};
  for (final (lines, offset, qualification) in [
    (finalA, 0, Qualification.finalA),
    (finalB, places, Qualification.finalB),
  ]) {
    if (!run(lines)) continue;
    finalists.addAll(lines.map((l) => l.entryId));
    final ranks = _ranks(lines);
    for (final line in _order(lines, ranks)) {
      final rank = switch (ranks[line]) {
        final r? => r + offset,
        // Un DQ en finale prend la dernière place de sa finale.
        null when line.result.status == _statusDisqualified => offset + places,
        null => null,
      };
      rows.add(
        line.row(rank, rank == null ? 0 : pointsFor(rank), qualification),
      );
    }
  }

  // Dès qu'une finale est courue, les qualifiés d'une finale à venir n'ont
  // plus le rang de leur série : il n'irait qu'à la suite des finalistes.
  final waiting = <_Line>[];
  final others = <_Line>[];
  for (final line in heats) {
    if (finalists.contains(line.entryId)) continue;
    final pending =
        finalsStarted && qualificationOf(line) != Qualification.none;
    (pending ? waiting : others).add(line);
  }
  for (final line in _order(waiting, _ranks(waiting))) {
    rows.add(line.row(null, 0, qualificationOf(line)));
  }

  final ranks = _ranks(others);
  // Finale A seule : les non-qualifiés marquent dès les séries les places
  // qui suivent la finale, à leur temps ; les qualifiés attendent la finale.
  // Avec deux finales, les séries ne marquent rien, même avant les finales.
  final scorerRanks = finalsCount == 1
      ? _ranks([
          for (final line in others)
            if (qualificationOf(line) == Qualification.none) line,
        ])
      : const <_Line, int>{};
  final offset = finalsStarted ? places * finalsCount : 0;
  for (final line in _order(others, ranks)) {
    final rank = ranks[line];
    final points = switch (finalsCount) {
      0 => rank == null ? 0 : pointsFor(rank),
      1 => switch (scorerRanks[line]) {
        final r? => pointsFor(places + r),
        null => 0,
      },
      _ => 0,
    };
    rows.add(
      line.row(
        rank == null ? null : rank + offset,
        points,
        qualificationOf(line),
      ),
    );
  }

  return EventRanking(
    event: event,
    rows: rows,
    finishedSeries: series.where((s) => s.finished).length,
    totalSeries: series.length,
    provisional: series.isEmpty || series.any((s) => s.provisional),
  );
}

/// Place de [result] dans sa série, parmi [heatResults] : mêmes classés et
/// mêmes égalités que le classement de l'épreuve. Nulle s'il n'est pas classé.
int? heatPlace(EventResult result, List<EventResult> heatResults) {
  if (!_isRanked(result)) return null;
  final time = result.time!;
  return 1 + heatResults.where((r) => _isRanked(r) && r.time! < time).length;
}

const _statusOk = 0;
const _statusDisqualified = 1;
const _statusForfeit = 2;

/// Statut OK avec un temps, hors temps exclu. Un `FF` est classé en série.
bool _isRanked(EventResult result) =>
    result.status == _statusOk &&
    result.time != null &&
    result.complement != 'HT';

/// Un temps, une DQ ou un forfait : une finale publiée avant d'être nagée ne
/// porte que des résultats sans rien de cela.
bool _hasOutcome(EventResult result) =>
    result.time != null ||
    result.status == _statusDisqualified ||
    result.status == _statusForfeit;

final class _Line {
  _Line(this.result, this.series);

  final EventResult result;
  final LinkedSeries series;

  int get entryId => result.entryId;

  int? get time => _isRanked(result) ? result.time : null;

  RankingRow row(int? rank, int points, Qualification qualification) =>
      RankingRow(
        result: result,
        rank: rank,
        points: points,
        qualification: qualification,
        series: series,
      );
}

/// Les résultats des séries du tour : un engagement n'y compte qu'une fois,
/// au premier résultat lu dans l'ordre du programme.
List<_Line> _lines(
  List<LinkedSeries> series,
  EventRound round, {
  Set<int> skip = const {},
}) {
  final seen = {...skip};
  return [
    for (final one in series)
      if (one.round == round)
        for (final result in one.series.results)
          if (seen.add(result.entryId)) _Line(result, one),
  ];
}

/// Rang au temps (1, 2, 2, 4) des lignes classées.
Map<_Line, int> _ranks(List<_Line> lines) {
  final timed = [
    for (final line in lines)
      if (line.time != null) line,
  ]..sort((a, b) => a.time!.compareTo(b.time!));
  final ranks = <_Line, int>{};
  for (final (i, line) in timed.indexed) {
    ranks[line] = i > 0 && line.time == timed[i - 1].time
        ? ranks[timed[i - 1]]!
        : i + 1;
  }
  return ranks;
}

/// Classés au rang, puis les non-classés ; ex æquo par numéro de série puis
/// id de résultat, pour un ordre reproductible.
List<_Line> _order(List<_Line> lines, Map<_Line, int> ranks) {
  int key(_Line line) => ranks[line] ?? 1 << 30;
  return [...lines]..sort((a, b) {
    for (final c in [
      key(a).compareTo(key(b)),
      _unrankedOrder(a.result).compareTo(_unrankedOrder(b.result)),
      a.series.series.number.compareTo(b.series.series.number),
      a.result.id.compareTo(b.result.id),
    ]) {
      if (c != 0) return c;
    }
    return 0;
  });
}

/// Ordre des non-classés de V3 : FF sans temps, HT, DQ, F, autres.
int _unrankedOrder(EventResult result) => switch (result) {
  _ when _isRanked(result) => 0,
  EventResult(complement: 'FF') => 0,
  EventResult(complement: 'HT') => 1,
  EventResult(status: _statusDisqualified) => 2,
  EventResult(status: _statusForfeit) => 3,
  _ => 4,
};
