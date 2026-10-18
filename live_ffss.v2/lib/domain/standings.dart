import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/gender.dart';

part 'standings.freezed.dart';

@freezed
abstract class ClubStanding with _$ClubStanding {
  const factory ClubStanding({
    required int rank,
    required String club,
    required int points,

    /// Points du club précédent moins les siens ; nul pour le premier.
    int? gapToPrevious,
  }) = _ClubStanding;
}

@freezed
abstract class LicenseeStanding with _$LicenseeStanding {
  const factory LicenseeStanding({
    required int rank,
    required int athleteId,
    required String name,
    required String club,
    required Gender gender,
    required String categoryName,
    required int points,

    /// Lignes de classement de l'athlète, comptées ou non.
    required int races,
  }) = _LicenseeStanding;
}

/// Classement des clubs, règles de V3 (`Standings.Clubs`) : par club et par
/// épreuve, seuls les meilleurs résultats comptent (points décroissants puis
/// rang), [individualCounted] en individuel, [relayCounted] en relais.
List<ClubStanding> clubStandings(
  List<EventRanking> rankings, {
  int individualCounted = 3,
  int relayCounted = 1,
}) {
  final totals = <String, int>{};
  for (final ranking in rankings) {
    final cap = ranking.event.isRelay ? relayCounted : individualCounted;
    final byClub = <String, List<RankingRow>>{};
    for (final row in ranking.rows) {
      final club = row.result.club;
      if (club.isEmpty) continue;
      byClub.putIfAbsent(club, () => []).add(row);
    }
    for (final MapEntry(key: club, value: rows) in byClub.entries) {
      rows.sort(_byPointsThenRank);
      final counted = rows.take(cap < 0 ? 0 : cap);
      totals[club] =
          (totals[club] ?? 0) + counted.fold(0, (sum, r) => sum + r.points);
    }
  }
  final ordered = totals.entries.toList()..sort(_byPointsThenName);
  return [
    for (final (i, entry) in ordered.indexed)
      ClubStanding(
        rank: _tieRank(ordered.map((e) => e.value).toList(), i),
        club: entry.key,
        points: entry.value,
        gapToPrevious: i == 0 ? null : ordered[i - 1].value - entry.value,
      ),
  ];
}

/// Classement des licenciés, règles de V3 (`Standings.Licensees`) : épreuves
/// individuelles seulement, un classement par sexe de l'athlète et catégorie,
/// tous les résultats comptent. Un athlète sans sexe est écarté.
List<LicenseeStanding> licenseeStandings(List<EventRanking> rankings) {
  final groups = <(Gender, String), Map<int, _Licensee>>{};
  for (final ranking in rankings) {
    if (ranking.event.isRelay) continue;
    for (final row in ranking.rows) {
      final athletes = row.result.athletes;
      if (athletes.isEmpty) continue;
      final athlete = athletes.first;
      final gender = athlete.gender;
      if (gender == null) continue;
      final group = groups.putIfAbsent((
        gender,
        ranking.event.categoryName,
      ), () => {});
      final licensee = group.putIfAbsent(
        athlete.id,
        () => _Licensee(
          athlete.id,
          athlete.name,
          athlete.club.isEmpty ? row.result.club : athlete.club,
        ),
      );
      licensee.points += row.points;
      licensee.races++;
    }
  }
  final keys = groups.keys.toList()
    ..sort((a, b) => a.$1.index.compareTo(b.$1.index));
  return [
    for (final key in keys) ..._rankGroup(key.$1, key.$2, groups[key]!.values),
  ];
}

final class _Licensee {
  _Licensee(this.id, this.name, this.club);

  final int id;
  final String name;
  final String club;
  int points = 0;
  int races = 0;
}

List<LicenseeStanding> _rankGroup(
  Gender gender,
  String category,
  Iterable<_Licensee> members,
) {
  final ordered = members.toList()
    ..sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      return byPoints != 0 ? byPoints : a.name.compareTo(b.name);
    });
  final points = [for (final m in ordered) m.points];
  return [
    for (final (i, m) in ordered.indexed)
      LicenseeStanding(
        rank: _tieRank(points, i),
        athleteId: m.id,
        name: m.name,
        club: m.club,
        gender: gender,
        categoryName: category,
        points: m.points,
        races: m.races,
      ),
  ];
}

/// Rang 1, 1, 3 : un ex æquo reprend le rang du premier du groupe.
int _tieRank(List<int> points, int i) {
  var first = i;
  while (first > 0 && points[first - 1] == points[i]) {
    first--;
  }
  return first + 1;
}

int _byPointsThenRank(RankingRow a, RankingRow b) {
  final byPoints = b.points.compareTo(a.points);
  if (byPoints != 0) return byPoints;
  // Les non-classés (rang nul) passent après les classés.
  return (a.rank ?? 1 << 30).compareTo(b.rank ?? 1 << 30);
}

int _byPointsThenName(MapEntry<String, int> a, MapEntry<String, int> b) {
  final byPoints = b.value.compareTo(a.value);
  return byPoints != 0 ? byPoints : a.key.compareTo(b.key);
}
