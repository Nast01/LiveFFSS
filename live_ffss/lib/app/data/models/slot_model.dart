import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/models/race_format_detail_model.dart';
import 'package:live_ffss/app/data/models/run_model.dart';

class SlotModel {
  late int id;
  late String name;
  late DateTime beginHour;
  late DateTime endHour;
  late MeetingModel meeting;
  late RaceFormatDetailModel? raceFormatDetailModel;
  late List<RunModel> runs; // Assuming you want to track runs in a slot

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

    SlotModel slotModel = SlotModel(
      id: json["id"],
      name: json["Nom"],
      beginHour: beginTime,
      endHour: endTime,
      meeting: meeting,
    );

    if (json['partie'] != null) {
      slotModel.raceFormatDetailModel = RaceFormatDetailModel.fromJson(
        json['partie'],
      );
    } else {
      slotModel.raceFormatDetailModel = null;
    }

    // Parse runs from JSON
    if (json['courses'] != null) {
      slotModel.runs = (json['courses'] as List<dynamic>)
          .map((run) => RunModel.fromJson(run))
          .toList();
    }

    return slotModel;
  }
}
