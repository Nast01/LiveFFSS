import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_times.dart';

void main() {
  test('un temps FFSS en centièmes', () {
    expect(parseFfssTime('00\'16"76'), 1676);
    expect(parseFfssTime('02\'43"30'), 16330);
    expect(parseFfssTime(' 01\'09"79 '), 6979);
  });

  test('vide ou illisible : aucun temps', () {
    expect(parseFfssTime(null), isNull);
    expect(parseFfssTime(''), isNull);
    expect(parseFfssTime('DQ'), isNull);
    expect(parseFfssTime('1:09.79'), isNull);
    expect(parseFfssTime('00\'75"00'), isNull);
  });
}
