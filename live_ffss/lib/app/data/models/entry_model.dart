import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/category_model.dart';

class EntryModel {
  late int id;
  late CategoryModel category;
  late int status;
  late String statusLabel;
  late int entryTime;
  late String entryTimeLabel;
  late List<AthleteModel> athletes;

  EntryModel({
    required this.id,
    required this.category,
    required this.status,
    required this.statusLabel,
    required this.entryTime,
    required this.entryTimeLabel,
    required this.athletes,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    var categoryFromJson = CategoryModel.fromJson(json["categorie"]);

    var athleteFromJson = (json["athletes"] as List)
        .map((athleteJson) => AthleteModel.fromJson(athleteJson))
        .toList();

    return EntryModel(
      id: json["Id"],
      category: categoryFromJson,
      status: json["Statut"],
      statusLabel: json["statutLabel"],
      entryTime: json["performance"],
      entryTimeLabel: json["performanceLabel"],
      athletes: athleteFromJson,
    );
  }
}