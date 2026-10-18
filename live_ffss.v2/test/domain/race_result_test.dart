import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

void main() {
  const base = RaceResult(
    id: 7,
    seriesId: 1,
    entryId: 2,
    time: 0,
    chronos: [100, null, 300],
    rank: 4,
    status: 0,
    points: 12,
  );

  test('des chronos seuls remplacent les trois et rien d\'autre', () {
    final r = applyChange(
      base,
      const ResultChange(chronos: [5000, 5100, null]),
    );
    expect(r.chronos, [5000, 5100, null]);
    expect(r, base.copyWith(chronos: [5000, 5100, null]));
  });

  test('une DQ pose le statut 1 et le code', () {
    final r = applyChange(
      base,
      const ResultChange(mark: ResultMark.disqualified, code: '12'),
    );
    expect(r.status, 1);
    expect(r.complement, '12');
  });

  test('un forfait pose le statut 2 et F', () {
    final r = applyChange(base, const ResultChange(mark: ResultMark.forfeit));
    expect(r.status, 2);
    expect(r.complement, 'F');
  });

  test('annuler une DQ remet le statut 0 et laisse le complément', () {
    final dq = base.copyWith(status: 1, complement: '12');
    final r = applyChange(dq, const ResultChange(mark: ResultMark.ok));
    expect(r.status, 0);
    expect(r.complement, '12');
  });

  test('un chrono vidé reste nul, temps, rang et points intacts', () {
    final r = applyChange(
      base.copyWith(time: 6000),
      const ResultChange(chronos: [null, null, null]),
    );
    expect(r.chronos, [null, null, null]);
    expect(r.time, 6000);
    expect(r.rank, 4);
    expect(r.points, 12);
  });

  test('validé par le juge : temps non nul et positif', () {
    expect(isValidatedByJudge(base.copyWith(time: null)), false);
    expect(isValidatedByJudge(base.copyWith(time: 0)), false);
    expect(isValidatedByJudge(base.copyWith(time: 17577)), true);
  });
}
