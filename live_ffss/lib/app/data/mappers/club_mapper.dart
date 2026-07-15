import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/referee_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

extension ClubMapper on ClubDto {
  Club toDomain() {
    // Lightweight back-reference used to populate athletes/referees `club`.
    // Excludes the athlete/referee lists themselves to avoid recursion.
    final clubLite = Club(
      id: id,
      name: name,
      shortName: shortName,
      logoUrl: logoUrl,
      capUrl: capUrl,
    );
    return Club(
      id: id,
      name: name,
      shortName: shortName,
      logoUrl: logoUrl,
      capUrl: capUrl,
      athletes:
          athletes.map((a) => a.toDomain().copyWith(club: clubLite)).toList(),
      referees:
          referees.map((r) => r.toDomain().copyWith(club: clubLite)).toList(),
    );
  }
}

extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
