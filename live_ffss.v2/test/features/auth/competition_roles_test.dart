import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/entry_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_token_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

const _jean = Account(label: 'DUPONT Jean', type: 'licencie');

void main() {
  late _MockAuthRepository auth;
  late InMemoryTokenStorage tokens;
  late InMemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    auth = _MockAuthRepository();
    tokens = InMemoryTokenStorage();
    store = InMemoryLocalStore();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        httpClientProvider.overrideWithValue(_MockHttpClient()),
        tokenStorageProvider.overrideWithValue(tokens),
        localStoreProvider.overrideWithValue(store),
      ],
      retry: noRetry,
    );
    addTearDown(container.dispose);
  });

  Future<void> logIn() async {
    when(() => auth.requestToken(any(), any())).thenAnswer((_) async => 'abc');
    when(() => auth.me()).thenAnswer((_) async => _jean);
    await container.read(sessionProvider.future);
    await container.read(sessionProvider.notifier).login('jdupont', 'secret');
  }

  test('sans session : public, sans appeler le site', () async {
    final sub = container.listen(competitionRolesProvider(1416), (_, _) {});
    addTearDown(sub.close);

    expect(
      (await container.read(competitionRolesProvider(1416).future)).roles,
      ['public'],
    );
    verifyNever(() => auth.competitionRoles(any()));
    expect(container.read(canEnterProvider(1416)), isFalse);
  });

  test('connecté : les rôles du compte sur la compétition', () async {
    await logIn();
    when(() => auth.competitionRoles(1416)).thenAnswer(
      (_) async =>
          const CompetitionRoles(roles: ['public', 'licencie', 'officiel']),
    );
    final sub = container.listen(canEnterProvider(1416), (_, _) {});
    addTearDown(sub.close);

    expect(
      (await container.read(competitionRolesProvider(1416).future)).roles,
      ['public', 'licencie', 'officiel'],
    );
    expect(container.read(canEnterProvider(1416)), isTrue);
  });

  test('pas de saisie tant que les rôles se lisent', () async {
    await logIn();
    final pending = Completer<CompetitionRoles>();
    when(() => auth.competitionRoles(1416)).thenAnswer((_) => pending.future);
    final sub = container.listen(canEnterProvider(1416), (_, _) {});
    addTearDown(sub.close);

    expect(container.read(canEnterProvider(1416)), isFalse);

    pending.complete(const CompetitionRoles(roles: ['public', 'officiel']));
    await container.read(competitionRolesProvider(1416).future);
    expect(container.read(canEnterProvider(1416)), isTrue);
  });

  test('une relecture ne garde pas le droit précédent', () async {
    await logIn();
    when(() => auth.competitionRoles(1416)).thenAnswer(
      (_) async => const CompetitionRoles(roles: ['public', 'officiel']),
    );
    final sub = container.listen(canEnterProvider(1416), (_, _) {});
    addTearDown(sub.close);
    await container.read(competitionRolesProvider(1416).future);
    expect(container.read(canEnterProvider(1416)), isTrue);

    final pending = Completer<CompetitionRoles>();
    when(() => auth.competitionRoles(1416)).thenAnswer((_) => pending.future);
    container.invalidate(competitionRolesProvider(1416));

    expect(container.read(canEnterProvider(1416)), isFalse);
    pending.complete(const CompetitionRoles(roles: ['public']));
  });

  test('pas de saisie si la lecture des rôles échoue', () async {
    await logIn();
    when(
      () => auth.competitionRoles(1416),
    ).thenThrow(const NetworkException('hors ligne'));
    final sub = container.listen(canEnterProvider(1416), (_, _) {});
    addTearDown(sub.close);

    final access = container.listen(entryAccessProvider(1416), (_, _) {});
    addTearDown(access.close);

    await expectLater(
      container.read(competitionRolesProvider(1416).future),
      throwsA(isA<NetworkException>()),
    );
    expect(container.read(canEnterProvider(1416)), isFalse);
    // Pas un refus : les droits n'ont pas pu être vérifiés, l'écran propose
    // de réessayer.
    expect(container.read(entryAccessProvider(1416)), EntryAccess.unverified);

    when(() => auth.competitionRoles(1416)).thenAnswer(
      (_) async => const CompetitionRoles(roles: ['public', 'officiel']),
    );
    // « Réessayer ».
    container.invalidate(competitionRolesProvider(1416));
    expect(container.read(entryAccessProvider(1416)), EntryAccess.checking);
    await container.read(competitionRolesProvider(1416).future);
    expect(container.read(entryAccessProvider(1416)), EntryAccess.allowed);
  });

  test('un licencié sans rôle d\'officiel ne saisit pas', () async {
    await logIn();
    when(() => auth.competitionRoles(1416)).thenAnswer(
      (_) async => const CompetitionRoles(roles: ['public', 'licencie']),
    );
    final sub = container.listen(canEnterProvider(1416), (_, _) {});
    addTearDown(sub.close);

    await container.read(competitionRolesProvider(1416).future);

    expect(container.read(canEnterProvider(1416)), isFalse);
  });

  test('relu quand la session change', () async {
    await logIn();
    when(() => auth.competitionRoles(1416)).thenAnswer(
      (_) async => const CompetitionRoles(roles: ['public', 'officiel']),
    );
    final sub = container.listen(competitionRolesProvider(1416), (_, _) {});
    addTearDown(sub.close);
    expect(
      (await container.read(competitionRolesProvider(1416).future)).roles,
      ['public', 'officiel'],
    );

    await container.read(sessionProvider.notifier).logout();

    expect(
      (await container.read(competitionRolesProvider(1416).future)).roles,
      ['public'],
    );
  });
}
