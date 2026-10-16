import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

part 'competition_summary.freezed.dart';

/// Une compétition de la liste en ligne : la forme de
/// `FfssCompetitionSummary` dans FFSSCompetition V3. Les dates sont des jours
/// (minuit local), sans heure.
///
/// `disciplines` est un ensemble parce que Dart n'a pas d'énumération
/// combinable comme le `[Flags] Disciplines` de V3 : une compétition mixte
/// contient les deux.
@freezed
abstract class CompetitionSummary with _$CompetitionSummary {
  const factory CompetitionSummary({
    required int id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required Set<Discipline> disciplines,
    String? organizer,
    String? location,
  }) = _CompetitionSummary;
}
