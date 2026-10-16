import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

void main() {
  test('les codes 0 à 3 sont ceux de ResultPublisher dans V3', () {
    expect(RunStatus.fromCode(0), RunStatus.waiting);
    expect(RunStatus.fromCode(1), RunStatus.marshalling);
    expect(RunStatus.fromCode(2), RunStatus.inProgress);
    expect(RunStatus.fromCode(3), RunStatus.finished);
  });

  test('un code inconnu ou absent vaut « En attente »', () {
    expect(RunStatus.fromCode(9), RunStatus.waiting);
    expect(RunStatus.fromCode(null), RunStatus.waiting);
  });
}
