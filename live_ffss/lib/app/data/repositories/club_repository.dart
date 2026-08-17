import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';

abstract class ClubRepository {
  Future<List<Club>> getClubs(int competitionId);
  Future<Club> getClubDetail(int clubId);

  /// Details for several clubs at once, keyed by club id. Best-effort: a club
  /// whose fetch fails is simply absent from the result. Needed because the
  /// competition's `organismes` list carries no logo/bonnet — only
  /// `organisme/:id` does — so callers have to fill the gap themselves.
  Future<Map<int, Club>> getClubDetails(Iterable<int> clubIds);

  /// Each athlete's club, images included, keyed by athlete id. Athletes whose
  /// club cannot be resolved are simply absent.
  ///
  /// Two sources, because neither alone is enough: the competition's club list
  /// names the clubs and splits the FFSS bucket organisme into the real ones,
  /// but it carries no logo or cap and does not name every athlete; the
  /// per-club detail carries the images but has to be asked for by club id.
  Future<Map<int, Club>> getAthleteClubs(
    int competitionId,
    Iterable<Athlete> athletes,
  );
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

  @override
  Future<Map<int, Club>> getAthleteClubs(
    int competitionId,
    Iterable<Athlete> athletes,
  ) async {
    final named = <int, Club>{};
    try {
      for (final club in await getClubs(competitionId)) {
        for (final member in club.athletes) {
          named[member.id] = club;
        }
      }
    } on AppException {
      // No names and no bucket split; the athlete's own clubId still gives the
      // detail call something to work with.
    }

    // The list does not name every athlete, so the club to fetch comes from the
    // athlete's own clubId whenever the list missed them. A guest club's id is
    // its own, not an FFSS organisme id: fetching it would 404 or, worse,
    // resolve to an unrelated club's logo.
    final wanted = <int>{
      for (final athlete in athletes)
        if (named[athlete.id]?.isGuest != true)
          if ((named[athlete.id]?.id ?? athlete.clubId) > 0)
            named[athlete.id]?.id ?? athlete.clubId,
    };

    final details = await getClubDetails(wanted);

    return {
      for (final athlete in athletes)
        if (_clubFor(athlete, named, details) case final Club club)
          athlete.id: club,
    };
  }

  Club? _clubFor(
    Athlete athlete,
    Map<int, Club> named,
    Map<int, Club> details,
  ) {
    final listed = named[athlete.id];
    if (listed?.isGuest == true) return listed;
    final id = listed?.id ?? athlete.clubId;
    // The detail wins: it is the only source carrying the logo and the cap.
    return details[id] ?? listed;
  }
}
