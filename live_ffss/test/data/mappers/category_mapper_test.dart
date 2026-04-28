import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';

void main() {
  group('CategoryMapper', () {
    test('maps a full CategoryDto to Category', () {
      const dto = CategoryDto(
        id: 1,
        name: 'Senior',
        ageMin: 18,
        ageMax: 35,
      );

      final c = dto.toDomain();

      expect(c.id, 1);
      expect(c.name, 'Senior');
      expect(c.ageMin, 18);
      expect(c.ageMax, 35);
    });

    test('preserves null ageMin/ageMax', () {
      const dto = CategoryDto(id: 1, name: 'Open');

      final c = dto.toDomain();

      expect(c.ageMin, isNull);
      expect(c.ageMax, isNull);
    });
  });
}
