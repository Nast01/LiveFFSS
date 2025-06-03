class ClubRanking {
  final int position;
  final String clubName;
  final int points;

  ClubRanking({
    required this.position,
    required this.clubName,
    required this.points,
  });

  factory ClubRanking.fromJson(Map<String, dynamic> json) {
    return ClubRanking(
      position: json['position'] ?? 0,
      clubName: json['clubName'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}
