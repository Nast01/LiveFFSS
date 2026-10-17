final RegExp _ffssTime = RegExp(r'''^(\d+)'(\d{2})"(\d{2})$''');

/// Un temps tel que FFSS le publie (`MM'SS"CC`, ex. « 02'43"30 ») en
/// centièmes de seconde. La place ne porte que ce libellé, et la place dans
/// la série se calcule sur ce temps. Nul s'il est absent ou illisible : la
/// ligne reste affichée, sans place.
int? parseFfssTime(String? raw) {
  final match = _ffssTime.firstMatch(raw?.trim() ?? '');
  if (match == null) return null;
  final minutes = int.parse(match[1]!);
  final seconds = int.parse(match[2]!);
  final hundredths = int.parse(match[3]!);
  if (seconds > 59) return null;
  return (minutes * 60 + seconds) * 100 + hundredths;
}
