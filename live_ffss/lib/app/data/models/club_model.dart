class ClubModel {
  final int id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? capUrl;

  ClubModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.capUrl,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['Id'],
      name: json['NomCompletOrga'],
      shortName: json['NomCourt'],
      logoUrl: json['logo'],
      capUrl: json['bonnet'],
    );
  }

  // Check if has logo
  bool get hasLogo => logoUrl?.isNotEmpty == true;

  // Check if has cap
  bool get hasCap => capUrl?.isNotEmpty == true;
}
