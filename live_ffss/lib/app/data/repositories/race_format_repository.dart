import 'package:live_ffss/app/data/datasources/race_format_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/race_format_configuration_mapper.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';

/// The "déroulements" of a competition: one per (discipline, gender), each
/// carrying its categories and the rounds FFSS holds for it.
///
/// Unlike everything else in this app's programme feature, these are stored
/// server-side and can be created and deleted through the API.
abstract class RaceFormatRepository {
  Future<List<RaceFormatConfiguration>> getRaceFormats(int competitionId);

  /// Creates a déroulement (or updates the one with [id]) and returns the id
  /// FFSS assigned. Returns 0 when the API reported a failure.
  Future<int> submitRaceFormat({
    required int competitionId,
    required int disciplineId,
    required String gender,
    required List<int> categoryIds,
    int? id,
  });

  Future<bool> deleteRaceFormat(int raceFormatId);

  /// Deletes one round of a déroulement, by its FFSS `partie` id.
  Future<bool> deleteRaceFormatDetail(int detailId);
}

class RaceFormatRepositoryImpl implements RaceFormatRepository {
  RaceFormatRepositoryImpl(this._dataSource);

  final RaceFormatRemoteDataSource _dataSource;

  @override
  Future<List<RaceFormatConfiguration>> getRaceFormats(
      int competitionId) async {
    final dtos = await _dataSource.getRaceFormats(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<int> submitRaceFormat({
    required int competitionId,
    required int disciplineId,
    required String gender,
    required List<int> categoryIds,
    int? id,
  }) =>
      _dataSource.submitRaceFormat(
        competitionId: competitionId,
        disciplineId: disciplineId,
        gender: gender,
        categoryIds: categoryIds,
        id: id,
      );

  @override
  Future<bool> deleteRaceFormat(int raceFormatId) =>
      _dataSource.deleteRaceFormat(raceFormatId);

  @override
  Future<bool> deleteRaceFormatDetail(int detailId) =>
      _dataSource.deleteRaceFormatDetail(detailId);
}
