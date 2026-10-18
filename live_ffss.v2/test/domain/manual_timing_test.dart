import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';

void main() {
  group('manualTime', () {
    test('aucun chrono : pas de temps', () {
      expect(manualTime([]), isNull);
      expect(manualTime([null, null, null]), isNull);
    });

    test('les zéros et négatifs sont ignorés', () {
      expect(manualTime([0, null, -5]), isNull);
      final r = manualTime([0, 4321, null])!;
      expect(r.hundredths, 4321);
      expect(r.rule, ManualTimeRule.single);
    });

    test('un chrono : lui-même', () {
      final r = manualTime([4000])!;
      expect(r.hundredths, 4000);
      expect(r.rule, ManualTimeRule.single);
    });

    test('deux chronos : moyenne', () {
      final r = manualTime([4000, 4100])!;
      expect(r.hundredths, 4050);
      expect(r.rule, ManualTimeRule.average);
    });

    test(
      'deux chronos : arrondi au centième le plus proche, demi vers le haut',
      () {
        expect(manualTime([4000, 4001])!.hundredths, 4001);
        expect(manualTime([4000, 4003])!.hundredths, 4002);
      },
    );

    test('deux chronos dont un zéro : le seul valide', () {
      final r = manualTime([0, 3000, 0])!;
      expect(r.hundredths, 3000);
      expect(r.rule, ManualTimeRule.single);
    });

    test('trois chronos : médiane', () {
      final r = manualTime([4300, 4000, 4100])!;
      expect(r.hundredths, 4100);
      expect(r.rule, ManualTimeRule.median);
    });
  });

  group('parseChronoDigits', () {
    test('1 à 6 chiffres lus mmsscc, complétés à gauche', () {
      expect(parseChronoDigits('5'), 5);
      expect(parseChronoDigits('43'), 43);
      expect(parseChronoDigits('432'), 432);
      expect(parseChronoDigits('4321'), 4321);
      expect(parseChronoDigits('14321'), 1 * 6000 + 43 * 100 + 21);
      expect(parseChronoDigits('104321'), 10 * 6000 + 43 * 100 + 21);
    });

    test('secondes supérieures à 59 : nul', () {
      expect(parseChronoDigits('6000'), isNull);
      expect(parseChronoDigits('5999'), 5999);
      expect(parseChronoDigits('106000'), isNull);
    });

    test('entrée invalide : nul', () {
      expect(parseChronoDigits(''), isNull);
      expect(parseChronoDigits('1234567'), isNull);
      expect(parseChronoDigits('12a4'), isNull);
    });
  });

  group('chronoDigitsLabel', () {
    test('affichage partiel pendant la frappe', () {
      expect(chronoDigitsLabel(''), '0"00');
      expect(chronoDigitsLabel('4'), '0"04');
      expect(chronoDigitsLabel('43'), '0"43');
      expect(chronoDigitsLabel('432'), '4"32');
      expect(chronoDigitsLabel('4321'), '43"21');
      expect(chronoDigitsLabel('14321'), "1'43\"21");
      expect(chronoDigitsLabel('104321'), "10'43\"21");
    });
  });

  group('canEnterResults', () {
    test('rôles autorisés', () {
      expect(canEnterResults(['officiel']), isTrue);
      expect(canEnterResults(['juge_principal']), isTrue);
      expect(canEnterResults(['x', 'admin']), isTrue);
    });

    test('autres rôles ou aucun', () {
      expect(canEnterResults([]), isFalse);
      expect(canEnterResults(['spectateur']), isFalse);
    });
  });

  test('un temps tel que le pavé l’affiche', () {
    expect(hundredthsLabel(4321), '43"21');
    expect(hundredthsLabel(6234), "1'02\"34");
  });
}
