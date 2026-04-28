import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

abstract class ClubRepository {
  Future<List<Club>> getClubs(int competitionId);
  Future<Club> getClubDetail(int clubId);
}

class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._dataSource);

  final ClubRemoteDataSource _dataSource;

  @override
  Future<List<Club>> getClubs(int competitionId) async {
    final dtos = await _dataSource.getClubs(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<Club> getClubDetail(int clubId) async {
    final dto = await _dataSource.getClubDetail(clubId);
    return dto.toDomain();
  }
}
