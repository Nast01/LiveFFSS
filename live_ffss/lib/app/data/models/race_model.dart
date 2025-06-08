import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/category_model.dart';

class RaceModel {
  late int id;
  late String name;
  late String nameEnglish;
  late String label;
  late int distance;
  late String gender;
  late int number;
  late int raceTypeId;
  late String raceType;
  late int disciplineId;
  late bool isEligibleToNationalRecord = false;
  late List<CategoryModel> categories;

  RaceModel({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.label,
    required this.distance,
    required this.gender,
    required this.number,
    required this.raceTypeId,
    required this.raceType,
    required this.disciplineId,
    required this.isEligibleToNationalRecord,
    required this.categories,
  });

  String get distanceLabel => "$distance m";

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    var categoriesFromJson = (json["categories"] as List)
        .map((categoryJson) => CategoryModel.fromJson(categoryJson))
        .toList();

    var genderLabel = "men".tr;
    if (json["Genre"] == "F") {
      genderLabel = "women".tr;
    } else if (json["Genre"] == "M") {
      genderLabel = "mixed".tr;
    }

    final languageService = LanguageService.to;
    var raceLabel =
        "${json["discipline"]["Nom"]} $genderLabel (${categoriesFromJson.map((category) => category.name).join(", ")})";
    if (languageService.isEnglish) {
      raceLabel =
          "${json["discipline"]["NomEn"]} $genderLabel (${categoriesFromJson.map((category) => category.name).join(", ")})";
    }

    return RaceModel(
      id: json["Id"],
      name: json["discipline"]["Nom"],
      nameEnglish: json["discipline"]["NomEn"],
      gender: genderLabel,
      label: raceLabel,
      distance: json["discipline"]["Distance"] ?? 0,
      number: json["discipline"]["NbAthleteParEquipe"],
      raceType: json["discipline"]["specialiteLabel"],
      raceTypeId: json["discipline"]["Specialite"],
      disciplineId: json["IdDiscipline"],
      isEligibleToNationalRecord: json["isEligibleToNationalRecord"] ?? false,
      categories: categoriesFromJson,
    );
  }
}
