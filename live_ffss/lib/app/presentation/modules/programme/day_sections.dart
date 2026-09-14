import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';

/// A single item on the day's réunion: either a course (a [Slot]'s [Run]) or,
/// when a créneau carries no course, the créneau itself — a manual item shown
/// at its own `beginHour`/`endHour`.
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

  /// The créneau backing this row. Always set for a manual item — the only
  /// kind [daySections] lets the editor resize. [meetingItems] also sets it
  /// on a course entry, so its caller can tell which créneau a course row
  /// belongs to; [daySections] leaves it null there.
  final int? slotId;

  /// The course backing this row, set only for a course entry.
  final int? runId;
}

/// A group of [DayEntry]s sharing a site — [Run.site] for course entries, or
/// the générique bucket for manual (course-less) créneaux, which carry no site
/// of their own.
class DaySection {
  const DaySection({
    required this.title,
    required this.items,
    this.isManual = false,
  });

  /// The site name, empty for the manual bucket: naming that one is a display
  /// concern, and keeping it out leaves this file free of translations.
  final String title;
  final List<DayEntry> items;

  /// The créneaux with no course. They belong to no site — a lunch break or a
  /// prize-giving concerns the whole day — so a site filter never hides them.
  final bool isManual;
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

/// Feeds the read-only competition-detail Programme tab. That screen shows
/// whatever FFSS actually holds — a réunion authored on the federal site, or
/// by the old flow, can legitimately mix sites — so it still needs the
/// per-site grouping the editor no longer does. Splits the réunion's
/// créneaux into per-[Run.site] sections, ordered by their earliest item so
/// the day reads top to bottom.
List<DaySection> daySections(Meeting? meeting) {
  if (meeting == null) return const [];

  final bySite = <String, List<DayEntry>>{};
  final manual = <DayEntry>[];
  for (final slot in meeting.slots) {
    if (slot.runs.isEmpty) {
      manual.add(DayEntry(
        begin: slot.beginHour,
        end: slot.endHour,
        label: slot.name,
        slotId: slot.id,
      ));
      continue;
    }
    for (final run in slot.runs) {
      (bySite[run.site] ??= []).add(DayEntry(
        begin: run.beginTime,
        end: run.endTime,
        label: run.fullLabel,
        runId: run.id,
      ));
    }
  }

  final sections = [
    for (final entry in bySite.entries)
      DaySection(title: entry.key, items: entry.value..sort(_byBegin)),
    if (manual.isNotEmpty)
      DaySection(title: '', items: manual..sort(_byBegin), isManual: true),
  ];
  sections.sort((a, b) => a.items.first.begin.compareTo(b.items.first.begin));
  return sections;
}

/// Feeds the meeting editor, where this app is the author. A réunion it
/// creates has exactly one site, so per-site grouping has no work left to
/// do — instead this flattens the réunion into its ordered créneaux, each
/// carrying its courses, because the créneau (not the course) is what a
/// drag-and-drop reorder moves.
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

int _byBegin(DayEntry a, DayEntry b) => a.begin.compareTo(b.begin);
