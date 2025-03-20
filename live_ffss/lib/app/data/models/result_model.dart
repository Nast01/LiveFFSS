import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/entry_model.dart';
import 'package:live_ffss/app/data/models/heat_model.dart';

class ResultModel {
  final String id;
  final bool isValid;
  final int status;
  final String statusLabel;
  final bool isDisqualified;
  final int rank;
  final int time;
  final String timeLabel;
  final String? complement;
  final String? complementLabel;
  final String disqualificationCode;
  final String disqualificationComment;
  final HeatModel heat;
  final EntryModel entry;
  final int? liveTime1;
  final int? liveTime2;
  final int? liveTime3;
  final List<AthleteModel> athletes;
  final bool isRecord;
  final bool isBestPerformance;
  final bool isFranceRecord;
  final int points;

  ResultModel({
    required this.id,
    required this.isValid,
    required this.status,
    required this.statusLabel,
    required this.rank,
    required this.time,
    required this.timeLabel,
    required this.complement,
    required this.complementLabel,
    required this.disqualificationCode,
    required this.disqualificationComment,
    required this.heat,
    required this.entry,
    required this.athletes,
    required this.isRecord,
    required this.isBestPerformance,
    required this.isFranceRecord,
    required this.points,
    this.isDisqualified = false,
    this.liveTime1 = 0,
    this.liveTime2 = 0,
    this.liveTime3 = 0,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json["Id"],
      isValid: json["isValid"],
      status: json["Statut"],
      statusLabel: json["statutLabel"],
      isDisqualified: json["isDisqualifie"],
      rank: json["Rang"],
      time: json["Temps"],
      timeLabel: json["tempsLabel"],
      isRecord: json["isRecord"],
      isBestPerformance: json["isMeilleurPerformance"],
      isFranceRecord: json["isRecordDeFrance"],
      liveTime1: json["TempsLive1"],
      liveTime2: json["TempsLive2"],
      liveTime3: json["TempsLive3"],
      points: json["points"],
      complement: json["complement"],
      complementLabel: json["complementLabel"],
      disqualificationCode: json["CodeDisqualification"],
      disqualificationComment: json["CommentaireDisqualification"],
      heat: HeatModel.fromJson(json["serie"]),
      entry: EntryModel.fromJson(json["engagement"]),
      athletes: (json["athletes"] as List)
          .map((athleteJson) => AthleteModel.fromJson(athleteJson))
          .toList(),
    );
  }
}
