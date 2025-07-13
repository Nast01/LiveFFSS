import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';

class SlotModel {
  late int id;
  late String name;
  late DateTime beginHour;
  late DateTime endHour;
  late MeetingModel meeting;

  SlotModel({
    required this.id,
    required this.name,
    required this.beginHour,
    required this.endHour,
    required this.meeting,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json, MeetingModel meeting) {
    final timeFormat = FormatConst.timeFormat;

    final beginTime = timeFormat.parse(json["Debut"]);
    final endTime = timeFormat.parse(json["Fin"]);

    return SlotModel(
      id: json["id"],
      name: json["Nom"],
      beginHour: beginTime,
      endHour: endTime,
      meeting: meeting,
    );
  }
}
