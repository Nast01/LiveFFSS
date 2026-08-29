# Programme piloté par FFSS — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** l'onglet Programme lit et écrit l'arbre Réunion → Créneau de FFSS au lieu d'un horaire qui n'existe que sur l'appareil.

**Architecture:** `MeetingRemoteDataSource` porte les trois niveaux de l'arbre `reunion` (réunion, créneau, course) parce qu'ils changent ensemble et n'ont de sens qu'ensemble. Le repository possède l'auto-pagination et le chargement parallèle des courses ; le contrôleur calcule les horaires par site et l'heure de fin de la réunion.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX, freezed + json_serializable, mocktail.

**Spec:** `docs/superpowers/specs/2026-08-29-programme-server-backed-design.md`

## Global Constraints

- Authentification : paramètre d'URL `token`, jamais l'en-tête seul. `HttpClient` l'injecte, ne rien faire de particulier.
- Toute liste FFSS est paginée façon DataTables : passer `start` et `length`, boucler jusqu'à une page courte. Sans paramètres, le serveur sert 30 lignes en silence.
- Les contrôleurs ne connaissent ni `.tr`, ni `Get.dialog`, ni `Get.snackbar`. Messages via `Rxn<UiMessage>` publiés avec `message.trigger(...)`, **jamais** `message.value =`.
- Attraper `AppException`, jamais `Exception`.
- Injection par constructeur uniquement, câblée dans le binding.
- Tests : `mocktail`, aucun test widget.
- Format des heures envoyées : `HH:mm`. Format du jour : `yyyy-MM-dd`.
- Durée par défaut d'un item : **10 minutes**. Départ par défaut d'une réunion : **08:00**.

---

## Ce que les sondes sur l'API ont établi

Vérifié en production le 2026-08-29, compétition 1451, données de test supprimées ensuite.

**Les DTO existants sont justes.** La réponse `reunion` porte `Id`, `IdEvenement`, `Nom`, `Jour`, `Description`, `Debut`, `Fin`, `label`, `fullLabel`, `creneaus` — `MeetingDto` correspond. Un créneau porte `id` **et** `Id`, plus `Nom`, `label`, `fullLabel`, `Debut`, `Fin`, `partie`, `courses` — `SlotDto` correspond. Aucune correction de casse n'est nécessaire.

**`reunion/submit`, `creneau/submit`, `reunion/delete`, `creneau/delete` fonctionnent** et renvoient l'id créé.

**`course/submit` est cassé côté serveur.** Tout POST sur `competition/reunion/creneau/:creneau/course/submit`, même sans aucun paramètre métier, répond :

```
HTTP 500 {"error":"Internal server error",
 "message":"Unknown named parameter $creneau in .../slim/Application.php at line 533"}
```

La route existe (un GET dessus répond « Method not allowed. Must be one of: POST »), mais son gabarit d'URL ne déclare pas le paramètre que le gestionnaire attend. Aucun réglage côté application ne peut y remédier — **c'est à signaler à la FFSS**.

**Conséquence sur ce plan :** il couvre les étapes 1 à 3 de la spec — couche données, affichage en lecture, items manuels. L'étape 4 (planification des courses) et l'étape 5 (recalculs en cascade) attendent le correctif fédéral, puisqu'elles reposent entièrement sur `course/submit`. `RunDto` reste donc **non vérifié** : aucune course n'a pu être créée.

---

## Structure des fichiers

| Fichier | Responsabilité |
|---|---|
| `lib/app/core/config/app_config.dart` | +4 constantes d'endpoint créneau/course |
| `lib/app/data/datasources/meeting_remote_datasource.dart` | l'arbre `reunion` : réunions paginées, submit/delete réunion, submit/delete créneau, courses d'un créneau |
| `lib/app/data/repositories/meeting_repository.dart` | auto-pagination, chargement parallèle des courses, conversions date/heure |
| `lib/app/module/programme/controllers/schedule_controller.dart` | modèle d'affichage : jours, frises par site, horaires dérivés, écritures |
| `lib/app/module/programme/views/schedule_view.dart` | rendu de l'arbre serveur |
| `lib/app/module/program/controllers/program_controller.dart` | adaptation à `submitMeeting` |

---

### Task 1: Les endpoints manquants

**Files:**
- Modify: `lib/app/core/config/app_config.dart:46-49`

**Interfaces:**
- Produces: `ApiEndpoints.slotSubmit`, `ApiEndpoints.slotDelete`, `ApiEndpoints.runSubmit`, `ApiEndpoints.runDelete`.

- [ ] **Step 1: Ajouter les constantes**

Dans `class ApiEndpoints`, sous `runList` :

```dart
  static const String slotSubmit =
      'competition/reunion/:reunion/creneau/submit';
  static const String slotDelete = 'competition/reunion/creneau/:id/delete';
  // Cassé côté FFSS au 2026-08-29 : tout POST répond
  // « Unknown named parameter $creneau ». Déclaré pour que la couche soit
  // complète, mais rien ne doit l'appeler tant que la fédération n'a pas
  // corrigé la route.
  static const String runSubmit =
      'competition/reunion/creneau/:creneau/course/submit';
  static const String runDelete =
      'competition/reunion/creneau/course/:id/delete';
```

- [ ] **Step 2: Vérifier que rien n'est cassé**

Run: `flutter analyze`
Expected: 6 issues (les préexistantes), aucune nouvelle.

- [ ] **Step 3: Commit**

```bash
git add lib/app/core/config/app_config.dart
git commit -m "chore(api): declare the créneau and course endpoints"
```

---

### Task 2: Pagination des réunions

**Files:**
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart`
- Modify: `lib/app/data/repositories/meeting_repository.dart`
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`
- Test: `test/data/repositories/meeting_repository_test.dart` (existe déjà — modifier)

**Interfaces:**
- Produces: `MeetingRemoteDataSource.getMeetings(int competitionId, {required int start, required int length})`, et `MeetingRepository.getMeetings(int competitionId)` qui pagine par 100.

- [ ] **Step 1: Écrire le test du datasource**

Dans `test/data/datasources/meeting_remote_datasource_test.dart` :

```dart
  test('demande la fenêtre qu on lui donne', () async {
    when(() => http.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true, 'data': <dynamic>[]});

    await ds.getMeetings(1451, start: 30, length: 30);

    verify(() => http.get('competition/1451/reunion',
        query: {'start': 30, 'length': 30})).called(1);
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: FAIL — `No named parameter with the name 'start'`.

- [ ] **Step 3: Implémenter**

Dans l'interface abstraite :

```dart
  /// Une fenêtre des réunions de la compétition. FFSS sert 30 lignes quand on
  /// ne demande rien, donc l'appelant pagine.
  Future<List<MeetingDto>> getMeetings(
    int competitionId, {
    required int start,
    required int length,
  });
```

Dans `MeetingRemoteDataSourceImpl` :

```dart
  @override
  Future<List<MeetingDto>> getMeetings(
    int competitionId, {
    required int start,
    required int length,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint, query: {
      'start': start,
      'length': length,
    });
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MeetingDto.fromJson)
        .toList();
  }
```

- [ ] **Step 4: Vérifier que le test passe**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: PASS.

- [ ] **Step 5: Écrire le test du repository**

Le fichier existe déjà. Y ajouter, en gardant ce qui s'y trouve :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements MeetingRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late MeetingRepository repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = MeetingRepositoryImpl(dataSource);
  });

  MeetingDto dto(int id) => MeetingDto(
        id: id,
        name: 'R$id',
        description: '',
        date: '2026-09-12',
        beginHour: '08:00',
        endHour: '18:00',
      );

  List<MeetingDto> page(int from, int count) =>
      [for (var i = 0; i < count; i++) dto(from + i)];

  // FFSS sert 30 lignes quand on ne demande pas de fenêtre : lire la première
  // page seulement ferait disparaître des journées entières de l'écran.
  test('pagine jusqu à une page courte', () async {
    when(() => dataSource.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => page(1, 100));
    when(() => dataSource.getMeetings(1451, start: 100, length: 100))
        .thenAnswer((_) async => page(101, 5));

    final all = await repository.getMeetings(1451);

    expect(all, hasLength(105));
  });

  test('une page courte suffit, sans second appel', () async {
    when(() => dataSource.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => page(1, 3));

    expect(await repository.getMeetings(1451), hasLength(3));
    verifyNever(() => dataSource.getMeetings(1451, start: 100, length: 100));
  });
}
```

- [ ] **Step 6: Le lancer et vérifier l'échec**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: FAIL — la boucle n'existe pas, un seul appel est fait.

- [ ] **Step 7: Implémenter la boucle**

Dans `MeetingRepositoryImpl` :

```dart
  /// Lignes par requête. FFSS retombe à 30 quand on ne demande rien, ce qui est
  /// bien en dessous d'un vrai programme.
  static const _pageSize = 100;

  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final all = <Meeting>[];
    var start = 0;
    while (true) {
      final batch = await _dataSource.getMeetings(
        competitionId,
        start: start,
        length: _pageSize,
      );
      all.addAll(batch.map((d) => d.toDomain()));
      if (batch.length < _pageSize) break;
      start += _pageSize;
    }
    return all;
  }
```

- [ ] **Step 8: Vérifier**

Run: `flutter test`
Expected: tout passe.

- [ ] **Step 9: Commit**

```bash
git add lib/app/data/datasources/meeting_remote_datasource.dart lib/app/data/repositories/meeting_repository.dart test/data/datasources/meeting_remote_datasource_test.dart test/data/repositories/meeting_repository_test.dart
git commit -m "fix(data): page through the réunion list"
```

---

### Task 3: Créer et modifier une réunion

`createMeeting` ne rend qu'un booléen, alors que l'API renvoie l'id — indispensable pour y accrocher des créneaux. Il devient `submitMeeting`, qui crée ou modifie.

**Files:**
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart`
- Modify: `lib/app/data/repositories/meeting_repository.dart`
- Modify: `lib/app/module/program/controllers/program_controller.dart:83`
- Modify: `test/presentation/modules/program/controllers/program_controller_test.dart` (appelle `createMeeting`)
- Modify: `test/data/repositories/meeting_repository_test.dart` (appelle `createMeeting`)
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`

**Interfaces:**
- Produces: `submitMeeting({required int competitionId, required String name, required String description, required String dayIso, required String beginTime, required String endTime, int? id}) → Future<int>` sur le datasource ; sur le repository, mêmes champs avec `DateTime date, DateTime beginHour, DateTime endHour`.

- [ ] **Step 1: Écrire le test**

```dart
  test('crée une réunion avec un id vide et rend l id assigné', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true, 'id': 78});

    final id = await ds.submitMeeting(
      competitionId: 1451,
      name: 'Samedi 12 septembre 2026',
      description: '',
      dayIso: '2026-09-12',
      beginTime: '08:00',
      endTime: '18:00',
    );

    expect(id, 78);
    final query = verify(() => http.post('competition/1451/reunion/submit',
        query: captureAny(named: 'query'))).captured.single;
    expect(query, {
      'id': '',
      'nom': 'Samedi 12 septembre 2026',
      'description': '',
      'jour': '2026-09-12',
      'debut': '08:00',
      'fin': '18:00',
    });
  });

  test('porte l id quand la réunion existe déjà', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true, 'id': 78});

    await ds.submitMeeting(
      competitionId: 1451,
      id: 78,
      name: 'Samedi 12 septembre 2026',
      description: '',
      dayIso: '2026-09-12',
      beginTime: '08:00',
      endTime: '11:20',
    );

    final query = verify(() => http.post(any(),
        query: captureAny(named: 'query'))).captured.single as Map;
    expect(query['id'], '78');
  });

  test('un refus rend 0 plutôt qu un id inventé', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': false, 'message': 'Jour invalide'});

    final id = await ds.submitMeeting(
      competitionId: 1451,
      name: 'x',
      description: '',
      dayIso: '2026-09-12',
      beginTime: '08:00',
      endTime: '18:00',
    );

    expect(id, 0);
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: FAIL — `submitMeeting` n'existe pas.

- [ ] **Step 3: Implémenter le datasource**

Remplacer `createMeeting` par :

```dart
  /// Crée une réunion, ou modifie celle dont l'[id] est donné. Rend l'id que
  /// FFSS a assigné, ou 0 quand l'appel a signalé un échec.
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required String dayIso,
    required String beginTime,
    required String endTime,
    int? id,
  });
```

```dart
  @override
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required String dayIso,
    required String beginTime,
    required String endTime,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingSubmit,
      {'competition': competitionId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Vide signifie « créer », une valeur signifie « modifier ».
      'id': id?.toString() ?? '',
      'nom': name,
      'description': description,
      'jour': dayIso,
      'debut': beginTime,
      'fin': endTime,
    });
    if (body['success'] != true) return 0;
    final assigned = body['id'];
    return assigned is int ? assigned : int.tryParse('$assigned') ?? 0;
  }
```

- [ ] **Step 4: Implémenter le repository**

```dart
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    int? id,
  });
```

```dart
  @override
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    int? id,
  }) =>
      _dataSource.submitMeeting(
        competitionId: competitionId,
        name: name,
        description: description,
        dayIso: DateFormat('yyyy-MM-dd').format(date),
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        id: id,
      );
```

- [ ] **Step 5: Adapter l'appelant existant**

Dans `program_controller.dart:83`, remplacer l'appel à `createMeeting` par `submitMeeting` et lire le résultat comme un id :

```dart
      final id = await _meetingRepo.submitMeeting(
        name: name,
        description: description,
        date: date,
        beginHour: beginHour,
        endHour: endHour,
        competitionId: competitionId,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('failed_to_create_meeting'));
        return;
      }
```

- [ ] **Step 6: Mettre à jour les tests qui appelaient createMeeting**

`test/presentation/modules/program/controllers/program_controller_test.dart` et
`test/data/repositories/meeting_repository_test.dart` stubbent `createMeeting`.
Remplacer chaque `when(() => repo.createMeeting(...)).thenAnswer((_) async => true)`
par `when(() => repo.submitMeeting(...)).thenAnswer((_) async => 78)`, et chaque
assertion sur un booléen par une assertion sur l'id rendu.

- [ ] **Step 7: Vérifier**

Run: `flutter test` puis `flutter analyze`
Expected: tout passe, 6 issues préexistantes.

- [ ] **Step 8: Commit**

```bash
git add -A lib/app/data lib/app/module/program test/data test/presentation/modules/program
git commit -m "feat(data): submit a réunion and get its id back"
```

---

### Task 4: Créer et supprimer un créneau

**Files:**
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart`
- Modify: `lib/app/data/repositories/meeting_repository.dart`
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`

**Interfaces:**
- Produces: `submitSlot({required int meetingId, required String name, required String beginTime, required String endTime, int? raceFormatDetailId, int? id}) → Future<int>` et `deleteSlot(int slotId) → Future<bool>`, sur le datasource comme sur le repository (le repository prend `DateTime beginHour, DateTime endHour`).

- [ ] **Step 1: Écrire le test**

```dart
  test('un item manuel part sans partie', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true, 'id': 66});

    final id = await ds.submitSlot(
      meetingId: 78,
      name: 'Accueil des clubs',
      beginTime: '08:00',
      endTime: '08:10',
    );

    expect(id, 66);
    final query = verify(() => http.post(
        'competition/reunion/78/creneau/submit',
        query: captureAny(named: 'query'))).captured.single;
    // `partie` vide est ce qui distingue un item informatif d'un tour
    // d'épreuve — vérifié en production, la réponse rend alors partie: null.
    expect(query, {
      'id': '',
      'nom': 'Accueil des clubs',
      'debut': '08:00',
      'fin': '08:10',
      'partie': '',
    });
  });

  test('un tour d épreuve porte l id de sa partie', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true, 'id': 67});

    await ds.submitSlot(
      meetingId: 78,
      name: 'Séries - Surfski - Dames - Junior',
      beginTime: '08:10',
      endTime: '08:20',
      raceFormatDetailId: 39,
    );

    final query = verify(() => http.post(any(),
        query: captureAny(named: 'query'))).captured.single as Map;
    expect(query['partie'], '39');
  });

  test('supprimer un créneau', () async {
    when(() => http.post(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'success': true});

    expect(await ds.deleteSlot(66), isTrue);
    verify(() => http.post('competition/reunion/creneau/66/delete')).called(1);
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: FAIL — `submitSlot` n'existe pas.

- [ ] **Step 3: Implémenter**

```dart
  /// Crée un créneau d'une réunion, ou modifie celui dont l'[id] est donné.
  ///
  /// [raceFormatDetailId] est la partie que ce créneau planifie ; laissé nul,
  /// le créneau est un item informatif — c'est la seule différence entre les
  /// deux, et la réponse rend alors `partie: null`.
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required String beginTime,
    required String endTime,
    int? raceFormatDetailId,
    int? id,
  });

  Future<bool> deleteSlot(int slotId);
```

```dart
  @override
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required String beginTime,
    required String endTime,
    int? raceFormatDetailId,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.slotSubmit,
      {'reunion': meetingId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      'id': id?.toString() ?? '',
      'nom': name,
      'debut': beginTime,
      'fin': endTime,
      'partie': raceFormatDetailId?.toString() ?? '',
    });
    if (body['success'] != true) return 0;
    final assigned = body['id'];
    return assigned is int ? assigned : int.tryParse('$assigned') ?? 0;
  }

  @override
  Future<bool> deleteSlot(int slotId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.slotDelete,
      {'id': slotId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }
```

Et le repository, qui convertit les heures :

```dart
  @override
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    int? raceFormatDetailId,
    int? id,
  }) =>
      _dataSource.submitSlot(
        meetingId: meetingId,
        name: name,
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        raceFormatDetailId: raceFormatDetailId,
        id: id,
      );

  @override
  Future<bool> deleteSlot(int slotId) => _dataSource.deleteSlot(slotId);
```

- [ ] **Step 4: Vérifier**

Run: `flutter test`
Expected: tout passe.

- [ ] **Step 5: Commit**

```bash
git add -A lib/app/data test/data
git commit -m "feat(data): create and delete a réunion's créneaux"
```

---

### Task 5: Charger les courses d'un créneau, en parallèle

`GET reunion` rend les créneaux mais **pas** leurs courses : il faut un appel par créneau.

**Files:**
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart`
- Modify: `lib/app/data/repositories/meeting_repository.dart`
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`
- Test: `test/data/repositories/meeting_repository_test.dart`

**Interfaces:**
- Produces: `getRuns(int slotId, {required int start, required int length}) → Future<List<RunDto>>` sur le datasource ; `MeetingRepository.getMeetings` remplit désormais `Meeting.slots[].runs`.

- [ ] **Step 1: Écrire le test du repository**

```dart
  test('les courses de chaque créneau partent ensemble, pas l une après l autre',
      () async {
    // Vingt créneaux ne doivent pas coûter vingt latences bout à bout.
    final gates = {for (final id in [1, 2, 3]) id: Completer<List<RunDto>>()};
    when(() => dataSource.getMeetings(1451, start: 0, length: 100))
        .thenAnswer((_) async => [
              dto(78).copyWith(slots: [
                for (final id in [1, 2, 3])
                  SlotDto(id: id, name: 'C$id', beginHour: '08:00', endHour: '08:10'),
              ]),
            ]);
    for (final id in gates.keys) {
      when(() => dataSource.getRuns(id, start: 0, length: 100))
          .thenAnswer((_) => gates[id]!.future);
    }

    final loading = repository.getMeetings(1451);
    await Future<void>.delayed(Duration.zero);

    verify(() => dataSource.getRuns(1, start: 0, length: 100)).called(1);
    verify(() => dataSource.getRuns(2, start: 0, length: 100)).called(1);
    verify(() => dataSource.getRuns(3, start: 0, length: 100)).called(1);

    for (final id in gates.keys) {
      gates[id]!.complete(const []);
    }
    await loading;
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: FAIL — `getRuns` n'existe pas.

- [ ] **Step 3: Implémenter le datasource**

```dart
  /// Une fenêtre des courses d'un créneau. `GET reunion` ne les porte pas.
  Future<List<RunDto>> getRuns(
    int slotId, {
    required int start,
    required int length,
  });
```

```dart
  @override
  Future<List<RunDto>> getRuns(
    int slotId, {
    required int start,
    required int length,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.runList,
      {'id': slotId.toString()},
    );
    final body = await _http.get(endpoint, query: {
      'start': start,
      'length': length,
    });
    final list = (body['data'] as List?) ?? const [];
    return list.whereType<Map<String, dynamic>>().map(RunDto.fromJson).toList();
  }
```

- [ ] **Step 4: Implémenter le remplissage parallèle**

Dans `MeetingRepositoryImpl.getMeetings`, après avoir rassemblé les DTO de réunion et avant le mapping :

```dart
    // Un aller-retour par créneau, tous en vol en même temps : en série, une
    // journée de vingt créneaux paierait vingt latences bout à bout.
    final slotIds = [
      for (final meeting in dtos)
        for (final slot in meeting.slots) slot.id,
    ];
    final runsBySlot = <int, List<RunDto>>{};
    final loaded = await Future.wait(
      slotIds.map((id) => _dataSource.getRuns(id, start: 0, length: _pageSize)),
    );
    for (var i = 0; i < slotIds.length; i++) {
      runsBySlot[slotIds[i]] = loaded[i];
    }
```

puis reconstruire chaque réunion avec ses créneaux garnis avant `toDomain()`.

- [ ] **Step 5: Rattraper les tests de la Task 2**

`getMeetings` appelle désormais `getRuns` pour chaque créneau. Les tests de
pagination écrits en Task 2 construisent des réunions sans créneau, donc rien
n'est appelé — mais tout test qui ajoute un créneau doit stubber :

```dart
    when(() => dataSource.getRuns(any(),
        start: any(named: 'start'),
        length: any(named: 'length'))).thenAnswer((_) async => const []);
```

Sans ce stub, mocktail lève au premier créneau rencontré.

- [ ] **Step 6: Vérifier**

Run: `flutter test`
Expected: tout passe.

- [ ] **Step 7: Commit**

```bash
git add -A lib/app/data test/data
git commit -m "feat(data): load a créneau's courses, all in flight at once"
```

---

### Task 6: Le contrôleur lit l'arbre serveur

**Files:**
- Modify: `lib/app/module/programme/controllers/schedule_controller.dart`
- Modify: `lib/app/module/programme/bindings/programme_binding.dart` (nouveau constructeur)
- Test: `test/presentation/modules/programme/controllers/schedule_controller_test.dart` (existe — instancie l'ancien constructeur)

**Interfaces:**
- Consumes: `MeetingRepository.getMeetings(int)` (Task 2 et 5).
- Produces: `ScheduleController(ProgrammeService, MeetingRepository, UserService)` ; `RxList<Meeting> meetings`, `Rxn<UiMessage> message`, `bool get canWriteToFfss`, `Meeting? meetingFor(DateTime day)`, `int endMinutesOfDay(DateTime day)`.

**Les horaires se comptent en minutes depuis minuit, pas en `DateTime`.**
`SlotMapper` et `RunMapper` ne parsent que `HH:mm` : leurs `DateTime` tombent au
1er janvier 1970, tandis que `MeetingMapper` construit les siens sur la vraie
date de la reunion. Les comparer donnerait toujours faux. Tout se joue a
l'interieur d'une meme journee, donc les minutes suffisent — et les mappers,
partages avec le module Slot, restent intacts.

- [ ] **Step 1: Écrire le test des horaires**

```dart
  /// Minutes depuis minuit — l'unite du controleur, cf. l'encadre ci-dessus.
  int minutes(int h, int m) => h * 60 + m;

  // Une frise par site, toutes démarrant à l'heure de la réunion ; la fin de
  // la réunion est la plus tardive des frises, pas la somme des durées.
  test('la fin de journée est le maximum des sites, pas leur somme', () {
    controller.meetings.value = [
      meetingWith(runs: [
        run(site: 'Plage', begin: '08:00', end: '08:30'),
        run(site: 'Bassin', begin: '08:00', end: '09:00'),
      ])
    ];

    expect(controller.endMinutesOfDay(day), minutes(9, 0));
  });

  test('une journée sans item finit à son heure de départ', () {
    controller.meetings.value = [meetingWith(runs: const [])];

    expect(controller.endMinutesOfDay(day), minutes(8, 0));
  });

  test('un créneau sans course compte par ses propres heures', () {
    // Un item manuel n'a aucune course : sans ce cas, il ne pèserait pas sur
    // la fin de journée et la réunion serait renvoyée trop courte.
    controller.meetings.value = [
      meetingWith(slotBegin: '08:00', slotEnd: '08:40', runs: const [])
    ];

    expect(controller.endMinutesOfDay(day), minutes(8, 40));
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/controllers/schedule_controller_test.dart`
Expected: FAIL — `endMinutesOfDay` n'existe pas.

- [ ] **Step 3: Implémenter**

```dart
  /// Minutes depuis minuit d'un `DateTime` dont seule l'heure compte.
  int _minutesOf(DateTime t) => t.hour * 60 + t.minute;

  /// La fin d'une journée, en minutes depuis minuit : l'item le plus tardif,
  /// tous sites confondus. Les frises tournent en parallèle, donc c'est un
  /// maximum et non un cumul. Sans le moindre item, une réunion ne dure pas.
  ///
  /// En minutes et non en `DateTime` : les heures d'un créneau et d'une course
  /// sont parsées depuis `HH:mm` seul et tombent en 1970, alors que celles
  /// d'une réunion portent sa vraie date. Tout se joue dans une même journée.
  int endMinutesOfDay(DateTime day) {
    final meeting = meetingFor(day);
    if (meeting == null) return defaultStartMinutes;
    var latest = _minutesOf(meeting.beginHour);
    for (final slot in meeting.slots) {
      // Un créneau sans course est un item manuel : ses heures font foi.
      final ends = slot.runs.isEmpty
          ? [_minutesOf(slot.endHour)]
          : [for (final run in slot.runs) _minutesOf(run.endTime)];
      for (final end in ends) {
        if (end > latest) latest = end;
      }
    }
    return latest;
  }
```

- [ ] **Step 4: Ajouter la session et le canal de message**

La tâche 8 en dépend ; ils arrivent ici avec `UserService`.

```dart
  /// Tout ce que cet écran lit est public, donc un opérateur déconnecté y
  /// arrive sans obstacle — et seule l'écriture reviendrait refusée.
  bool get canWriteToFfss => _user.currentUser.value != null;

  final Rxn<UiMessage> message = Rxn<UiMessage>();
```

- [ ] **Step 5: Rattraper les appelants du constructeur**

`programme_binding.dart` construit `ScheduleController(Get.find<ProgrammeService>())`
et `schedule_controller_test.dart` fait de même. Les deux prennent désormais
`Get.find<MeetingRepository>()` et `Get.find<UserService>()` en plus ; dans le
test, un mock `_MockMeetingRepo` et un `UserService(_MockAuthRepo())` dont
`currentUser` est renseigné, comme dans `structure_editor_controller_test.dart`.

- [ ] **Step 6: Vérifier**

Run: `flutter test` puis `flutter analyze`
Expected: tout passe, 6 issues préexistantes.

- [ ] **Step 7: Commit**

```bash
git add -A lib/app/module/programme test/presentation/modules/programme
git commit -m "feat(programme): read the day from the FFSS tree"
```

---

### Task 7: La vue affiche l'arbre serveur

**Files:**
- Modify: `lib/app/module/programme/views/schedule_view.dart`

**Interfaces:**
- Consumes: tout ce que la Task 6 expose.

- [ ] **Step 1: Remplacer la source des lignes**

Là où la vue lit `controller.rowsFor(siteId, day)`, lire les créneaux et courses de la réunion du jour, groupés par `Run.site`. Un créneau sans course s'affiche comme un item manuel, à son propre `beginHour`/`endHour`.

- [ ] **Step 2: Afficher l'en-tête de journée**

Sous la barre de dates : `08:00 → 11:20`, la fin venant de `controller.endMinutesOfDay(day)`.

- [ ] **Step 3: Vérifier à la main**

Run: `flutter run`, ouvrir une compétition → Programme.
Expected: les journées portant une réunion FFSS s'affichent avec leurs items ; les autres sont vides.

- [ ] **Step 4: Commit**

```bash
git add lib/app/module/programme/views/schedule_view.dart
git commit -m "feat(programme): render the FFSS day"
```

---

### Task 8: Ajouter, redimensionner et supprimer un item manuel

**Files:**
- Modify: `lib/app/module/programme/controllers/schedule_controller.dart`
- Modify: `lib/app/module/programme/views/schedule_view.dart`
- Modify: `lib/app/core/translations/fr_FR.dart`, `lib/app/core/translations/en_US.dart`
- Test: `test/presentation/modules/programme/controllers/schedule_controller_test.dart`

**Interfaces:**
- Consumes: `submitSlot`, `deleteSlot`, `submitMeeting` (Tasks 3 et 4).
- Produces: `addManualItem(String label, DateTime day)`, `setSlotDuration(int slotId, int minutes)`, `removeSlot(int slotId)`.

- [ ] **Step 1: Écrire le test de la création implicite**

```dart
  // Aucune réunion n'existe pour ce jour : le premier item la crée, sinon il
  // n'aurait rien où s'accrocher.
  test('le premier item d une journée crée la réunion', () async {
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 78);
    when(() => meetingRepo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 66);

    await controller.addManualItem('Accueil des clubs', day);

    verify(() => meetingRepo.submitMeeting(
          competitionId: 1451,
          name: any(named: 'name'),
          description: '',
          date: day,
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: null,
        )).called(1);
    verify(() => meetingRepo.submitSlot(
          meetingId: 78,
          name: 'Accueil des clubs',
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('la fin de réunion est renvoyée après l ajout', () async {
    // Le créneau dure 10 minutes, donc la journée finit à 08:10.
    // ... même montage que ci-dessus ...
    await controller.addManualItem('Accueil des clubs', day);

    verify(() => meetingRepo.submitMeeting(
          competitionId: 1451,
          name: any(named: 'name'),
          description: '',
          date: day,
          beginHour: any(named: 'beginHour'),
          endHour: timeOf(8, 10),
          id: 78,
        )).called(1);
  });

  test('hors session, rien ne part', () async {
    userService.currentUser.value = null;

    await controller.addManualItem('Accueil des clubs', day);

    verifyNever(() => meetingRepo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        ));
    expect(controller.message.value!.translationKey, 'login_required');
  });
```

- [ ] **Step 2: Le lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/controllers/schedule_controller_test.dart`
Expected: FAIL — `addManualItem` n'existe pas.

- [ ] **Step 3: Implémenter**

```dart
  /// Le nom d'une réunion suit la langue de l'application : elle s'affichera
  /// telle quelle sur le site fédéral.
  String _meetingName(DateTime day) =>
      DateFormat('EEEE d MMMM y', Get.locale?.toString()).format(day);

  /// Ajoute un item informatif à la journée, en créant la réunion si elle
  /// n'existe pas encore, puis remonte la nouvelle fin de journée.
  Future<void> addManualItem(String label, DateTime day) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final meetingId = await _ensureMeeting(day);
    if (meetingId <= 0) return;

    final beginMinutes = endMinutesOfDay(day);
    final endMinutes = beginMinutes + defaultItemMinutes;
    final slotId = await _meetingRepo.submitSlot(
      meetingId: meetingId,
      name: label,
      beginHour: _atMinutes(day, beginMinutes),
      endHour: _atMinutes(day, endMinutes),
    );
    if (slotId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    await reload();
    await _pushMeetingEnd(day);
  }
```

- [ ] **Step 4: Ajouter les traductions**

```dart
  'schedule_item_failed': "FFSS n'a pas enregistré cet item",
  'schedule_day_range': '@begin → @end',
```

et leurs équivalents anglais.

- [ ] **Step 5: Vérifier**

Run: `flutter test` puis `flutter analyze`
Expected: tout passe, 6 issues préexistantes.

- [ ] **Step 6: Vérifier à la main**

Run: `flutter run`, se connecter, ajouter un item, recharger.
Expected: l'item revient du serveur, l'en-tête affiche la nouvelle fin de journée.

- [ ] **Step 7: Commit**

```bash
git add -A lib/app/module/programme lib/app/core/translations test/presentation/modules/programme
git commit -m "feat(programme): manual items live on FFSS"
```

---

## Ce que ce plan ne couvre pas

**La planification des courses** (étape 4 de la spec) et **les recalculs en cascade** (étape 5) reposent sur `course/submit`, cassé côté FFSS. Ils feront l'objet d'un second plan une fois la route corrigée.

**`RunDto` reste non vérifié** faute d'avoir pu créer une course. Ses clés (`id`, `Nom`, `statut`, `site`, `debut`, `fin`) sont en minuscules alors que la documentation annonce des capitales. Le créneau renvoyant à la fois `id` et `Id`, la casse peut différer d'un niveau à l'autre : **première chose à vérifier** quand une course pourra enfin être créée.

**La suppression de `ScheduleBlock` / `SiteDayStart`** et du planificateur local n'intervient qu'une fois l'étape 4 livrée — les retirer plus tôt laisserait l'app sans aucun moyen de placer une course.
