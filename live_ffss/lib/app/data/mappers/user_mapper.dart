import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/domain/models/user.dart';

extension UserMapper on UserDto {
  User toDomain({
    required String token,
    required DateTime tokenExpiration,
  }) =>
      User(
        token: token,
        tokenExpiration: tokenExpiration,
        label: label,
        type: _parseType(type),
        role: _parseRole(data.role),
        firstName: data.firstName,
        lastName: data.lastName,
        licenseeNumber: data.licenseeNumber,
        clubName: data.club?.label,
      );
}

UserType _parseType(String raw) => switch (raw) {
      'licencie' => UserType.licensee,
      'organisme' => UserType.organisme,
      _ => UserType.unknown,
    };

UserRole _parseRole(String raw) => switch (raw) {
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      _ => UserRole.unknown,
    };
