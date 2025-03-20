import 'package:live_ffss/app/data/models/category_model.dart';

class RaceModel {
  late int id;
  late String name;
  late String nameEnglish;
  late String label;
  late int distance;
  late String gender;
  late int number;
  late String raceType;
  late int disciplineId;
  late List<CategoryModel> categories;

  RaceModel({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.label,
    required this.distance,
    required this.gender,
    required this.number,
    required this.raceType,
    required this.disciplineId,
    required this.categories,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    var categoriesFromJson = (json["categories"] as List)
        .map((categoryJson) => CategoryModel.fromJson(categoryJson))
        .toList();

    var genderLabel = "Messieurs";
    if (json["Genre"] == "F") {
      genderLabel = "Dames";
    } else if (json["Genre"] == "M") {
      genderLabel = "Mixte";
    }

    var raceLabel =
        "${json["discipline"]["Nom"]} $genderLabel (${categoriesFromJson.map((category) => category.name).join(", ")})";

    return RaceModel(
      id: json["Id"],
      name: json["discipline"]["Nom"],
      nameEnglish: json["discipline"]["NomEn"],
      gender: genderLabel,
      label: raceLabel,
      distance: json["discipline"]["Distance"],
      number: json["discipline"]["NbAthleteParEquipe"],
      raceType: json["discipline"]["specialiteLabel"],
      disciplineId: json["IdDiscipline"],
      categories: categoriesFromJson,
    );
  }
}