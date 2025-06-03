import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/models/club_model.dart';

class CompetitionModel {
  final int id;
  final String name;
  final DateTime? beginDate;
  final DateTime? endDate;
  final DateTime? beginEntryLimitDate;
  final DateTime? endEntryLimitDate;
  final String? location;
  final int status;
  final String statusLabel;
  final String? description;
  final int speciality;
  final String specialityLabel;
  final String typeWater;
  final String typePool;
  final String typeChrono;
  final bool isEligibleToNationalRecord;
  final int numberOfLanes;
  final String organizer;
  final bool hasBegun;
  final bool hasResult;
  final bool hasPassed;
  final int level;
  final String levelLabel;
  final String? refereePrincipal;
  final ClubModel organizerClub;

  CompetitionModel({
    required this.id,
    required this.name,
    required this.beginDate,
    required this.endDate,
    required this.beginEntryLimitDate,
    required this.endEntryLimitDate,
    required this.location,
    required this.status,
    required this.statusLabel,
    required this.description,
    required this.speciality,
    required this.specialityLabel,
    required this.typeWater,
    required this.typePool,
    required this.typeChrono,
    required this.isEligibleToNationalRecord,
    required this.numberOfLanes,
    required this.organizer,
    required this.hasBegun,
    required this.hasResult,
    required this.hasPassed,
    required this.level,
    required this.levelLabel,
    required this.organizerClub,
    this.refereePrincipal,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: json['Id'],
      name: json['Nom'],
      beginDate: DateTime.parse(json['Debut']),
      endDate: DateTime.parse(json['Fin']),
      beginEntryLimitDate: json['DebutEngagement'] != null
          ? DateTime.parse(json['DebutEngagement'])
          : null,
      endEntryLimitDate: DateTime.parse(json['FinEngagement']),
      location: json['Lieu'],
      status: json['Statut'],
      statusLabel: json['statutLabel'],
      description: json['Description'],
      speciality: json['Specialite'],
      specialityLabel: json['specialiteLabel'],
      typeWater: json['water'],
      typePool: json['bassin'],
      typeChrono: json['chronoLabel'],
      isEligibleToNationalRecord: json['isEligibleToNationalRecord'],
      numberOfLanes: json["numberOfLanes"] ?? 0,
      organizer: json["Organisme"]["NomOrga"],
      hasBegun: json['hasBegun'],
      hasResult: json['hasResultat'],
      hasPassed: json['hasPassed'],
      level: json['Niveau'],
      levelLabel: json["niveauLabel"],
      organizerClub: ClubModel.fromJson(
        json["Organisme"],
      ),
      refereePrincipal: json['JugePrincipal'],
    );
  }

  bool get hasRefereePrincipal =>
      refereePrincipal != null && refereePrincipal!.isNotEmpty;

  // Format date for display
  String get formattedBeginDate => DateFormat('dd/MM/yyyy').format(beginDate!);
  String get dayDateBeginDate {
    String day = DateFormat('EEE').format(beginDate!).toUpperCase();
    String date = DateFormat('dd').format(beginDate!);
    return '$day $date';
  }

  String get formattedDayBeginDate {
    return DateFormat('dd').format(beginDate!);
  }

  String get formattedEndDate => DateFormat('dd/MM/yyyy').format(endDate!);
  String get formattedBeginEntryLimitDate =>
      DateFormat('dd/MM/yyyy').format(beginEntryLimitDate!);
  String get formattedEndEntryLimitDate =>
      DateFormat('dd/MM/yyyy').format(endEntryLimitDate!);
  String get formattedBeginDateMonth =>
      DateFormat('MMM').format(beginDate!).toUpperCase();

  // Get entry status
  String get entryStatus {
    final now = DateTime.now();
    if (now.isAfter(beginEntryLimitDate!) && now.isBefore(endEntryLimitDate!)) {
      return 'open'.tr;
    } else if (now.isAfter(beginEntryLimitDate!)) {
      return 'closed'.tr;
    } else {
      return 'soon'.tr;
    }
  }

  Color get entryStatusColor {
    final now = DateTime.now();
    if (now.isAfter(beginEntryLimitDate!) && now.isBefore(endEntryLimitDate!)) {
      return Colors.green;
    } else if (now.isAfter(beginEntryLimitDate!)) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  String get competitionStatus {
    if (beginDate == null || endDate == null) {
      return 'unknown'.tr;
    }

    final now = DateTime.now();
    if (now.isAfter(beginDate!) && now.isBefore(endDate!)) {
      return 'on_going'.tr;
    } else if (now.isAfter(endDate!)) {
      return 'done'.tr;
    } else {
      return 'coming'.tr;
    }
  }

  Color get competitionStatusColor {
    if (beginDate == null || endDate == null) {
      return Colors.grey;
    }

    final now = DateTime.now();
    if (now.isAfter(beginDate!) && now.isBefore(endDate!)) {
      return Colors.amber;
    } else if (now.isAfter(endDate!)) {
      return Colors.grey;
    } else {
      return Colors.blue;
    }
  }
}
