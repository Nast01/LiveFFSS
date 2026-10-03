import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:mocktail/mocktail.dart';

/// Branche, sur un [ClubRepository] simulé, la composition que
/// `ClubRepositoryImpl.withAthleteClubs` fait réellement : lire les clubs,
/// patcher les engagements avec, et les rendre inchangés quand la lecture
/// échoue.
///
/// Sans elle, chaque test devrait décider deux fois de la même chose — une
/// pour `getAthleteClubs`, une pour `withAthleteClubs`. Or c'est
/// `getAthleteClubs` qui porte la décision, et le patch n'est pas ce que ces
/// tests examinent ; il a ses propres tests, dans
/// `test/data/repositories/club_repository_test.dart`.
void stubAthleteClubPatch(ClubRepository repo) {
  // `any()` sur une liste exige une valeur de repli enregistrée ; la poser ici
  // épargne un `setUpAll` à chaque appelant.
  registerFallbackValue(<Entry>[]);
  when(() => repo.withAthleteClubs(any(), any()))
      .thenAnswer((invocation) async {
    final competitionId = invocation.positionalArguments[0] as int;
    final entries = invocation.positionalArguments[1] as List<Entry>;
    final athletes = [for (final entry in entries) ...entry.athletes];
    if (athletes.isEmpty) return entries;
    try {
      return entriesWithClubs(
        entries,
        await repo.getAthleteClubs(competitionId, athletes),
      );
    } on AppException {
      return entries;
    }
  });
}
