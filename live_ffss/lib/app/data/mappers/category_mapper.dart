import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/domain/models/category.dart';

extension CategoryMapper on CategoryDto {
  Category toDomain() => Category(
        id: id,
        name: name,
        ageMin: ageMin,
        ageMax: ageMax,
      );
}
