import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/data/models/heat_model.dart';
import 'package:live_ffss/app/data/models/live_result_model.dart';

class RunModel {
  late int id;
  late String name;
  late String label;
  late String fullLabel;
  late int status;
  late String statusLabel;
  late String site;
  late DateTime beginTime;
  late DateTime endTime;
  late HeatModel? heat;
  late List<LiveResultModel> liveResults;

  RunModel({
    required this.id,
    required this.name,
    required this.label,
    required this.fullLabel,
    required this.status,
    required this.statusLabel,
    required this.site,
    required this.beginTime,
    required this.endTime,
    this.heat,
    this.liveResults = const [],
    // required this.places,
  });

  factory RunModel.fromJson(Map<String, dynamic> json) {
    final timeFormat = FormatConst.timeFormat;

    // Parse begin and end times
    final beginTime = timeFormat.parse(json["debut"]);
    final endTime = timeFormat.parse(json["fin"]);

    return RunModel(
      id: json["id"],
      name: json["Nom"],
      label: json["label"],
      fullLabel: json["fullLabel"],
      status: json["statut"],
      statusLabel: json["statutLabel"],
      site: json["site"],
      beginTime: beginTime,
      endTime: endTime,
      // places: json["places"] ?? [],
      // serie: json["serie"],
    );
  }

  Map<String, dynamic> toJson() {
    final timeFormat = FormatConst.timeFormat;

    return {
      "id": id,
      "Nom": name,
      "label": label,
      "fullLabel": fullLabel,
      "statut": status,
      "statutLabel": statusLabel,
      "site": site,
      "debut": timeFormat.format(beginTime),
      "fin": timeFormat.format(endTime),
      // "places": places,
      // "serie": serie,
    };
  }

  // Helper method to format begin time for display
  String get formattedBeginTime {
    return "${beginTime.hour.toString().padLeft(2, '0')}:${beginTime.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to format end time for display
  String get formattedEndTime {
    return "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to get time range
  String get timeRange {
    return "$formattedBeginTime - $formattedEndTime";
  }

  // Helper method to get duration
  Duration get duration {
    return endTime.difference(beginTime);
  }

  // Helper method to format duration
  String get formattedDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Helper method to get status color based on status
  String get statusColor {
    switch (status) {
      case 0:
        return 'orange'; // En attente (Waiting)
      case 1:
        return 'blue'; // Marshalling
      case 2:
        return 'yellow'; // In progress
      default:
        return 'green'; // Finished status
    }
  }

  // Helper method to check if run is waiting
  bool get isWaiting => status == 0;

  // Helper method to check if run is in marshalling
  bool get isInMarshalling => status == 1;

  // Helper method to check if run is in progress
  bool get isInProgress => status == 2;

  // Helper method to check if run is finished
  bool get isFinished => status == 3;

  // Helper method to get localized status
  String get localizedStatus {
    switch (status) {
      case 0:
        return 'waiting'.tr;
      case 1:
        return 'marshalling'.tr;
      case 2:
        return 'in_progress'.tr;
      default:
        return 'finished'.tr;
    }
  }

  // // Helper method to check if run has places
  // bool get hasPlaces => places.isNotEmpty;

  // // Helper method to get number of places
  // int get numberOfPlaces => places.length;
}
