import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';

part 'follows.freezed.dart';

/// Un athlète suivi. Les ids d'engagement et le nom sont gardés à la création :
/// le Live et les classements marquent une ligne sans relire les participants.
@freezed
abstract class FollowedAthlete with _$FollowedAthlete {
  const factory FollowedAthlete({
    required int participantId,
    required String name,
    @Default('') String club,
    @Default(<int>[]) List<int> entryIds,
  }) = _FollowedAthlete;

  factory FollowedAthlete.fromParticipant(Participant participant) =>
      FollowedAthlete(
        participantId: participant.id,
        name: [
          participant.firstName,
          participant.lastName,
        ].where((part) => part.isNotEmpty).join(' '),
        club: participant.club,
        entryIds: [for (final entry in participant.entries) entry.entryId],
      );
}

/// Un club suivi, par son libellé : c'est tout ce qu'une place ou un
/// résultat porte du club.
@freezed
abstract class FollowedClub with _$FollowedClub {
  const factory FollowedClub({required int id, required String label}) =
      _FollowedClub;
}

/// Ce que l'utilisateur suit dans une compétition.
@freezed
abstract class Follows with _$Follows {
  const Follows._();

  const factory Follows({
    @Default(<FollowedAthlete>[]) List<FollowedAthlete> athletes,
    @Default(<FollowedClub>[]) List<FollowedClub> clubs,
  }) = _Follows;

  bool followsAthlete(int participantId) =>
      athletes.any((a) => a.participantId == participantId);

  bool followsClub(int id) => clubs.any((c) => c.id == id);

  bool _followsEntry(int? entryId) =>
      entryId != null && athletes.any((a) => a.entryIds.contains(entryId));

  /// Suivre un club, c'est voir tous ses nageurs : le libellé vaut pour les
  /// places individuelles comme pour les relais. Un libellé vide ne désigne aucun club : il ne doit pas faire suivre
  /// toutes les lignes sans club.
  bool _followsClubLabel(String label) {
    final wanted = label.trim();
    return wanted.isNotEmpty && clubs.any((c) => c.label.trim() == wanted);
  }
}

/// Vrai si la place est celle d'un athlète suivi (par engagement) ou d'un
/// club suivi (par libellé : relais compris).
bool isFollowedLane(Follows follows, LaneAssignment lane) =>
    follows._followsEntry(lane.entryId) || follows._followsClubLabel(lane.club);

/// Même règle pour une ligne de classement.
bool isFollowedResult(Follows follows, EventResult result) =>
    follows._followsEntry(result.entryId) ||
    follows._followsClubLabel(result.club);
