
class AthleteModel {
  late int id;
  late String licenseeNumber;
  late String firstName;
  late String lastName;
  late bool? isLicensee;
  late bool? isGuest;
  late String gender;
  late int year;
  late String club;
  late bool isValid;
  AthleteModel({
    required this.id,
    required this.licenseeNumber,
    required this.firstName,
    required this.lastName,
    required this.isLicensee,
    required this.isGuest,
    required this.gender,
    required this.year,
    required this.club,
    required this.isValid,
  });

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
      club: json["clubLabel"],
      isValid: json["isValid"],
    );
  }
}