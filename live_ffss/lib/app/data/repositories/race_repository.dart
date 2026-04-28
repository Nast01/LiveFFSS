import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/race_mapper.dart';
import 'package:live_ffss/app/domain/models/race.dart';

abstract class RaceRepository {
  Future<List<Race>> getRaces(int competitionId);
}

class RaceRepositoryImpl implements RaceRepository {
  RaceRepositoryImpl(this._dataSource);

  final RaceRemoteDataSource _dataSource;

  @override
  Future<List<Race>> getRaces(int competitionId) async {
    final dtos = await _dataSource.getRaces(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }
}
