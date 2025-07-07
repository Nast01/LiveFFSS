class DisciplineModel {
  late String id;
  late String name;
  late int speciality;
  late String specialityLabel;
  late int distance;
  late int numberOfAthletes;
  late bool isRelay;
  late bool hasTime;

  DisciplineModel({
    required this.id,
    required this.name,
    required this.speciality,
    required this.specialityLabel,
    required this.distance,
    required this.numberOfAthletes,
    required this.isRelay,
    required this.hasTime,
  });

  factory DisciplineModel.fromJson(Map<String, dynamic> json) {
    return DisciplineModel(
      id: json['Id'],
      name: json['Nom'],
      speciality: json['specialite'],
      specialityLabel: json['specialiteLabel'] ?? '',
      distance: json['distance'] ?? 0,
      numberOfAthletes: json['nbAthleteParEquipe'] ?? 0,
      isRelay: json['isRelais'] ?? false,
      hasTime: json['hasTemps'] ?? false,
    );
  }
}
