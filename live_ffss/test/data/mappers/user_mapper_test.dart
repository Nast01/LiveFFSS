import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';
import 'package:live_ffss/app/data/mappers/user_mapper.dart';
import 'package:live_ffss/app/domain/models/user.dart';

void main() {
  final fixedExpiry = DateTime.utc(2030, 1, 1);
  const token = 'tok-abc';

  group('UserMapper', () {
    test('maps a licencie UserDto with admin role to User', () {
      const dto = UserDto(
        label: 'Doe John',
        type: 'licencie',
        data: UserDtoData(
          role: 'admin',
          lastName: 'Doe',
          firstName: 'John',
          licenseeNumber: '12345',
          club: UserDtoClub(label: 'Marseille SC'),
        ),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.token, token);
      expect(user.tokenExpiration, fixedExpiry);
      expect(user.label, 'Doe John');
      expect(user.type, UserType.licensee);
      expect(user.role, UserRole.admin);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.licenseeNumber, '12345');
      expect(user.clubName, 'Marseille SC');
    });

    test('maps an organisme UserDto with no personal fields', () {
      const dto = UserDto(
        label: 'CN Marseille',
        type: 'organisme',
        data: UserDtoData(role: 'user'),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.type, UserType.organisme);
      expect(user.role, UserRole.user);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.licenseeNumber, isNull);
      expect(user.clubName, isNull);
    });

    test('maps unknown type and role to UserType.unknown / UserRole.unknown',
        () {
      const dto = UserDto(
        label: 'X',
        type: 'martian',
        data: UserDtoData(role: 'overlord'),
      );

      final user = dto.toDomain(token: token, tokenExpiration: fixedExpiry);

      expect(user.type, UserType.unknown);
      expect(user.role, UserRole.unknown);
    });

    test('preserves token + tokenExpiration verbatim', () {
      const dto = UserDto(
        label: 'X',
        type: 'licencie',
        data: UserDtoData(role: 'user'),
      );

      final user = dto.toDomain(
        token: 'special-token',
        tokenExpiration: DateTime.utc(2099, 12, 31, 23, 59, 59),
      );

      expect(user.token, 'special-token');
      expect(user.tokenExpiration, DateTime.utc(2099, 12, 31, 23, 59, 59));
    });
  });
}
