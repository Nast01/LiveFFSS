import 'package:live_ffss/app/data/dtos/live_result_dto.dart';
import 'package:live_ffss/app/data/mappers/entry_mapper.dart';
import 'package:live_ffss/app/data/mappers/result_mapper.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

extension LiveResultMapper on LiveResultDto {
  LiveResult toDomain() => LiveResult(
        id: id,
        number: number,
        entry: entry?.toDomain(),
        result: result?.toDomain(),
      );
}
