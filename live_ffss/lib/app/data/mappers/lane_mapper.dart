import 'package:live_ffss/app/data/dtos/lane_dto.dart';
import 'package:live_ffss/app/data/mappers/entry_mapper.dart';
import 'package:live_ffss/app/data/mappers/result_mapper.dart';
import 'package:live_ffss/app/domain/models/lane.dart';

extension LaneMapper on LaneDto {
  Lane toDomain() => Lane(
        id: id,
        number: number,
        label: label,
        entry: entry?.toDomain(),
        result: result?.toDomain(),
      );
}
