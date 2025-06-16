import 'package:live_ffss/app/data/models/club_model.dart';

class RefereeModel {
  late int id;
  late String licenseeNumber;
  late String firstName;
  late String lastName;
  late bool? isLicensee;
  late bool? isGuest;
  late String gender;
  late int year;
  late List<int> availabilities = [];
  late String level;
  late String levelMax;
  late bool isPrincipal;
  late ClubModel? club;
  late bool isValid;
  late String nationalityCode;
  late String nationality;

  RefereeModel({
    required this.id,
    required this.licenseeNumber,
    required this.firstName,
    required this.lastName,
    required this.isLicensee,
    required this.isGuest,
    required this.gender,
    required this.year,
    required this.availabilities,
    required this.level,
    required this.levelMax,
    required this.isPrincipal,
    required this.nationalityCode,
    required this.nationality,
    this.club,
    required this.isValid,
  });

  String get fullName => "$firstName $lastName";
  String get fullNameWithLevel => "$firstName $lastName ($level)";

  factory RefereeModel.fromJson(Map<String, dynamic> json) {
    return RefereeModel(
      id: json["Id"] ?? 0,
      licenseeNumber: json["NumeroLicence"],
      firstName: json["Prenom"],
      lastName: json["Nom"],
      isLicensee: json["isLicencie"] ?? false,
      isGuest: json["isInvite"] ?? false,
      gender: json["Sexe"],
      year: json["Annee"] is String ? int.parse(json["Annee"]) : json["Annee"],
      availabilities: (json["Jours"] as List<dynamic>?)
              ?.map((day) => int.parse(day.toString()))
              .toList() ??
          [],
      level: json["Niveau"] ?? "",
      levelMax: json["NiveauMax"] ?? "",
      isPrincipal: json["Principal"] ?? false,
      nationalityCode: json["nationaliteCode"],
      nationality: json["nationaliteLabel"],
      club: null,
      isValid: json["isValid"],
    );
  }

  factory RefereeModel.fromJsonWithClub(
      Map<String, dynamic> json, ClubModel club) {
    return RefereeModel(
      id: json["Id"] ?? 0,
      licenseeNumber: json["NumeroLicence"],
      firstName: json["Prenom"],
      lastName: json["Nom"],
      isLicensee: json["isLicencie"] ?? false,
      isGuest: json["isInvite"] ?? false,
      gender: json["Sexe"],
      year: json["Annee"] is String ? int.parse(json["Annee"]) : json["Annee"],
      availabilities: (json["Jours"] as List<dynamic>?)
              ?.map((day) => int.parse(day.toString()))
              .toList() ??
          [],
      level: json["Niveau"] ?? "",
      levelMax: json["NiveauMax"] ?? "",
      isPrincipal: json["Principal"] ?? false,
      nationalityCode: json["nationaliteCode"],
      nationality: json["nationaliteLabel"],
      club: club,
      isValid: json["isValid"],
    );
  }
}
