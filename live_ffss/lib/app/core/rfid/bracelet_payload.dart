import 'package:live_ffss/app/domain/models/athlete.dart';

/// Field separator for the bracelet payload. The future attendance scanner
/// splits on this, so it must never appear inside a field.
const braceletFieldSeparator = ';';

/// The exact string written to an RFID bracelet: `<licenseeNumber>;<lastName>`.
///
/// This is the contract shared with the (not yet built) bracelet scanner —
/// change it here and the reader changes with it.
String braceletPayload(Athlete athlete) {
  final lastName =
      athlete.lastName.replaceAll(braceletFieldSeparator, ' ');
  return '${athlete.licenseeNumber}$braceletFieldSeparator$lastName';
}
