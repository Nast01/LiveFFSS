# Le dossard d'un athlète — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Faire porter à chaque athlète son dossard FFSS, l'afficher partout où un athlète s'affiche, et l'écrire sur le bracelet — où il sert de vérification à la relecture.

**Architecture:** `Athlete.orderNumber` est un entier (0 = pas de dossard), lu du champ `Dossard` que FFSS sert en chaîne. Le DTO existant le mappe, ce qui couvre d'un coup les athlètes venus de `participants` et de `organismes` ; les athlètes venus de `engagement`, qui ne le porte pas, le reçoivent d'un `ParticipantService` mémorisant une lecture par compétition, recopié là où les contrôleurs recopient déjà le club.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX, freezed + json_serializable, mocktail.

**Spec:** [docs/superpowers/specs/2026-09-15-athlete-order-number-design.md](../specs/2026-09-15-athlete-order-number-design.md)

## Global Constraints

- **Architecture** : `Controller → Repository → DataSource`, injection par constructeur uniquement. Jamais de `Get.find()` dans un corps de contrôleur.
- **Discipline contrôleur** : pas de `Get.context!`, pas de `Get.snackbar`, pas de `Get.dialog`, pas de `.tr`, pas de `BuildContext` en paramètre. Les messages passent par `Rxn<UiMessage>` et la vue les affiche avec `showUiMessages`.
- **Noms de domaine** : camelCase anglais. Le champ Dart s'appelle **`orderNumber`** ; `Dossard` n'apparaît que dans l'annotation `@JsonKey` et dans le `.g.dart` généré.
- **Traductions** : toute clé ajoutée l'est dans **les deux** fichiers (`fr_fr.dart` et `en_us.dart`). Aucune clé morte.
- **Codegen** : après modification d'un fichier freezed, `dart run build_runner build --delete-conflicting-outputs`, et les `.freezed.dart` / `.g.dart` sont commités avec la source.
- **Tests** : mocktail, `class _MockX extends Mock implements X {}`. **Aucun test de widget, aucun test d'intégration.**
- **Analyzer** : `strict-casts: true`, `strict-raw-types: true`. Pas de `dynamic`. `flutter analyze` doit ne rien signaler.
- **Commentaires** : seulement là où le *pourquoi* n'est pas évident. Un fichier ne mélange pas les langues.
- **Commandes** : formes courtes — `flutter test`, `flutter analyze`, `dart format lib/ test/`.
- **Pas de nouvelle dépendance.**
- **Vérification sur appareil** : impossible ici. Les tâches s'arrêtent à `flutter test` + `flutter analyze` ; le rendu et le NFC reviennent à l'utilisateur.

---

### Task 1: Le champ `orderNumber`

Le DTO des athlètes est partagé par trois routes. Lui ajouter le champ suffit à ce que les athlètes venus de `participants` **et** de `organismes` portent leur dossard ; `engagement` ne l'envoie pas, le défaut 0 s'applique.

**Files:**
- Modify: `lib/app/data/dtos/athlete_dto.dart`
- Modify: `lib/app/domain/models/athlete.dart`
- Modify: `lib/app/data/mappers/athlete_mapper.dart`
- Test: `test/data/mappers/athlete_mapper_test.dart`

**Interfaces:**
- Produces : `AthleteDto.orderNumber` (`int`, clé JSON `Dossard`), `Athlete.orderNumber` (`int`, 0 quand absent).

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/data/mappers/athlete_mapper_test.dart`, un nouveau groupe :

```dart
  group('orderNumber', () {
    int orderNumberFrom(Object? dossard) =>
        AthleteDto.fromJson(<String, dynamic>{
          'Id': 1,
          if (dossard != null) 'Dossard': dossard,
        }).toDomain().orderNumber;

    test('une chaine de chiffres devient un entier', () {
      expect(orderNumberFrom('12'), 12);
    });

    // FFSS documente `Dossard` en String, mais sert deja `Annee` tantot en
    // nombre tantot en texte : les deux formes doivent passer.
    test('un nombre passe tel quel', () {
      expect(orderNumberFrom(12), 12);
    });

    test('sans dossard, zero', () {
      expect(orderNumberFrom(null), 0);
    });

    test('une chaine vide vaut pas de dossard', () {
      expect(orderNumberFrom(''), 0);
    });

    // Consequence assumee de l'entier : un dossard alphanumerique se lit 0,
    // donc pas de dossard, et disparait de l'ecran.
    test('un dossard non numerique vaut pas de dossard', () {
      expect(orderNumberFrom('A12'), 0);
    });
  });
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/mappers/athlete_mapper_test.dart`
Expected: FAIL — `The getter 'orderNumber' isn't defined for the type 'Athlete'`

- [ ] **Step 3: Ajouter le champ au DTO**

Dans `lib/app/data/dtos/athlete_dto.dart`, à la suite des champs portés par l'endpoint engagement :

```dart
    // Le dossard : unique pour un athlète sur une compétition. FFSS le type en
    // String ; il est lu en entier pour que deux dossards se comparent comme
    // des nombres. Présent sur les charges utiles de forme Participant
    // (`participants`, `organismes`), absent de `engagement`.
    @JsonKey(name: 'Dossard', readValue: _readOrderNumber)
    @Default(0)
    int orderNumber,
```

et, à côté de `_readYear` en bas du fichier :

```dart
Object? _readOrderNumber(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  if (raw is int) return raw;
  return 0;
}
```

- [ ] **Step 4: Ajouter le champ au domaine**

Dans `lib/app/domain/models/athlete.dart`, à côté des autres champs portés par l'engagement :

```dart
    /// Le dossard que l'athlète porte sur cette compétition, 0 quand il n'en a
    /// pas — ou quand il vient d'une route qui ne le sert pas.
    @Default(0) int orderNumber,
```

- [ ] **Step 5: Le recopier dans le mapper**

Dans `lib/app/data/mappers/athlete_mapper.dart`, dans `toDomain()`, après `clubLabel: clubLabel,` :

```dart
        orderNumber: orderNumber,
```

- [ ] **Step 6: Régénérer le codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: succès ; `athlete_dto.freezed.dart`, `athlete_dto.g.dart`, `athlete.freezed.dart`, `athlete.g.dart` régénérés.

Si la commande échoue sur `frontend_server.dart.snapshot not found`, le cache du SDK a dérivé : lancer `flutter --version` une fois puis réessayer. C'est environnemental, pas un bug de code.

- [ ] **Step 7: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/data/mappers/athlete_mapper_test.dart`
Expected: PASS

- [ ] **Step 8: Vérifier que la clé JSON est bien `Dossard`**

Run: `grep -n "Dossard" lib/app/data/dtos/athlete_dto.g.dart`
Expected: la clé apparaît dans `_$AthleteDtoFromJson` — c'est ce qui prouve que le champ se lit sur le fil.

- [ ] **Step 9: Lancer toute la suite et commiter**

Run: `flutter test && flutter analyze`
Expected: PASS, aucun avertissement.

```bash
dart format lib/ test/
git add -A
git commit -m "feat(athlete): un athlete porte son dossard"
```

---

### Task 2: La route `participants`

**Files:**
- Modify: `lib/app/core/config/app_config.dart` (`ApiEndpoints`)
- Modify: `lib/app/data/datasources/competition_remote_datasource.dart`
- Modify: `lib/app/data/repositories/competition_repository.dart`
- Test: `test/data/datasources/competition_remote_datasource_test.dart`
- Test: `test/data/repositories/competition_repository_test.dart`

**Interfaces:**
- Consumes : `AthleteDto.orderNumber`, `AthleteMapper.toDomain()` (tâche 1)
- Produces :
  - `ApiEndpoints.participantList` = `'competition/evenement/:id/participants'`
  - `CompetitionRemoteDataSource.getParticipants(int competitionId) → Future<List<AthleteDto>>`
  - `CompetitionRepository.getParticipants(int competitionId) → Future<List<Athlete>>`

- [ ] **Step 1: Écrire le test de datasource qui échoue**

Dans `test/data/datasources/competition_remote_datasource_test.dart` :

```dart
  group('CompetitionRemoteDataSourceImpl.getParticipants', () {
    test('appelle la route de l evenement et mappe les participants', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'data': [
                  {'Id': 7, 'Nom': 'DUPONT', 'Dossard': '12'},
                ]
              });

      final dtos = await ds.getParticipants(42);

      verify(() => http.get('competition/evenement/42/participants',
          query: any(named: 'query'))).called(1);
      expect(dtos.single.id, 7);
      expect(dtos.single.orderNumber, 12);
    });

    test('une reponse sans data rend une liste vide', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => <String, dynamic>{});

      expect(await ds.getParticipants(42), isEmpty);
    });
  });
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/datasources/competition_remote_datasource_test.dart`
Expected: FAIL — `The method 'getParticipants' isn't defined`

- [ ] **Step 3: Déclarer la route**

Dans `lib/app/core/config/app_config.dart`, dans `ApiEndpoints`, à côté de `clubList` :

```dart
  // Les athlètes d'une compétition, avec leur dossard. Un élément Participant a
  // la forme d'un athlète : le même DTO le décode.
  static const String participantList =
      'competition/evenement/:id/participants';
```

- [ ] **Step 4: Implémenter la datasource**

Dans `lib/app/data/datasources/competition_remote_datasource.dart` — ajouter à l'interface puis à l'impl, en calquant `ClubRemoteDataSourceImpl.getClubs`, qui appelle la route sœur `organismes` :

```dart
  Future<List<AthleteDto>> getParticipants(int competitionId);
```

```dart
  @override
  Future<List<AthleteDto>> getParticipants(int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.participantList,
      {'id': competitionId.toString()},
    );
    // Pas de fenêtre start/length : la route sœur `organismes` n'en demande
    // pas non plus. Voir le risque de troncature noté dans le design.
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AthleteDto.fromJson)
        .toList();
  }
```

Ajouter l'import `package:live_ffss/app/data/dtos/athlete_dto.dart`.

- [ ] **Step 5: Écrire le test de repository qui échoue**

Dans `test/data/repositories/competition_repository_test.dart` :

```dart
  group('getParticipants', () {
    test('rend des athletes de domaine avec leur dossard', () async {
      when(() => ds.getParticipants(42)).thenAnswer((_) async => const [
            AthleteDto(id: 7, lastName: 'DUPONT', orderNumber: 12),
          ]);

      final athletes = await repo.getParticipants(42);

      expect(athletes.single.id, 7);
      expect(athletes.single.orderNumber, 12);
    });
  });
```

(Le mock de datasource et le `repo` existent déjà dans ce fichier ; réutiliser leurs noms tels qu'ils y sont déclarés.)

- [ ] **Step 6: Implémenter le repository**

Dans `lib/app/data/repositories/competition_repository.dart` — à l'interface :

```dart
  /// Les athlètes engagés sur la compétition, dossard compris.
  Future<List<Athlete>> getParticipants(int competitionId);
```

et à l'impl :

```dart
  @override
  Future<List<Athlete>> getParticipants(int competitionId) async {
    final dtos = await _dataSource.getParticipants(competitionId);
    return [for (final dto in dtos) dto.toDomain()];
  }
```

Ajouter les imports `athlete.dart` et `athlete_mapper.dart`.

- [ ] **Step 7: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/data/datasources/competition_remote_datasource_test.dart test/data/repositories/competition_repository_test.dart`
Expected: PASS

- [ ] **Step 8: Lancer toute la suite et commiter**

Run: `flutter test && flutter analyze`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(api): lire les participants d une competition"
```

---

### Task 3: `ParticipantService`

**Files:**
- Create: `lib/app/data/services/participant_service.dart`
- Modify: `lib/app/core/di/initial_binding.dart:168-175` (à côté de `MeetingService`)
- Test: `test/data/services/participant_service_test.dart`

**Interfaces:**
- Consumes : `CompetitionRepository.getParticipants(int) → Future<List<Athlete>>` (tâche 2)
- Produces :
  - `ParticipantService(CompetitionRepository)` 
  - `Future<bool> ensureLoaded(int competitionId)`
  - `Future<bool> reload()`
  - `int orderNumberOf(int athleteId)` — 0 quand inconnu
  - `int? get competitionId`

- [ ] **Step 1: Écrire les tests qui échouent**

Create `test/data/services/participant_service_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/participant_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:mocktail/mocktail.dart';

class _MockCompetitionRepo extends Mock implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepo repo;
  late ParticipantService service;

  Athlete athlete(int id, int orderNumber) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.male,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        orderNumber: orderNumber,
      );

  setUp(() {
    repo = _MockCompetitionRepo();
    when(() => repo.getParticipants(any()))
        .thenAnswer((_) async => [athlete(7, 12)]);
    service = ParticipantService(repo);
  });

  test('le dossard se lit par id d athlete', () async {
    await service.ensureLoaded(42);

    expect(service.orderNumberOf(7), 12);
  });

  test('un athlete inconnu n a pas de dossard', () async {
    await service.ensureLoaded(42);

    expect(service.orderNumberOf(999), 0);
  });

  // Une lecture par competition : les quatre ecrans de course la partagent.
  test('une competition deja tenue n est pas relue', () async {
    await service.ensureLoaded(42);
    await service.ensureLoaded(42);

    verify(() => repo.getParticipants(42)).called(1);
  });

  test('changer de competition relit', () async {
    await service.ensureLoaded(42);
    await service.ensureLoaded(43);

    verify(() => repo.getParticipants(43)).called(1);
  });

  test('reload relit la competition tenue', () async {
    await service.ensureLoaded(42);
    clearInteractions(repo);

    await service.reload();

    verify(() => repo.getParticipants(42)).called(1);
  });

  test('sans competition chargee, reload ne fait rien', () async {
    expect(await service.reload(), isFalse);
    verifyNever(() => repo.getParticipants(any()));
  });

  // Le dossard est un repere, pas une condition : une lecture qui echoue
  // laisse l'ecran entier lisible, dossards en moins.
  test('une lecture qui echoue rend false et ne jette pas', () async {
    when(() => repo.getParticipants(any()))
        .thenThrow(const NetworkException('coupe'));

    expect(await service.ensureLoaded(42), isFalse);
    expect(service.orderNumberOf(7), 0);
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/services/participant_service_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../participant_service.dart'`

- [ ] **Step 3: Écrire le service**

Create `lib/app/data/services/participant_service.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

/// Les dossards d'une compétition, par athlète.
///
/// Un service et non un contrôleur parce que quatre écrans lisent le même
/// index : le marshalling, le tirage, l'onglet Séries et la saisie des places.
/// Ils reçoivent leurs athlètes de `competition/engagement`, qui ne sert pas le
/// dossard — c'est cette lecture-ci qui le leur donne, une fois par
/// compétition.
class ParticipantService extends GetxService {
  ParticipantService(this._repo);

  final CompetitionRepository _repo;

  final Map<int, int> _byAthlete = {};

  int? _competitionId;

  int? get competitionId => _competitionId;

  /// Le dossard de cet athlète, 0 quand l'index ne le connaît pas — athlète
  /// absent de la liste, ou lecture qui a échoué.
  int orderNumberOf(int athleteId) => _byAthlete[athleteId] ?? 0;

  /// Charge l'index seulement s'il n'est pas déjà celui de cette compétition.
  ///
  /// Qui a besoin de fraîcheur appelle [reload] ; un dossard ne change pas en
  /// cours de compétition, donc les écrans se contentent de celui-ci.
  Future<bool> ensureLoaded(int competitionId) async {
    if (_competitionId == competitionId && _byAthlete.isNotEmpty) return true;
    return _load(competitionId);
  }

  /// Relit la compétition déjà chargée. Sans appel préalable à [ensureLoaded],
  /// il n'y a aucune compétition à relire.
  Future<bool> reload() async {
    final id = _competitionId;
    if (id == null) return false;
    return _load(id);
  }

  Future<bool> _load(int competitionId) async {
    // Vider d'abord : les dossards de la compétition précédente désigneraient
    // les mauvais athlètes sous celle-ci.
    if (_competitionId != competitionId) _byAthlete.clear();
    _competitionId = competitionId;
    try {
      final participants = await _repo.getParticipants(competitionId);
      _byAthlete
        ..clear()
        ..addEntries([
          for (final Athlete participant in participants)
            if (participant.orderNumber > 0)
              MapEntry(participant.id, participant.orderNumber),
        ]);
      return true;
    } on AppException {
      // Best-effort : l'écran s'affiche sans dossards plutôt que pas du tout.
      return false;
    }
  }
}
```

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/data/services/participant_service_test.dart`
Expected: PASS

- [ ] **Step 5: L'enregistrer dans le DI**

Dans `lib/app/core/di/initial_binding.dart`, juste après le bloc `MeetingService` :

```dart
    // Les dossards de la compétition ouverte, partagés par les quatre écrans
    // de course. Synchrone comme MeetingService : il ne lit aucun stockage à
    // la construction.
    Get.put<ParticipantService>(
      ParticipantService(Get.find<CompetitionRepository>()),
      permanent: true,
    );
```

Vérifier que `CompetitionRepository` est bien enregistré **avant** ce point dans le même fichier ; si ce n'est pas le cas, déplacer l'enregistrement du service après lui et non l'inverse.

- [ ] **Step 6: Lancer toute la suite et commiter**

Run: `flutter test && flutter analyze`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(participants): un service tient les dossards d une competition"
```

---

### Task 4: Le dossard rejoint les athlètes des quatre écrans

Les athlètes de ces écrans viennent de `competition/engagement`, qui ne sert pas le dossard. Chacun de ces quatre contrôleurs résout déjà les clubs et les recopie sur ses athlètes : le dossard se recopie au même endroit.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_detail_controller.dart:111-153`
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart:170-180`
- Modify: `lib/app/module/competitions/controllers/race_structure_controller.dart:440-450`
- Modify: `lib/app/module/competitions/controllers/heat_draw_controller.dart:250-262`
- Modify: `lib/app/module/competitions/bindings/race_detail_binding.dart`, `race_course_binding.dart`, `heat_draw_binding.dart` (les noms exacts sont ceux du dossier `bindings/`)
- Test: les quatre `test/presentation/modules/competitions/controllers/*_controller_test.dart` correspondants

**Interfaces:**
- Consumes : `ParticipantService.ensureLoaded(int)`, `ParticipantService.orderNumberOf(int)` (tâche 3) ; `Athlete.orderNumber` (tâche 1)
- Produces : les athlètes exposés par ces quatre contrôleurs portent leur dossard.

- [ ] **Step 1: Écrire le test qui échoue, sur le marshalling d'abord**

Dans `test/presentation/modules/competitions/controllers/race_detail_controller_test.dart` :

```dart
  test('les athletes affiches portent leur dossard', () async {
    when(() => participants.ensureLoaded(any())).thenAnswer((_) async => true);
    when(() => participants.orderNumberOf(11)).thenReturn(12);

    final controller = await loadWith([
      entry(1, [athlete(11)]),
    ]);

    expect(controller.entries.single.athletes.single.orderNumber, 12);
  });
```

`participants` est un `_MockParticipantService extends Mock implements ParticipantService {}` créé dans le `setUp` du fichier, avec `orderNumberOf` stubbé à 0 par défaut :

```dart
    participants = _MockParticipantService();
    when(() => participants.ensureLoaded(any())).thenAnswer((_) async => true);
    when(() => participants.orderNumberOf(any())).thenReturn(0);
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`
Expected: FAIL — le constructeur n'accepte pas encore le service, puis `orderNumber` vaut 0.

- [ ] **Step 3: Brancher le service sur `RaceDetailController`**

Le constructeur gagne `this._participants` en dernier paramètre, le champ `final ParticipantService _participants;`, et `_resolveClubs` charge l'index avant de recopier :

```dart
  Future<void> _resolveClubs() async {
    try {
      final competitionId = competition.value?.id;
      final athletes = [
        for (final entry in entries) ...entry.athletes,
      ];
      if (competitionId == null || athletes.isEmpty) return;
      // Le dossard vient d'une autre route que les engagés : il se charge ici,
      // dans le même passage que les clubs, et sans rien exiger — une lecture
      // qui échoue laisse simplement les pastilles vides.
      await _participants.ensureLoaded(competitionId);
      _clubs = await _clubRepo.getAthleteClubs(competitionId, athletes);
      entries.value = _withClubs(entries);
    } on AppException {
      // Best-effort: every row keeps the club initial rather than an image.
    } finally {
      _clubsFuture = null;
    }
  }
```

Noter la suppression du `if (_clubs.isEmpty) return;` : les clubs peuvent être vides alors que les dossards, eux, sont arrivés.

`_withClubs` recopie les deux :

```dart
  List<Entry> _withClubs(List<Entry> loaded) => [
        for (final entry in loaded)
          entry.copyWith(
            athletes: [
              for (final athlete in entry.athletes)
                athlete.copyWith(
                  club: _clubs[athlete.id] ?? athlete.club,
                  orderNumber: _participants.orderNumberOf(athlete.id) > 0
                      ? _participants.orderNumberOf(athlete.id)
                      : athlete.orderNumber,
                ),
            ],
          ),
      ];
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run: `flutter test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Faire de même sur les trois autres contrôleurs**

Même forme dans chacun : le service injecté en dernier paramètre du constructeur, `await _participants.ensureLoaded(competitionId);` juste avant l'appel à `getAthleteClubs`, et le `copyWith` qui pose `orderNumber` à côté de `club` :

- `RaceCourseController` — la résolution est dans `load()`, autour de `_clubRepo.getAthleteClubs(competitionIdValue, drawnAthletes)`. Les engagements de `competitors` doivent porter des athlètes patchés : le dossard se pose dans le même `copyWith` que le club.
- `RaceStructureController` — dans `_indexAthletes(entries, competitionId)`, qui construit `_athletesById` ; `_indexEntries` s'appuie ensuite dessus, donc patcher là suffit pour les deux index.
- `HeatDrawController` — autour de `_clubRepo.getAthleteClubs(competitionId, athletes)`.

Et un test par contrôleur, sur le même patron que celui du Step 1 : un athlète dont `orderNumberOf` rend 12 ressort avec `orderNumber == 12`.

- [ ] **Step 6: Mettre à jour les bindings**

Chaque `Get.lazyPut` de ces quatre contrôleurs gagne `Get.find<ParticipantService>()` en dernier argument, et l'import du service.

- [ ] **Step 7: Suivre les constructions dans les tests**

Run: `flutter analyze`
Expected: des erreurs `not_enough_positional_arguments` sur les fichiers de test. Ajouter le mock du service à chaque site de construction — `race_structure_controller_test.dart` en compte une douzaine.

- [ ] **Step 8: Lancer toute la suite et commiter**

Run: `flutter test && flutter analyze`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(dossard): les quatre ecrans de course portent le dossard"
```

---

### Task 5: La pastille

**Files:**
- Modify: `lib/app/core/theme/app_colors.dart` (un token)
- Create: `lib/app/presentation/shared/order_number_badge.dart`
- Modify: `lib/app/presentation/shared/entry_group_tile.dart`
- Modify: `lib/app/module/competitions/views/rfid_writer_view.dart:255-290`
- Modify: `lib/app/module/competitions/views/competition_detail_clubs_view.dart:215-224`
- Modify: `lib/app/module/competitions/views/race_detail_entries_view.dart` (le journal de scan)

**Interfaces:**
- Consumes : `Athlete.orderNumber` (tâche 1)
- Produces : le widget `OrderNumberBadge(orderNumber: int, {double fontSize})`, qui ne rend rien quand `orderNumber <= 0`.

- [ ] **Step 1: Ajouter le token de couleur**

Dans `lib/app/core/theme/app_colors.dart`, avec les autres tokens :

```dart
  /// Fond de la pastille de dossard. Volontairement la seule forme sombre de
  /// l'app : une place est colorée par son rang, un couloir est bleu pâle, un
  /// statut est vert ou rouge — le dossard ne doit se confondre avec aucun.
  static const Color orderNumberBadge = Color(0xFF263238);
```

- [ ] **Step 2: Écrire le widget**

Create `lib/app/presentation/shared/order_number_badge.dart` :

```dart
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';

/// Le dossard d'un athlète : le numéro épinglé sur son maillot.
///
/// Rend `SizedBox.shrink()` quand l'athlète n'en a pas — une pastille « 0 »
/// dirait quelque chose de faux.
class OrderNumberBadge extends StatelessWidget {
  const OrderNumberBadge({
    super.key,
    required this.orderNumber,
    this.fontSize = 11,
  });

  final int orderNumber;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (orderNumber <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.orderNumberBadge,
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        '$orderNumber',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          // Chiffres à chasse fixe sans embarquer de police : deux dossards
          // s'alignent en colonne quel que soit le nombre de chiffres.
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: La poser sur les lignes d'athlète et d'engagement individuel**

Dans `lib/app/presentation/shared/entry_group_tile.dart` :

- dans `_AthleteLine`, avant le `Expanded` qui porte le nom :

```dart
          OrderNumberBadge(orderNumber: athlete.orderNumber),
          const SizedBox(width: AppSpacing.xs),
```

- dans le `head`, entre `ClubAvatar` et le `Expanded` du titre, **seulement pour un engagement individuel** — une équipe n'a pas de dossard, ses athlètes portent le leur une fois dépliés :

```dart
          if (!_isTeam && entry.athletes.isNotEmpty) ...[
            OrderNumberBadge(
              orderNumber: entry.athletes.single.orderNumber,
              fontSize: 12,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
```

- [ ] **Step 4: La poser sur les trois autres écrans**

- `rfid_writer_view.dart` — dans la ligne de la liste, avant le `Text('${athlete.lastName} ${athlete.firstName}')` (lire la ligne entière avant d'éditer : elle porte déjà la licence et le club sur une seconde ligne, et la pastille se place à gauche du nom, pas dans ce sous-titre) ;
- `competition_detail_clubs_view.dart` — `_AthleteTile` passe le dossard à `_LicenseeRow`, qui le rend avant le nom (ajouter un paramètre `int orderNumber = 0` à `_LicenseeRow` plutôt que de dupliquer la ligne) ;
- `race_detail_entries_view.dart` — le journal de scan : `ScanResult` porte un libellé déjà composé par le contrôleur (`'${match.lastName} ${match.firstName}'`). Y ajouter le dossard **dans le contrôleur** (`RaceDetailController._onScanPayload`), pas dans la vue : `'${match.orderNumber > 0 ? '${match.orderNumber} · ' : ''}${match.lastName} ${match.firstName}'`. Le journal est une liste de chaînes, pas de widgets.

- [ ] **Step 5: Vérifier**

Run: `flutter analyze && flutter test`
Expected: PASS. Aucun test de widget n'est attendu ici — le rendu se vérifie à l'écran.

- [ ] **Step 6: Commit**

```bash
dart format lib/
git add -A
git commit -m "feat(dossard): une pastille sombre partout ou un athlete s affiche"
```

---

### Task 6: Le bracelet

**Files:**
- Modify: `lib/app/core/rfid/bracelet_payload.dart`
- Modify: `lib/app/module/competitions/controllers/race_detail_controller.dart` (`_onScanPayload`)
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart` (`_onBracelet`)
- Modify: `lib/app/core/translations/fr_fr.dart`, `en_us.dart`
- Test: `test/core/rfid/bracelet_payload_test.dart`
- Test: `race_detail_controller_test.dart`, `race_course_controller_test.dart`

**Interfaces:**
- Consumes : `Athlete.orderNumber` (tâche 1)
- Produces :
  - `braceletPayload(Athlete)` → `'<licence>;<nom>'` sans dossard, `'<licence>;<nom>;<dossard>'` avec
  - `parseBraceletOrderNumber(String payload) → int` — 0 si absent, illisible, ou non numérique
  - clé `bracelet_other_event` dans les deux langues

- [ ] **Step 1: Écrire les tests de payload qui échouent**

Dans `test/core/rfid/bracelet_payload_test.dart` :

```dart
  test('le dossard est ecrit en troisieme champ', () {
    expect(braceletPayload(athlete(licence: 'L1', last: 'DUPONT', dossard: 12)),
        'L1;DUPONT;12');
  });

  test('sans dossard, le payload garde ses deux champs', () {
    expect(braceletPayload(athlete(licence: 'L1', last: 'DUPONT', dossard: 0)),
        'L1;DUPONT');
  });

  test('le dossard se relit', () {
    expect(parseBraceletOrderNumber('L1;DUPONT;12'), 12);
  });

  // Un bracelet ecrit avant cette version n'a que deux champs : il reste
  // lisible, et ne declenche aucune alerte.
  test('un payload herite n a pas de dossard', () {
    expect(parseBraceletOrderNumber('L1;DUPONT'), 0);
    expect(parseBraceletLicence('L1;DUPONT'), 'L1');
  });

  test('un troisieme champ illisible vaut pas de dossard', () {
    expect(parseBraceletOrderNumber('L1;DUPONT;A12'), 0);
  });
```

(`athlete(...)` : le helper de construction déjà présent dans ce fichier, ou un helper local si le fichier n'en a pas.)

- [ ] **Step 2: Lancer et vérifier l'échec**

Run: `flutter test test/core/rfid/bracelet_payload_test.dart`
Expected: FAIL — `parseBraceletOrderNumber` non défini

- [ ] **Step 3: Étendre le contrat du bracelet**

Dans `lib/app/core/rfid/bracelet_payload.dart` :

```dart
/// The exact string written to an RFID bracelet:
/// `<licenseeNumber>;<lastName>` — plus `;<orderNumber>` when the athlete has
/// a bib.
///
/// The bib comes last so that a bracelet written before it existed stays
/// readable: the licence is still the first field.
String braceletPayload(Athlete athlete) {
  final lastName = athlete.lastName.replaceAll(braceletFieldSeparator, ' ');
  final base = '${athlete.licenseeNumber}$braceletFieldSeparator$lastName';
  if (athlete.orderNumber <= 0) return base;
  return '$base$braceletFieldSeparator${athlete.orderNumber}';
}

/// The bib carried by a bracelet payload, 0 when it carries none — a bracelet
/// written before bibs existed, or a third field that is not a number.
int parseBraceletOrderNumber(String payload) {
  final fields = payload.split(braceletFieldSeparator);
  if (fields.length < 3) return 0;
  return int.tryParse(fields[2].trim()) ?? 0;
}
```

- [ ] **Step 4: Lancer et vérifier que ça passe**

Run: `flutter test test/core/rfid/bracelet_payload_test.dart`
Expected: PASS

- [ ] **Step 5: Ajouter la clé de traduction**

`fr_fr.dart` : `'bracelet_other_event': 'Bracelet d\'un autre événement',`
`en_us.dart` : `'bracelet_other_event': 'Bracelet from another event',`

- [ ] **Step 6: Écrire les tests de scan qui échouent**

Dans `race_detail_controller_test.dart`, groupe `scanning` :

```dart
    test('un bracelet d un autre evenement pointe quand meme et alerte',
        () async {
      // L'athlete porte le dossard 12 ici ; le bracelet en annonce 7.
      final c = await loadWithBibs({11: 12});
      c.startScan();

      stream.add('L11;B11;7');
      await pumpEventQueue();

      expect(c.attendanceOf(athlete(11)), AttendanceStatus.present);
      expect(c.message.value, const UiMessageError('bracelet_other_event'));
      c.stopScan();
    });

    test('un bracelet du bon evenement ne dit rien', () async {
      final c = await loadWithBibs({11: 12});
      c.startScan();

      stream.add('L11;B11;12');
      await pumpEventQueue();

      expect(c.message.value, isNull);
      c.stopScan();
    });
```

(`loadWithBibs` : le helper de chargement du fichier, avec `participants.orderNumberOf` stubbé sur la table donnée.)

Le même couple de tests dans `race_course_controller_test.dart`, groupe `scanning`, en vérifiant que l'engagement est bien classé **et** que le message part.

- [ ] **Step 7: Appliquer la règle dans les deux contrôleurs**

Dans `RaceDetailController._onScanPayload`, après avoir trouvé `match` et posé la présence :

```dart
    // Le dossard ne sert pas à identifier : il ne vaut que pour sa
    // compétition, donc un bracelet non réécrit pointerait en silence
    // l'athlète qui porte ce numéro ici. Il vérifie, et alerte quand il
    // dément la licence.
    final onBracelet = parseBraceletOrderNumber(payload);
    if (onBracelet > 0 &&
        match.orderNumber > 0 &&
        onBracelet != match.orderNumber) {
      message.trigger(const UiMessageError('bracelet_other_event'));
    }
```

La même chose dans `RaceCourseController._onBracelet`, après `assign(match)` — en lisant le dossard sur l'athlète dont la licence a matché, pas sur l'engagement.

- [ ] **Step 8: Lancer toute la suite et commiter**

Run: `flutter test && flutter analyze`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(bracelet): ecrire le dossard, et s en servir pour verifier"
```

---

### Task 7: Documenter

**Files:**
- Modify: `live_ffss/CLAUDE.md`

- [ ] **Step 1: Les quatre passages**

- **API contract** : la route `competition/evenement/:id/participants` sert des éléments de forme athlète portant `Dossard` (une chaîne), que `organismes` porte aussi et que `engagement` **ne porte pas** — c'est la raison d'être de `ParticipantService`. Noter le risque de troncature à 30 lignes, non vérifié, comme pour `engagement`.
- **DI registration order** : `ParticipantService` à côté de `MeetingService`, synchrone, `permanent`.
- **presentation/shared** : `OrderNumberBadge`, avec la règle — tout affichage d'un dossard passe par lui, et rien d'autre dans l'app n'est une pastille sombre à chasse fixe.
- **`core/rfid`** : le payload du bracelet est `<licence>;<nom>` ou `<licence>;<nom>;<dossard>` ; la licence identifie, le dossard vérifie, et un bracelet à deux champs reste lisible.

Écrire chaque passage dans la langue de la section qu'il rejoint.

- [ ] **Step 2: Commit**

```bash
git add live_ffss/CLAUDE.md
git commit -m "docs: le dossard, sa route, son service et son bracelet"
```

---

## Notes d'exécution

**Ordre.** 1 → 2 → 3 fondent la donnée ; 4 la distribue ; 5 l'affiche ; 6 l'écrit sur le bracelet ; 7 documente. Les tâches 5 et 6 ne dépendent l'une de l'autre en rien et peuvent être revues séparément.

**Ce que la tâche 1 donne gratuitement.** Dès la tâche 1, l'écran bracelet et l'effectif d'un club portent le dossard dans leurs données — ils lisent `organismes`, qui le sert. Seul l'affichage (tâche 5) leur manque encore. Les quatre écrans de course, eux, ont besoin de la tâche 4.

**Ce qui n'est pas vérifiable ici.** Ni toolchain ni appareil : chaque tâche s'arrête à `flutter test` et `flutter analyze`. La pastille, le scan d'un vrai bracelet et la lecture d'un bracelet d'un autre événement demandent un passage sur appareil, qui revient à l'utilisateur.
