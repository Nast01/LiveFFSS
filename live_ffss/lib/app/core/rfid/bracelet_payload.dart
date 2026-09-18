import 'package:live_ffss/app/domain/models/athlete.dart';

/// Field separator for the bracelet payload. The future attendance scanner
/// splits on this, so it must never appear inside a field.
const braceletFieldSeparator = ';';

/// The exact string written to an RFID bracelet:
/// `<licenseeNumber>;<lastName>` — plus `;<orderNumber>` when the athlete has
/// a bib.
///
/// The bib comes last so that a bracelet written before it existed stays
/// readable: the licence is still the first field.
String braceletPayload(Athlete athlete) {
  final lastName = athlete.lastName.replaceAll(braceletFieldSeparator, ' ');
  final base = '${athlete.licenseeNumber}$braceletFieldSeparator$lastName';
  if (athlete.orderNumber <= 0) return base;
  return '$base$braceletFieldSeparator${athlete.orderNumber}';
}

/// The licence number carried by a bracelet payload (`<licence>;<lastName>`) —
/// the field the attendance scanner matches against [Athlete.licenseeNumber].
String parseBraceletLicence(String payload) =>
    payload.split(braceletFieldSeparator).first.trim();

/// The bib carried by a bracelet payload, 0 when it carries none — a bracelet
/// written before bibs existed, or a third field that is not a number.
int parseBraceletOrderNumber(String payload) {
  final fields = payload.split(braceletFieldSeparator);
  if (fields.length < 3) return 0;
  return int.tryParse(fields[2].trim()) ?? 0;
}
