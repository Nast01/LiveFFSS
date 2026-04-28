import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/live_result_dto.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

void main() {
  test('LiveResultMapper handles null entry and result', () {
    const dto = LiveResultDto(id: 1, number: '5');
    final lr = dto.toDomain();
    expect(lr.id, 1);
    expect(lr.number, '5');
    expect(lr.entry, isNull);
    expect(lr.result, isNull);
    expect(lr.hasValidResult, isFalse);
    expect(lr.isDisqualified, isFalse);
  });
}
