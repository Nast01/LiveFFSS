import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/domain/models/club.dart';

extension ClubMapper on ClubDto {
  Club toDomain() => Club(
        id: id,
        name: name,
        shortName: shortName,
        logoUrl: logoUrl,
        capUrl: capUrl,
      );
}

extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
