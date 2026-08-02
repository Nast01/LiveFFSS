import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

abstract class ClubRepository {
  Future<List<Club>> getClubs(int competitionId);
  Future<Club> getClubDetail(int clubId);

  /// Details for several clubs at once, keyed by club id. Best-effort: a club
  /// whose fetch fails is simply absent from the result. Needed because the
  /// competition's `organismes` list carries no logo/bonnet — only
  /// `organisme/:id` does — so callers have to fill the gap themselves.
  Future<Map<int, Club>> getClubDetails(Iterable<int> clubIds);
}

class ClubRepositoryImpl implements ClubRepository {
  ClubRepositoryImpl(this._dataSource);

  final ClubRemoteDataSource _dataSource;

  @override
  Future<List<Club>> getClubs(int competitionId) async {
    final dtos = await _dataSource.getClubs(competitionId);
    // expand, not map: the FFSS bucket organisme stands for several real clubs.
    return dtos.expand((d) => d.toDomainClubs()).toList();
  }

  @override
  Future<Club> getClubDetail(int clubId) async {
    final dto = await _dataSource.getClubDetail(clubId);
    final clubs = dto.toDomainClubs();
    return clubs.firstWhere((c) => c.id == clubId, orElse: () => clubs.first);
  }

  /// Fan-out size. The API has no bulk club route, so a competition with 60
  /// clubs means 60 requests — chunked to avoid opening them all at once.
  static const int _detailBatchSize = 8;

  @override
  Future<Map<int, Club>> getClubDetails(Iterable<int> clubIds) async {
    final ids = clubIds.where((id) => id > 0).toSet().toList();
    final byId = <int, Club>{};
    for (var i = 0; i < ids.length; i += _detailBatchSize) {
      final batch = ids.skip(i).take(_detailBatchSize);
      await Future.wait(batch.map((id) async {
        try {
          byId[id] = await getClubDetail(id);
        } on AppException {
          // Best-effort: this club keeps whatever fallback the view shows.
        }
      }));
    }
    return byId;
  }
}
