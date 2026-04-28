import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';
import 'package:live_ffss/app/domain/models/entry.dart';

extension EntryMapper on EntryDto {
  Entry toDomain() => Entry(
        id: id,
        category: category.toDomain(),
        status: status,
        statusLabel: statusLabel,
        entryTime: entryTime,
        entryTimeLabel: entryTimeLabel,
        athletes: athletes.map((a) => a.toDomain()).toList(),
      );
}
