import 'package:live_ffss/app/data/models/club_model.dart';

class AthleteModel {
  late int id;
  late String licenseeNumber;
  late String firstName;
  late String lastName;
  late bool? isLicensee;
  late bool? isGuest;
  late String gender;
  late int year;
  late ClubModel? club;
  late bool isValid;
  late String nationalityCode;
  late String nationality;

  AthleteModel({
    required this.id,
    required this.licenseeNumber,
    required this.firstName,
    required this.lastName,
    required this.isLicensee,
    required this.isGuest,
    required this.gender,
    required this.year,
    required this.nationalityCode,
    required this.nationality,
    this.club,
    required this.isValid,
  });

  String get fullName => "$firstName $lastName";

  factory AthleteModel.fromJson(Map<String, dynamic> json) {
    return AthleteModel(
      id: json["Id"] ?? 0,
      licenseeNumber: json["NumeroLicence"],
      firstName: json["Prenom"],
      lastName: json["Nom"],
      isLicensee: json["isLicencie"] ?? false,
      isGuest: json["isInvite"] ?? false,
      gender: json["Sexe"],
      year: json["Annee"] is String ? int.parse(json["Annee"]) : json["Annee"],
      nationalityCode: json["nationaliteCode"],
      nationality: json["nationaliteLabel"],
      club: null,
      isValid: json["isValid"],
    );
  }
  factory AthleteModel.fromJsonWithClub(
      Map<String, dynamic> json, ClubModel club) {
    return AthleteModel(
      id: json["Id"] ?? 0,
      licenseeNumber: json["NumeroLicence"],
      firstName: json["Prenom"],
      lastName: json["Nom"],
      isLicensee: json["isLicencie"] ?? false,
      isGuest: json["isInvite"] ?? false,
      gender: json["Sexe"],
      year: json["Annee"] is String ? int.parse(json["Annee"]) : json["Annee"],
      nationalityCode: json["nationaliteCode"],
      nationality: json["nationaliteLabel"],
      isValid: json["isValid"],
      club: club,
    );
  }
}
