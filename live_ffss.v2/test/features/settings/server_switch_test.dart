import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/in_memory_local_store.dart';
import '../../support/in_memory_secure_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

class _FailingStore extends InMemoryLocalStore {
  @override
  Future<String?> read(String key) async =>
      throw const StorageException('illisible');
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

void main() {
  group('readLaunchEnvironment', () {
    test("rien d'enregistré : la recette", () async {
      expect(
        await readLaunchEnvironment(InMemoryLocalStore()),
        AppEnvironment.development,
      );
    });

    test('relit le serveur enregistré', () async {
      final store = InMemoryLocalStore()
        ..values[AppEnvironment.environmentKey] = 'production';

      expect(await readLaunchEnvironment(store), AppEnvironment.production);
    });

    test('valeur inconnue ou stockage en panne : la recette', () async {
      final store = InMemoryLocalStore()
        ..values[AppEnvironment.environmentKey] = 'staging';

      expect(await readLaunchEnvironment(store), AppEnvironment.development);
      expect(
        await readLaunchEnvironment(_FailingStore()),
        AppEnvironment.development,
      );
    });
  });

  group('changement de serveur', () {
    late InMemorySecureStorage secure;
    late _MockAuthRepository recetteAuth;
    late _MockAuthRepository productionAuth;
    late ProviderContainer container;
    late List<AppEnvironment> cancelledOn;

    setUp(() {
      secure = InMemorySecureStorage();
      recetteAuth = _MockAuthRepository();
      productionAuth = _MockAuthRepository();
      cancelledOn = [];
      when(() => recetteAuth.me()).thenAnswer((_) async => _recette);
      when(() => productionAuth.me()).thenAnswer((_) async => _production);
      container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          // Un faux site par serveur : la session doit être reprise par
          // celui du serveur choisi.
          authRepositoryProvider.overrideWith(
            (ref) =>
                ref.watch(appConfigProvider).environment ==
                    AppEnvironment.production
                ? productionAuth
                : recetteAuth,
          ),
          httpClientProvider.overrideWith((ref) {
            ref.watch(appConfigProvider);
            return _MockHttpClient();
          }),
          reminderSchedulerProvider.overrideWithValue(
            _Scheduler(
              () => cancelledOn.add(
                container.read(appConfigProvider).environment,
              ),
            ),
          ),
        ],
        retry: noRetry,
      );
      addTearDown(container.dispose);
      // Chaque serveur a sa session et sa compétition active.
      secure.values
        ..['dev_token'] = 'jeton-recette'
        ..['dev_session_account'] = 'ORGANISME TEST'
        ..['dev_session_role'] = 'admin'
        ..['dev_active_competition'] = '1416'
        ..['token'] = 'jeton-production'
        ..['session_account'] = 'DUPONT Jean'
        ..['active_competition'] = '900';
    });

    test('par défaut, la recette', () {
      expect(
        container.read(appConfigProvider).environment,
        AppEnvironment.development,
      );
    });

    test("le serveur lu au lancement est celui de l'app", () {
      final launched = ProviderContainer(
        overrides: [
          launchEnvironmentProvider.overrideWithValue(
            AppEnvironment.production,
          ),
        ],
        retry: noRetry,
      );
      addTearDown(launched.dispose);

      expect(
        launched.read(appConfigProvider).environment,
        AppEnvironment.production,
      );
    });

    test('switchTo enregistre le serveur sous la clé globale', () async {
      await container
          .read(appConfigProvider.notifier)
          .switchTo(AppEnvironment.production);

      expect(
        container.read(appConfigProvider).environment,
        AppEnvironment.production,
      );
      expect(secure.values[AppEnvironment.environmentKey], 'production');
      expect(secure.values.containsKey('dev_api_environment'), isFalse);
    });

    test("le stockage, la session et la compétition active suivent, sans rien "
        "effacer de l'autre serveur", () async {
      expect(await container.read(sessionProvider.future), _recette);
      expect(
        (await container.read(activeCompetitionProvider.future))?.id,
        1416,
      );

      await switchServer(container, AppEnvironment.production);

      expect(await container.read(sessionProvider.future), _production);
      expect((await container.read(activeCompetitionProvider.future))?.id, 900);
      expect(
        await container.read(localStoreProvider).read('active_competition'),
        '900',
      );
      // La recette garde tout, pour le retour.
      expect(secure.values['dev_token'], 'jeton-recette');
      expect(secure.values['dev_session_account'], 'ORGANISME TEST');
      expect(secure.values['dev_session_role'], 'admin');
      expect(secure.values['dev_active_competition'], '1416');

      await switchServer(container, AppEnvironment.development);

      expect(await container.read(sessionProvider.future), _recette);
      expect(
        (await container.read(activeCompetitionProvider.future))?.id,
        1416,
      );
      expect(secure.values['token'], 'jeton-production');
    });

    test('les rappels sont annulés avant de changer de serveur', () async {
      await switchServer(container, AppEnvironment.production);

      expect(cancelledOn, [AppEnvironment.development]);
    });

    test('même serveur : rien ne change', () async {
      await switchServer(container, AppEnvironment.development);

      expect(cancelledOn, isEmpty);
      expect(secure.values.containsKey(AppEnvironment.environmentKey), isFalse);
    });

    test("la navigation repart de l'onglet d'ouverture", () async {
      final before = container.read(routerProvider);

      await switchServer(container, AppEnvironment.production);

      expect(identical(container.read(routerProvider), before), isFalse);
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
      expect(
        serverSwitchMessage(AppEnvironment.production, 0, fr),
        isNot(contains('saisie')),
      );
      expect(
        serverSwitchMessage(AppEnvironment.production, 2, fr),
        contains('2 saisies'),
      );
    });
  });
}
