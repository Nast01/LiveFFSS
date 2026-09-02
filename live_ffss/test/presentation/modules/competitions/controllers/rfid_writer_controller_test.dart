import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/module/competitions/controllers/rfid_writer_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockClubRepo extends Mock implements ClubRepository {}

class _MockRfidWriter extends Mock implements RfidWriter {}

void main() {
  late _MockClubRepo repo;
  late _MockRfidWriter writer;
  late RfidWriterController controller;

  Athlete athlete(
    int id,
    String first,
    String last, {
    String licence = '',
    Club? club,
    List<Category> categories = const [],
  }) =>
      Athlete(
        id: id,
        licenseeNumber: licence,
        firstName: first,
        lastName: last,
        gender: Gender.male,
        year: 2004,
        nationalityCode: 'FRA',
        nationality: 'France',
        isValid: true,
        club: club,
        categories: categories,
      );

  const nantes = Club(id: 1, name: 'SC Nantes');
  const rennes = Club(id: 2, name: 'SN Rennes');

  setUp(() {
    repo = _MockClubRepo();
    writer = _MockRfidWriter();
    controller = RfidWriterController(repo, writer);
  });

  group('loadAthletes', () {
    test('flattens every club athlete into one list', () async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [athlete(1, 'Jean', 'DUPONT')]),
            rennes.copyWith(athletes: [athlete(2, 'Marie', 'DURAND')]),
          ]);

      await controller.loadAthletes(1);

      expect(controller.allAthletes.length, 2);
      expect(controller.isLoading.value, isFalse);
      expect(controller.hasError.value, isFalse);
    });

    test('sorts by last name then first name', () async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [
              athlete(1, 'Zoe', 'DURAND'),
              athlete(2, 'Alice', 'DURAND'),
              athlete(3, 'Jean', 'DUPONT'),
            ]),
          ]);

      await controller.loadAthletes(1);

      expect(
        controller.allAthletes.map((a) => '${a.lastName} ${a.firstName}'),
        ['DUPONT Jean', 'DURAND Alice', 'DURAND Zoe'],
      );
    });

    test('deduplicates by athlete id, first occurrence wins', () async {
      // The two copies must be distinguishable, otherwise a last-wins
      // implementation passes a test named "first occurrence wins".
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(
              athletes: [athlete(1, 'Jean', 'DUPONT', licence: 'FIRST')],
            ),
            rennes.copyWith(
              athletes: [athlete(1, 'Jean', 'DUPONT', licence: 'SECOND')],
            ),
          ]);

      await controller.loadAthletes(1);

      expect(controller.allAthletes.length, 1);
      expect(controller.allAthletes.single.licenseeNumber, 'FIRST');
    });

    test('sets hasError when the repository throws an AppException', () async {
      when(() => repo.getClubs(1))
          .thenThrow(const NetworkException('offline'));

      await controller.loadAthletes(1);

      expect(controller.hasError.value, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.allAthletes, isEmpty);
    });
  });

  group('setSearchQuery', () {
    setUp(() async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [
              athlete(1, 'Jean', 'DUPONT', licence: '123456', club: nantes),
            ]),
            rennes.copyWith(athletes: [
              athlete(2, 'Marie', 'DURAND', licence: '999888', club: rennes),
            ]),
          ]);
      await controller.loadAthletes(1);
    });

    test('matches on last name, case-insensitively', () {
      controller.setSearchQuery('dupont');
      expect(controller.filteredAthletes.single.id, 1);
    });

    test('matches on first name', () {
      controller.setSearchQuery('Marie');
      expect(controller.filteredAthletes.single.id, 2);
    });

    test('matches on licensee number', () {
      controller.setSearchQuery('999');
      expect(controller.filteredAthletes.single.id, 2);
    });

    test('matches on club name', () {
      controller.setSearchQuery('Nantes');
      expect(controller.filteredAthletes.single.id, 1);
    });

    test('an empty query restores the full list', () {
      controller.setSearchQuery('dupont');
      controller.setSearchQuery('  ');
      expect(controller.filteredAthletes.length, 2);
    });

    test('a query matching nothing yields an empty list', () {
      controller.setSearchQuery('zzz');
      expect(controller.filteredAthletes, isEmpty);
    });
  });

  group('writeBracelet', () {
    const jean = Athlete(
      id: 1,
      licenseeNumber: '123456',
      firstName: 'Jean',
      lastName: 'DUPONT',
      gender: Gender.male,
      year: 2004,
      nationalityCode: 'FRA',
      nationality: 'France',
      isValid: true,
    );

    test('writes the bracelet payload and reports success', () async {
      when(() => writer.write(any())).thenAnswer((_) async {});

      await controller.writeBracelet(jean);

      verify(() => writer.write('123456;DUPONT')).called(1);
      expect(controller.writeState.value, RfidWriteState.success);
      expect(controller.selected.value, jean);
      expect(controller.message.value, isA<UiMessageSuccess>());
    });

    test('surfaces an RfidException as an error state and message', () async {
      when(() => writer.write(any()))
          .thenThrow(const RfidException('bracelet_not_writable'));

      await controller.writeBracelet(jean);

      expect(controller.writeState.value, RfidWriteState.error);
      final message = controller.message.value;
      expect(message, isA<UiMessageError>());
      expect(message!.translationKey, 'bracelet_not_writable');
    });

    test('cancelWrite returns to idle and clears the selection', () async {
      when(() => writer.write(any())).thenAnswer((_) async {});
      when(() => writer.cancel()).thenAnswer((_) async {});
      await controller.writeBracelet(jean);

      await controller.cancelWrite();

      expect(controller.writeState.value, RfidWriteState.idle);
      expect(controller.selected.value, isNull);
    });

    test('cancelWrite releases the hardware', () async {
      // Without this the NFC session stays open and the next bracelet
      // presented gets silently written with the cancelled athlete's payload.
      when(() => writer.cancel()).thenAnswer((_) async {});

      await controller.cancelWrite();

      verify(() => writer.cancel()).called(1);
    });

    test('a cancelled write does not report an error at the user', () async {
      // cancel() makes the in-flight write reject; the user who pressed
      // Annuler must not get an error popped at them for getting what they
      // asked for.
      when(() => writer.cancel()).thenAnswer((_) async {});
      when(() => writer.write(any())).thenAnswer((_) async {
        await controller.cancelWrite();
        throw const RfidException('bracelet_write_cancelled');
      });

      await controller.writeBracelet(jean);

      expect(controller.writeState.value, RfidWriteState.idle);
      expect(controller.message.value, isNull);
    });

    test('a write completing after a cancel does not report success', () async {
      when(() => writer.cancel()).thenAnswer((_) async {});
      when(() => writer.write(any())).thenAnswer((_) async {
        await controller.cancelWrite();
      });

      await controller.writeBracelet(jean);

      expect(controller.writeState.value, RfidWriteState.idle);
      expect(controller.message.value, isNull);
    });

    test('payloadFor exposes what will be written, for the UI preview', () {
      expect(controller.payloadFor(jean), '123456;DUPONT');
    });

    test('a second write while one is in flight is ignored', () async {
      // Otherwise `selected` flips to the second athlete and the FIRST
      // write's success reports itself against them — the wrong name under a
      // green check.
      const marie = Athlete(
        id: 2,
        licenseeNumber: '999888',
        firstName: 'Marie',
        lastName: 'DURAND',
        gender: Gender.female,
        year: 2005,
        nationalityCode: 'FRA',
        nationality: 'France',
        isValid: true,
      );
      final inFlight = Completer<void>();
      when(() => writer.write('123456;DUPONT'))
          .thenAnswer((_) => inFlight.future);

      unawaited(controller.writeBracelet(jean));
      await controller.writeBracelet(marie);

      expect(controller.selected.value, jean);
      verifyNever(() => writer.write('999888;DURAND'));

      inFlight.complete();
    });
  });

  group('filtre par catégorie', () {
    const cadet = Category(id: 13, name: 'Cadet');
    const junior = Category(id: 14, name: 'Junior');
    const open = Category(id: 24, name: 'Open');

    setUp(() async {
      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            nantes.copyWith(athletes: [
              athlete(1, 'Jean', 'DUPONT',
                  licence: '123456',
                  club: nantes,
                  categories: const [cadet, open]),
              athlete(3, 'Luc', 'MARTIN',
                  licence: '555', club: nantes, categories: const [junior]),
            ]),
            rennes.copyWith(athletes: [
              athlete(2, 'Marie', 'DURAND',
                  licence: '999888',
                  club: rennes,
                  categories: const [junior, open]),
            ]),
          ]);
      await controller.loadAthletes(1);
    });

    List<int> visible() => controller.filteredAthletes.map((a) => a.id).toList();

    test('sans catégorie cochée, tout le monde est visible', () {
      expect(visible(), [1, 2, 3]);
      expect(controller.hasActiveFilters, isFalse);
    });

    // Un athlète court plusieurs catégories : le masquer parce que l'une
    // d'elles n'est pas retenue cacherait quelqu'un qui prend bien le départ.
    test('une seule catégorie cochée suffit à garder l athlète', () {
      controller.toggleCategory(13);

      expect(visible(), [1]);
      expect(controller.hasActiveFilters, isTrue);
    });

    test('deux catégories cochées sont un OU', () {
      controller.toggleCategory(13);
      controller.toggleCategory(14);

      expect(visible(), [1, 2, 3]);
    });

    test('la catégorie et la recherche se combinent', () {
      controller.toggleCategory(24);
      controller.setSearchQuery('Rennes');

      expect(visible(), [2]);
    });

    test('les catégories proposées sont celles des athlètes chargés', () {
      expect(controller.categoryOptions.map((o) => o.label),
          ['Cadet', 'Junior', 'Open']);
      expect(controller.categoryOptions.map((o) => o.value), [13, 14, 24]);
    });

    test('décocher rend les athlètes masqués', () {
      controller.toggleCategory(13);
      expect(visible(), [1]);

      controller.toggleCategory(13);

      expect(visible(), [1, 2, 3]);
    });

    test('clearCategories vide le filtre d un coup', () {
      controller.toggleCategory(13);
      controller.toggleCategory(14);

      controller.clearCategories();

      expect(controller.hasActiveFilters, isFalse);
      expect(visible(), [1, 2, 3]);
    });

    // Sinon l'opérateur reste devant une liste vide sans rien à décocher.
    test('une catégorie disparue au rechargement est décochée', () async {
      controller.toggleCategory(13);
      expect(visible(), [1]);

      when(() => repo.getClubs(1)).thenAnswer((_) async => [
            rennes.copyWith(athletes: [
              athlete(2, 'Marie', 'DURAND',
                  club: rennes, categories: const [junior]),
            ]),
          ]);
      await controller.loadAthletes(1);

      expect(controller.isCategorySelected(13), isFalse);
      expect(visible(), [2]);
    });
  });
}
