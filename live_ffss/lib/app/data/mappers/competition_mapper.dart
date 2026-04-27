import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

extension CompetitionMapper on CompetitionDto {
  Competition toDomain() => Competition(
        id: id,
        name: name,
        beginDate: _parseDate(beginDate),
        endDate: _parseDate(endDate),
        beginEntryLimitDate: _parseDate(beginEntryLimitDate),
        endEntryLimitDate: _parseDate(endEntryLimitDate),
        location: location,
        statusCode: statusCode,
        statusLabel: statusLabel,
        description: description,
        speciality: speciality,
        specialityLabel: specialityLabel,
        typeWater: typeWater,
        typePool: typePool,
        typeChrono: typeChrono,
        isEligibleToNationalRecord: isEligibleToNationalRecord,
        numberOfLanes: numberOfLanes ?? 0,
        organizer: organisme.organizerName,
        hasBegun: hasBegun,
        hasResult: hasResult,
        hasPassed: hasPassed,
        level: level,
        levelLabel: levelLabel,
        organizerClub: organisme.toClub(),
        refereePrincipal: refereePrincipal,
      );
}

extension CompetitionOrganismeMapper on CompetitionOrganismeDto {
  Club toClub() => Club(
        id: id,
        name: clubFullName ?? '',
        shortName: shortName,
        logoUrl: logoUrl,
        capUrl: capUrl,
      );
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.parse(raw);
}
