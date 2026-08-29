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

  /// Rows per request. FFSS falls back to 30 when no window is asked for,
  /// which is well under what a real competition holds.
  static const _pageSize = 100;

  /// Pages until the server returns a short batch.
  ///
  /// Asking for the whole list in one go is not an option: the endpoint caps
  /// what it serves, and reading only the first page made every déroulement
  /// past the cap look absent from the app while it sat plainly on the federal
  /// site — a competition with 69 of them showed 30.
  @override
  Future<List<RaceFormatConfiguration>> getRaceFormats(
      int competitionId) async {
    final all = <RaceFormatConfiguration>[];
    var start = 0;
    while (true) {
      final batch = await _dataSource.getRaceFormats(
        competitionId,
        start: start,
        length: _pageSize,
      );
      all.addAll(batch.map((d) => d.toDomain()));
      if (batch.length < _pageSize) break;
      start += _pageSize;
    }
    return all;
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
