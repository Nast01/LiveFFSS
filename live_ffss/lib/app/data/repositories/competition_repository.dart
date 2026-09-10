import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
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
  CompetitionRepositoryImpl(this._dataSource);

  static const _defaultSeason = '2025-2026';
  static const _defaultStartDate = '2025-09-29';
  static const _defaultPageSize = 10;

  final CompetitionRemoteDataSource _dataSource;

  /// Une page brute. Interne : les appelants passent par les deux methodes
  /// qui paginent pour eux, seule facon d'obtenir une liste complete.
  Future<List<Competition>> _getCompetitions({
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int pageSize,
    required int page,
  }) async {
    final dtos = await _dataSource.getCompetitions(
      season: _defaultSeason,
      startDate: _defaultStartDate,
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
    final fmt = DateFormat('yyyy-MM-dd');
    final fromStr = fmt.format(from);
    final toStr = fmt.format(to);
    final all = <Competition>[];
    var page = 1;
    while (true) {
      final dtos = await _dataSource.getCompetitions(
        season: _defaultSeason,
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
