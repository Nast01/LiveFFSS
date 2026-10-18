import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/text_fold.dart';

void main() {
  group('foldForSearch', () {
    test('minuscules, sans accents', () {
      expect(foldForSearch('Élodie LÉGER'), 'elodie leger');
      expect(foldForSearch('Çà Ñoël'), 'ca noel');
    });

    test('ligatures et eszett', () {
      expect(foldForSearch('Cœur'), 'coeur');
      expect(foldForSearch('Lætitia'), 'laetitia');
      expect(foldForSearch('Strauß'), 'strauss');
      expect(foldForSearch('ŒUVRE'), 'oeuvre');
    });
  });
}
