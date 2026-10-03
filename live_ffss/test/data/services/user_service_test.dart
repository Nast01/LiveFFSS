import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepo auth;
  late StreamController<User?> users;

  final stored = User(
    token: 'tok',
    tokenExpiration: DateTime.utc(2099),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

  setUp(() {
    auth = _MockAuthRepo();
    users = StreamController<User?>.broadcast();
    when(() => auth.userStream).thenAnswer((_) => users.stream);
    when(() => auth.revalidateSession()).thenAnswer((_) async {});
  });

  tearDown(() => users.close());

  group('UserService.init', () {
    test('rend la session memorisee', () async {
      when(() => auth.restoreStoredSession()).thenAnswer((_) async => stored);

      final service = await UserService(auth).init();

      expect(service.currentUser.value, stored);
      expect(service.isLoggedIn, isTrue);
      expect(service.userFirstLetter, 'F');
    });

    // Le coeur du correctif : `InitialBinding.register()` tourne avant
    // `runApp`, donc une sonde attendue ici tenait l'ecran noir jusqu'a quatre
    // secondes plus la resolution DNS.
    test('n attend pas la sonde serveur', () async {
      when(() => auth.restoreStoredSession()).thenAnswer((_) async => stored);
      // Une sonde qui ne repond jamais : si init() l'attendait, ce test
      // expirerait au lieu de passer.
      when(() => auth.revalidateSession())
          .thenAnswer((_) => Completer<void>().future);

      final service = await UserService(auth).init();

      expect(service.currentUser.value, stored);
      verify(() => auth.revalidateSession()).called(1);
    });

    test('sans session memorisee, aucune sonde', () async {
      when(() => auth.restoreStoredSession()).thenAnswer((_) async => null);

      final service = await UserService(auth).init();

      expect(service.currentUser.value, isNull);
      verifyNever(() => auth.revalidateSession());
    });

    // Ce que la sonde fait quand le serveur repond « vous n'etes personne » :
    // elle ferme la session, et c'est par ce flux que l'interface l'apprend.
    test('une fermeture venue du flux vide la session', () async {
      when(() => auth.restoreStoredSession()).thenAnswer((_) async => stored);
      final service = await UserService(auth).init();

      users.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(service.currentUser.value, isNull);
      expect(service.isLoggedIn, isFalse);
    });

    test('un echec de la sonde ne fait pas echouer le demarrage', () async {
      when(() => auth.restoreStoredSession()).thenAnswer((_) async => stored);
      when(() => auth.revalidateSession())
          .thenAnswer((_) async => throw Exception('keystore indisponible'));

      final service = await UserService(auth).init();
      await Future<void>.delayed(Duration.zero);

      // La session locale tient : la premiere ecriture retombera sur
      // onAuthFailure si elle est reellement morte.
      expect(service.currentUser.value, stored);
    });
  });
}
