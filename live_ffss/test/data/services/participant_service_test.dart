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
