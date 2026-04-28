import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/domain/models/heat.dart';

extension HeatMapper on HeatDto {
  Heat toDomain() => Heat(
        id: id,
        name: name,
        done: done,
        number: number,
      );
}
