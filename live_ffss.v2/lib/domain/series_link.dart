import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'series_link.freezed.dart';

/// Le tour d'une épreuve auquel appartient une série.
enum EventRound { heats, finalA, finalB }

/// Une série d'une épreuve rattachée à la course du programme où elle a été
/// nagée : la série porte les résultats de sa catégorie, la course son état.
@freezed
abstract class LinkedSeries with _$LinkedSeries {
  const LinkedSeries._();

  const factory LinkedSeries({
    required EventSeries series,
    required Heat heat,
    required EventRound round,
  }) = _LinkedSeries;

  bool get provisional => isProvisional(heat);

  bool get finished => heat.status == RunStatus.finished;
}

/// Écart toléré entre le début réel d'une série et l'heure prévue de sa
/// course : au-delà, un même numéro peut désigner une autre course.
const seriesStartTolerance = Duration(minutes: 5);

/// Rattache les [series] de [event] aux courses du programme (spec lot 5, § 3).
/// Le programme ne pointe que vers la série d'une catégorie par course : le
/// lien passe donc par le déroulement de l'épreuve, le tour, le numéro et
/// l'heure. Une série sans course (vieilles séries de la recette, `Debut`
/// nul) est ignorée. Résultat dans l'ordre du programme.
List<LinkedSeries> linkSeries(
  Programme programme,
  CompetitionEvent event,
  List<EventSeries> series,
) {
  final progression = progressionOfEvent(programme.progressions, event);
  if (progression == null) return const [];

  final heats = <({Heat heat, EventRound round})>[];
  for (final meeting in programme.meetings) {
    for (final item in meeting.items) {
      final stage = item.roundId == null
          ? null
          : progression.stageById(item.roundId!);
      if (stage == null || !_stageCovers(stage, event)) continue;
      for (final heat in item.heats) {
        if (_roundOf(stage.level, heat.name) case final round?) {
          heats.add((heat: heat, round: round));
        }
      }
    }
  }

  final candidates =
      <({int series, int heat, EventRound round, Duration gap})>[];
  for (final (seriesIndex, one) in series.indexed) {
    final start = one.start;
    if (start == null) continue;
    final seriesRound = _seriesRound(one.name);
    for (final (heatIndex, candidate) in heats.indexed) {
      final heat = candidate.heat;
      if (candidate.round != seriesRound) continue;
      if (!_sameNumber(one, heat, seriesRound)) continue;
      final planned = heat.plannedStart;
      final Duration gap;
      if (planned == null) {
        // Sans heure prévue, seul le numéro reste : il ne suffit qu'en séries,
        // où il est porté par le nom de la course.
        if (seriesRound != EventRound.heats) continue;
        gap = const Duration(days: 365);
      } else {
        gap = start.difference(planned).abs();
        if (gap > seriesStartTolerance) continue;
      }
      candidates.add((
        series: seriesIndex,
        heat: heatIndex,
        round: seriesRound,
        gap: gap,
      ));
    }
  }

  // Les couples les plus proches dans le temps d'abord : une course ne prend
  // qu'une série de l'épreuve, et une série qu'une course.
  // `List.sort` n'est pas stable : à écart égal, l'ordre des séries puis celui
  // du programme départagent, pour un rattachement reproductible.
  candidates.sort((a, b) {
    final byGap = a.gap.compareTo(b.gap);
    if (byGap != 0) return byGap;
    final bySeries = a.series.compareTo(b.series);
    return bySeries != 0 ? bySeries : a.heat.compareTo(b.heat);
  });
  final usedSeries = <int>{};
  final byHeat = <int, LinkedSeries>{};
  for (final candidate in candidates) {
    if (usedSeries.contains(candidate.series) ||
        byHeat.containsKey(candidate.heat)) {
      continue;
    }
    usedSeries.add(candidate.series);
    byHeat[candidate.heat] = LinkedSeries(
      series: series[candidate.series],
      heat: heats[candidate.heat].heat,
      round: candidate.round,
    );
  }
  return [for (final index in byHeat.keys.toList()..sort()) byHeat[index]!];
}

/// Les finales sont publiées par catégorie (« Finale - Cadet ») et peuvent se
/// suivre à quelques minutes : sans ce filtre, avec du retard, la finale A
/// Cadet prendrait la course de la finale A Junior.
bool _stageCovers(Stage stage, CompetitionEvent event) =>
    stage.level != StageLevel.finalStage ||
    // Un nom vide serait contenu dans le nom de toutes les finales.
    (event.categoryName.isNotEmpty && stage.name.contains(event.categoryName));

EventRound? _roundOf(StageLevel level, String heatName) => switch (level) {
  StageLevel.heats => EventRound.heats,
  StageLevel.finalStage => _finalRound(heatName),
  // Le lot 5 ne connaît que séries et finales : FFSS n'en publie pas d'autres.
  StageLevel.quarterFinal || StageLevel.semiFinal => null,
};

// Ancrées au début du nom (spec § 2 : les finales commencent par « Finale A »
// ou « Finale B ») : ailleurs, « Demi-finale » ou « Quart de finale » seraient
// prises pour des finales.
final _finalB = RegExp(r'^\s*finale\s+b\b', caseSensitive: false);
final _final = RegExp(r'^\s*finale\b', caseSensitive: false);

EventRound _finalRound(String name) =>
    _finalB.hasMatch(name) ? EventRound.finalB : EventRound.finalA;

/// Le tour d'une série d'épreuve, d'après son nom : V3 les nomme comme les
/// courses (« Série 3 », « Finale A - Cadet »).
EventRound _seriesRound(String name) =>
    _final.hasMatch(name) ? _finalRound(name) : EventRound.heats;

/// Une course de finale n'a pas de numéro (son nom finit par la catégorie, le
/// mapper lui donne 0) : il n'y en a qu'une par finale et par catégorie.
bool _sameNumber(EventSeries series, Heat heat, EventRound round) =>
    series.number == heat.number ||
    (round != EventRound.heats && heat.number == 0);
