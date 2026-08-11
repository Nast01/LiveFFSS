import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

void main() {
  group('roundTypeFromApi', () {
    test('translates the four FFSS niveau codes', () {
      expect(roundTypeFromApi('heat'), RoundType.serie);
      expect(roundTypeFromApi('quarter'), RoundType.quart);
      expect(roundTypeFromApi('semi'), RoundType.demi);
      expect(roundTypeFromApi('final'), RoundType.finale);
    });

    test('an unknown or absent code never passes for a real round', () {
      expect(roundTypeFromApi('repechage'), RoundType.unknown);
      expect(roundTypeFromApi(''), RoundType.unknown);
      expect(roundTypeFromApi(null), RoundType.unknown);
      expect(roundTypeFromApi(3), RoundType.unknown);
    });

    test('the codes are case-sensitive, as the API sends them', () {
      // Guards against a lax `toLowerCase()` creeping in and masking a genuine
      // vocabulary change on the server side.
      expect(roundTypeFromApi('Final'), RoundType.unknown);
    });
  });
}
