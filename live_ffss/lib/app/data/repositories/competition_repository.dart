import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/competition_mapper.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

abstract class CompetitionRepository {
  Future<List<Competition>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
    int page = 1,
  });

  Future<List<Competition>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
  });

  Future<List<Competition>> getNext5();
}

class CompetitionRepositoryImpl implements CompetitionRepository {
  CompetitionRepositoryImpl(this._dataSource);

  static const _defaultSeason = '2023-2024';
  static const _defaultStartDate = '2024-09-29';
  static const _defaultPageSize = 10;

  final CompetitionRemoteDataSource _dataSource;

  @override
  Future<List<Competition>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = _defaultPageSize,
    int page = 1,
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
      final batch = await getCompetitions(
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
  Future<List<Competition>> getNext5() async {
    final batch = await getCompetitions(
      visibility: CompetitionVisibility.incoming,
      type: CompetitionType.mixte,
      pageSize: 5,
      page: 1,
    );
    return batch.take(5).toList();
  }
}
