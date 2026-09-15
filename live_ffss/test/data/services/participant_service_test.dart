import 'dart:async';

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

    expect(service.orderNumberOf(42, 7), 12);
  });

  test('un athlete inconnu n a pas de dossard', () async {
    await service.ensureLoaded(42);

    expect(service.orderNumberOf(42, 999), 0);
  });

  // Le service est permanent : il tient l'index d'une seule competition a la
  // fois. Interroge pour une autre, il ne doit pas servir celui qu'il tient.
  test('une competition qui n est pas celle tenue n a aucun dossard', () async {
    await service.ensureLoaded(42);

    expect(service.orderNumberOf(43, 7), 0);
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

  // Une competition sans aucun dossard assigne reste une lecture reussie :
  // elle ne doit pas etre reprise a chaque appel sous pretexte que l'index
  // est vide.
  test('une competition chargee sans aucun dossard n est pas relue', () async {
    when(() => repo.getParticipants(any())).thenAnswer((_) async => []);

    await service.ensureLoaded(42);
    await service.ensureLoaded(42);

    verify(() => repo.getParticipants(42)).called(1);
  });

  test('deux appels concurrents ne declenchent qu une seule lecture', () async {
    final f1 = service.ensureLoaded(42);
    final f2 = service.ensureLoaded(42);

    await Future.wait([f1, f2]);

    verify(() => repo.getParticipants(42)).called(1);
  });

  // Le dossard est un repere, pas une condition : une lecture qui echoue
  // laisse l'ecran entier lisible, dossards en moins.
  test('une lecture qui echoue rend false et ne jette pas', () async {
    when(() => repo.getParticipants(any()))
        .thenThrow(const NetworkException('coupe'));

    expect(await service.ensureLoaded(42), isFalse);
    expect(service.orderNumberOf(42, 7), 0);
  });

  // Le service est permanent et change de competition en place : deux
  // lectures peuvent se chevaucher. Celle qui repond en dernier gagne, pas
  // celle qui a ete lancee en dernier.
  test('une lecture plus ancienne ne remplace pas la competition plus recente',
      () async {
    final c42 = Completer<List<Athlete>>();
    final c43 = Completer<List<Athlete>>();
    when(() => repo.getParticipants(42)).thenAnswer((_) => c42.future);
    when(() => repo.getParticipants(43)).thenAnswer((_) => c43.future);

    final f42 = service.ensureLoaded(42);
    final f43 = service.ensureLoaded(43);

    c43.complete([athlete(9, 5)]);
    expect(await f43, isTrue);

    c42.complete([athlete(7, 12)]);
    expect(await f42, isFalse);

    expect(service.competitionId, 43);
    expect(service.orderNumberOf(43, 9), 5);
    expect(service.orderNumberOf(43, 7), 0);
  });

  test(
      'une lecture depassee ne casse pas le partage d une lecture encore en '
      'vol', () async {
    final c42 = Completer<List<Athlete>>();
    final c43 = Completer<List<Athlete>>();
    when(() => repo.getParticipants(42)).thenAnswer((_) => c42.future);
    when(() => repo.getParticipants(43)).thenAnswer((_) => c43.future);

    final f42 = service.ensureLoaded(42);
    final f43a = service.ensureLoaded(43);

    c42.complete([athlete(7, 12)]);
    await f42;

    // 43 est toujours en vol : ce troisieme appel doit partager f43a plutot
    // que de relancer sa propre lecture.
    final f43b = service.ensureLoaded(43);

    c43.complete([athlete(9, 5)]);
    await Future.wait([f43a, f43b]);

    verify(() => repo.getParticipants(43)).called(1);
  });
}
