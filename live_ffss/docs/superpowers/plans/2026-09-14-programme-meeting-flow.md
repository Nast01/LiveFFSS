# Flow de création d'un programme — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer la création implicite d'une réunion par un flow explicite — créer une réunion (titre, date, heure, site), gérer les sites, y poser des créneaux manuels ou des tours d'épreuve, et tout réediter — en découpant `ScheduleController` (912 lignes) en un service, trois contrôleurs et un module de fonctions pures.

**Architecture:** `MeetingService` devient le propriétaire unique de l'arbre réunion FFSS (`Réunion → Créneau → Course`), partagé par trois contrôleurs à responsabilité unique : liste, formulaire, éditeur. Tout le calcul d'horaires sort des contrôleurs vers `meeting_timetable.dart`, en fonctions pures testables sans mock. Une réunion porte **un** site, transporté par sa `description` FFSS, dont héritent toutes ses courses.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX (état + DI), freezed + json_serializable, mocktail.

**Spec:** [docs/superpowers/specs/2026-09-14-programme-meeting-flow-design.md](../specs/2026-09-14-programme-meeting-flow-design.md)

## Global Constraints

Ces règles viennent du `CLAUDE.md` du projet et du spec. **Elles s'appliquent implicitement à chaque tâche.**

- **Commandes** : `flutter test`, `dart format lib/ test/`, `flutter analyze` — appelées **nues**, jamais par chemin complet `.bat` (l'allowlist de permissions matche les formes courtes).
- **Analyzer strict** : `strict-casts: true` et `strict-raw-types: true`. Aucun `dynamic` coercé, aucun `// ignore:` ajouté.
- **Discipline des contrôleurs** : pas de `Get.context!`, pas de `Get.snackbar`, pas de `Get.dialog`, pas de `.tr`, pas de `BuildContext` en paramètre, pas de `TextEditingController`/`GlobalKey` dans un contrôleur scopé à une vue. Injection par constructeur uniquement — jamais de `Get.find()` dans le corps d'un contrôleur.
- **Erreurs** : attraper `AppException` (le type scellé de `core/errors/`), jamais `Exception` brut.
- **Messages** : `Rxn<UiMessage>` dans le contrôleur, `showUiMessages(controller.message)` dans le `initState` de la vue et `_worker.dispose()` dans son `dispose`. Ne jamais réécrire le bloc `ever` + `ScaffoldMessenger` à la main.
- **Traductions** : les deux fichiers `en_us.dart` et `fr_fr.dart` restent **symétriques et sans clé morte**. Toute clé ajoutée l'est dans les deux ; toute clé dont le dernier appelant disparaît est supprimée des deux.
- **Mocktail** : `class _MockX extends Mock implements X {}` — **jamais** `extends Fake`. Enregistrer les `registerFallbackValue` nécessaires dans `setUpAll`.
- **Pas de test de widget, pas de test d'intégration.** Les couches mapper / repository / datasource / service / contrôleur uniquement.
- **Commentaires** : uniquement là où le *pourquoi* n'est pas évident (contrainte cachée, contournement, bizarrerie du backend). Jamais de narration de la ligne suivante.
- **Spinners** : `LoadingIndicator` (ou `compact: true`), `ProgressOverlay` pour le voile. Jamais de `CircularProgressIndicator` nu.
- **Attribution des commits** : terminer chaque message par
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`
- **Vérification sur appareil impossible ici** (ni toolchain Visual Studio ni appareil Android) : le parcours réel revient à l'utilisateur. Ne jamais annoncer « vérifié dans l'app ».

## Structure des fichiers

**Créés**

| Fichier | Responsabilité |
|---|---|
| `lib/app/domain/models/meeting_timetable.dart` | fonctions pures : poser une réunion bout à bout, diffuser ce qui a bougé |
| `lib/app/data/services/meeting_service.dart` | propriétaire de l'arbre réunion FFSS, partagé |
| `lib/app/module/programme/controllers/meeting_list_controller.dart` | la liste : lecture, groupement par jour, suppression |
| `lib/app/module/programme/controllers/meeting_form_controller.dart` | créer / éditer une réunion, décalage inclus |
| `lib/app/module/programme/controllers/meeting_editor_controller.dart` | les items d'une réunion |
| `lib/app/module/programme/views/meeting_list_view.dart` | l'onglet Programme |
| `lib/app/module/programme/views/meeting_form_view.dart` | le formulaire, création et édition |
| `lib/app/module/programme/views/meeting_editor_view.dart` | l'éditeur d'une réunion + sa palette |
| `lib/app/module/programme/bindings/meeting_form_binding.dart` | — |
| `lib/app/module/programme/bindings/meeting_editor_binding.dart` | — |
| `lib/app/module/programme/bindings/sites_binding.dart` | — |

**Modifiés**

| Fichier | Changement |
|---|---|
| `lib/app/core/config/app_config.dart` | + `meetingDelete` |
| `lib/app/data/datasources/meeting_remote_datasource.dart` | + `deleteMeeting`, `submitLane` prend `engagement` en `String` |
| `lib/app/data/repositories/meeting_repository.dart` | + `deleteMeeting`, `createDefaultLanes` envoie `'0'`, `syncLanes` envoie `''`/id |
| `lib/app/domain/models/meeting.dart` | + `extension MeetingSite` |
| `lib/app/presentation/modules/programme/day_sections.dart` | `DaySection`/`daySections` → `meetingEntries` |
| `lib/app/core/di/initial_binding.dart` | + `MeetingService` en 4b |
| `lib/app/module/programme/bindings/programme_binding.dart` | `ScheduleController` → `MeetingListController` |
| `lib/app/module/programme/views/programme_view.dart` | `ScheduleView` → `MeetingListView` |
| `lib/app/routes/app_pages.dart`, `app_routes.dart` | 3 routes |
| `lib/app/core/translations/{en_us,fr_fr}.dart` | clés ajoutées / retirées |
| `CLAUDE.md` | modules, services, DI, routes |

**Supprimés** — `schedule_controller.dart`, `schedule_view.dart`, `schedule_controller_test.dart`.

**Ordre des tâches.** 1 et 2 touchent la couche data et ne dépendent de rien. 3 et 4 sont du domaine pur. 5 dépend de 1. 6 ne dépend de rien. 7, 8 et 9 sont les contrôleurs et dépendent de 3, 4, 5 et 6. 10 câble routes, bindings et traductions. 11 écrit les vues et crée les `GetPage`. 12 démolit.

Entre la Task 6 et la Task 11, `flutter analyze` signale `schedule_view.dart`, qui appelle le `daySections` disparu. C'est attendu et la Task 12 le supprime : ne pas rafistoler l'ancienne vue en chemin.

---

### Task 1 : `deleteMeeting` de bout en bout

**Files:**
- Modify: `lib/app/core/config/app_config.dart` (bloc `ApiEndpoints`, à côté de `meetingSubmit`/`meetingList`, l. 67-68)
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart`
- Modify: `lib/app/data/repositories/meeting_repository.dart`
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`, `test/data/repositories/meeting_repository_test.dart`

**Interfaces:**
- Consumes: rien
- Produces: `MeetingRemoteDataSource.deleteMeeting(int meetingId) → Future<bool>`, `MeetingRepository.deleteMeeting(int meetingId) → Future<bool>`, `ApiEndpoints.meetingDelete`

Route documentée : `POST competition/reunion/:id/delete`, paramètres `token` (injecté par `HttpClient`) et `id` (dans le chemin), réponse `{success, message}`. Même forme que `deleteSlot`.

- [ ] **Step 1 : écrire le test de la datasource qui échoue**

Dans `test/data/datasources/meeting_remote_datasource_test.dart`, ajouter à la fin de `main()`. Ouvrir le fichier d'abord et **copier la forme exacte des mocks et du `setUp` déjà présents** plutôt que de réinventer un harnais.

```dart
  group('deleteMeeting', () {
    test('posts to competition/reunion/:id/delete and returns success',
        () async {
      when(() => http.post('competition/reunion/77/delete'))
          .thenAnswer((_) async => {'success': true});

      final deleted = await dataSource.deleteMeeting(77);

      expect(deleted, isTrue);
      verify(() => http.post('competition/reunion/77/delete')).called(1);
    });

    test('returns false when FFSS reports a failure', () async {
      when(() => http.post(any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Nope'});

      expect(await dataSource.deleteMeeting(77), isFalse);
    });
  });
```

Si le `setUp` du fichier n'expose pas de variables nommées `http` et `dataSource`, adopter les noms qui y sont déjà utilisés.

- [ ] **Step 2 : lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: FAIL — `The method 'deleteMeeting' isn't defined`.

- [ ] **Step 3 : ajouter l'endpoint**

Dans `lib/app/core/config/app_config.dart`, juste après `meetingList` :

```dart
  // Supprime la réunion ET, côté serveur, ses créneaux et ses courses — la
  // réponse ne le détaille pas.
  static const String meetingDelete = 'competition/reunion/:id/delete';
```

- [ ] **Step 4 : implémenter la datasource**

Dans la classe abstraite `MeetingRemoteDataSource`, après `submitMeeting` :

```dart
  /// Supprime une réunion. Emporte ses créneaux et ses courses côté serveur.
  Future<bool> deleteMeeting(int meetingId);
```

Dans `MeetingRemoteDataSourceImpl`, à côté de `deleteSlot` :

```dart
  @override
  Future<bool> deleteMeeting(int meetingId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingDelete,
      {'id': meetingId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }
```

- [ ] **Step 5 : lancer le test et vérifier qu'il passe**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: PASS

- [ ] **Step 6 : écrire le test du repository qui échoue**

Dans `test/data/repositories/meeting_repository_test.dart` :

```dart
  group('deleteMeeting', () {
    test('forwards to the data source', () async {
      when(() => dataSource.deleteMeeting(77)).thenAnswer((_) async => true);

      expect(await repository.deleteMeeting(77), isTrue);
      verify(() => dataSource.deleteMeeting(77)).called(1);
    });
  });
```

- [ ] **Step 7 : lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: FAIL — `deleteMeeting` absent de `MeetingRepository`.

- [ ] **Step 8 : implémenter le repository**

Dans l'abstrait `MeetingRepository`, après `submitMeeting` :

```dart
  /// Supprime une réunion, ses créneaux et ses courses.
  Future<bool> deleteMeeting(int meetingId);
```

Dans `MeetingRepositoryImpl`, à côté de `deleteSlot` :

```dart
  @override
  Future<bool> deleteMeeting(int meetingId) =>
      _dataSource.deleteMeeting(meetingId);
```

- [ ] **Step 9 : lancer toute la suite**

Run: `flutter test`
Expected: PASS. Un `_MockMeetingRepo` d'un autre fichier de test n'a pas besoin d'être touché : mocktail génère les membres manquants.

- [ ] **Step 10 : formater, analyser, commiter**

```bash
dart format lib/ test/
flutter analyze
git add lib/app/core/config/app_config.dart lib/app/data/datasources/meeting_remote_datasource.dart lib/app/data/repositories/meeting_repository.dart test/data/datasources/meeting_remote_datasource_test.dart test/data/repositories/meeting_repository_test.dart
git commit -m "$(cat <<'EOF'
feat(data): suppression d'une reunion

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2 : `engagement`, trois valeurs au lieu de deux

**Files:**
- Modify: `lib/app/data/datasources/meeting_remote_datasource.dart` (`submitLane`, l. ~73-81 pour l'abstrait et ~222-243 pour l'impl)
- Modify: `lib/app/data/repositories/meeting_repository.dart` (`createDefaultLanes` l. ~241, `syncLanes` l. ~277)
- Test: `test/data/datasources/meeting_remote_datasource_test.dart`, `test/data/repositories/meeting_repository_test.dart`

**Interfaces:**
- Consumes: rien
- Produces: `MeetingRemoteDataSource.submitLane({required int runId, required int number, required String engagement, int? id})` — **`entryId` disparaît**, remplacé par la valeur de fil.

Le *pourquoi* : `null` signifiait à la fois « place créée sans engagement » et « libère cette place », alors que FFSS attend deux choses différentes. `'0'` à la création, `''` pour libérer, l'id pour asseoir.

- [ ] **Step 1 : écrire les tests de la datasource qui échouent**

Remplacer le groupe `submitLane` existant du fichier de test (le chercher, il existe) par :

```dart
  group('submitLane', () {
    test('sends engagement verbatim', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'id': 5});

      await dataSource.submitLane(runId: 9, number: 3, engagement: '0');

      final query = verify(() => http.post(
            'competition/reunion/creneau/course/9/place/submit',
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;
      expect(query['engagement'], '0');
      expect(query['numero'], '3');
      expect(query['id'], '');
    });

    test('an empty engagement stays empty — it frees the spot', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'id': 5});

      await dataSource.submitLane(
          runId: 9, number: 3, engagement: '', id: 41);

      final query = verify(() => http.post(any(),
              query: captureAny(named: 'query')))
          .captured
          .single as Map<String, dynamic>;
      expect(query['engagement'], '');
      expect(query['id'], '41');
    });
  });
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: FAIL — `engagement` n'est pas un paramètre nommé de `submitLane`.

- [ ] **Step 3 : changer la signature de la datasource**

Dans l'abstrait, remplacer le bloc `submitLane` (doc comprise) par :

```dart
  /// Crée une place numérotée sur une course, ou réécrit celle d'[id].
  /// Rend l'id attribué par FFSS, ou 0 quand l'appel a signalé un échec.
  ///
  /// [engagement] est envoyé tel quel, et ses trois valeurs ne sont pas
  /// interchangeables : `'0'` pour une place créée sans engagement associé,
  /// `''` pour LIBÉRER une place occupée (vérifié le 2026-09-03), l'id de
  /// l'engagement pour l'y asseoir. Le paramètre part toujours, y compris
  /// vide — c'est ce qui rend la libération possible.
  Future<int> submitLane({
    required int runId,
    required int number,
    required String engagement,
    int? id,
  });
```

Dans l'impl :

```dart
  @override
  Future<int> submitLane({
    required int runId,
    required int number,
    required String engagement,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.laneSubmit,
      {'course': runId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Vide = « créer » ; une valeur = « mettre à jour ».
      'id': id?.toString() ?? '',
      'numero': number.toString(),
      'engagement': engagement,
    });
    final assigned = body['id'];
    return assigned is int ? assigned : 0;
  }
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/data/datasources/meeting_remote_datasource_test.dart`
Expected: PASS

- [ ] **Step 5 : écrire les tests du repository qui échouent**

Dans `test/data/repositories/meeting_repository_test.dart`, ajouter aux groupes `createDefaultLanes` et `syncLanes` existants :

```dart
    test('createDefaultLanes opens each spot with engagement 0', () async {
      when(() => dataSource.submitLane(
            runId: any(named: 'runId'),
            number: any(named: 'number'),
            engagement: any(named: 'engagement'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 1);

      await repository.createDefaultLanes(runId: 9, count: 2);

      verify(() => dataSource.submitLane(
          runId: 9, number: 1, engagement: '0')).called(1);
      verify(() => dataSource.submitLane(
          runId: 9, number: 2, engagement: '0')).called(1);
    });

    test('syncLanes seats an entry by id and never sends 0', () async {
      when(() => dataSource.submitLane(
            runId: any(named: 'runId'),
            number: any(named: 'number'),
            engagement: any(named: 'engagement'),
            id: any(named: 'id'),
          )).thenAnswer((_) async => 1);

      await repository.syncLanes(
          runId: 9, entryIds: [51], existing: const []);

      verify(() => dataSource.submitLane(
          runId: 9, number: 1, engagement: '51', id: null)).called(1);
    });
```

- [ ] **Step 6 : lancer et vérifier l'échec**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: FAIL — `engagement` n'est pas un paramètre nommé.

- [ ] **Step 7 : adapter les deux appelants du repository**

`createDefaultLanes` — la place naît sans engagement, donc `'0'` :

```dart
      final id = await _dataSource.submitLane(
        runId: runId,
        number: number,
        engagement: '0',
      );
```

`syncLanes` — l'id de l'engagement dans la boucle qui assied :

```dart
      final id = await _dataSource.submitLane(
        runId: runId,
        number: i + 1,
        engagement: entryIds[i].toString(),
        id: i < reusable.length ? reusable[i].id : null,
      );
```

Puis **relire la suite de `syncLanes`** : si une branche y libère une place en passant `entryId: null`, elle passe désormais `engagement: ''`. Vérifier par `grep -rn "submitLane" lib/` qu'il ne reste aucun appelant non migré.

- [ ] **Step 8 : lancer toute la suite**

Run: `flutter test`
Expected: PASS. Tout test existant qui stubbe `submitLane` avec `entryId:` casse à la compilation — le migrer vers `engagement:` avec la valeur que l'appelant envoie désormais, sans changer ce qu'il vérifie par ailleurs.

- [ ] **Step 9 : formater, analyser, commiter**

```bash
dart format lib/ test/
flutter analyze
git add lib/app/data test/data
git commit -m "$(cat <<'EOF'
fix(data): une place creee sans engagement part avec 0

La chaine vide libere une place occupee (verifie le 2026-09-03), elle ne
peut donc pas signifier aussi « place creee libre ». submitLane prend
desormais la valeur de fil telle quelle : '0' a la creation, '' pour
liberer, l'id pour asseoir.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3 : l'accesseur `site` sur `Meeting`

**Files:**
- Modify: `lib/app/domain/models/meeting.dart`
- Test: `test/data/models/meeting_site_test.dart` (créer)

**Interfaces:**
- Consumes: rien
- Produces: `extension MeetingSite on Meeting { String get site; }`

- [ ] **Step 1 : écrire le test qui échoue**

Créer `test/data/models/meeting_site_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

void main() {
  Meeting meeting(String description) => Meeting(
        id: 1,
        name: 'Matin',
        description: description,
        date: DateTime(2026, 9, 12),
        beginHour: DateTime(2026, 9, 12, 8),
        endHour: DateTime(2026, 9, 12, 8),
      );

  test('the site is the réunion description', () {
    expect(meeting('Plage').site, 'Plage');
  });

  test('a réunion with no description has no site', () {
    expect(meeting('').site, isEmpty);
  });
}
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/data/models/meeting_site_test.dart`
Expected: FAIL — `The getter 'site' isn't defined for the type 'Meeting'`.

- [ ] **Step 3 : implémenter**

À la fin de `lib/app/domain/models/meeting.dart`, après la classe :

```dart
extension MeetingSite on Meeting {
  /// FFSS ne porte aucun site sur une réunion : la description le transporte.
  /// Toutes les courses de la réunion sont créées sur ce site.
  ///
  /// Dans le domaine et non dans une extension de présentation : c'est une
  /// relecture sémantique d'un champ, pas un formatage, et un contrôleur en a
  /// besoin pour créer ses courses.
  String get site => description;
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/data/models/meeting_site_test.dart`
Expected: PASS

- [ ] **Step 5 : commiter**

```bash
dart format lib/ test/
flutter analyze
git add lib/app/domain/models/meeting.dart test/data/models/meeting_site_test.dart
git commit -m "$(cat <<'EOF'
feat(domain): le site d'une reunion, porte par sa description

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4 : `meeting_timetable.dart`, les fonctions pures

**Files:**
- Create: `lib/app/domain/models/meeting_timetable.dart`
- Test: `test/data/models/meeting_timetable_test.dart`

**Interfaces:**
- Consumes: `Slot`, `Run` (`lib/app/domain/models/`)
- Produces:
  - `int minutesOf(DateTime t)`
  - `class TimetableRun { int runId; int beginMinutes; int endMinutes; }`
  - `class TimetableItem { int slotId; int beginMinutes; int endMinutes; List<TimetableRun> runs; }`
  - `class Timetable { List<TimetableItem> items; int endMinutes; }`
  - `Timetable layOut(List<Slot> slots, int startMinutes)`
  - `class TimetableMove { int slotId; int? runId; int beginMinutes; int endMinutes; }`
  - `List<TimetableMove> moves(List<Slot> current, Timetable target)`

Les règles que ces fonctions portent, déjà vraies dans `_resequenceDay` et à préserver mot pour mot :

1. Un créneau **portant des courses** dure la somme de ses courses, jamais son propre `fin - debut` : FFSS conserve l'étendue de création, et la lire garderait la place d'une course supprimée.
2. Une réunion sans item finit à sa propre heure de début.
3. Un créneau ne porte aucun rang côté FFSS : son heure de début EST sa place. Réordonner et recompacter sont le même geste.
4. `moves` ne rend que ce qui a bougé : supprimer le dernier item d'une journée de vingt ne doit pas réécrire les dix-neuf autres.

- [ ] **Step 1 : écrire les tests qui échouent**

Créer `test/data/models/meeting_timetable_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

/// Les horaires d'un Slot/Run arrivent d'un `HH:mm` nu et atterrissent sur
/// 1970-01-01 — c'est exactement la forme que le mapper produit, donc celle
/// que ces tests doivent utiliser.
DateTime hm(int hour, int minute) => DateTime(1970, 1, 1, hour, minute);

Run run(int id, int beginH, int beginM, int endH, int endM) => Run(
      id: id,
      name: 'c$id',
      label: '',
      fullLabel: '',
      status: RunStatus.waiting,
      statusLabel: '',
      site: 'Plage',
      beginTime: hm(beginH, beginM),
      endTime: hm(endH, endM),
    );

Slot slot(int id, int beginH, int beginM, int endH, int endM,
        {List<Run> runs = const []}) =>
    Slot(
      id: id,
      name: 's$id',
      beginHour: hm(beginH, beginM),
      endHour: hm(endH, endM),
      runs: runs,
    );

void main() {
  group('layOut', () {
    test('an empty réunion ends at its own start', () {
      final table = layOut(const [], 8 * 60);

      expect(table.items, isEmpty);
      expect(table.endMinutes, 8 * 60);
    });

    test('lays manual items back to back from the start, keeping durations',
        () {
      final table = layOut([
        slot(1, 9, 0, 9, 10), // 10 min
        slot(2, 14, 0, 14, 30), // 30 min
      ], 8 * 60);

      expect(table.items[0].beginMinutes, 8 * 60);
      expect(table.items[0].endMinutes, 8 * 60 + 10);
      expect(table.items[1].beginMinutes, 8 * 60 + 10);
      expect(table.items[1].endMinutes, 8 * 60 + 40);
      expect(table.endMinutes, 8 * 60 + 40);
    });

    test('a créneau carrying courses lasts the sum of its courses, not its '
        'own span', () {
      // Étendue propre de 60 min, mais deux courses de 10 : c'est 20 qui
      // compte, sinon la place d'une course supprimée resterait réservée.
      final table = layOut([
        slot(1, 9, 0, 10, 0, runs: [
          run(11, 9, 0, 9, 10),
          run(12, 9, 10, 9, 20),
        ]),
      ], 8 * 60);

      expect(table.items.single.endMinutes, 8 * 60 + 20);
      expect(table.endMinutes, 8 * 60 + 20);
    });

    test('courses ride with their créneau, back to back', () {
      final table = layOut([
        slot(1, 9, 0, 9, 10, runs: [run(11, 9, 0, 9, 10)]),
        slot(2, 10, 0, 10, 30, runs: [
          run(21, 10, 0, 10, 10),
          run(22, 10, 10, 10, 30),
        ]),
      ], 8 * 60);

      expect(table.items[1].runs[0].beginMinutes, 8 * 60 + 10);
      expect(table.items[1].runs[0].endMinutes, 8 * 60 + 20);
      expect(table.items[1].runs[1].beginMinutes, 8 * 60 + 20);
      expect(table.items[1].runs[1].endMinutes, 8 * 60 + 40);
    });

    test('courses are laid in running order, whatever the payload order', () {
      final table = layOut([
        slot(1, 9, 0, 9, 30, runs: [
          run(22, 9, 10, 9, 30), // le plus tardif d'abord
          run(21, 9, 0, 9, 10),
        ]),
      ], 8 * 60);

      expect(table.items.single.runs.map((r) => r.runId), [21, 22]);
    });

    test('the order given is the order laid out — reordering is repacking',
        () {
      final a = slot(1, 9, 0, 9, 10);
      final b = slot(2, 14, 0, 14, 30);

      final table = layOut([b, a], 8 * 60);

      expect(table.items.map((i) => i.slotId), [2, 1]);
      expect(table.items[0].endMinutes, 8 * 60 + 30);
    });
  });

  group('moves', () {
    test('returns nothing when FFSS already holds the target times', () {
      final slots = [slot(1, 8, 0, 8, 10)];

      expect(moves(slots, layOut(slots, 8 * 60)), isEmpty);
    });

    test('returns only the items whose times changed', () {
      // Le premier est déjà en place ; seul le second a glissé.
      final slots = [
        slot(1, 8, 0, 8, 10),
        slot(2, 9, 0, 9, 30),
      ];

      final result = moves(slots, layOut(slots, 8 * 60));

      expect(result.length, 1);
      expect(result.single.slotId, 2);
      expect(result.single.runId, isNull);
      expect(result.single.beginMinutes, 8 * 60 + 10);
      expect(result.single.endMinutes, 8 * 60 + 40);
    });

    test('reports a moved course separately from its créneau', () {
      final slots = [
        slot(1, 9, 0, 9, 10, runs: [run(11, 9, 0, 9, 10)]),
      ];

      final result = moves(slots, layOut(slots, 8 * 60));

      expect(result.length, 2);
      expect(result[0].slotId, 1);
      expect(result[0].runId, isNull);
      expect(result[1].slotId, 1);
      expect(result[1].runId, 11);
      expect(result[1].beginMinutes, 8 * 60);
    });

    test('a course whose end alone changed is still reported', () {
      // Même début, fin différente : un raccourcissement ne doit pas passer
      // inaperçu.
      final slots = [
        slot(1, 8, 0, 8, 20, runs: [run(11, 8, 0, 8, 20)]),
      ];
      final target = layOut([
        slot(1, 8, 0, 8, 10, runs: [run(11, 8, 0, 8, 10)]),
      ], 8 * 60);

      final result = moves(slots, target);

      expect(result.map((m) => m.runId), containsAll(<int?>[null, 11]));
    });

    test('ignores a target item FFSS does not hold', () {
      final target = layOut([slot(99, 8, 0, 8, 10)], 8 * 60);

      expect(moves(const [], target), isEmpty);
    });
  });

  test('minutesOf ignores the calendar date', () {
    expect(minutesOf(DateTime(1970, 1, 1, 8, 30)), 8 * 60 + 30);
    expect(minutesOf(DateTime(2026, 9, 12, 8, 30)), 8 * 60 + 30);
  });
}
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/data/models/meeting_timetable_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../meeting_timetable.dart'`.

- [ ] **Step 3 : implémenter le module**

Créer `lib/app/domain/models/meeting_timetable.dart` :

```dart
import 'package:live_ffss/app/domain/models/slot.dart';

/// Minutes depuis minuit, en ignorant la date portée par [t].
///
/// Les horaires d'un [Slot] ou d'une course sont parsés d'un `HH:mm` nu et
/// atterrissent sur 1970-01-01, alors que `Meeting.beginHour` porte la vraie
/// date de la réunion : les comparer en `DateTime` se lirait toujours comme
/// « avant ». Tout ce que fait une réunion tient dans une journée, donc les
/// minutes suffisent — et les mappers, partagés avec d'autres modules,
/// restent intouchés.
int minutesOf(DateTime t) => t.hour * 60 + t.minute;

/// Une course, une fois la réunion posée bout à bout.
class TimetableRun {
  const TimetableRun({
    required this.runId,
    required this.beginMinutes,
    required this.endMinutes,
  });

  final int runId;
  final int beginMinutes;
  final int endMinutes;
}

/// Un item de la réunion — un créneau — une fois la réunion posée bout à bout.
class TimetableItem {
  const TimetableItem({
    required this.slotId,
    required this.beginMinutes,
    required this.endMinutes,
    required this.runs,
  });

  final int slotId;
  final int beginMinutes;
  final int endMinutes;

  /// Les courses du créneau, en ordre de passage. Vide pour un item manuel.
  final List<TimetableRun> runs;
}

/// Une réunion posée bout à bout depuis son heure de début.
class Timetable {
  const Timetable({required this.items, required this.endMinutes});

  final List<TimetableItem> items;

  /// La fin de la réunion : la fin de son dernier item, ou son heure de début
  /// quand elle n'en porte aucun — une réunion vide ne « dure » pas.
  final int endMinutes;
}

/// Pose [slots] bout à bout depuis [startMinutes], dans l'ordre donné, en
/// conservant la durée de chacun.
///
/// L'ordre donné EST l'ordre posé : un créneau ne porte aucun rang côté FFSS,
/// son heure de début est sa place dans la journée. Réordonner et recompacter
/// sont donc le même geste.
Timetable layOut(List<Slot> slots, int startMinutes) {
  final items = <TimetableItem>[];
  var cursor = startMinutes;

  for (final slot in slots) {
    final ordered = [...slot.runs]
      ..sort((a, b) => a.beginTime.compareTo(b.beginTime));

    // Un créneau portant des courses est exactement aussi long qu'elles.
    // Lire sa propre étendue garderait la place qu'une course supprimée
    // occupait : FFSS conserve l'étendue avec laquelle il a été créé.
    final duration = ordered.isEmpty
        ? minutesOf(slot.endHour) - minutesOf(slot.beginHour)
        : ordered.fold<int>(
            0,
            (sum, run) =>
                sum + minutesOf(run.endTime) - minutesOf(run.beginTime),
          );

    var runCursor = cursor;
    final runs = <TimetableRun>[];
    for (final run in ordered) {
      final runDuration = minutesOf(run.endTime) - minutesOf(run.beginTime);
      runs.add(TimetableRun(
        runId: run.id,
        beginMinutes: runCursor,
        endMinutes: runCursor + runDuration,
      ));
      runCursor += runDuration;
    }

    items.add(TimetableItem(
      slotId: slot.id,
      beginMinutes: cursor,
      endMinutes: cursor + duration,
      runs: runs,
    ));
    cursor += duration;
  }

  return Timetable(items: items, endMinutes: cursor);
}

/// Une écriture à envoyer pour que FFSS corresponde à la cible.
class TimetableMove {
  const TimetableMove({
    required this.slotId,
    required this.beginMinutes,
    required this.endMinutes,
    this.runId,
  });

  final int slotId;

  /// Null pour le créneau lui-même, renseigné pour une de ses courses.
  final int? runId;
  final int beginMinutes;
  final int endMinutes;
}

/// Les seuls items dont l'horaire diffère entre ce que FFSS porte ([current])
/// et [target].
///
/// Ne rendre que ce qui bouge n'est pas une optimisation gratuite : sur une
/// journée de vingt items, supprimer le dernier ne doit pas réécrire les
/// dix-neuf d'avant. Un item de [target] absent de [current] est ignoré —
/// rien à déplacer sur un serveur qui ne l'a pas.
List<TimetableMove> moves(List<Slot> current, Timetable target) {
  final bySlotId = {for (final slot in current) slot.id: slot};
  final result = <TimetableMove>[];

  for (final item in target.items) {
    final slot = bySlotId[item.slotId];
    if (slot == null) continue;

    if (minutesOf(slot.beginHour) != item.beginMinutes ||
        minutesOf(slot.endHour) != item.endMinutes) {
      result.add(TimetableMove(
        slotId: item.slotId,
        beginMinutes: item.beginMinutes,
        endMinutes: item.endMinutes,
      ));
    }

    final byRunId = {for (final run in slot.runs) run.id: run};
    for (final run in item.runs) {
      final held = byRunId[run.runId];
      if (held == null) continue;
      // La fin compte autant que le début : un raccourcissement laisse le
      // début en place et doit tout de même partir.
      if (minutesOf(held.beginTime) != run.beginMinutes ||
          minutesOf(held.endTime) != run.endMinutes) {
        result.add(TimetableMove(
          slotId: item.slotId,
          runId: run.runId,
          beginMinutes: run.beginMinutes,
          endMinutes: run.endMinutes,
        ));
      }
    }
  }

  return result;
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/data/models/meeting_timetable_test.dart`
Expected: PASS — 12 tests.

- [ ] **Step 5 : commiter**

```bash
dart format lib/ test/
flutter analyze
git add lib/app/domain/models/meeting_timetable.dart test/data/models/meeting_timetable_test.dart
git commit -m "$(cat <<'EOF'
feat(domain): le calcul d'horaires d'une reunion, en fonctions pures

_resequenceDay calculait et ecrivait dans la meme boucle, ce qui la
rendait intestable et enfouissait le « n'envoyer que ce qui bouge » dans
un if. layOut et moves sortent ce calcul, testable sans un seul mock.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 5 : `MeetingService`

**Files:**
- Create: `lib/app/data/services/meeting_service.dart`
- Modify: `lib/app/core/di/initial_binding.dart` (après `MeetingRepository`, l. ~166)
- Modify: `CLAUDE.md` (section DI, étape 4b)
- Test: `test/data/services/meeting_service_test.dart`

**Interfaces:**
- Consumes: `MeetingRepository.getMeetings(int competitionId) → Future<List<Meeting>>`
- Produces:
  - `MeetingService(MeetingRepository repo)` — `extends GetxService`
  - `RxList<Meeting> meetings`, `RxBool isLoading`, `RxBool hasError`
  - `Future<bool> load(int competitionId, {bool silent = false})`
  - `Future<bool> reload({bool silent = false})`
  - `Meeting? byId(int id)`
  - `Set<int> placedPartieIds`

Pourquoi un service et non un contrôleur : **trois contrôleurs ont besoin du même arbre**, et l'éditeur doit connaître les parties déjà placées *dans les autres réunions*, sinon il proposerait deux fois le même tour. Le confier à un service évite un contrôleur qui injecte un contrôleur.

- [ ] **Step 1 : écrire les tests qui échouent**

Créer `test/data/services/meeting_service_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepo extends Mock implements MeetingRepository {}

void main() {
  late _MockMeetingRepo repo;
  late MeetingService service;

  setUp(() {
    repo = _MockMeetingRepo();
    service = MeetingService(repo);
  });

  RaceFormatDetail partie(int id) => RaceFormatDetail(
        id: id,
        order: 1,
        label: '',
        fullLabel: '',
        levelLabel: '',
        level: 'heat',
        numberOfRun: 1,
        qualificationMethod: 'none',
        qualificationMethodLabel: '',
        spotsPerRace: 8,
        qualifyingSpots: 0,
      );

  Meeting meeting(int id, {List<Slot> slots = const []}) => Meeting(
        id: id,
        name: 'R$id',
        description: 'Plage',
        date: DateTime(2026, 9, 12),
        beginHour: DateTime(2026, 9, 12, 8),
        endHour: DateTime(2026, 9, 12, 8),
        slots: slots,
      );

  Slot slot(int id, {RaceFormatDetail? detail}) => Slot(
        id: id,
        name: 's$id',
        beginHour: DateTime(1970, 1, 1, 8),
        endHour: DateTime(1970, 1, 1, 8, 10),
        raceFormatDetail: detail,
      );

  test('load fills meetings and lowers the loading flag', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);

    expect(await service.load(42), isTrue);

    expect(service.meetings.single.id, 1);
    expect(service.isLoading.value, isFalse);
    expect(service.hasError.value, isFalse);
  });

  test('a failure flips hasError and keeps the meetings already held',
      () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);
    await service.load(42);
    when(() => repo.getMeetings(42))
        .thenThrow(const ApiException('boom'));

    expect(await service.reload(), isFalse);

    // Une journée périmée mais réelle vaut mieux qu'une page blanche.
    expect(service.meetings.single.id, 1);
    expect(service.hasError.value, isTrue);
  });

  test('silent keeps isLoading down', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async {
      expect(service.isLoading.value, isFalse);
      return [meeting(1)];
    });

    await service.load(42, silent: true);
  });

  test('reload before any load does nothing', () async {
    expect(await service.reload(), isFalse);
    verifyNever(() => repo.getMeetings(any()));
  });

  test('switching competition clears the previous meetings first', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(1)]);
    await service.load(42);

    when(() => repo.getMeetings(43)).thenThrow(const ApiException('boom'));
    await service.load(43);

    // Sinon les réunions de la compétition 42 resteraient affichées sous la 43.
    expect(service.meetings, isEmpty);
  });

  test('byId finds a meeting, or nothing', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [meeting(7)]);
    await service.load(42);

    expect(service.byId(7)?.id, 7);
    expect(service.byId(8), isNull);
  });

  test('placedPartieIds spans every meeting and skips manual items', () async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => [
          meeting(1, slots: [slot(10, detail: partie(100)), slot(11)]),
          meeting(2, slots: [slot(12, detail: partie(200))]),
        ]);
    await service.load(42);

    expect(service.placedPartieIds, {100, 200});
  });
}
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/data/services/meeting_service_test.dart`
Expected: FAIL — `meeting_service.dart` n'existe pas.

- [ ] **Step 3 : implémenter le service**

Créer `lib/app/data/services/meeting_service.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

/// L'arbre réunion FFSS d'une compétition — `Réunion → Créneau → Course` —
/// et son unique propriétaire.
///
/// Un service et non un contrôleur parce que trois contrôleurs lisent le même
/// arbre : la liste, le formulaire et l'éditeur. Ce dernier doit en outre
/// connaître les parties déjà placées *dans les autres réunions*, sinon il
/// proposerait deux fois le même tour.
class MeetingService extends GetxService {
  MeetingService(this._repo);

  final MeetingRepository _repo;

  final RxList<Meeting> meetings = <Meeting>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  int? _competitionId;

  /// Rend si [meetings] reflète bien FFSS. Un appelant qui enchaîne sur une
  /// écriture dérivée de la liste doit le savoir : calculer une fin de réunion
  /// depuis une liste que le rechargement n'a pas pu rafraîchir pousserait une
  /// `fin` d'avant l'écriture, et la signalerait comme un succès.
  ///
  /// Un échec lève [hasError] plutôt qu'un message one-shot : un opérateur qui
  /// ne voit pas pourquoi sa journée est vide a besoin d'un état que la vue
  /// continue de rendre, pas d'un toast déjà disparu. [meetings] est laissée
  /// en place — une journée périmée mais réelle vaut mieux qu'une page blanche.
  ///
  /// [silent] garde [isLoading] baissé pour qu'un tiré-pour-rafraîchir ne
  /// remplace pas la liste par un spinner sous le doigt de l'opérateur.
  Future<bool> load(int competitionId, {bool silent = false}) async {
    // Changer de compétition vide d'abord : les réunions de la précédente
    // s'afficheraient sous la nouvelle si le chargement échouait.
    if (_competitionId != competitionId) meetings.clear();
    _competitionId = competitionId;
    try {
      if (!silent) isLoading.value = true;
      hasError.value = false;
      meetings.value = await _repo.getMeetings(competitionId);
      return true;
    } on AppException {
      hasError.value = true;
      return false;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Recharge la compétition déjà chargée. Sans appel préalable à [load], il
  /// n'y a aucune compétition à recharger.
  Future<bool> reload({bool silent = false}) async {
    final id = _competitionId;
    if (id == null) return false;
    return load(id, silent: silent);
  }

  Meeting? byId(int id) {
    for (final meeting in meetings) {
      if (meeting.id == id) return meeting;
    }
    return null;
  }

  /// Les parties qu'un créneau porte déjà, toutes réunions confondues. Un
  /// créneau sans partie est un item manuel et n'en place aucune.
  Set<int> get placedPartieIds => {
        for (final meeting in meetings)
          for (final slot in meeting.slots)
            if (slot.raceFormatDetail != null) slot.raceFormatDetail!.id,
      };
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/data/services/meeting_service_test.dart`
Expected: PASS — 7 tests.

- [ ] **Step 5 : enregistrer dans `InitialBinding`**

Dans `lib/app/core/di/initial_binding.dart`, **immédiatement après** le `Get.put<MeetingRepository>(...)` :

```dart
    Get.put<MeetingService>(
      MeetingService(Get.find<MeetingRepository>()),
      permanent: true,
    );
```

Pas de `putAsync` : le service ne lit aucun stockage à la construction, contrairement à `ProgrammeService`. Ajouter l'import.

- [ ] **Step 6 : documenter dans `CLAUDE.md`**

Section « DI registration order in `InitialBinding` », étape 4 — ajouter juste après :

```markdown
4b. `MeetingService` — propriétaire de l'arbre réunion FFSS, partagé par les
    trois contrôleurs du module programme. Synchrone (`Get.put`) : il ne lit
    aucun stockage à la construction.
```

Et dans la liste des services de la section « Data + domain layers », mentionner `MeetingService` à côté de `ProgrammeService`.

- [ ] **Step 7 : lancer toute la suite et commiter**

Run: `flutter test` puis `flutter analyze`
Expected: PASS

```bash
dart format lib/ test/
git add lib/app/data/services/meeting_service.dart lib/app/core/di/initial_binding.dart CLAUDE.md test/data/services/meeting_service_test.dart
git commit -m "$(cat <<'EOF'
feat(data): MeetingService, proprietaire de l'arbre reunion

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 6 : `meetingItems` remplace `daySections`

**Files:**
- Modify: `lib/app/presentation/modules/programme/day_sections.dart`
- Test: `test/presentation/modules/programme/day_sections_test.dart` (créer si absent — vérifier d'abord)

**Interfaces:**
- Consumes: `Meeting`, `Slot`, `Run`
- Produces:
  - `class DayEntry { DateTime begin; DateTime end; String label; int? slotId; int? runId; }` — **inchangée**
  - `class MeetingItem { int slotId; String label; DateTime begin; DateTime end; List<DayEntry> courses; }`
  - `List<MeetingItem> meetingItems(Meeting? meeting)` — **pas** `meetingEntries`

`DaySection` et `daySections` disparaissent : le regroupement par site n'a plus d'objet, une réunion n'en a qu'un. Ce qui les remplace est une liste **ordonnée de créneaux**, chacun portant ses courses — parce que l'unité qui se déplace est le créneau, pas la course.

- [ ] **Step 1 : écrire les tests qui échouent**

Créer `test/presentation/modules/programme/day_sections_test.dart` (ou remplacer le contenu s'il existe) :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';

DateTime hm(int h, int m) => DateTime(1970, 1, 1, h, m);

Run run(int id, String label, int bh, int bm, int eh, int em) => Run(
      id: id,
      name: 'c$id',
      label: label,
      fullLabel: label,
      status: RunStatus.waiting,
      statusLabel: '',
      site: 'Plage',
      beginTime: hm(bh, bm),
      endTime: hm(eh, em),
    );

Slot slot(int id, String name, int bh, int bm, int eh, int em,
        {List<Run> runs = const []}) =>
    Slot(
      id: id,
      name: name,
      beginHour: hm(bh, bm),
      endHour: hm(eh, em),
      runs: runs,
    );

Meeting meeting(List<Slot> slots) => Meeting(
      id: 1,
      name: 'Matin',
      description: 'Plage',
      date: DateTime(2026, 9, 12),
      beginHour: DateTime(2026, 9, 12, 8),
      endHour: DateTime(2026, 9, 12, 9),
      slots: slots,
    );

void main() {
  test('a null réunion has no item', () {
    expect(meetingItems(null), isEmpty);
  });

  test('a manual créneau is one item with no course', () {
    final items = meetingItems(meeting([slot(1, 'Accueil', 8, 0, 8, 10)]));

    expect(items.single.slotId, 1);
    expect(items.single.label, 'Accueil');
    expect(items.single.courses, isEmpty);
  });

  test('a round créneau carries its courses in running order', () {
    final items = meetingItems(meeting([
      slot(1, 'Séries', 8, 0, 8, 20, runs: [
        run(12, 'Série 2', 8, 10, 8, 20),
        run(11, 'Série 1', 8, 0, 8, 10),
      ]),
    ]));

    expect(items.single.courses.map((c) => c.runId), [11, 12]);
    expect(items.single.courses.first.label, 'Série 1');
  });

  test('items are ordered by their own start', () {
    final items = meetingItems(meeting([
      slot(2, 'Pause', 10, 0, 10, 30),
      slot(1, 'Accueil', 8, 0, 8, 10),
    ]));

    expect(items.map((i) => i.slotId), [1, 2]);
  });

  test('a course entry carries its own times, not its créneau\'s', () {
    final items = meetingItems(meeting([
      slot(1, 'Séries', 8, 0, 9, 0, runs: [run(11, 'Série 1', 8, 0, 8, 10)]),
    ]));

    expect(items.single.courses.single.begin, hm(8, 0));
    expect(items.single.courses.single.end, hm(8, 10));
  });
}
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/day_sections_test.dart`
Expected: FAIL — `meetingItems` non défini.

- [ ] **Step 3 : réécrire `day_sections.dart`**

Remplacer intégralement le contenu de `lib/app/presentation/modules/programme/day_sections.dart` par :

```dart
import 'package:live_ffss/app/domain/models/meeting.dart';

/// Une course d'un créneau, telle que l'éditeur l'affiche.
class DayEntry {
  const DayEntry({
    required this.begin,
    required this.end,
    required this.label,
    this.slotId,
    this.runId,
  });

  final DateTime begin;
  final DateTime end;
  final String label;

  /// Le créneau qui porte cette ligne.
  final int? slotId;

  /// La course qui porte cette ligne.
  final int? runId;
}

/// Un item de la réunion : un créneau, avec ses courses s'il en porte.
///
/// Le créneau est l'unité, pas la course : c'est lui que FFSS positionne dans
/// la journée — il ne porte aucun rang, son heure de début EST sa place — et
/// ses courses le suivent.
class MeetingItem {
  const MeetingItem({
    required this.slotId,
    required this.label,
    required this.begin,
    required this.end,
    required this.courses,
  });

  final int slotId;
  final String label;
  final DateTime begin;
  final DateTime end;

  /// Les courses du créneau, en ordre de passage. Vide pour un item manuel.
  final List<DayEntry> courses;

  bool get isManual => courses.isEmpty;
}

/// Les items d'une réunion, ordonnés par leur heure de début.
List<MeetingItem> meetingItems(Meeting? meeting) {
  if (meeting == null) return const [];

  final items = <MeetingItem>[];
  for (final slot in meeting.slots) {
    final ordered = [...slot.runs]
      ..sort((a, b) => a.beginTime.compareTo(b.beginTime));
    items.add(MeetingItem(
      slotId: slot.id,
      label: slot.name,
      begin: slot.beginHour,
      end: slot.endHour,
      courses: [
        for (final run in ordered)
          DayEntry(
            begin: run.beginTime,
            end: run.endTime,
            label: run.fullLabel,
            slotId: slot.id,
            runId: run.id,
          ),
      ],
    ));
  }
  items.sort((a, b) => a.begin.compareTo(b.begin));
  return items;
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/presentation/modules/programme/day_sections_test.dart`
Expected: PASS — 5 tests.

`flutter analyze` signalera que `schedule_view.dart` appelle `daySections` : c'est attendu, la Task 12 le supprime. **Ne pas y toucher ici** ; enchaîner sur le commit et accepter cette erreur transitoire jusqu'à la Task 11.

- [ ] **Step 5 : commiter**

```bash
dart format lib/ test/
git add lib/app/presentation/modules/programme/day_sections.dart test/presentation/modules/programme/day_sections_test.dart
git commit -m "$(cat <<'EOF'
refactor(programme): les items d'une reunion remplacent les sections par site

Une reunion ne porte qu'un site : le regroupement par site n'a plus
d'objet. L'unite devient le creneau, qui porte ses courses.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 7 : `MeetingListController`

**Files:**
- Create: `lib/app/module/programme/controllers/meeting_list_controller.dart`
- Test: `test/presentation/modules/programme/controllers/meeting_list_controller_test.dart`

**Interfaces:**
- Consumes: `MeetingService` (Task 5), `MeetingRepository.deleteMeeting` (Task 1), `ProgrammeService`, `UserService`, `competitionDays`, `sameDay`, `MeetingSite.site` (Task 3)
- Produces:
  - `MeetingListController(MeetingService, MeetingRepository, ProgrammeService, UserService)`
  - `Rxn<Competition> competition`, `RxList<DateTime> days`, `Rxn<UiMessage> message`, `RxBool isDeleting`
  - `Future<void> setCompetition(Competition? comp)`
  - `List<Meeting> meetingsOn(DateTime day)`
  - `int get unscheduledRoundCount`
  - `List<ProgrammeSite> get sites`
  - `bool get canWriteToFfss`
  - `Future<void> deleteMeeting(int meetingId)`
  - `Future<void> refresh()` — recharge en silencieux, pour le `RefreshIndicator`

- [ ] **Step 1 : écrire les tests qui échouent**

Créer `test/presentation/modules/programme/controllers/meeting_list_controller_test.dart`.

**Avant d'écrire**, ouvrir `test/presentation/modules/programme/controllers/schedule_controller_test.dart` et **reprendre tels quels** son `_MockStorage`, sa constante `competition`, son `loggedInUser` et sa façon de construire un `UserService` avec un `_MockAuthRepo` : ce harnais est déjà accordé au projet, le réinventer coûterait des heures.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_list_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

// … mocks et fixtures reprises de schedule_controller_test.dart …

void main() {
  // competition : id 42, beginDate 2026-09-12, endDate 2026-09-13.
  // Reprendre la constante `competition` du fichier existant et la
  // copyWith-er avec ces deux dates.

  Meeting meeting(int id, DateTime date, {String description = 'Plage'}) =>
      Meeting(
        id: id,
        name: 'R$id',
        description: description,
        date: date,
        beginHour: DateTime(date.year, date.month, date.day, 8),
        endHour: DateTime(date.year, date.month, date.day, 11),
      );

  test('setCompetition derives the competition days', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    await controller.setCompetition(comp);

    expect(controller.days.length, 2);
    expect(controller.days.first, DateTime(2026, 9, 12));
  });

  test('meetingsOn returns every meeting of that day, earliest first',
      () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => [
          meeting(2, DateTime(2026, 9, 12)).copyWith(
              beginHour: DateTime(2026, 9, 12, 14)),
          meeting(1, DateTime(2026, 9, 12)),
          meeting(3, DateTime(2026, 9, 13)),
        ]);
    await controller.setCompetition(comp);

    final saturday = controller.meetingsOn(DateTime(2026, 9, 12));

    expect(saturday.map((m) => m.id), [1, 2]);
  });

  test('a day with no meeting returns an empty list', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);

    expect(controller.meetingsOn(DateTime(2026, 9, 13)), isEmpty);
  });

  test('unscheduledRoundCount ignores rounds with no serverId', () async {
    // Un tour sans serverId ne peut porter aucun créneau côté FFSS :
    // l'annoncer ne vaudrait à l'opérateur qu'un refus qu'il ne peut pas
    // corriger depuis cet écran.
    await programme.save(CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: const [
            RoundLevel(type: RoundType.serie, serverId: 100),
            RoundLevel(type: RoundType.finale, serverId: 0),
          ],
        ),
      ],
    ));
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);
    await controller.setCompetition(comp);

    expect(controller.unscheduledRoundCount, 1);
  });

  test('deleteMeeting reloads the tree on success', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1)).thenAnswer((_) async => true);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    await controller.deleteMeeting(1);

    expect(meetings.meetings, isEmpty);
    expect(controller.isDeleting.value, isFalse);
  });

  test('deleteMeeting reports a refusal and leaves the tree alone', () async {
    when(() => meetingRepo.getMeetings(42))
        .thenAnswer((_) async => [meeting(1, DateTime(2026, 9, 12))]);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1)).thenAnswer((_) async => false);

    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    expect(meetings.meetings.single.id, 1);
  });

  test('deleteMeeting reports an AppException with its detail', () async {
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);
    await controller.setCompetition(comp);
    when(() => meetingRepo.deleteMeeting(1))
        .thenThrow(const ApiException('Invalid token'));

    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    expect((controller.message.value! as UiMessageError).details,
        contains('Invalid token'));
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    // FFSS répondrait à une écriture anonyme par un « Invalid Token » nu qui
    // se lit comme une panne serveur.
    // … faire retourner null à userService.currentUser …
    await controller.deleteMeeting(1);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.deleteMeeting(any()));
  });
}
```

Compléter les `// …` en reprenant le harnais du fichier existant. **Chaque test listé doit exister et passer** — ne pas en sauter un parce que le harnais demande du travail.

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_list_controller_test.dart`
Expected: FAIL — `meeting_list_controller.dart` n'existe pas.

- [ ] **Step 3 : implémenter le contrôleur**

Créer `lib/app/module/programme/controllers/meeting_list_controller.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/utils/competition_days.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// L'onglet Programme : les réunions de la compétition, groupées par jour.
class MeetingListController extends GetxController {
  MeetingListController(
    this._meetings,
    this._repo,
    this._programme,
    this._user,
  );

  final MeetingService _meetings;
  final MeetingRepository _repo;
  final ProgrammeService _programme;
  final UserService _user;

  final Rxn<Competition> competition = Rxn<Competition>();

  /// Les jours de la compétition. Un groupement d'affichage, et la contrainte
  /// du sélecteur de date du formulaire — plus un appariement : une journée
  /// porte autant de réunions que l'opérateur en crée.
  final RxList<DateTime> days = <DateTime>[].obs;

  final RxBool isDeleting = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  RxBool get isLoading => _meetings.isLoading;
  RxBool get hasError => _meetings.hasError;
  RxList<Meeting> get meetings => _meetings.meetings;

  /// Tout ce que cet écran lit est public, donc un opérateur déconnecté entre
  /// sans friction — seule une écriture revient refusée.
  bool get canWriteToFfss => _user.currentUser.value != null;

  List<ProgrammeSite> get sites => _programme.current.value?.sites ?? const [];

  Future<void> setCompetition(Competition? comp) async {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = competitionDays(comp?.beginDate, comp?.endDate);
    if (comp != null) await _meetings.load(comp.id);
  }

  Future<void> refresh() => _meetings.reload(silent: true);

  /// Les réunions de [day], la plus matinale d'abord. Comparées par date
  /// civile : [Meeting.date] porte le vrai jour, ses créneaux non.
  List<Meeting> meetingsOn(DateTime day) {
    final held = [
      for (final meeting in meetings)
        if (sameDay(meeting.date, day)) meeting,
    ]..sort((a, b) => a.beginHour.compareTo(b.beginHour));
    return held;
  }

  /// Combien de tours restent à placer. Informatif : placer un tour demande
  /// une réunion cible, geste qui n'a de sens que dans l'éditeur.
  ///
  /// Un tour sans `serverId` ne compte pas — rien côté FFSS ne pourrait
  /// porter son créneau, et l'annoncer ne vaudrait à l'opérateur qu'un refus
  /// qu'il ne peut pas corriger d'ici.
  int get unscheduledRoundCount {
    final placed = _meetings.placedPartieIds;
    var count = 0;
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      for (final level in structure.levels) {
        if (level.serverId > 0 && !placed.contains(level.serverId)) count++;
      }
    }
    return count;
  }

  /// Supprime une réunion. Emporte ses créneaux et ses courses côté serveur :
  /// la vue demande confirmation avant d'arriver ici.
  Future<void> deleteMeeting(int meetingId) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    isDeleting.value = true;
    try {
      if (!await _repo.deleteMeeting(meetingId)) {
        message.trigger(const UiMessageError('meeting_delete_failed'));
        return;
      }
    } on AppException catch (e) {
      message.trigger(
          UiMessageError('meeting_delete_failed', details: e.detail));
      return;
    } finally {
      isDeleting.value = false;
    }
    await _meetings.reload();
  }
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_list_controller_test.dart`
Expected: PASS — 8 tests.

- [ ] **Step 5 : commiter**

```bash
dart format lib/ test/
git add lib/app/module/programme/controllers/meeting_list_controller.dart test/presentation/modules/programme/controllers/meeting_list_controller_test.dart
git commit -m "$(cat <<'EOF'
feat(programme): MeetingListController

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 8 : `MeetingFormController`

**Files:**
- Create: `lib/app/module/programme/controllers/meeting_form_controller.dart`
- Test: `test/presentation/modules/programme/controllers/meeting_form_controller_test.dart`

**Interfaces:**
- Consumes: `MeetingService`, `MeetingRepository.submitMeeting`/`submitSlot`/`submitRun`, `ProgrammeService`, `UserService`, `layOut`, `moves`, `minutesOf` (Task 4)
- Produces:
  - `MeetingFormController(MeetingService, MeetingRepository, ProgrammeService, UserService)`
  - `Rxn<Competition> competition`, `Rxn<Meeting> editing`, `RxList<DateTime> days`
  - `Rxn<DateTime> date`, `RxInt startMinutes`, `Rxn<String> site`, `RxBool isSaving`, `Rxn<UiMessage> message`
  - `bool get isEditing`, `bool get canWriteToFfss`, `List<ProgrammeSite> get sites`
  - `void applyArguments(Object? arg)` — attend `{'competition': Competition, 'meeting': Meeting?}`
  - `Future<bool> save(String title)` — `true` quand la vue peut se refermer

Un point d'API décisif : `submitSlot` et `submitRun` n'envoient que `HH:mm`, **jamais le jour**. Changer la date d'une réunion ne demande donc qu'un `reunion/submit`. Seul un changement d'**heure de début** décale ses items, via `moves`.

- [ ] **Step 1 : écrire les tests qui échouent**

Créer le fichier de test. Même consigne qu'à la Task 7 : reprendre le harnais de `schedule_controller_test.dart`.

```dart
void main() {
  // … harnais : storage, programme (ProgrammeService), meetingRepo,
  // userService (connecté), meetings (MeetingService), controller …

  const defaultStart = 8 * 60;

  test('a fresh form starts on the first competition day at 08:00', () {
    controller.applyArguments({'competition': comp, 'meeting': null});

    expect(controller.isEditing, isFalse);
    expect(controller.date.value, DateTime(2026, 9, 12));
    expect(controller.startMinutes.value, defaultStart);
    expect(controller.site.value, isNull);
  });

  test('editing seeds every field from the meeting, site included', () {
    final existing = meeting(1, DateTime(2026, 9, 13), description: 'Bassin')
        .copyWith(beginHour: DateTime(2026, 9, 13, 14, 30));

    controller.applyArguments({'competition': comp, 'meeting': existing});

    expect(controller.isEditing, isTrue);
    expect(controller.date.value, DateTime(2026, 9, 13));
    expect(controller.startMinutes.value, 14 * 60 + 30);
    expect(controller.site.value, 'Bassin');
  });

  test('creating sends the site as the description and ends at its start',
      () async {
    // Une réunion sans item ne « dure » pas : sa fin est son début.
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 7);
    when(() => meetingRepo.getMeetings(42)).thenAnswer((_) async => []);

    expect(await controller.save('Matin — Plage'), isTrue);

    final captured = verify(() => meetingRepo.submitMeeting(
          competitionId: 42,
          name: 'Matin — Plage',
          description: captureAny(named: 'description'),
          date: DateTime(2026, 9, 12),
          beginHour: captureAny(named: 'beginHour'),
          endHour: captureAny(named: 'endHour'),
          id: null,
        )).captured;
    expect(captured[0], 'Plage');
    expect(captured[1], DateTime(2026, 9, 12, 8));
    expect(captured[2], DateTime(2026, 9, 12, 8));
  });

  test('an empty title is refused without a single call', () async {
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';

    expect(await controller.save('   '), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.submitMeeting(
        competitionId: any(named: 'competitionId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        date: any(named: 'date'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        id: any(named: 'id')));
  });

  test('no site is refused — every course of the réunion inherits it',
      () async {
    controller.applyArguments({'competition': comp, 'meeting': null});

    expect(await controller.save('Matin'), isFalse);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    // … userService sans utilisateur …
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';

    expect(await controller.save('Matin'), isFalse);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('a refusal from FFSS is reported and the form stays open', () async {
    controller.applyArguments({'competition': comp, 'meeting': null});
    controller.site.value = 'Plage';
    when(() => meetingRepo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 0);

    expect(await controller.save('Matin'), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    expect(controller.isSaving.value, isFalse);
  });

  test('changing the date alone shifts no item', () async {
    // submitSlot et submitRun n'envoient que HH:mm, jamais le jour.
    final existing = meetingWithItems(); // créneau 8:00→8:10, course 8:00→8:10
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.date.value = DateTime(2026, 9, 13);
    // … stubber submitMeeting → 1, getMeetings → [existing] …

    expect(await controller.save('Matin'), isTrue);

    verifyNever(() => meetingRepo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('moving the start hour shifts every item by the same amount', () async {
    // Une réunion qui démarre à 09:00 pendant que son premier item dit encore
    // 08:00 énonce deux choses différentes sur la même matinée.
    final existing = meetingWithItems();
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.startMinutes.value = 9 * 60;
    // … stubs …

    expect(await controller.save('Matin'), isTrue);

    verify(() => meetingRepo.submitSlot(
          meetingId: 1,
          name: any(named: 'name'),
          beginHour: DateTime(2026, 9, 12, 9),
          endHour: DateTime(2026, 9, 12, 9, 10),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: 10,
        )).called(1);
    verify(() => meetingRepo.submitRun(
          slotId: 10,
          name: any(named: 'name'),
          beginHour: DateTime(2026, 9, 12, 9),
          endHour: DateTime(2026, 9, 12, 9, 10),
          site: any(named: 'site'),
          id: 11,
        )).called(1);
  });

  test('a refused item stops the move rather than half-shifting the day',
      () async {
    final existing = meetingWithItems();
    controller.applyArguments({'competition': comp, 'meeting': existing});
    controller.startMinutes.value = 9 * 60;
    // … submitSlot → 0 …

    expect(await controller.save('Matin'), isFalse);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => meetingRepo.submitRun(
        slotId: any(named: 'slotId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        site: any(named: 'site'),
        id: any(named: 'id')));
  });
}
```

- [ ] **Step 2 : lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_form_controller_test.dart`
Expected: FAIL — fichier absent.

- [ ] **Step 3 : implémenter le contrôleur**

Créer `lib/app/module/programme/controllers/meeting_form_controller.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/utils/competition_days.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Une réunion sans item démarre à 08:00 — le défaut de la réunion FFSS.
const int defaultMeetingStartMinutes = 8 * 60;

/// Créer ou éditer une réunion : titre, date, heure de début, site.
class MeetingFormController extends GetxController {
  MeetingFormController(
    this._meetings,
    this._repo,
    this._programme,
    this._user,
  );

  final MeetingService _meetings;
  final MeetingRepository _repo;
  final ProgrammeService _programme;
  final UserService _user;

  final Rxn<Competition> competition = Rxn<Competition>();

  /// La réunion éditée, null en création.
  final Rxn<Meeting> editing = Rxn<Meeting>();

  final RxList<DateTime> days = <DateTime>[].obs;
  final Rxn<DateTime> date = Rxn<DateTime>();
  final RxInt startMinutes = defaultMeetingStartMinutes.obs;
  final Rxn<String> site = Rxn<String>();
  final RxBool isSaving = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  bool get isEditing => editing.value != null;
  bool get canWriteToFfss => _user.currentUser.value != null;
  List<ProgrammeSite> get sites => _programme.current.value?.sites ?? const [];

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is! Map) return;
    final comp = arg['competition'];
    if (comp is Competition) {
      competition.value = comp;
      days.value = competitionDays(comp.beginDate, comp.endDate);
    }
    final existing = arg['meeting'];
    if (existing is Meeting) {
      editing.value = existing;
      date.value = DateTime(
          existing.date.year, existing.date.month, existing.date.day);
      startMinutes.value = minutesOf(existing.beginHour);
      site.value = existing.site.isEmpty ? null : existing.site;
      return;
    }
    date.value = days.isEmpty ? null : days.first;
  }

  /// Enregistre la réunion. Rend `true` quand la vue peut se refermer.
  ///
  /// [title] vient de la vue : le champ de saisie appartient à un
  /// `StatefulWidget`, pas au contrôleur.
  Future<bool> save(String title) async {
    final trimmed = title.trim();
    final competitionId = competition.value?.id;
    final day = date.value;
    final chosenSite = site.value;

    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return false;
    }
    if (trimmed.isEmpty) {
      message.trigger(const UiMessageError('meeting_title_required'));
      return false;
    }
    if (competitionId == null || day == null) {
      message.trigger(const UiMessageError('no_days'));
      return false;
    }
    // Le site n'est pas décoratif : toutes les courses de la réunion en
    // héritent, et une course sans site atterrit dans une colonne sans nom.
    if (chosenSite == null || chosenSite.isEmpty) {
      message.trigger(const UiMessageError('meeting_site_required'));
      return false;
    }

    isSaving.value = true;
    try {
      return await _push(
        competitionId: competitionId,
        title: trimmed,
        day: day,
        site: chosenSite,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> _push({
    required int competitionId,
    required String title,
    required DateTime day,
    required String site,
  }) async {
    final existing = editing.value;
    final slots = existing?.slots ?? const [];
    // Les items partent d'abord et la réunion en dernier : un créneau refusé
    // laisse la journée où elle était plutôt qu'à moitié déplacée.
    //
    // Seule l'heure de début décale quoi que ce soit. Changer la date n'en
    // décale aucun : submitSlot et submitRun n'envoient que `HH:mm`, jamais
    // le jour.
    final target = layOut(slots.toList(), startMinutes.value);
    final shifted = existing == null
        ? const <TimetableMove>[]
        : moves(slots.toList(), target);

    try {
      for (final move in shifted) {
        if (!await _applyMove(existing!, move, day)) {
          message.trigger(const UiMessageError('schedule_item_failed'));
          return false;
        }
      }

      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: title,
        description: site,
        date: day,
        beginHour: _atMinutes(day, startMinutes.value),
        endHour: _atMinutes(day, target.endMinutes),
        id: existing?.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('meeting_save_failed'));
        return false;
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('meeting_save_failed', details: e.detail));
      return false;
    }

    await _meetings.reload();
    return true;
  }

  Future<bool> _applyMove(
      Meeting meeting, TimetableMove move, DateTime day) async {
    final slot = meeting.slots.firstWhere((s) => s.id == move.slotId);
    if (move.runId == null) {
      final id = await _repo.submitSlot(
        meetingId: meeting.id,
        name: slot.name,
        beginHour: _atMinutes(day, move.beginMinutes),
        endHour: _atMinutes(day, move.endMinutes),
        raceFormatDetailId: slot.raceFormatDetail?.id,
        id: slot.id,
      );
      return id > 0;
    }
    final run = slot.runs.firstWhere((r) => r.id == move.runId);
    final id = await _repo.submitRun(
      slotId: slot.id,
      name: run.name,
      beginHour: _atMinutes(day, move.beginMinutes),
      endHour: _atMinutes(day, move.endMinutes),
      site: run.site,
      id: run.id,
    );
    return id > 0;
  }

  /// Minutes depuis minuit → un vrai [DateTime] sur [day] : les écritures FFSS
  /// veulent une heure qui porte une date.
  DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
}
```

- [ ] **Step 4 : lancer et vérifier le passage**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_form_controller_test.dart`
Expected: PASS — 10 tests.

- [ ] **Step 5 : commiter**

```bash
dart format lib/ test/
flutter analyze
git add lib/app/module/programme/controllers/meeting_form_controller.dart test/presentation/modules/programme/controllers/meeting_form_controller_test.dart
git commit -m "$(cat <<'EOF'
feat(programme): MeetingFormController, creation et edition d'une reunion

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 9 : `MeetingEditorController`

**Files:**
- Create: `lib/app/module/programme/controllers/meeting_editor_controller.dart`
- Modify: `lib/app/data/services/meeting_service.dart` (+ `competitionId`)
- Test: `test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart`, `test/data/services/meeting_service_test.dart`

**Interfaces:**
- Consumes: `MeetingService` (Task 5), `MeetingRepository`, `ProgrammeService`, `UserService`, `layOut`/`moves`/`minutesOf`/`TimetableMove` (Task 4), `meetingItems`/`MeetingItem` (Task 6), `MeetingSite.site` (Task 3)
- Produces:
  - `MeetingService.competitionId → int?`
  - `class UnscheduledRound` — déplacée telle quelle depuis `schedule_controller.dart` : `partieId`, `raceId`, `categoryId`, `raceLabel`, `categoryLabel`, `type`, `courseCount`, `spotsPerRace`
  - `const int defaultItemMinutes = 10`
  - `MeetingEditorController(MeetingService, MeetingRepository, ProgrammeService, UserService)`
  - `RxInt meetingId`, `RxBool isBusy`, `Rxn<UiMessage> message`
  - `Meeting? get meeting`, `List<MeetingItem> get items`, `List<UnscheduledRound> get unscheduledRounds`, `bool get canWriteToFfss`, `String get site`
  - `void applyArguments(Object? arg)` — attend `{'meetingId': int}`
  - `Future<void> addManualItem(String label)`
  - `Future<void> scheduleRound({required int partieId, required String name, required List<String> courseNames, required int spotsPerRace})`
  - `Future<void> setSlotDuration(int slotId, int minutes)`
  - `Future<void> setRunDuration(int runId, int minutes)`
  - `Future<void> reorderItems(int oldIndex, int newIndex)`
  - `Future<void> removeSlot(int slotId)`
  - `Future<void> removeRun(int runId)`

**Avant d'écrire, lire `lib/app/module/programme/controllers/schedule_controller.dart` en entier.** Ses commentaires enregistrent des contraintes serveur qu'il ne faut pas reperdre : le `runId` d'un heat enregistré position par position plutôt que re-dérivé, une course refusée qui laisse son heat à 0 au lieu de lui donner la suivante, un créneau vidé de ses courses qui n'est pas anodin.

- [ ] **Step 1 : ajouter `competitionId` au service, en TDD**

`submitMeeting` exige un `competitionId` que le modèle `Meeting` ne porte pas. Ne pas inventer de champ sur le modèle : prendre celui que le service a déjà mémorisé.

Test, dans `test/data/services/meeting_service_test.dart` :

```dart
  test('competitionId remembers the loaded competition', () async {
    expect(service.competitionId, isNull);
    when(() => repo.getMeetings(42)).thenAnswer((_) async => []);

    await service.load(42);

    expect(service.competitionId, 42);
  });
```

Run: `flutter test test/data/services/meeting_service_test.dart` → FAIL (`competitionId` non défini).

Implémentation, dans `MeetingService`, sous `int? _competitionId;` :

```dart
  /// La compétition chargée. Exposée pour les écritures qui l'exigent sans
  /// que le modèle `Meeting` la porte — `reunion/submit` en tête.
  int? get competitionId => _competitionId;
```

Run: PASS.

- [ ] **Step 2 : écrire le harnais et les tests qui échouent**

Créer `test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart` :

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/user.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_editor_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockMeetingRepo extends Mock implements MeetingRepository {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockStorage storage;
  late _MockMeetingRepo repo;
  late ProgrammeService programme;
  late MeetingService meetings;
  late UserService user;
  late MeetingEditorController controller;

  final loggedIn = User(
    token: 'tok',
    tokenExpiration: DateTime(2030),
    label: 'FFSS',
    type: UserType.organisme,
    role: UserRole.admin,
  );

  final day = DateTime(2026, 9, 12);

  DateTime hm(int h, int m) => DateTime(1970, 1, 1, h, m);
  DateTime onDay(int h, int m) => DateTime(2026, 9, 12, h, m);

  Run run(int id, String name, int bh, int bm, int eh, int em,
          {String site = 'Plage'}) =>
      Run(
        id: id,
        name: name,
        label: name,
        fullLabel: name,
        status: RunStatus.waiting,
        statusLabel: '',
        site: site,
        beginTime: hm(bh, bm),
        endTime: hm(eh, em),
      );

  RaceFormatDetail partie(int id) => RaceFormatDetail(
        id: id,
        order: 1,
        label: '',
        fullLabel: '',
        levelLabel: '',
        level: 'heat',
        numberOfRun: 1,
        qualificationMethod: 'none',
        qualificationMethodLabel: '',
        spotsPerRace: 8,
        qualifyingSpots: 0,
      );

  Slot slot(int id, String name, int bh, int bm, int eh, int em,
          {List<Run> runs = const [], RaceFormatDetail? detail}) =>
      Slot(
        id: id,
        name: name,
        beginHour: hm(bh, bm),
        endHour: hm(eh, em),
        raceFormatDetail: detail,
        runs: runs,
      );

  Meeting meeting({List<Slot> slots = const [], int startHour = 8}) => Meeting(
        id: 1,
        name: 'Matin',
        description: 'Plage',
        date: day,
        beginHour: DateTime(2026, 9, 12, startHour),
        endHour: DateTime(2026, 9, 12, startHour),
        slots: slots,
      );

  /// Charge [tree] dans le service et pointe le contrôleur sur la réunion 1.
  Future<void> seed(List<Meeting> tree) async {
    when(() => repo.getMeetings(42)).thenAnswer((_) async => tree);
    await meetings.load(42);
    controller.applyArguments({'meetingId': 1});
  }

  /// Stubbe tout ce qu'une écriture peut appeler, avec des succès.
  void stubWritesOk() {
    when(() => repo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 10);
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 11);
    when(() => repo.submitMeeting(
          competitionId: any(named: 'competitionId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          date: any(named: 'date'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => 1);
    when(() => repo.createDefaultLanes(
          runId: any(named: 'runId'),
          count: any(named: 'count'),
        )).thenAnswer((_) async => 8);
    when(() => repo.deleteRun(any())).thenAnswer((_) async => true);
    when(() => repo.deleteSlot(any())).thenAnswer((_) async => true);
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue('');
  });

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    repo = _MockMeetingRepo();

    programme = ProgrammeService(storage);
    await programme.load(42);

    final auth = _MockAuthRepo();
    when(() => auth.userStream).thenAnswer((_) => const Stream.empty());
    when(() => auth.getStoredUser()).thenAnswer((_) async => loggedIn);
    user = UserService(auth);
    await user.init();

    meetings = MeetingService(repo);
    controller = MeetingEditorController(meetings, repo, programme, user);
  });
```

Reprendre de `schedule_controller_test.dart` la forme exacte de la construction de `UserService` (nom de la méthode d'init, stubs d'`AuthRepository`) : celle esquissée ici est indicative, celle du fichier existant est celle qui compile.

Les tests, tous obligatoires :

```dart
  test('items come from the meeting the arguments named', () async {
    await seed([
      meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)]),
      Meeting(
        id: 2,
        name: 'Après-midi',
        description: 'Bassin',
        date: day,
        beginHour: onDay(14, 0),
        endHour: onDay(14, 0),
        slots: [slot(20, 'Autre', 14, 0, 14, 10)],
      ),
    ]);

    expect(controller.items.single.slotId, 10);
    expect(controller.site, 'Plage');
  });

  test('addManualItem lands at the end of the réunion for 10 minutes',
      () async {
    await seed([meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)])]);
    stubWritesOk();

    await controller.addManualItem('Pause');

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 10),
          endHour: onDay(8, 20),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('the first item of an empty réunion starts at its own start', () async {
    await seed([meeting(startHour: 9)]);
    stubWritesOk();

    await controller.addManualItem('Accueil');

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Accueil',
          beginHour: onDay(9, 0),
          endHour: onDay(9, 10),
          raceFormatDetailId: null,
          id: null,
        )).called(1);
  });

  test('addManualItem pushes the new end of réunion', () async {
    // La liste rechargée porte l'item qui vient d'atterrir : la fin poussée
    // doit être calculée sur elle, pas sur celle d'avant l'écriture.
    when(() => repo.getMeetings(42)).thenAnswer((_) async =>
        [meeting(slots: [slot(10, 'Pause', 8, 0, 8, 10)])]);
    await meetings.load(42);
    controller.applyArguments({'meetingId': 1});
    stubWritesOk();

    await controller.addManualItem('Pause');

    verify(() => repo.submitMeeting(
          competitionId: 42,
          name: 'Matin',
          description: 'Plage',
          date: day,
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          id: 1,
        )).called(1);
  });

  test('a signed-out operator is refused before anything leaves the device',
      () async {
    // FFSS répondrait à une écriture anonyme par un « Invalid Token » nu qui
    // se lit comme une panne serveur.
    await seed([meeting()]);
    user.currentUser.value = null;

    await controller.addManualItem('Pause');

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('scheduleRound creates one course per name, back to back', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries - Surfski - Dames - Junior',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 8,
    );

    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 1',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          site: 'Plage',
          id: null,
        )).called(1);
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 2',
          beginHour: onDay(8, 10),
          endHour: onDay(8, 20),
          site: 'Plage',
          id: null,
        )).called(1);
  });

  test('the créneau lasts one slot per course', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 8,
    );

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Séries',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 20),
          raceFormatDetailId: 100,
          id: null,
        )).called(1);
  });

  test('a round with no course still gets a non-zero créneau', () async {
    // Un créneau de longueur nulle serait invisible sur la frise et
    // laisserait l'item suivant démarrer à la même minute.
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const [],
      spotsPerRace: 0,
    );

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Séries',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          raceFormatDetailId: 100,
          id: null,
        )).called(1);
  });

  test('scheduleRound opens each course with spotsPerRace free spots',
      () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1'],
      spotsPerRace: 8,
    );

    verify(() => repo.createDefaultLanes(runId: 11, count: 8)).called(1);
  });

  test('spotsPerRace 0 creates no spot at all', () async {
    await seed([meeting()]);
    stubWritesOk();

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1'],
      spotsPerRace: 0,
    );

    verifyNever(() => repo.createDefaultLanes(
        runId: any(named: 'runId'), count: any(named: 'count')));
  });

  test('each heat records the course it runs as, position by position',
      () async {
    // Enregistré et non re-dérivé : supprimer une course décalerait
    // silencieusement chaque heat suivant sur un départ qui n'est pas le sien.
    await programme.save(CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: const [
            RoundLevel(type: RoundType.serie, serverId: 100, races: [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ]),
          ],
        ),
      ],
    ));
    await seed([meeting()]);
    stubWritesOk();
    var runId = 100;
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => ++runId);

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 0,
    );

    final races =
        programme.current.value!.structures.single.levels.single.races;
    expect(races[0].runId, 101);
    expect(races[1].runId, 102);
  });

  test('a refused course leaves its heat runId at 0 and the rest lands',
      () async {
    // Une demi-manche sur le site est mauvaise ; une demi-manche que
    // l'opérateur croit complète est pire.
    await programme.save(CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: const [
            RoundLevel(type: RoundType.serie, serverId: 100, races: [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ]),
          ],
        ),
      ],
    ));
    await seed([meeting()]);
    stubWritesOk();
    final answers = <int>[0, 102];
    var call = 0;
    when(() => repo.submitRun(
          slotId: any(named: 'slotId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          site: any(named: 'site'),
          id: any(named: 'id'),
        )).thenAnswer((_) async => answers[call++]);

    await controller.scheduleRound(
      partieId: 100,
      name: 'Séries',
      courseNames: const ['Série 1', 'Série 2'],
      spotsPerRace: 0,
    );

    final races =
        programme.current.value!.structures.single.levels.single.races;
    expect(races[0].runId, 0);
    expect(races[1].runId, 102);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('unscheduledRounds skips a round already placed in ANOTHER meeting',
      () async {
    // C'est la raison d'être de MeetingService.placedPartieIds : sans elle,
    // le même tour serait proposé deux fois.
    await programme.save(CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: const [
            RoundLevel(type: RoundType.serie, serverId: 100),
            RoundLevel(type: RoundType.finale, serverId: 200),
          ],
        ),
      ],
    ));
    await seed([
      meeting(),
      Meeting(
        id: 2,
        name: 'Après-midi',
        description: 'Bassin',
        date: day,
        beginHour: onDay(14, 0),
        endHour: onDay(14, 0),
        slots: [slot(20, 'Séries', 14, 0, 14, 10, detail: partie(100))],
      ),
    ]);

    expect(controller.unscheduledRounds.map((r) => r.partieId), [200]);
  });

  test('unscheduledRounds skips a round with no serverId', () async {
    await programme.save(CompetitionProgramme(
      competitionId: 42,
      structures: [
        EventStructure(
          raceId: 1,
          categoryId: 2,
          raceLabel: 'Surfski',
          categoryLabel: 'Junior',
          levels: const [RoundLevel(type: RoundType.serie, serverId: 0)],
        ),
      ],
    ));
    await seed([meeting()]);

    expect(controller.unscheduledRounds, isEmpty);
  });

  test('setRunDuration repacks the réunion, not just its end', () async {
    // Une course plus longue chevauche la suivante, une plus courte laisse un
    // trou — et son créneau doit suivre dans les deux cas.
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 20, detail: partie(100), runs: [
          run(11, 'Série 1', 8, 0, 8, 10),
          run(12, 'Série 2', 8, 10, 8, 20),
        ]),
      ]),
    ]);
    stubWritesOk();

    await controller.setRunDuration(11, 20);

    // La course 11 s'allonge…
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 1',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 20),
          site: 'Plage',
          id: 11,
        )).called(1);
    // …et la 12 est repoussée d'autant.
    verify(() => repo.submitRun(
          slotId: 10,
          name: 'Série 2',
          beginHour: onDay(8, 20),
          endHour: onDay(8, 30),
          site: 'Plage',
          id: 12,
        )).called(1);
  });

  test('setSlotDuration repacks the réunion', () async {
    await seed([
      meeting(slots: [
        slot(10, 'Accueil', 8, 0, 8, 10),
        slot(20, 'Pause', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();

    await controller.setSlotDuration(10, 30);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 30),
          endHour: onDay(8, 40),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
  });

  test('a duration below one minute is refused', () async {
    await seed([meeting(slots: [slot(10, 'Accueil', 8, 0, 8, 10)])]);

    await controller.setSlotDuration(10, 0);
    await controller.setRunDuration(11, 0);

    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('reorderItems repacks from the réunion start in the new order',
      () async {
    // Un créneau ne porte aucun rang côté FFSS : ses nouvelles heures SONT
    // son nouveau rang.
    await seed([
      meeting(slots: [
        slot(10, 'Accueil', 8, 0, 8, 10),
        slot(20, 'Pause', 8, 10, 8, 40),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(1, 0);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Pause',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 30),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'Accueil',
          beginHour: onDay(8, 30),
          endHour: onDay(8, 40),
          raceFormatDetailId: null,
          id: 10,
        )).called(1);
  });

  test('a downward move accounts for the item leaving the list', () async {
    // Un déplacement vers le bas est rapporté contre la liste AVANT le
    // retrait, donc l'index cible est trop haut d'un cran.
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(0, 2);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'B',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
  });

  test('a no-op reorder writes nothing', () async {
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();

    await controller.reorderItems(0, 1);

    verifyNever(() => repo.submitSlot(
        meetingId: any(named: 'meetingId'),
        name: any(named: 'name'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        raceFormatDetailId: any(named: 'raceFormatDetailId'),
        id: any(named: 'id')));
  });

  test('removeRun deletes its créneau when it was the last course', () async {
    // Un créneau vidé n'a plus de site propre : la frise le rangerait parmi
    // les items manuels, là où personne ne cherchera le tour qu'il vient de
    // vider.
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 10,
            detail: partie(100), runs: [run(11, 'Série 1', 8, 0, 8, 10)]),
      ]),
    ]);
    stubWritesOk();

    await controller.removeRun(11);

    verify(() => repo.deleteRun(11)).called(1);
    verify(() => repo.deleteSlot(10)).called(1);
  });

  test('removeRun keeps the créneau when other courses remain', () async {
    await seed([
      meeting(slots: [
        slot(10, 'Séries', 8, 0, 8, 20, detail: partie(100), runs: [
          run(11, 'Série 1', 8, 0, 8, 10),
          run(12, 'Série 2', 8, 10, 8, 20),
        ]),
      ]),
    ]);
    stubWritesOk();

    await controller.removeRun(11);

    verify(() => repo.deleteRun(11)).called(1);
    verifyNever(() => repo.deleteSlot(any()));
  });

  test('removeSlot repacks the réunion afterwards', () async {
    await seed([
      meeting(slots: [
        slot(10, 'A', 8, 0, 8, 10),
        slot(20, 'B', 8, 10, 8, 20),
      ]),
    ]);
    stubWritesOk();
    // Après la suppression, FFSS ne porte plus que B, resté à 8:10.
    when(() => repo.getMeetings(42)).thenAnswer(
        (_) async => [meeting(slots: [slot(20, 'B', 8, 10, 8, 20)])]);

    await controller.removeSlot(10);

    verify(() => repo.submitSlot(
          meetingId: 1,
          name: 'B',
          beginHour: onDay(8, 0),
          endHour: onDay(8, 10),
          raceFormatDetailId: null,
          id: 20,
        )).called(1);
  });

  test('a failed reload stops the repack rather than computing from stale '
      'state', () async {
    // Sinon la fin poussée serait celle d'avant l'écriture, et signalée comme
    // un succès.
    await seed([meeting(slots: [slot(10, 'A', 8, 0, 8, 10)])]);
    stubWritesOk();
    when(() => repo.getMeetings(42)).thenThrow(const ApiException('boom'));

    await controller.removeSlot(10);

    expect(controller.message.value, isA<UiMessageError>());
    verifyNever(() => repo.submitMeeting(
        competitionId: any(named: 'competitionId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        date: any(named: 'date'),
        beginHour: any(named: 'beginHour'),
        endHour: any(named: 'endHour'),
        id: any(named: 'id')));
  });

  test('an AppException on a write is reported with its detail', () async {
    await seed([meeting()]);
    when(() => repo.submitSlot(
          meetingId: any(named: 'meetingId'),
          name: any(named: 'name'),
          beginHour: any(named: 'beginHour'),
          endHour: any(named: 'endHour'),
          raceFormatDetailId: any(named: 'raceFormatDetailId'),
          id: any(named: 'id'),
        )).thenThrow(const ApiException('Invalid token'));

    await controller.addManualItem('Pause');

    expect(controller.message.value, isA<UiMessageError>());
    expect((controller.message.value! as UiMessageError).details,
        contains('Invalid token'));
    expect(controller.isBusy.value, isFalse);
  });
}
```

- [ ] **Step 3 : lancer et vérifier l'échec**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart`
Expected: FAIL — `meeting_editor_controller.dart` n'existe pas.

- [ ] **Step 4 : implémenter le contrôleur**

Créer `lib/app/module/programme/controllers/meeting_editor_controller.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Durée d'un item nouvellement ajouté.
const int defaultItemMinutes = 10;

/// Un tour dont FFSS porte une `partie` et qu'aucun créneau ne pointe encore —
/// une ligne de la palette.
///
/// L'unité est le tour, pas la course : un créneau pointe une partie, donc
/// c'est un tour entier qui se pose d'un coup.
class UnscheduledRound {
  const UnscheduledRound({
    required this.partieId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.type,
    required this.courseCount,
    required this.spotsPerRace,
  });

  /// La `partie` FFSS que ce tour est devenu quand le déroulement a été poussé.
  final int partieId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final RoundType type;
  final int courseCount;
  final int spotsPerRace;
}

/// Les items d'une réunion : ajout, durées, ordre, suppression.
///
/// Chaque geste part immédiatement sur FFSS : la fin de la réunion dépend de
/// chaque durée et doit rester juste à tout instant.
class MeetingEditorController extends GetxController {
  MeetingEditorController(
    this._meetings,
    this._repo,
    this._programme,
    this._user,
  );

  final MeetingService _meetings;
  final MeetingRepository _repo;
  final ProgrammeService _programme;
  final UserService _user;

  final RxInt meetingId = 0.obs;
  final RxBool isBusy = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is Map && arg['meetingId'] is int) {
      meetingId.value = arg['meetingId'] as int;
    }
  }

  Meeting? get meeting => _meetings.byId(meetingId.value);

  List<MeetingItem> get items => meetingItems(meeting);

  /// Le site de la réunion, dont héritent toutes ses courses.
  String get site => meeting?.site ?? '';

  /// Tout ce que cet écran lit est public, donc un opérateur déconnecté entre
  /// sans friction — seule une écriture revient refusée.
  bool get canWriteToFfss => _user.currentUser.value != null;

  /// Les tours restant à placer : ceux dont FFSS porte une `partie`, moins
  /// ceux qu'un créneau pointe déjà — **toutes réunions confondues**, sinon le
  /// même tour serait proposé deux fois.
  ///
  /// Un tour sans `serverId` est écarté exprès : rien côté FFSS ne pourrait
  /// porter son créneau, donc l'offrir ne vaudrait à l'opérateur qu'un refus
  /// qu'il ne peut pas corriger d'ici. Pousser le déroulement depuis l'onglet
  /// Structure est ce qui le fait entrer dans cette liste.
  List<UnscheduledRound> get unscheduledRounds {
    final placed = _meetings.placedPartieIds;
    final rounds = <UnscheduledRound>[];
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      for (final level in structure.levels) {
        if (level.serverId <= 0 || placed.contains(level.serverId)) continue;
        rounds.add(UnscheduledRound(
          partieId: level.serverId,
          raceId: structure.raceId,
          categoryId: structure.categoryId,
          raceLabel: structure.raceLabel,
          categoryLabel: structure.categoryLabel,
          type: level.type,
          courseCount: level.races.length,
          spotsPerRace: structure.spotsForLevel(level),
        ));
      }
    }
    return rounds;
  }

  /// Ajoute un item informatif à la réunion, puis pousse sa nouvelle fin.
  ///
  /// L'item démarre à la fin actuelle de la réunion et dure
  /// [defaultItemMinutes]. Un opérateur déconnecté est refusé avant que quoi
  /// que ce soit quitte l'appareil — FFSS répondrait sinon à une écriture
  /// anonyme par un « Invalid Token » nu qui se lit comme une panne serveur.
  Future<void> addManualItem(String label) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    isBusy.value = true;
    try {
      final begin = _endMinutes(held);
      final slotId = await _repo.submitSlot(
        meetingId: held.id,
        name: label,
        beginHour: _atMinutes(held.date, begin),
        endHour: _atMinutes(held.date, begin + defaultItemMinutes),
      );
      if (slotId <= 0) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      if (!await _meetings.reload()) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return;
      }
      await _pushEnd();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Place un tour : son créneau, puis les courses dedans, puis les places de
  /// départ de chaque course.
  ///
  /// Le créneau dure [defaultItemMinutes] par course et les courses le
  /// remplissent bout à bout — un tour de trois séries prend trois fois la
  /// place d'un tour d'une. L'opérateur ajuste ensuite, mais la journée est
  /// d'abord à peu près juste.
  ///
  /// [name] et [courseNames] sont composés par la vue : nommer un tour demande
  /// le genre, et un genre est un mot traduit que ce contrôleur n'a pas à
  /// résoudre. [courseNames] compte une entrée par course. [spotsPerRace] est
  /// ce que le tour déclare ; 0 ouvre les courses vides.
  ///
  /// Le site n'est pas un paramètre : il vient de la réunion, et toutes ses
  /// courses en héritent.
  Future<void> scheduleRound({
    required int partieId,
    required String name,
    required List<String> courseNames,
    required int spotsPerRace,
  }) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    isBusy.value = true;
    try {
      final begin = _endMinutes(held);
      final courseCount = courseNames.length;
      // Au moins la place d'une course : un créneau de longueur nulle serait
      // invisible sur la frise et laisserait l'item suivant démarrer à la
      // même minute.
      final duration =
          defaultItemMinutes * (courseCount < 1 ? 1 : courseCount);

      final slotId = await _repo.submitSlot(
        meetingId: held.id,
        name: name,
        beginHour: _atMinutes(held.date, begin),
        endHour: _atMinutes(held.date, begin + duration),
        raceFormatDetailId: partieId,
      );
      if (slotId <= 0) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }

      final created = await _createRoundCourses(
        slotId: slotId,
        courseNames: courseNames,
        spotsPerRace: spotsPerRace,
        day: held.date,
        beginMinutes: begin,
      );
      await _linkRunsToRound(partieId, created.runIds);

      if (!await _meetings.reload()) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return;
      }
      await _pushEnd();

      // Signalé après le rechargement, pour que l'opérateur voie le tour qui
      // a bien atterri à côté de l'avertissement, plutôt qu'un échec nu
      // au-dessus d'une réunion vide.
      if (created.refused != null) {
        message.trigger(UiMessageError('schedule_courses_failed',
            details: created.refused));
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Crée les courses du tour bout à bout dans son créneau, chacune ouvrant
  /// avec [spotsPerRace] places de départ.
  ///
  /// Un refus sur une course n'arrête pas les autres : une demi-manche sur le
  /// site est mauvaise, une demi-manche que l'opérateur croit complète est
  /// pire.
  Future<({List<int> runIds, String? refused})> _createRoundCourses({
    required int slotId,
    required List<String> courseNames,
    required int spotsPerRace,
    required DateTime day,
    required int beginMinutes,
  }) async {
    final failures = <String>[];
    // Une case par nom, portant 0 pour celles qui n'ont jamais atterri : un
    // refus ne doit pas faire glisser les heats d'après sur la mauvaise
    // course.
    final runIds = List<int>.filled(courseNames.length, 0);

    for (var i = 0; i < courseNames.length; i++) {
      final begin = beginMinutes + i * defaultItemMinutes;
      try {
        final runId = await _repo.submitRun(
          slotId: slotId,
          name: courseNames[i],
          beginHour: _atMinutes(day, begin),
          endHour: _atMinutes(day, begin + defaultItemMinutes),
          site: site,
        );
        if (runId <= 0) {
          failures.add(courseNames[i]);
          continue;
        }
        runIds[i] = runId;
        if (spotsPerRace > 0) {
          await _repo.createDefaultLanes(runId: runId, count: spotsPerRace);
        }
      } on AppException catch (e) {
        failures.add('${courseNames[i]} (${e.detail})');
      }
    }

    return (
      runIds: runIds,
      refused: failures.isEmpty ? null : failures.join(', '),
    );
  }

  /// Enregistre sur chaque heat tiré la course qu'il court, position par
  /// position : la n-ième course du tour a été créée depuis le n-ième heat,
  /// donc ils se correspondent par construction ici — ce qui est exactement
  /// pourquoi l'id est stocké maintenant plutôt que re-dérivé plus tard, une
  /// fois que des suppressions auront tout décalé.
  ///
  /// Une course refusée laisse l'id de son heat à 0 plutôt que de lui donner
  /// la course suivante.
  Future<void> _linkRunsToRound(int partieId, List<int> runIds) async {
    final programme = _programme.current.value;
    if (programme == null) return;
    var touched = false;
    final structures = [
      for (final structure in programme.structures)
        structure.copyWith(levels: [
          for (final level in structure.levels)
            if (level.serverId == partieId && level.races.isNotEmpty)
              () {
                touched = true;
                return level.copyWith(races: [
                  for (var i = 0; i < level.races.length; i++)
                    if (i < runIds.length && runIds[i] != 0)
                      level.races[i].copyWith(runId: runIds[i])
                    else
                      level.races[i],
                ]);
              }()
            else
              level,
        ]),
    ];
    if (!touched) return;
    await _programme.save(programme.copyWith(structures: structures));
  }

  /// Fixe la durée d'une course. Son début ne bouge pas ; tout ce qui suit,
  /// oui.
  ///
  /// Les courses d'un tour naissent toutes de la même longueur, mais une
  /// finale de plage ne prend pas ce qu'une série prend — l'opérateur ajuste
  /// donc celle qui diffère plutôt que le tour entier.
  Future<void> setRunDuration(int runId, int minutes) =>
      _resizeThenRepack(minutes, (held) async {
        final owner = _slotOfRun(held, runId);
        if (owner == null) return null;
        final run = owner.runs.firstWhere((r) => r.id == runId);
        final begin = minutesOf(run.beginTime);
        return await _repo.submitRun(
              slotId: owner.id,
              name: run.name,
              beginHour: _atMinutes(held.date, begin),
              endHour: _atMinutes(held.date, begin + minutes),
              site: run.site,
              id: runId,
            ) >
            0;
      });

  /// Redimensionne un créneau en gardant son propre début, puis recompacte.
  Future<void> setSlotDuration(int slotId, int minutes) =>
      _resizeThenRepack(minutes, (held) async {
        final slot = _slotById(held, slotId);
        if (slot == null) return null;
        final begin = minutesOf(slot.beginHour);
        return await _repo.submitSlot(
              meetingId: held.id,
              name: slot.name,
              beginHour: _atMinutes(held.date, begin),
              endHour: _atMinutes(held.date, begin + minutes),
              raceFormatDetailId: slot.raceFormatDetail?.id,
              id: slotId,
            ) >
            0;
      });

  /// Déplace l'item [oldIndex] en [newIndex], puis recalcule chaque horaire
  /// depuis le début de la réunion.
  ///
  /// Les nouvelles heures *sont* le nouvel ordre — FFSS n'a nulle part ailleurs
  /// pour l'enregistrer — donc ceci réutilise le même recompactage qu'une
  /// suppression.
  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    final ordered = _ordered(held);
    if (oldIndex < 0 || oldIndex >= ordered.length) return;
    // Un déplacement vers le bas est rapporté contre la liste *avant* que
    // l'item n'en sorte, donc l'index cible est trop haut d'un cran une fois
    // qu'il est retiré.
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (target == oldIndex) return;
    ordered.insert(
        target.clamp(0, ordered.length - 1), ordered.removeAt(oldIndex));

    isBusy.value = true;
    try {
      if (await _repack(held, ordered)) await _meetings.reload(silent: true);
    } finally {
      isBusy.value = false;
    }
  }

  /// Retire une course de la réunion, et son créneau avec elle quand c'était
  /// la dernière.
  ///
  /// Un créneau vidé de ses courses n'est pas anodin : il n'a pas de site
  /// propre, donc la frise le range parmi les items manuels, là où personne
  /// n'ira chercher le tour qu'il vient de vider.
  Future<void> removeRun(int runId) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;
    final owner = _slotOfRun(held, runId);
    if (owner == null) return;

    isBusy.value = true;
    try {
      if (!await _repo.deleteRun(runId)) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      if (owner.runs.length == 1) await _repo.deleteSlot(owner.id);
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Supprime un créneau, puis recompacte pour ne rien laisser flotter.
  Future<void> removeSlot(int slotId) async {
    if (!_refuseWhenSignedOut()) return;
    if (meeting == null) return;

    isBusy.value = true;
    try {
      if (!await _repo.deleteSlot(slotId)) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  // — Interne —

  /// Refuse l'écriture d'un opérateur déconnecté et rend `false`.
  bool _refuseWhenSignedOut() {
    if (canWriteToFfss) return true;
    message.trigger(const UiMessageError('login_required'));
    return false;
  }

  /// Le corps commun aux deux réglages de durée : refuser une durée nulle,
  /// envoyer le redimensionnement, puis recharger et recompacter.
  ///
  /// Recompacté et pas seulement re-terminé : allonger un item le fait
  /// chevaucher le suivant, le raccourcir laisse le même trou qu'une
  /// suppression.
  Future<void> _resizeThenRepack(
    int minutes,
    Future<bool?> Function(Meeting held) resize,
  ) async {
    if (minutes < 1) return;
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    isBusy.value = true;
    try {
      final ok = await resize(held);
      if (ok == null) return;
      if (!ok) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Recharge l'arbre, puis recompacte la réunion telle qu'elle est revenue.
  ///
  /// Le rechargement d'abord : `layOut` lit les créneaux, donc une liste
  /// périmée calculerait une fin d'avant l'écriture et la signalerait comme un
  /// succès.
  Future<void> _reloadThenRepack() async {
    if (!await _meetings.reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
    final refreshed = meeting;
    if (refreshed != null) await _repack(refreshed, _ordered(refreshed));
  }

  /// Recompacte [held] depuis son heure de début dans l'ordre [ordered],
  /// n'envoie que ce qui a bougé, puis pousse la nouvelle fin.
  ///
  /// Seuls les items dont l'horaire change réellement partent : sur une
  /// journée de vingt, supprimer le dernier ne doit pas réécrire les
  /// dix-neuf d'avant.
  Future<bool> _repack(Meeting held, List<Slot> ordered) async {
    final competitionId = _meetings.competitionId;
    if (competitionId == null) return false;
    final target = layOut(ordered, minutesOf(held.beginHour));

    try {
      for (final move in moves(ordered, target)) {
        if (!await _applyMove(held, move)) {
          message.trigger(const UiMessageError('schedule_item_failed'));
          return false;
        }
      }
      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: held.name,
        description: held.description,
        date: held.date,
        beginHour: held.beginHour,
        endHour: _atMinutes(held.date, target.endMinutes),
        id: held.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return false;
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return false;
    }
    return true;
  }

  /// Pousse la fin de la réunion à ce que ses items disent maintenant.
  ///
  /// Tourne *après* que l'item a atterri : un échec ici laisse une `fin`
  /// périmée sur FFSS plutôt qu'un item non enregistré — à signaler tout de
  /// même, puisque l'app recalcule la sienne depuis les créneaux et ne
  /// laisserait jamais l'opérateur savoir que les deux ont divergé.
  Future<void> _pushEnd() async {
    final held = meeting;
    final competitionId = _meetings.competitionId;
    if (held == null || competitionId == null) return;
    try {
      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: held.name,
        description: held.description,
        date: held.date,
        beginHour: held.beginHour,
        endHour: _atMinutes(held.date, _endMinutes(held)),
        id: held.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      }
    } on AppException catch (e) {
      message.trigger(
          UiMessageError('schedule_meeting_end_failed', details: e.detail));
    }
  }

  Future<bool> _applyMove(Meeting held, TimetableMove move) async {
    final slot = _slotById(held, move.slotId);
    if (slot == null) return false;
    if (move.runId == null) {
      return await _repo.submitSlot(
            meetingId: held.id,
            name: slot.name,
            beginHour: _atMinutes(held.date, move.beginMinutes),
            endHour: _atMinutes(held.date, move.endMinutes),
            raceFormatDetailId: slot.raceFormatDetail?.id,
            id: slot.id,
          ) >
          0;
    }
    final run = slot.runs.firstWhere((r) => r.id == move.runId);
    return await _repo.submitRun(
          slotId: slot.id,
          name: run.name,
          beginHour: _atMinutes(held.date, move.beginMinutes),
          endHour: _atMinutes(held.date, move.endMinutes),
          site: run.site,
          id: run.id,
        ) >
        0;
  }

  /// La fin actuelle de la réunion, en minutes depuis minuit : là où se pose
  /// le prochain item. Une réunion sans item finit à son propre début.
  int _endMinutes(Meeting held) =>
      layOut(_ordered(held), minutesOf(held.beginHour)).endMinutes;

  List<Slot> _ordered(Meeting held) =>
      [...held.slots]..sort((a, b) => a.beginHour.compareTo(b.beginHour));

  Slot? _slotById(Meeting held, int slotId) {
    for (final slot in held.slots) {
      if (slot.id == slotId) return slot;
    }
    return null;
  }

  Slot? _slotOfRun(Meeting held, int runId) {
    for (final slot in held.slots) {
      if (slot.runs.any((run) => run.id == runId)) return slot;
    }
    return null;
  }

  DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
}
```

- [ ] **Step 5 : lancer et vérifier le passage**

Run: `flutter test test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart`
Expected: PASS — 24 tests.

Si un test échoue sur un `verify` d'horaire, comparer d'abord avec ce que `layOut` rend : le calcul est déjà couvert par `meeting_timetable_test.dart`, donc l'écart vient presque toujours du `_atMinutes` ou du jour passé, pas de la pose.

- [ ] **Step 6 : lancer toute la suite et commiter**

```bash
flutter test
dart format lib/ test/
flutter analyze
git add lib/app/module/programme/controllers/meeting_editor_controller.dart lib/app/data/services/meeting_service.dart test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart test/data/services/meeting_service_test.dart
git commit -m "$(cat <<'EOF'
feat(programme): MeetingEditorController

Les items d'une reunion : ajout manuel, pose d'un tour, durees, ordre et
suppression. Le recompactage passe par layOut et moves au lieu de
calculer et ecrire dans la meme boucle.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 10 : routes, bindings et traductions

**Files:**
- Modify: `lib/app/routes/app_routes.dart` (les `GetPage` viennent à la Task 11, avec les vues qu'ils construisent)
- Create: `lib/app/module/programme/bindings/meeting_form_binding.dart`, `meeting_editor_binding.dart`, `sites_binding.dart`
- Modify: `lib/app/module/programme/bindings/programme_binding.dart`
- Modify: `lib/app/core/translations/en_us.dart`, `lib/app/core/translations/fr_fr.dart`

**Interfaces:**
- Consumes: les trois contrôleurs des tâches 7-9, `SitesController`
- Produces: `Routes.programmeMeetingForm`, `Routes.programmeMeeting`, `Routes.programmeSites` ; `MeetingFormBinding`, `MeetingEditorBinding`, `SitesBinding` ; les clés de traduction listées ci-dessous

Cette tâche câble la plomberie. Les `GetPage` ne peuvent pas encore exister — ils construisent des vues que la Task 11 crée — donc **cette tâche ne touche pas `app_pages.dart`** : routes, bindings et traductions seulement.

- [ ] **Step 1 : déclarer les routes**

Dans `lib/app/routes/app_routes.dart`, après `structureEditor` :

```dart
  static const programmeMeeting = '/programme/meeting';
  static const programmeMeetingForm = '/programme/meeting-form';
  static const programmeSites = '/programme/sites';
```

- [ ] **Step 2 : écrire les trois bindings**

`lib/app/module/programme/bindings/meeting_form_binding.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/meeting_form_controller.dart';

class MeetingFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingFormController>(
      () => MeetingFormController(
        Get.find<MeetingService>(),
        Get.find<MeetingRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<UserService>(),
      ),
    );
  }
}
```

`meeting_editor_binding.dart` : identique, avec `MeetingEditorController`.

`sites_binding.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/sites_controller.dart';

class SitesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SitesController>(
      () => SitesController(Get.find<ProgrammeService>()),
    );
  }
}
```

- [ ] **Step 3 : alléger `ProgrammeBinding`**

Remplacer `ScheduleController` par `MeetingListController` et **retirer** `SitesController`, qui a désormais son propre binding :

```dart
    Get.lazyPut<MeetingListController>(
      () => MeetingListController(
        Get.find<MeetingService>(),
        Get.find<MeetingRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<UserService>(),
      ),
    );
```

Retirer les imports de `ScheduleController`, `SitesController` et `RaceFormatRepository` s'il n'est plus utilisé — vérifier avant.

- [ ] **Step 4 : ajouter les clés de traduction**

Dans **les deux** fichiers, au même endroit (près du bloc `schedule_*`), en gardant l'ordre identique.

`fr_fr.dart` :

```dart
  'meeting_new': 'Nouvelle réunion',
  'meeting_edit': 'Modifier la réunion',
  'meeting_title': 'Titre',
  'meeting_date': 'Date',
  'meeting_start': 'Début',
  'meeting_site': 'Site',
  'meeting_title_required': 'Donnez un titre à la réunion',
  'meeting_site_required': 'Choisissez un site',
  'meeting_save_failed': "FFSS n'a pas enregistré la réunion",
  'meeting_delete_failed': "FFSS n'a pas supprimé la réunion",
  'meeting_delete_title': 'Supprimer cette réunion ?',
  'meeting_delete_body':
      '« @name » et ses @count item(s) seront supprimés du serveur FFSS '
          'pour tout le monde. Cette action est irréversible.',
  'meeting_item_count': '@count item(s)',
  'no_meetings': 'Aucune réunion — commencez par en créer une',
  'no_meeting_on_day': 'aucune réunion',
  'unscheduled_round_count': '@count tour(s) non planifié(s)',
  'no_items': 'Aucun item — ajoutez-en un ou placez une épreuve',
  'add_from_round': 'Depuis une épreuve',
  'manage_sites': 'Gérer',
```

`en_us.dart` :

```dart
  'meeting_new': 'New réunion',
  'meeting_edit': 'Edit réunion',
  'meeting_title': 'Title',
  'meeting_date': 'Date',
  'meeting_start': 'Start',
  'meeting_site': 'Site',
  'meeting_title_required': 'Give the réunion a title',
  'meeting_site_required': 'Pick a site',
  'meeting_save_failed': 'FFSS did not save the réunion',
  'meeting_delete_failed': 'FFSS did not delete the réunion',
  'meeting_delete_title': 'Delete this réunion?',
  'meeting_delete_body':
      '"@name" and its @count item(s) will be removed from the FFSS server '
          'for everyone. This cannot be undone.',
  'meeting_item_count': '@count item(s)',
  'no_meetings': 'No réunion yet — start by creating one',
  'no_meeting_on_day': 'no réunion',
  'unscheduled_round_count': '@count unscheduled round(s)',
  'no_items': 'No item yet — add one or place a round',
  'add_from_round': 'From a round',
  'manage_sites': 'Manage',
```

- [ ] **Step 5 : vérifier la symétrie**

```bash
grep -c "':" lib/app/core/translations/fr_fr.dart lib/app/core/translations/en_us.dart
```

Les deux comptes doivent être égaux. S'ils diffèrent, extraire et comparer les clés :

```bash
grep -oE "^  '[a-z0-9_]+':" lib/app/core/translations/fr_fr.dart | sort > /tmp/fr.txt
grep -oE "^  '[a-z0-9_]+':" lib/app/core/translations/en_us.dart | sort > /tmp/en.txt
diff /tmp/fr.txt /tmp/en.txt
```

- [ ] **Step 6 : commiter**

`flutter analyze` signale encore les vues manquantes : normal, la Task 11 les crée. Commiter tel quel.

```bash
dart format lib/
git add lib/app/routes lib/app/module/programme/bindings lib/app/core/translations
git commit -m "$(cat <<'EOF'
feat(programme): routes, bindings et traductions du flow reunion

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 11 : les trois vues

**Files:**
- Create: `lib/app/module/programme/views/meeting_list_view.dart`, `meeting_form_view.dart`, `meeting_editor_view.dart`
- Modify: `lib/app/module/programme/views/programme_view.dart`
- Modify: `lib/app/routes/app_pages.dart` (les trois `GetPage`)

**Interfaces:**
- Consumes: `MeetingListController` (Task 7), `MeetingFormController` (Task 8), `MeetingEditorController` + `UnscheduledRound` (Task 9), `MeetingItem`/`DayEntry` (Task 6), `ProgrammeController.competition` + `genderForRace`, `heatName` + `RoundTypeFormatting` (`presentation/modules/programme/programme_formatting.dart`), `GenderFormatting.label`, `LoadingIndicator`, `EmptyState`, `ErrorState`, `ProgressOverlay`, `GenderBadge`, `showUiMessages`, `FormatConst.timeFormat`
- Produces: `MeetingListView`, `MeetingFormView`, `MeetingEditorView`

Règles non négociables pour les trois :
- `showUiMessages(controller.message)` dans `initState`, `dispose()` dans `dispose`. **Jamais** de bloc `ever` + `ScaffoldMessenger` à la main : il n'y en a qu'un dans `lib/`.
- `showDatePicker` / `showTimePicker` / `showDialog` vivent **ici**, avec le `context` local — un contrôleur n'a pas de `Get.context!`.
- **La vue compose les noms.** `heatName` et `gender.label` demandent `.tr`, que les contrôleurs ne font jamais.
- `LoadingIndicator` / `ProgressOverlay`, jamais de `CircularProgressIndicator` nu.

- [ ] **Step 1 : `MeetingListView`**

Créer `lib/app/module/programme/views/meeting_list_view.dart` :

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_list_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingListView extends StatefulWidget {
  const MeetingListView({super.key});

  @override
  State<MeetingListView> createState() => _MeetingListViewState();
}

class _MeetingListViewState extends State<MeetingListView> {
  final _controller = Get.find<MeetingListController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    // La compétition arrive par l'onglet Structure, qui la porte.
    _compWorker = ever<Competition?>(_programme.competition, _onCompetition);
    _onCompetition(_programme.competition.value);
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    _messageWorker.dispose();
    super.dispose();
  }

  // Sans attendre : la liste rend elle-même son isLoading et son hasError.
  void _onCompetition(Competition? comp) =>
      unawaited(_controller.setCompetition(comp));

  /// Le nom du jour suit **la langue de l'application** : il s'affichera comme
  /// ça sur le site fédéral si l'opérateur le reprend dans un titre.
  String _dayLabel(DateTime day) =>
      DateFormat('EEEE d MMMM', Get.locale?.toString()).format(day);

  Future<void> _openForm({Meeting? meeting}) => Get.toNamed<void>(
        Routes.programmeMeetingForm,
        arguments: {
          'competition': _controller.competition.value,
          'meeting': meeting,
        },
      ).then((_) {});

  void _openEditor(Meeting meeting) => Get.toNamed<void>(
        Routes.programmeMeeting,
        arguments: {'meetingId': meeting.id},
      );

  Future<void> _confirmDelete(Meeting meeting) async {
    // Le décompte compte les courses, pas les créneaux : c'est ce que
    // l'opérateur voit dans l'éditeur, et donc ce qu'il croit perdre.
    final count = meeting.slots.fold<int>(
      0,
      (sum, slot) => sum + (slot.runs.isEmpty ? 1 : slot.runs.length),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('meeting_delete_title'.tr),
        content: Text('meeting_delete_body'.trParams({
          'name': meeting.name,
          'count': '$count',
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _controller.deleteMeeting(meeting.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) return const LoadingIndicator();
      if (_controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: _controller.refresh,
        );
      }
      final days = _controller.days;
      if (days.isEmpty) {
        return EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      }

      final empty = _controller.meetings.isEmpty;
      final unscheduled = _controller.unscheduledRoundCount;

      return RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ListView(
          padding: AppSpacing.pageAll,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    Get.toNamed<void>(Routes.programmeSites),
                icon: const Icon(Icons.place_outlined, size: 18),
                label: Text('${'sites'.tr} (${_controller.sites.length})'),
              ),
            ),
            // Informatif et non cliquable : placer un tour demande une réunion
            // cible, geste qui n'a de sens que dans l'éditeur.
            if (unscheduled > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: AppColors.statusWaiting),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'unscheduled_round_count'
                          .trParams({'count': '$unscheduled'}),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            if (empty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.event_note_outlined,
                  title: 'no_meetings'.tr,
                ),
              ),
            for (final day in days) ..._daySection(day),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: Text('meeting_new'.tr),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _daySection(DateTime day) {
    final held = _controller.meetingsOn(day);
    return [
      Padding(
        padding: const EdgeInsets.only(
            top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Text(
          _dayLabel(day).toUpperCase(),
          style: AppTypography.caption
              .copyWith(color: AppColors.textSecondary),
        ),
      ),
      if (held.isEmpty)
        Text(
          'no_meeting_on_day'.tr,
          style:
              AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
      for (final meeting in held) _MeetingCard(
          meeting: meeting,
          onTap: () => _openEditor(meeting),
          onEdit: () => _openForm(meeting: meeting),
          onDelete: () => _confirmDelete(meeting)),
    ];
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({
    required this.meeting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final items = meeting.slots.fold<int>(
      0,
      (sum, slot) => sum + (slot.runs.isEmpty ? 1 : slot.runs.length),
    );
    final range = 'schedule_day_range'.trParams({
      'begin': FormatConst.timeFormat.format(meeting.beginHour),
      'end': FormatConst.timeFormat.format(meeting.endHour),
    });
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        title: Text(meeting.name.isEmpty ? '—' : meeting.name,
            style: AppTypography.body),
        subtitle: Text(
          '$range · ${'meeting_item_count'.trParams({'count': '$items'})}'
          '${meeting.site.isEmpty ? '' : ' · ${meeting.site}'}',
          style: AppTypography.caption,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text('edit_item'.tr)),
            PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
          ],
        ),
      ),
    );
  }
}
```

Vérifier que les clés `delete`, `cancel`, `edit_item`, `error_occured`, `no_days`, `sites` et `schedule_day_range` existent bien dans **les deux** fichiers de traduction (`grep "'delete':" lib/app/core/translations/fr_fr.dart`). Ajouter celles qui manquent, symétriquement.

- [ ] **Step 2 : `MeetingFormView`**

Créer `lib/app/module/programme/views/meeting_form_view.dart`. `StatefulWidget` : le `TextEditingController` du titre vit ici, jamais dans le contrôleur.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_form_controller.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingFormView extends StatefulWidget {
  const MeetingFormView({super.key});

  @override
  State<MeetingFormView> createState() => _MeetingFormViewState();
}

class _MeetingFormViewState extends State<MeetingFormView> {
  final _controller = Get.find<MeetingFormController>();
  late final TextEditingController _title;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: _controller.editing.value?.name ?? '');
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _title.dispose();
    _messageWorker.dispose();
    super.dispose();
  }

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}'
      ':${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final days = _controller.days;
    if (days.isEmpty) return;
    // Restreint aux jours de la compétition : une réunion hors de ses dates
    // n'aurait aucun sens sur le site fédéral.
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.date.value ?? days.first,
      firstDate: days.first,
      lastDate: days.last,
      selectableDayPredicate: (day) => days.any((d) =>
          d.year == day.year && d.month == day.month && d.day == day.day),
    );
    if (picked != null) {
      _controller.date.value = DateTime(picked.year, picked.month, picked.day);
    }
  }

  Future<void> _pickTime() async {
    final current = _controller.startMinutes.value;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _controller.startMinutes.value = picked.hour * 60 + picked.minute;
    }
  }

  Future<void> _save() async {
    if (await _controller.save(_title.text)) Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
              _controller.isEditing ? 'meeting_edit'.tr : 'meeting_new'.tr,
              style: AppTypography.title
                  .copyWith(color: Colors.white, fontSize: 16),
            )),
      ),
      body: ListView(
        padding: AppSpacing.pageAll,
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'meeting_title'.tr),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final day = _controller.date.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text('meeting_date'.tr, style: AppTypography.caption),
              subtitle: Text(
                day == null
                    ? 'no_days'.tr
                    : DateFormat('EEEE d MMMM y', Get.locale?.toString())
                        .format(day),
                style: AppTypography.body,
              ),
              onTap: _pickDate,
            );
          }),
          Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text('meeting_start'.tr, style: AppTypography.caption),
                subtitle: Text(_hhmm(_controller.startMinutes.value),
                    style: AppTypography.body),
                onTap: _pickTime,
              )),
          const SizedBox(height: AppSpacing.md),
          Text('meeting_site'.tr, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Obx(() {
            final sites = _controller.sites;
            if (sites.isEmpty) {
              return Row(
                children: [
                  Expanded(
                    child: Text('no_sites'.tr,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Get.toNamed<void>(Routes.programmeSites),
                    child: Text('manage_sites'.tr),
                  ),
                ],
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final site in sites)
                  ChoiceChip(
                    label: Text(site.name),
                    selected: _controller.site.value == site.name,
                    onSelected: (_) => _controller.site.value = site.name,
                  ),
                TextButton(
                  onPressed: () => Get.toNamed<void>(Routes.programmeSites),
                  child: Text('manage_sites'.tr),
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => FilledButton(
                onPressed: _controller.isSaving.value ? null : _save,
                child: _controller.isSaving.value
                    ? const LoadingIndicator(
                        compact: true, size: 18, color: Colors.white)
                    : Text(_controller.isEditing ? 'save'.tr : 'add'.tr),
              )),
        ],
      ),
    );
  }
}
```

Vérifier les clés `save` et `add` ; si `add` n'existe pas, réutiliser `meeting_new` plutôt que d'ajouter une clé pour un mot.

- [ ] **Step 3 : `MeetingEditorView`**

Créer `lib/app/module/programme/views/meeting_editor_view.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_editor_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/gender_badge.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/progress_overlay.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingEditorView extends StatefulWidget {
  const MeetingEditorView({super.key});

  @override
  State<MeetingEditorView> createState() => _MeetingEditorViewState();
}

class _MeetingEditorViewState extends State<MeetingEditorView> {
  final _controller = Get.find<MeetingEditorController>();
  final _programme = Get.find<ProgrammeController>();
  late final Worker _messageWorker;
  bool _paletteOpen = false;

  @override
  void initState() {
    super.initState();
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    super.dispose();
  }

  /// « Séries - Surfski - Dames - Junior » — composé ici et non dans le
  /// contrôleur, qui n'a pas à résoudre un genre traduit.
  String _nameFor(UnscheduledRound round, Gender gender) =>
      '${round.type.labelKey.tr} - ${round.raceLabel} - ${gender.label}'
      ' - ${round.categoryLabel}';

  /// Un nom par course, en ordre de passage : « Demie 1 - Surfski -
  /// Messieurs - Junior ». Le rang tombe quand le tour ne court qu'une course
  /// — « Finale 1 » ne nomme rien de plus que « Finale ».
  List<String> _courseNamesFor(UnscheduledRound round, Gender gender) {
    final tail =
        '${round.raceLabel} - ${gender.label} - ${round.categoryLabel}';
    return [
      for (var i = 0; i < round.courseCount; i++)
        '${heatName(round.type, i, round.courseCount)} - $tail',
    ];
  }

  Future<void> _addManualItem() async {
    // Le libellé seulement : l'horaire de l'item n'est pas au choix de
    // l'opérateur, il démarre à la fin de la réunion.
    final labelController = TextEditingController();
    try {
      final label = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('add_manual_item'.tr),
          content: TextField(
            controller: labelController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'manual_label'.tr),
            onSubmitted: (value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(labelController.text),
              child: Text('add_manual_item'.tr),
            ),
          ],
        ),
      );
      final trimmed = label?.trim() ?? '';
      if (trimmed.isEmpty) return;
      await _controller.addManualItem(trimmed);
    } finally {
      labelController.dispose();
    }
  }

  Future<void> _editDuration({
    required String label,
    required int currentMinutes,
    required Future<void> Function(int minutes) onSave,
  }) async {
    final field = TextEditingController(text: '$currentMinutes');
    try {
      final value = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(label),
          content: TextField(
            controller: field,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(suffixText: 'min_short'.tr),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(int.tryParse(field.text)),
              child: Text('save'.tr),
            ),
          ],
        ),
      );
      if (value != null && value > 0) await onSave(value);
    } finally {
      field.dispose();
    }
  }

  void _openForm() => Get.toNamed<void>(
        Routes.programmeMeetingForm,
        arguments: {
          'competition': _programme.competition.value,
          'meeting': _controller.meeting,
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
              _controller.meeting?.name ?? '',
              style: AppTypography.title
                  .copyWith(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openForm,
            tooltip: 'meeting_edit'.tr,
          ),
        ],
      ),
      body: Obx(() {
        final meeting = _controller.meeting;
        if (meeting == null) {
          return EmptyState(
              icon: Icons.event_busy, title: 'schedule_no_meeting'.tr);
        }
        final items = _controller.items;
        return Stack(
          children: [
            Column(
              children: [
                _Header(
                  date: meeting.date,
                  begin: meeting.beginHour,
                  end: meeting.endHour,
                  site: _controller.site,
                ),
                Expanded(
                  child: items.isEmpty
                      ? EmptyState(
                          icon: Icons.playlist_add, title: 'no_items'.tr)
                      : ReorderableListView(
                          padding: AppSpacing.pageAll,
                          onReorder: _controller.reorderItems,
                          children: [
                            for (final item in items)
                              _ItemCard(
                                key: ValueKey(item.slotId),
                                item: item,
                                onEditSlotDuration: () => _editDuration(
                                  label: item.label,
                                  currentMinutes: item.end
                                      .difference(item.begin)
                                      .inMinutes,
                                  onSave: (m) => _controller
                                      .setSlotDuration(item.slotId, m),
                                ),
                                onDeleteSlot: () =>
                                    _controller.removeSlot(item.slotId),
                                onEditCourseDuration: (course) =>
                                    _editDuration(
                                  label: course.label,
                                  currentMinutes: course.end
                                      .difference(course.begin)
                                      .inMinutes,
                                  onSave: (m) => _controller
                                      .setRunDuration(course.runId!, m),
                                ),
                                onDeleteCourse: (course) =>
                                    _controller.removeRun(course.runId!),
                              ),
                          ],
                        ),
                ),
                _Actions(
                  onManual: _addManualItem,
                  onRound: () =>
                      setState(() => _paletteOpen = !_paletteOpen),
                ),
                if (_paletteOpen) _Palette(controller: _controller,
                    nameFor: _nameFor, courseNamesFor: _courseNamesFor,
                    genderOf: _programme.genderForRace),
              ],
            ),
            if (_controller.isBusy.value)
              ProgressOverlay(message: 'loading'.tr),
          ],
        );
      }),
    );
  }
}
```

Puis les widgets privés, dans le même fichier :

- `_Header` : la date via `DateFormat('EEEE d MMMM', Get.locale?.toString())`, la plage via `'schedule_day_range'.trParams({...})` sur `FormatConst.timeFormat`, et le site en `Text`.
- `_ItemCard extends StatelessWidget` : une `Card`. Un `ListTile` d'en-tête — `leading: ReorderableDragStartListener(index: …, child: Icon(Icons.drag_handle))` *ou*, plus simple, laisser `ReorderableListView` poser sa poignée par défaut ; `title: item.label` ; `subtitle` l'heure via `FormatConst.timeFormat.format(item.begin)`. Pour un item **manuel** (`item.isManual`), le `trailing` porte la durée cliquable (`onEditSlotDuration`) et `🗑` (`onDeleteSlot`). Pour un item **à courses**, le `trailing` ne porte que `🗑`, et une `Column` de sous-`ListTile`s dense suit, une par `item.courses`, chacune avec son heure, son `label`, sa durée cliquable (`onEditCourseDuration`) et son `🗑` (`onDeleteCourse`).
- `_Actions` : une `Row` de deux `OutlinedButton.icon` — `add_manual_item` et `add_from_round`.
- `_Palette` et `_RoundRow` : **reprendre `schedule_view.dart` l. 687-843 tel quel**, en retirant `_siteFor` et le paramètre `site` (le site vient de la réunion) et en remplaçant le paramètre `day` par rien — `onAdd` n'est jamais `null`, puisqu'une réunion est forcément là. L'appel devient :

```dart
                          onAdd: () => controller.scheduleRound(
                                partieId: round.partieId,
                                name: nameFor(round, gender),
                                courseNames: courseNamesFor(round, gender),
                                spotsPerRace: round.spotsPerRace,
                              ),
```

Le `maxHeight` de la palette : reprendre `_paletteHeight(context)` de `schedule_view.dart`.

Vérifier la clé `loading` ; si elle n'existe pas, utiliser celle que `ProgressOverlay` reçoit ailleurs dans `lib/` (`grep -rn "ProgressOverlay(" lib/`).

- [ ] **Step 4 : brancher `ProgrammeView`**

Dans `programme_view.dart`, remplacer l'import de `schedule_view.dart` par celui de `meeting_list_view.dart`, et l'entrée de l'`IndexedStack` :

```dart
                    children: const [
                      StructureOverviewView(),
                      MeetingListView(),
                    ],
```

- [ ] **Step 5 : ajouter les trois `GetPage`**

Dans `app_pages.dart`, après le `GetPage` de `structureEditor`, avec les imports correspondants :

```dart
    GetPage(
      name: Routes.programmeMeeting,
      page: () => const MeetingEditorView(),
      binding: MeetingEditorBinding(),
    ),
    GetPage(
      name: Routes.programmeMeetingForm,
      page: () => const MeetingFormView(),
      binding: MeetingFormBinding(),
    ),
    GetPage(
      name: Routes.programmeSites,
      page: () => const SitesView(),
      binding: SitesBinding(),
    ),
```

`SitesView` fonctionne telle quelle : son `build` fait déjà `Get.find<SitesController>()`, que `SitesBinding` fournit. **Ne pas la réécrire.**

- [ ] **Step 6 : analyser et lancer la suite**

```bash
dart format lib/
flutter analyze
flutter test
```

Expected: `flutter analyze` ne signale plus que `schedule_view.dart` et `schedule_controller.dart`, que la Task 12 supprime. Aucun autre avertissement — en particulier aucun `unused_import` ni `dead_code`.

- [ ] **Step 7 : commiter**

```bash
git add lib/app/module/programme/views lib/app/routes/app_pages.dart lib/app/core/translations
git commit -m "$(cat <<'EOF'
feat(programme): liste, formulaire et editeur de reunion

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 12 : démolition

**Files:**
- Delete: `lib/app/module/programme/controllers/schedule_controller.dart`, `lib/app/module/programme/views/schedule_view.dart`, `test/presentation/modules/programme/controllers/schedule_controller_test.dart`
- Modify: `lib/app/core/translations/{en_us,fr_fr}.dart`
- Modify: `CLAUDE.md`

- [ ] **Step 1 : vérifier qu'il ne reste aucun appelant**

```bash
grep -rn "ScheduleController\|ScheduleView\|daySections\|DaySection\|selectedSite\|UnscheduledRound" lib/ test/
```

Seuls `meeting_editor_controller.dart` et `meeting_editor_view.dart` doivent ressortir, pour `UnscheduledRound`. Si autre chose apparaît, le migrer **avant** de supprimer.

- [ ] **Step 2 : supprimer les trois fichiers**

```bash
git rm lib/app/module/programme/controllers/schedule_controller.dart lib/app/module/programme/views/schedule_view.dart test/presentation/modules/programme/controllers/schedule_controller_test.dart
```

- [ ] **Step 3 : lancer la suite**

```bash
flutter test
flutter analyze
```

Expected: PASS, zéro avertissement. Si un test retiré couvrait un comportement qu'aucun nouveau test ne couvre, **le réécrire** dans le fichier du contrôleur qui a repris ce comportement — ne pas perdre la couverture au passage.

- [ ] **Step 4 : traquer les clés de traduction mortes**

Pour chacune de ces clés, vérifier qu'elle n'a plus d'appelant et la supprimer **des deux fichiers** si c'est le cas :

```bash
for key in schedule_day_range schedule_manual_items schedule_no_meeting \
  schedule_start_title schedule_place_round no_placement_here \
  schedule_course_count schedule_all_placed unscheduled add_manual_item \
  manual_label schedule_delete_item_title schedule_delete_course_body \
  schedule_delete_item_body schedule_item_failed schedule_courses_failed \
  schedule_meeting_end_failed no_days; do
  echo "--- $key : $(grep -rn "'$key'" lib/ --include=*.dart | grep -v translations | wc -l) appelant(s)"
done
```

Attention : une clé construite à l'exécution échappe au grep — `RoundTypeFormatting.singularLabelKey` fabrique `'${labelKey}_one'`. **Ne pas supprimer `round_*_one`.** Vérifier chaque suffixe avant de conclure.

- [ ] **Step 5 : re-vérifier la symétrie**

```bash
grep -oE "^  '[a-z0-9_]+':" lib/app/core/translations/fr_fr.dart | sort > /tmp/fr.txt
grep -oE "^  '[a-z0-9_]+':" lib/app/core/translations/en_us.dart | sort > /tmp/en.txt
diff /tmp/fr.txt /tmp/en.txt && echo SYMETRIQUE
```

- [ ] **Step 6 : mettre à jour `CLAUDE.md`**

Quatre endroits :

1. **Data + domain layers** — ajouter `MeetingService` à la liste des services, et `meeting_timetable` à celle des modèles du domaine.
2. **Feature modules** — remplacer la description de l'onglet Programme : la liste des réunions, le formulaire et l'éditeur, plus « une réunion = un site, porté par sa `description` FFSS ».
3. **DI registration order** — l'étape 4b de la Task 5 (déjà faite), et vérifier que la phrase sur `ProgrammeBinding` reflète bien `MeetingListController`.
4. **API contract** — une ligne sur les trois valeurs de `engagement` (`'0'` à la création, `''` pour libérer, l'id pour asseoir), à côté des autres bizarreries FFSS documentées. Et `competition/reunion/:id/delete` parmi les routes qui fonctionnent.

Dans **Things to NOT do**, ajouter :

```markdown
- Don't compute a réunion's timetable inside a controller. `layOut` et `moves`
  (`domain/models/meeting_timetable.dart`) sont pures et testées sans mock ;
  c'est précisément ce que `_resequenceDay` mélangeait avec ses écritures.
- Don't send an empty `engagement` to create a free spot. `''` **libère** une
  place occupée, `'0'` en crée une libre — voir le design du 2026-09-14.
```

Dans **Known gaps**, remplacer ce qui parle du filtre par site du Programme par les limites du spec : liste de sites locale, réunion de l'ancien flow sans site, chevauchement non signalé, description écrasée.

- [ ] **Step 7 : commit final**

```bash
dart format lib/ test/
flutter analyze
flutter test
git add -A
git commit -m "$(cat <<'EOF'
refactor(programme): demolition de ScheduleController et ScheduleView

1300 lignes retirees. Les cles de traduction mortes partent avec elles,
et CLAUDE.md enregistre le nouveau decoupage.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Vérification finale

- [ ] `flutter test` — tout vert
- [ ] `flutter analyze` — zéro avertissement
- [ ] `dart format lib/ test/` — aucun fichier reformaté
- [ ] `grep -rn "Get.snackbar\|Get.dialog\|Get.context!" lib/app/module/programme/` — rien de nouveau (les deux violations connues du module auth restent hors sujet)
- [ ] `diff` des deux fichiers de traduction — symétriques
- [ ] Toute route déclarée a un `GetPage`, et tout `GetPage` est joignable :
  `grep -c "static const" lib/app/routes/app_routes.dart` contre le nombre de `GetPage` — écart attendu uniquement pour les quatre routes `kDebugMode`
- [ ] **Parcours réel à faire par l'utilisateur** (`flutter run`, appareil Android) : créer une réunion, poser un item manuel, poser un tour, vérifier sur ffss.fr que les places des courses créées portent bien `0` en engagement, changer l'heure de début, réordonner, supprimer la réunion
