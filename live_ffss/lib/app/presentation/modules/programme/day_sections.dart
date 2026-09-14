import 'package:live_ffss/app/domain/models/meeting.dart';

/// Une course d'un créneau, telle que l'éditeur l'affiche.
class DayEntry {
  const DayEntry({
    required this.begin,
    required this.end,
    required this.label,
    this.slotId,
    this.runId,
  });

  final DateTime begin;
  final DateTime end;
  final String label;

  /// Le créneau qui porte cette ligne.
  final int? slotId;

  /// La course qui porte cette ligne.
  final int? runId;
}

/// Un item de la réunion : un créneau, avec ses courses s'il en porte.
///
/// Le créneau est l'unité, pas la course : c'est lui que FFSS positionne dans
/// la journée — il ne porte aucun rang, son heure de début EST sa place — et
/// ses courses le suivent.
class MeetingItem {
  const MeetingItem({
    required this.slotId,
    required this.label,
    required this.begin,
    required this.end,
    required this.courses,
  });

  final int slotId;
  final String label;
  final DateTime begin;
  final DateTime end;

  /// Les courses du créneau, en ordre de passage. Vide pour un item manuel.
  final List<DayEntry> courses;

  bool get isManual => courses.isEmpty;
}

/// Les items d'une réunion, ordonnés par leur heure de début.
List<MeetingItem> meetingItems(Meeting? meeting) {
  if (meeting == null) return const [];

  final items = <MeetingItem>[];
  for (final slot in meeting.slots) {
    final ordered = [...slot.runs]
      ..sort((a, b) => a.beginTime.compareTo(b.beginTime));
    items.add(MeetingItem(
      slotId: slot.id,
      label: slot.name,
      begin: slot.beginHour,
      end: slot.endHour,
      courses: [
        for (final run in ordered)
          DayEntry(
            begin: run.beginTime,
            end: run.endTime,
            label: run.fullLabel,
            slotId: slot.id,
            runId: run.id,
          ),
      ],
    ));
  }
  items.sort((a, b) => a.begin.compareTo(b.begin));
  return items;
}
