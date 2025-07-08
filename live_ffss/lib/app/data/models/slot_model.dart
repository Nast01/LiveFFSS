import 'package:live_ffss/app/core/const/format_const.dart';

class SlotModel {
  late int id;
  late String name;
  late DateTime beginHour;
  late DateTime endHour;

  SlotModel({
    required this.id,
    required this.name,
    required this.beginHour,
    required this.endHour,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    final timeFormat = FormatConst.timeFormat;

    final beginTime = timeFormat.parse(json["Debut"]);
    final endTime = timeFormat.parse(json["Fin"]);

    return SlotModel(
      id: json["id"],
      name: json["Nom"],
      beginHour: beginTime,
      endHour: endTime,
    );
  }
}
