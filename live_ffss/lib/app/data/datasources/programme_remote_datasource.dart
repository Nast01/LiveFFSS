import 'package:live_ffss/app/domain/models/competition_programme.dart';

abstract class ProgrammeRemoteDataSource {
  Future<void> pushProgramme(CompetitionProgramme programme);
}

/// Stub: FFSS has no documented write endpoints for créneaux/courses/parties
/// yet (only réunions). The local `ProgrammeService` is the source of truth;
/// wire this — plus the lean-model → Meeting/Slot/Run mapper — when the FFSS
/// endpoints land. Mirrors `ResultRemoteDataSourceImpl`.
class ProgrammeRemoteDataSourceImpl implements ProgrammeRemoteDataSource {
  ProgrammeRemoteDataSourceImpl();

  @override
  Future<void> pushProgramme(CompetitionProgramme programme) {
    throw UnimplementedError(
      'pushProgramme: FFSS write endpoints for créneaux/courses/parties are '
      'not documented. Local storage is the source of truth until then.',
    );
  }
}
