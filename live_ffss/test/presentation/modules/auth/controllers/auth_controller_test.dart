import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;
  late AuthController controller;

  final fakeUser = User(
    token: 'T',
    tokenExpiration: DateTime.utc(2030, 1, 1),
    label: 'X',
    type: UserType.licensee,
    role: UserRole.user,
  );

  setUp(() {
    repo = _MockAuthRepository();
    controller = AuthController(repo);
  });

  group('AuthController.login', () {
    test('on success: sets user, fires loggedIn event, clears error', () async {
      when(() => repo.login(login: 'a', password: 'b'))
          .thenAnswer((_) async => fakeUser);

      await controller.login(login: 'a', password: 'b');

      expect(controller.user.value, fakeUser);
      expect(controller.error.value, isNull);
      expect(controller.event.value, AuthEvent.loggedIn);
      expect(controller.isLoading.value, false);
    });

    test('on AppException: sets error, leaves user null, no event', () async {
      const failure = ApiException('Invalid credentials', statusCode: 401);
      when(() => repo.login(login: 'a', password: 'b')).thenThrow(failure);

      await controller.login(login: 'a', password: 'b');

      expect(controller.user.value, isNull);
      expect(controller.error.value, failure);
      expect(controller.event.value, isNull);
      expect(controller.isLoading.value, false);
    });

    test('isLoading is true while in flight', () async {
      var seenLoadingTrue = false;
      when(() => repo.login(login: 'a', password: 'b')).thenAnswer((_) async {
        seenLoadingTrue = controller.isLoading.value;
        return fakeUser;
      });

      await controller.login(login: 'a', password: 'b');

      expect(seenLoadingTrue, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('AuthController.logout', () {
    test('clears user and fires loggedOut event', () async {
      controller.user.value = fakeUser;
      when(() => repo.logout()).thenAnswer((_) async {});

      await controller.logout();

      expect(controller.user.value, isNull);
      expect(controller.event.value, AuthEvent.loggedOut);
    });

    test('on AppException sets error, leaves user untouched', () async {
      controller.user.value = fakeUser;
      const failure = NetworkException('offline');
      when(() => repo.logout()).thenThrow(failure);

      await controller.logout();

      expect(controller.user.value, fakeUser);
      expect(controller.error.value, failure);
    });
  });
}
