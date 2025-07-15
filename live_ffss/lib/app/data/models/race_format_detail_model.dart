import 'package:live_ffss/app/data/models/race_format_configuration_model.dart';

class RaceFormatDetailModel {
  late int id;
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
  late RaceFormatConfigurationModel raceFormatConfiguration;

  RaceFormatDetailModel({
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

  factory RaceFormatDetailModel.fromJson(Map<String, dynamic> json) {
    return RaceFormatDetailModel(
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
