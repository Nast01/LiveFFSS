import 'package:live_ffss_v2/data/ffss/dtos/competition_me_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';

extension CompetitionMeMapper on CompetitionMeDto {
  CompetitionRoles toDomain() {
    final roles = [
      for (final role in this.roles)
        if (role is String) role,
    ];
    return CompetitionRoles(
      roles: roles.isEmpty ? const ['public'] : roles,
      licenseeId: decodeRows([licensee], LicencieDto.fromJson, (
        LicencieDto dto,
      ) {
        return dto.id;
      }).firstOrNull,
      official: decodeRows([official], OfficialRoleDto.fromJson, (
        OfficialRoleDto dto,
      ) {
        return dto.toDomain();
      }).firstOrNull,
      refereeClubs: decodeRows(
        refereeClubs,
        ClubRefDto.fromJson,
        (ClubRefDto dto) => dto.toDomain(),
      ),
    );
  }
}

extension OfficialRoleMapper on OfficialRoleDto {
  /// Nul sans niveau. Un `principal` absent vaut faux : le rôle reste lu.
  OfficialRole? toDomain() {
    final level = this.level?.trim().toUpperCase();
    if (level == null || level.isEmpty) return null;
    return OfficialRole(
      level: level,
      levelLabel: levelLabel?.trim() ?? level,
      principal: principal ?? false,
    );
  }
}

extension ClubRefMapper on ClubRefDto {
  /// Nul sans id ni libellé.
  ClubRef? toDomain() {
    final id = this.id;
    final label = this.label;
    if (id == null || label == null) return null;
    return ClubRef(id: id, label: label);
  }
}
