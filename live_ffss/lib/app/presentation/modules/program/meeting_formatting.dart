import 'package:intl/intl.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

extension MeetingFormatting on Meeting {
  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  String get formattedDateMonth =>
      DateFormat('MMM').format(date).toUpperCase();

  String get formattedBeginTime =>
      '${beginHour.hour.toString().padLeft(2, '0')}:${beginHour.minute.toString().padLeft(2, '0')}';

  String get formattedEndTime =>
      '${endHour.hour.toString().padLeft(2, '0')}:${endHour.minute.toString().padLeft(2, '0')}';

  Duration get duration => endHour.difference(beginHour);

  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}min';
    return '${minutes}min';
  }
}
