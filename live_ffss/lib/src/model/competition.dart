import 'dart:core';

import 'package:intl/intl.dart';

class Competition {
  late int id;
  late String name;
  late String? description;
  late String? location;
  late int priceByAthlete;
  late int priceByEntry;
  late int priceByClub;
  late DateTime beginDate;
  late DateTime endDate;
  late String dateLabel;
  late DateTime? entryLimitDate;
  late String entryLimitLabel;
  late String speciality;
  late String typeWater;
  late String typePool;
  late String typeChrono;
  late bool isEligibleToNationalRecord;
  late int numberOfLanes;
  late String organizer;
  late bool hasBegun;
  late bool hasResult;
  late bool hasPassed;
  late String level;

  Competition({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.priceByAthlete,
    required this.priceByEntry,
    required this.priceByClub,
    required this.beginDate,
    required this.endDate,
    required this.dateLabel,
    required this.entryLimitDate,
    required this.entryLimitLabel,
    required this.speciality,
    required this.typeWater,
    required this.typePool,
    required this.typeChrono,
    required this.isEligibleToNationalRecord,
    required this.organizer,
    required this.hasBegun,
    required this.hasResult,
    required this.hasPassed,
    required this.level,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

    return Competition(
      id: json["Id"],
      name: json["Nom"],
      description: json["Description"],
      location: json["Lieu"],
      priceByAthlete: json["TarifParAthlete"],
      priceByEntry: json["TarifParEngagement"],
      priceByClub: json["TarifParClub"],
      beginDate: dateFormat.parse(json["Debut"]),
      endDate: dateFormat.parse(json["Fin"]),
      dateLabel: json["dateLabel"],
      entryLimitDate: json["DebutEngagement"] != null
          ? dateFormat.parse(json["DebutEngagement"])
          : null,
      entryLimitLabel: json["engagementLabel"],
      speciality: json["specialiteLabel"],
      typeWater: json["water"],
      typePool: json["bassin"],
      typeChrono: json["chronoLabel"],
      isEligibleToNationalRecord: json["isEligibleToNationalRecord"],
      organizer: json["Organisme"]["NomOrga"],
      hasBegun: json["hasBegun"],
      hasResult: json["hasResultat"],
      hasPassed: json["hasPassed"],
      level: json["niveauLabel"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "location": location,
        "priceByAthlete": priceByAthlete,
        "priceByEntry": priceByEntry,
        "priceByClub": priceByClub,
        "beginDate": beginDate,
        "endDate": endDate,
        "dateLabel": dateLabel,
        "entryLimitDate": entryLimitDate,
        "entryLimitLabel": entryLimitLabel,
        "speciality": speciality,
        "typeWater": typeWater,
        "typePool": typePool,
        "typeChrono": typeChrono,
        "isEligibleToNationalRecord": isEligibleToNationalRecord,
        "organizer": organizer,
        "hasBegun": hasBegun,
        "hasResult": hasResult,
        "hasPassed": hasPassed,
        "level": level,
      };
}
