import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/referee_model.dart';

class ClubModel {
  final int id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? capUrl;
  late List<AthleteModel> athletes = [];
  late List<RefereeModel> referees = [];

  ClubModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.capUrl,
    this.athletes = const [],
    this.referees = const [],
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    ClubModel clubModel = ClubModel(
      id: json['Id'],
      name: json['NomCompletOrga'],
      shortName: json['NomCourt'],
      logoUrl: json['logo'],
      capUrl: json['bonnet'],
    );
    // If athletes or referees are present, parse them
    if (json['athletes'] != null) {
      clubModel.athletes = (json['athletes'] as List<dynamic>)
          .map((athlete) => AthleteModel.fromJson(
                athlete,
              ))
          .toList();
    }

    if (json['officiels'] != null) {
      clubModel.referees = (json['officiels'] as List<dynamic>)
          .map((referee) => RefereeModel.fromJson(referee))
          .toList();
    }
    return clubModel;
  }

  // Check if has logo
  bool get hasLogo => logoUrl?.isNotEmpty == true;

  // Check if has cap
  bool get hasCap => capUrl?.isNotEmpty == true;
}
