import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';
import 'package:live_ffss/app/domain/models/run.dart';

final _timeFormat = DateFormat('HH:mm');

DateTime _parseTime(String hhmm) => _timeFormat.parse(hhmm);

/// FFSS construit le `fullLabel` d'une course en collant le libellé à
/// lui-même : « Demie 1 - Surfski - Messieurs - Junior » ressort en
/// « Demie 1 - Surfski - Messieurs - Junior - Demie 1 - Surfski - Messieurs -
/// Junior ». Affiché tel quel, le nom apparaît deux fois à l'écran.
///
/// Seul le doublon exact est réduit : le `fullLabel` d'une partie apporte, lui,
/// un vrai complément (« Surfski - Homme - Demi-finale - Junior ») et doit
/// survivre. Le jour où la fédération corrigera la concaténation, ceci
/// deviendra sans effet.
String _undoubled(String fullLabel, String label) =>
    label.isNotEmpty && fullLabel == '$label - $label' ? label : fullLabel;

extension RunMapper on RunDto {
  Run toDomain() => Run(
        id: id,
        name: name,
        label: label,
        fullLabel: _undoubled(fullLabel, label),
        status: status.asRunStatus,
        statusLabel: statusLabel,
        site: site,
        beginTime: _parseTime(beginTime),
        endTime: _parseTime(endTime),
        heat: heat?.toDomain(),
        liveResults: liveResults.map((lr) => lr.toDomain()).toList(),
      );
}
