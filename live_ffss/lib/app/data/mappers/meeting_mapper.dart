import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/mappers/slot_mapper.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');
final _timeFormat = DateFormat('HH:mm');

extension MeetingMapper on MeetingDto {
  Meeting toDomain() {
    final parsedDate = _dateFormat.parse(date);
    final parsedBegin = _timeFormat.parse(beginHour);
    final parsedEnd = _timeFormat.parse(endHour);

    final beginDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedBegin.hour,
      parsedBegin.minute,
    );

    final endDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedEnd.hour,
      parsedEnd.minute,
    );

    final mappedSlots = slots.map((s) => s.toDomain()).toList()
      ..sort((a, b) => a.beginHour.compareTo(b.beginHour));

    return Meeting(
      id: id,
      name: name,
      description: description,
      date: parsedDate,
      beginHour: beginDateTime,
      endHour: endDateTime,
      slots: mappedSlots,
    );
  }
}
