/// Le jour d'une date FFSS (`Y-m-d` ou `Y-m-d H:i:s`), à minuit local.
DateTime? parseFfssDay(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// L'heure FFSS [raw] (`HH:mm`, `HH:mm:ss`, ou une date-heure complète) posée
/// sur [day]. Nulle si elle est illisible : une heure mal formée ne doit pas
/// faire disparaître la série qui la porte.
DateTime? atFfssTime(DateTime day, String? raw) {
  if (raw == null) return null;
  var text = raw.trim();
  final space = text.indexOf(' ');
  if (space >= 0) text = text.substring(space + 1);
  final parts = text.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) return null;
  return DateTime(day.year, day.month, day.day, hour, minute);
}
