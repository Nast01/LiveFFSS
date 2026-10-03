import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/utils/ffss_season.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/competition_mapper.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

abstract class CompetitionRepository {
  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
  });

  Future<List<Competition>> getCompetitionsForRange({
    required DateTime from,
    required DateTime to,
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.passed,
    int pageSize = 10,
  });
}

class CompetitionRepositoryImpl implements CompetitionRepository {
  /// [now] n'existe que pour les tests : la saison demandée se déduit de la
  /// date courante, et une horloge figée est la seule façon de la vérifier.
  CompetitionRepositoryImpl(this._dataSource, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  static const _defaultPageSize = 10;

  final CompetitionRemoteDataSource _dataSource;
  final DateTime Function() _now;

  static final _dayFormat = DateFormat('yyyy-MM-dd');

  /// Une page brute. Interne : les appelants passent par les deux methodes
  /// qui paginent pour eux, seule facon d'obtenir une liste complete.
  Future<List<Competition>> _getCompetitions({
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int pageSize,
    required int page,
  }) async {
    // La saison en cours, et son 1er octobre comme borne basse : la liste
    // couvre la saison courante, pas une fenêtre figée en constante.
    final today = _now();
    final dtos = await _dataSource.getCompetitions(
      season: seasonLabel(today),
      startDate: _dayFormat.format(seasonStart(today)),
      type: type,
      visibility: visibility,
      page: page,
      pageSize: pageSize,
    );
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = _defaultPageSize,
  }) async {
    final all = <Competition>[];
    var page = 1;
    while (true) {
      final batch = await _getCompetitions(
        type: type,
        visibility: visibility,
        pageSize: pageSize,
        page: page,
      );
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < pageSize) break;
      page++;
    }
    return all;
  }

  @override
  Future<List<Competition>> getCompetitionsForRange({
    required DateTime from,
    required DateTime to,
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.passed,
    int pageSize = _defaultPageSize,
  }) async {
    final fromStr = _dayFormat.format(from);
    final toStr = _dayFormat.format(to);
    // La saison de la fenetre demandee, pas celle du jour : une plage dans une
    // saison revolue doit partir avec l'etiquette de cette saison-la.
    final season = seasonLabel(from);
    final all = <Competition>[];
    var page = 1;
    while (true) {
      final dtos = await _dataSource.getCompetitions(
        season: season,
        startDate: fromStr,
        endDate: toStr,
        type: type,
        visibility: visibility,
        page: page,
        pageSize: pageSize,
      );
      final batch = dtos.map((d) => d.toDomain()).toList();
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < pageSize) break;
      page++;
    }
    return all;
  }
}
