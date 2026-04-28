import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/mappers/heat_mapper.dart';

void main() {
  test('HeatMapper maps with int Numero', () {
    final dto = HeatDto.fromJson(const {
      'Id': 1,
      'Nom': 'A',
      'Fini': false,
      'Numero': 3,
    });
    expect(dto.toDomain().number, 3);
  });

  test('HeatMapper maps with String Numero', () {
    final dto = HeatDto.fromJson(const {
      'Id': 1,
      'Nom': 'A',
      'Fini': true,
      'Numero': '7',
    });
    expect(dto.toDomain().number, 7);
  });
}
