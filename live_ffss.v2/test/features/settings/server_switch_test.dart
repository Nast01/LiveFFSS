import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/app_host.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/admin/maintenance_providers.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/officiel/outbox_store.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_secure_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

class _MockCompetitionRepository extends Mock
    implements CompetitionRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

class _MockResultRepository extends Mock implements ResultRepository {}

class _FailingStore extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async => throw StateError('keystore');
}

class _Scheduler extends NoReminderScheduler {
  _Scheduler(this.onCancel);

  final void Function() onCancel;

  @override
  Future<void> cancelAll() async => onCancel();
}

const _recette = Account(label: 'ORGANISME TEST', role: 'admin');
const _production = Account(label: 'DUPONT Jean', role: 'user');

OutboxOperation _op(String account, OutboxState state) => OutboxOperation(
  id: '$account-${state.name}',
  account: account,
  competitionId: 1416,
  placeId: 11,
  seriesId: 5,
  entryId: 7,
  change: const ResultChange(chronos: [5000, null, null]),
  state: state,
);

/// Un faux par serveur, choisi d'après le serveur du conteneur.
T _byServer<T>(Ref ref, {required T recette, required T production}) =>
    ref.watch(appConfigProvider).environment == AppEnvironment.production
    ? production
    : recette;

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const RaceResult(seriesId: 0, entryId: 0));
    registerFallbackValue(<int>[]);
  });

  group('readLaunchEnvironment', () {
    test("rien d'enregistré : la recette", () async {
      expect(
        await readLaunchEnvironment(GlobalStore(InMemoryLocalStore())),
        AppEnvironment.development,
      );
    });

    test('relit le serveur enregistré', () async {
      final store = InMemoryLocalStore()
        ..values[AppEnvironment.environmentKey] = 'production';

      expect(
        await readLaunchEnvironment(GlobalStore(store)),
        AppEnvironment.production,
      );
    });

    test('valeur inconnue ou stockage en panne : la recette', () async {
      final store = InMemoryLocalStore()
        ..values[AppEnvironment.environmentKey] = 'staging';

      expect(
        await readLaunchEnvironment(GlobalStore(store)),
        AppEnvironment.development,
      );
      expect(
        await readLaunchEnvironment(GlobalStore(_FailingStore())),
        AppEnvironment.development,
      );
    });
  });

  group('GlobalStore', () {
    test('ne lit ni n\'écrit une clé propre à un serveur', () {
      final store = GlobalStore(InMemoryLocalStore());

      expect(() => store.read('token'), throwsA(isA<AssertionError>()));
      expect(
        () => store.write('active_competition', '1'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('changement de serveur', () {
    late InMemorySecureStorage secure;
    late _MockAuthRepository recetteAuth;
    late _MockAuthRepository productionAuth;
    late _MockHttpClient recetteHttp;
    late _MockHttpClient productionHttp;
    late _MockCompetitionRepository recetteCompetitions;
    late _MockCompetitionRepository productionCompetitions;
    late _MockMeetingRepository recetteMeetings;
    late _MockMeetingRepository productionMeetings;
    late _MockResultRepository recetteResults;
    late _MockResultRepository productionResults;
    late List<AppEnvironment> cancelledOn;
    late AppContainerHost host;

    setUp(() {
      secure = InMemorySecureStorage();
      recetteAuth = _MockAuthRepository();
      productionAuth = _MockAuthRepository();
      recetteHttp = _MockHttpClient();
      productionHttp = _MockHttpClient();
      recetteCompetitions = _MockCompetitionRepository();
      productionCompetitions = _MockCompetitionRepository();
      recetteMeetings = _MockMeetingRepository();
      productionMeetings = _MockMeetingRepository();
      recetteResults = _MockResultRepository();
      productionResults = _MockResultRepository();
      cancelledOn = [];
      when(() => recetteAuth.me()).thenAnswer((_) async => _recette);
      when(() => productionAuth.me()).thenAnswer((_) async => _production);
      when(() => recetteCompetitions.getCompetitionsFrom(any())).thenAnswer(
        (_) async => [competition(1416, start: DateTime(2026, 10, 19))],
      );
      when(() => productionCompetitions.getCompetitionsFrom(any())).thenAnswer(
        (_) async => [competition(900, start: DateTime(2026, 10, 19))],
      );
      // La recette est hors ligne : sa saisie attend.
      when(
        () => recetteMeetings.getLanes(any()),
      ).thenThrow(const NetworkException('hors ligne'));
      when(() => productionMeetings.getLanes(any())).thenAnswer((_) async {
        return {};
      });

      host = AppContainerHost(
        environment: AppEnvironment.development,
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          authRepositoryProvider.overrideWith(
            (ref) => _byServer(
              ref,
              recette: recetteAuth,
              production: productionAuth,
            ),
          ),
          httpClientProvider.overrideWith(
            (ref) => _byServer(
              ref,
              recette: recetteHttp,
              production: productionHttp,
            ),
          ),
          competitionRepositoryProvider.overrideWith(
            (ref) => _byServer(
              ref,
              recette: recetteCompetitions,
              production: productionCompetitions,
            ),
          ),
          meetingRepositoryProvider.overrideWith(
            (ref) => _byServer(
              ref,
              recette: recetteMeetings,
              production: productionMeetings,
            ),
          ),
          resultRepositoryProvider.overrideWith(
            (ref) => _byServer(
              ref,
              recette: recetteResults,
              production: productionResults,
            ),
          ),
          reminderSchedulerProvider.overrideWith(
            (ref) => _Scheduler(
              () => cancelledOn.add(ref.read(appConfigProvider).environment),
            ),
          ),
        ],
      );
      addTearDown(host.dispose);
      // Chaque serveur a sa session et sa compétition active. Le même nom
      // de compte sur la file de la recette : le pire cas.
      secure.values
        ..['dev_token'] = 'jeton-recette'
        ..['dev_session_account'] = 'ORGANISME TEST'
        ..['dev_session_role'] = 'admin'
        ..['dev_active_competition'] = '1416'
        ..['dev_outbox'] = OutboxStore.encode([
          _op('DUPONT Jean', OutboxState.pending),
        ])
        ..['token'] = 'jeton-production'
        ..['session_account'] = 'DUPONT Jean'
        ..['active_competition'] = '900';
    });

    test('par défaut, la recette', () {
      expect(
        host.container.read(appConfigProvider).environment,
        AppEnvironment.development,
      );
    });

    test('enregistre le serveur sous la clé globale', () async {
      await switchServer(host.container, AppEnvironment.production);

      expect(
        host.container.read(appConfigProvider).environment,
        AppEnvironment.production,
      );
      expect(secure.values[AppEnvironment.environmentKey], 'production');
      expect(secure.values.containsKey('dev_api_environment'), isFalse);
    });

    test('un conteneur neuf : session, accueil, compétition active, file '
        "d'envoi et routeur, sans rien de l'ancien serveur", () async {
      final old = host.container;
      old.listen(outboxProvider, (_, _) {});
      expect(await old.read(sessionProvider.future), _recette);
      expect(
        (await old.read(homeCompetitionsProvider.future)).map((c) => c.id),
        [1416],
      );
      expect((await old.read(activeCompetitionProvider.future))?.id, 1416);
      await pumpEventQueue();
      expect(old.read(outboxProvider), hasLength(1));
      final oldRouter = old.read(routerProvider);

      await switchServer(old, AppEnvironment.production);
      final fresh = host.container;

      expect(identical(fresh, old), isFalse);
      // Rien de l'ancien, pas même une valeur précédente pendant la reprise.
      expect(fresh.read(sessionProvider).hasValue, isFalse);
      expect(await fresh.read(sessionProvider.future), _production);
      expect(fresh.read(sessionExpiredProvider), isFalse);
      expect(
        (await fresh.read(
          homeCompetitionsProvider.future,
        )).map((CompetitionSummary c) => c.id),
        [900],
      );
      expect((await fresh.read(activeCompetitionProvider.future))?.id, 900);
      expect(fresh.read(outboxProvider), isEmpty);
      expect(identical(fresh.read(routerProvider), oldRouter), isFalse);
      // La recette garde tout, pour le retour.
      expect(secure.values['dev_token'], 'jeton-recette');
      expect(secure.values['dev_session_account'], 'ORGANISME TEST');
      expect(secure.values['dev_session_role'], 'admin');
      expect(secure.values['dev_active_competition'], '1416');
      expect(secure.values['dev_outbox'], contains('DUPONT Jean'));

      await switchServer(fresh, AppEnvironment.development);

      expect(await host.container.read(sessionProvider.future), _recette);
      expect(secure.values['token'], 'jeton-production');
    });

    test("un refus de jeton venu de l'ancien serveur ne touche pas au "
        'nouveau', () async {
      await host.container.read(sessionProvider.future);
      final expire =
          verify(() => recetteHttp.onAuthFailure = captureAny()).captured.last
              as Future<void> Function();

      await switchServer(host.container, AppEnvironment.production);
      expect(await host.container.read(sessionProvider.future), _production);
      await expire();

      expect(host.container.read(sessionProvider).value, _production);
      expect(host.container.read(sessionExpiredProvider), isFalse);
      expect(secure.values['token'], 'jeton-production');
      expect(secure.values['dev_token'], 'jeton-recette');
    });

    test("une connexion en cours sur l'ancien serveur n'ouvre rien sur le "
        'nouveau', () async {
      final old = host.container;
      await old.read(sessionProvider.future);
      final token = Completer<String>();
      when(
        () => recetteAuth.requestToken(any(), any()),
      ).thenAnswer((_) => token.future);
      final login = old.read(sessionProvider.notifier).login('x', 'secret');
      await pumpEventQueue();

      await switchServer(old, AppEnvironment.production);
      expect(await host.container.read(sessionProvider.future), _production);
      token.complete('jeton-neuf');
      await login;

      expect(host.container.read(sessionProvider).value, _production);
      expect(secure.values['token'], 'jeton-production');
      expect(secure.values['dev_token'], isNot('jeton-neuf'));
    });

    test(
      "la file d'un serveur ne part jamais avec la session de l'autre",
      () async {
        host.container.listen(outboxProvider, (_, _) {});
        await host.container.read(sessionProvider.future);
        await pumpEventQueue();
        expect(host.container.read(outboxProvider), hasLength(1));

        await switchServer(host.container, AppEnvironment.production);
        host.container.listen(outboxProvider, (_, _) {});
        await host.container.read(sessionProvider.future);
        await pumpEventQueue();

        verifyNever(() => productionMeetings.getLanes(any()));
        verifyNever(() => productionResults.submit(any()));
        verifyNever(() => recetteResults.submit(any()));
        expect(secure.values['dev_outbox'], contains('DUPONT Jean'));
      },
    );

    group('une saisie en cours d\'envoi', () {
      late Completer<int> submitted;

      setUp(() {
        secure.values['dev_outbox'] = OutboxStore.encode([
          _op('ORGANISME TEST', OutboxState.pending),
        ]);
        when(() => recetteMeetings.getLanes(any())).thenAnswer(
          (_) async => {11: const LaneAssignment(id: 11, lane: 1, entryId: 7)},
        );
        submitted = Completer<int>();
        when(
          () => recetteResults.submit(any()),
        ).thenAnswer((_) => submitted.future);
      });

      /// La création part, sa réponse n'est pas revenue.
      Future<ProviderContainer> sending() async {
        final old = host.container;
        old.listen(outboxProvider, (_, _) {});
        await old.read(sessionProvider.future);
        await pumpEventQueue();
        verify(() => recetteResults.submit(any())).called(1);
        return old;
      }

      List<OutboxOperation> stored(String key) =>
          switch (OutboxStore.decode(secure.values[key])) {
            OutboxLoaded(:final operations) => operations,
            OutboxUnreadable() => const [],
          };

      Future<void> backOnRecette() async {
        await switchServer(host.container, AppEnvironment.development);
        host.container.listen(outboxProvider, (_, _) {});
        await host.container.read(sessionProvider.future);
        await pumpEventQueue();
      }

      test('changer de serveur attend sa réponse, et elle ne repart pas au '
          'retour', () async {
        final old = await sending();
        var switched = false;
        final switching = switchServer(
          old,
          AppEnvironment.production,
        ).whenComplete(() => switched = true);
        await pumpEventQueue();

        expect(switched, isFalse);
        expect(identical(host.container, old), isTrue);
        expect(cancelledOn, isEmpty);

        submitted.complete(99);
        expect(await switching, isTrue);

        expect(identical(host.container, old), isFalse);
        expect(stored('dev_outbox').single.state, OutboxState.sent);
        await backOnRecette();
        verifyNever(() => recetteResults.submit(any()));
      });

      test('forcer le rechargement attend aussi sa réponse', () async {
        final old = await sending();
        var reloaded = false;
        final reloading = forceReload(
          old,
          1416,
        ).whenComplete(() => reloaded = true);
        await pumpEventQueue();

        expect(reloaded, isFalse);
        expect(identical(host.container, old), isTrue);

        submitted.complete(99);
        expect(await reloading, isTrue);

        expect(identical(host.container, old), isFalse);
        host.container.listen(outboxProvider, (_, _) {});
        await host.container.read(sessionProvider.future);
        await pumpEventQueue();
        verifyNever(() => recetteResults.submit(any()));
        expect(stored('dev_outbox').single.state, OutboxState.sent);
      });

      test('délai dépassé : rien ne change, rien ne part deux fois', () async {
        final old = await sending();

        expect(
          await switchServer(
            old,
            AppEnvironment.production,
            timeout: const Duration(milliseconds: 20),
          ),
          isFalse,
        );
        expect(
          await forceReload(
            old,
            1416,
            timeout: const Duration(milliseconds: 20),
          ),
          isFalse,
        );

        expect(identical(host.container, old), isTrue);
        expect(cancelledOn, isEmpty);
        expect(
          secure.values.containsKey(AppEnvironment.environmentKey),
          isFalse,
        );
        submitted.complete(99);
        await pumpEventQueue();
        verifyNever(() => recetteResults.submit(any()));
        expect(old.read(outboxProvider).single.state, OutboxState.sent);
        expect(stored('dev_outbox').single.state, OutboxState.sent);
      });
    });

    test('les rappels sont annulés avant de changer de serveur', () async {
      await switchServer(host.container, AppEnvironment.production);

      expect(cancelledOn, [AppEnvironment.development]);
    });

    test('même serveur : rien ne change', () async {
      final before = host.container;

      await switchServer(before, AppEnvironment.development);

      expect(cancelledOn, isEmpty);
      expect(identical(host.container, before), isTrue);
      expect(secure.values.containsKey(AppEnvironment.environmentKey), isFalse);
    });
  });

  test('confirmation : les saisies non envoyées du compte connecté', () {
    final queue = [
      _op('ORGANISME TEST', OutboxState.pending),
      _op('ORGANISME TEST', OutboxState.rejected),
      _op('ORGANISME TEST', OutboxState.sent),
      _op('DUPONT Jean', OutboxState.pending),
    ];

    expect(serverSwitchUnsentCount(queue, _recette), 2);
    expect(serverSwitchUnsentCount(queue, null), 0);
  });

  group('formatage', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('nom du serveur', () {
      expect(serverLabel(AppEnvironment.development, fr), 'Recette');
      expect(serverLabel(AppEnvironment.production, fr), 'Production');
      expect(serverLabel(AppEnvironment.development, en), 'Staging');
    });

    test('bandeau : hors production seulement', () {
      expect(serverBanner(AppEnvironment.development, fr), 'RECETTE');
      expect(serverBanner(AppEnvironment.production, fr), isNull);
    });

    test('message de confirmation, avec les saisies non envoyées', () {
      expect(serverSwitchMessage(0, fr), isNot(contains('saisie')));
      expect(serverSwitchMessage(2, fr), contains('2 saisies'));
    });
  });
}
