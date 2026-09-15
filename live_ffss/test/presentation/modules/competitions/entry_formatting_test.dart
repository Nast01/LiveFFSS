import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/entry_formatting.dart';

void main() {
  Athlete athlete(int id, {String clubLabel = ''}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'Jean',
        lastName: 'Dupont',
        gender: Gender.male,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubLabel: clubLabel,
      );

  Entry entry(List<Athlete> athletes, {Club? organisme}) => Entry(
        id: 1,
        category: const Category(id: 1, name: 'Senior'),
        status: 1,
        statusLabel: 'Engagé',
        organisme: organisme,
        athletes: athletes,
      );

  test('un engagement a un athlete n est pas une equipe', () {
    expect(isTeamEntry(entry([athlete(1)])), isFalse);
    expect(isTeamEntry(entry([athlete(1), athlete(2)])), isTrue);
  });

  test('en individuel le titre est le nom de l athlete', () {
    expect(
        entryTitle(entry([athlete(1, clubLabel: 'SNS Nice')])), 'DUPONT Jean');
  });

  // La regle de `entryClubId` : l'organisme de l'engagement l'emporte, le club
  // du premier athlete prend le relais.
  test('en relais le titre est l organisme, sinon le club du premier', () {
    expect(
      entryTitle(entry(
        [athlete(1, clubLabel: 'SNS Nice'), athlete(2)],
        organisme: const Club(id: 3, name: 'Nice Sauvetage'),
      )),
      'Nice Sauvetage',
    );
    expect(
      entryTitle(entry([athlete(1, clubLabel: 'SNS Nice'), athlete(2)])),
      'SNS Nice',
    );
  });

  test('un relais sans club ni organisme se nomme par ses athletes', () {
    expect(entryTitle(entry([athlete(1), athlete(2)])),
        'DUPONT Jean / DUPONT Jean');
  });

  test('le sous-titre porte le club en individuel', () {
    expect(
        entrySubtitle(entry([athlete(1, clubLabel: 'SNS Nice')])), 'SNS Nice');
  });

  // `entrySubtitle` traduit le mot « athletes » ; sans GetX charge dans un
  // test, `.tr` rend la cle. Seul l'effectif est donc affirme ici.
  test('le sous-titre porte l effectif en relais', () {
    expect(entrySubtitle(entry([athlete(1), athlete(2)])), startsWith('2 '));
  });

  test('le club de l equipe se lit sans traduction', () {
    expect(
        entryClubLabel(entry([athlete(1, clubLabel: 'SNS Nice'), athlete(2)])),
        'SNS Nice');
    expect(entryClubLabel(entry([athlete(1)])), '');
  });
}
