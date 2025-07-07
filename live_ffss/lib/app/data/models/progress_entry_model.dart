import 'package:live_ffss/app/data/models/progress_model.dart';

class ProgressEntryModel {
  late String id;
  late int order;
  late String label;
  late String fullLabel;
  late String levelLabel;
  late String level;
  late int numberOfRun;
  late String qualificationMethod;
  late String qualificationMethodLabel;
  late int spotsPerRace;
  late int qualifyingSpots;
  late ProgressModel progress;

  ProgressEntryModel({
    required this.id,
    required this.order,
    required this.label,
    required this.fullLabel,
    required this.levelLabel,
    required this.level,
    required this.numberOfRun,
    required this.qualificationMethod,
    required this.qualificationMethodLabel,
    required this.spotsPerRace,
    required this.qualifyingSpots,
  });

  factory ProgressEntryModel.fromJson(Map<String, dynamic> json) {
    return ProgressEntryModel(
      id: json['id'],
      order: json['ordre'],
      label: json['label'],
      fullLabel: json['fullLabel'],
      levelLabel: json['niveauLabel'],
      level: json['niveau'],
      numberOfRun: json['nbCourses'],
      qualificationMethod: json['logiqueQualification'],
      qualificationMethodLabel: json['logiqueQualificationLabel'],
      spotsPerRace: json['nbPlaceParCourse'],
      qualifyingSpots: json['nbPlaceQualificative'],
    );
  }
}
