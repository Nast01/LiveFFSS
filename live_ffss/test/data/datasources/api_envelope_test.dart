import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/api_envelope.dart';

void main() {
  group('assignedId', () {
    test('un id entier est rendu tel quel', () {
      expect(assignedId({'id': 94369}), 94369);
    });

    // Quatre des dix ecritures n'acceptaient que l'entier : un id servi en
    // chaine faisait passer une creation reussie pour un refus.
    test('un id servi en chaine est lu', () {
      expect(assignedId({'id': '94369'}), 94369);
    });

    test('un id absent vaut 0', () {
      expect(assignedId({'success': true}), 0);
    });

    test('une chaine qui n est pas un nombre vaut 0', () {
      expect(assignedId({'id': 'nope'}), 0);
    });

    test('un id nul vaut 0', () {
      expect(assignedId({'id': null}), 0);
    });
  });

  group('wasAccepted', () {
    test('success booleen vrai', () {
      expect(wasAccepted({'success': true}), isTrue);
    });

    test('success absent vaut succes', () {
      expect(wasAccepted({'message': 'ok'}), isTrue);
    });

    test('la chaine "true" vaut succes', () {
      expect(wasAccepted({'success': 'true'}), isTrue);
    });

    test('un refus booleen', () {
      expect(wasAccepted({'success': false}), isFalse);
    });

    // `"false"` est une chaine non vide, donc veridique en Dart : c'est tout
    // le piege de cette enveloppe.
    test('la chaine "false" est un refus', () {
      expect(wasAccepted({'success': 'false'}), isFalse);
    });
  });
}
