import 'package:live_ffss/app/data/models/category_model.dart';
import 'package:live_ffss/app/data/models/discipline_model.dart';
import 'package:live_ffss/app/data/models/race_format_detail_model.dart';

class RaceFormatConfigurationModel {
  late int id;
  late String label;
  late String fullLabel;
  late String gender;
  late String genderLabel;
  late DisciplineModel discipline;
  late List<CategoryModel> categories;
  late List<RaceFormatDetailModel> raceFormatDetails;

  RaceFormatConfigurationModel({
    required this.id,
    required this.label,
    required this.fullLabel,
    required this.gender,
    required this.genderLabel,
    required this.discipline,
    required this.categories,
    required this.raceFormatDetails,
  });

  factory RaceFormatConfigurationModel.fromJson(Map<String, dynamic> json) {
    return RaceFormatConfigurationModel(
      id: json["Id"],
      label: json["label"],
      fullLabel: json["fullLabel"],
      gender: json["Genre"],
      genderLabel: json["genreLabel"],
      discipline: DisciplineModel.fromJson(json["Discipline"]),
      categories: json["categories"] != null
          ? (json["categories"] as List)
              .map((categoryJson) =>
                  CategoryModel.fromJson(categoryJson["categorie"]))
              .toList()
          : [],
      raceFormatDetails: json["parties"] != null
          ? (json["parties"] as List)
              .map((entryJson) => RaceFormatDetailModel.fromJson(entryJson))
              .toList()
          : [],
    );
  }
}
