import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'heat.freezed.dart';

/// Une série telle que le site FFSS la publie (une « course » FFSS), comme
/// `Heat` dans FFSSCompetition V3. Version minimale du lot 1 : ce que la
/// carte en direct affiche. Le lot 2 l'enrichit.
@freezed
abstract class Heat with _$Heat {
  const factory Heat({
    required int id,
    required String name,
    required int number,
    required RunStatus status,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    int? raceId,
    @Default('') String raceName,
    Gender? gender,

    /// Ids FFSS des places, dans l'ordre où l'API les sert : le tri par
    /// couloir se fait à l'affichage (`MeetingItemDetail.lanesOf`).
    @Default(<int>[]) List<int> placeIds,

    /// Nul tant que la série n'est pas générée (finale à venir).
    int? seriesId,
  }) = _Heat;
}
