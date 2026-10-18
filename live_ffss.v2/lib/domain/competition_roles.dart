import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition_roles.freezed.dart';

/// Ce que le site sait du compte connecté sur une compétition (`/me`).
@freezed
abstract class CompetitionRoles with _$CompetitionRoles {
  const CompetitionRoles._();

  const factory CompetitionRoles({
    /// Les codes de rôle (`public`, `licencie`, `officiel`…).
    required List<String> roles,

    /// L'identifiant du licencié du compte, qui relie ses engagements.
    int? licenseeId,
    OfficialRole? official,

    /// Les clubs dont le compte est référent sportif.
    @Default(<ClubRef>[]) List<ClubRef> refereeClubs,
  }) = _CompetitionRoles;

  bool get isAdmin => roles.contains('admin');
  bool get isOfficial => roles.contains('officiel');
  bool get isReferee => roles.contains('referent_sportif');
}

/// La fonction d'officiel du compte sur la compétition.
@freezed
abstract class OfficialRole with _$OfficialRole {
  const factory OfficialRole({
    /// Le code du niveau (`A`, `B`, `C`…).
    required String level,
    required String levelLabel,
    required bool principal,
  }) = _OfficialRole;
}

/// Un club dont le compte est référent.
@freezed
abstract class ClubRef with _$ClubRef {
  const factory ClubRef({required int id, required String label}) = _ClubRef;
}
