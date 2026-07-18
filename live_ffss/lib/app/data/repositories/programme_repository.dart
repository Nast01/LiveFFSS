import 'package:live_ffss/app/data/datasources/programme_remote_datasource.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

abstract class ProgrammeRepository {
  Future<void> push(CompetitionProgramme programme);
}

class ProgrammeRepositoryImpl implements ProgrammeRepository {
  ProgrammeRepositoryImpl(this._dataSource);

  final ProgrammeRemoteDataSource _dataSource;

  @override
  Future<void> push(CompetitionProgramme programme) =>
      _dataSource.pushProgramme(programme);
}
