import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/discipline.dart';

CompetitionSummary competition(
  int id, {
  String? name,
  required DateTime start,
  DateTime? end,
  Set<Discipline> disciplines = const {Discipline.flatWater},
}) => CompetitionSummary(
  id: id,
  name: name ?? 'Compétition $id',
  startDate: start,
  endDate: end ?? start,
  disciplines: disciplines,
);
