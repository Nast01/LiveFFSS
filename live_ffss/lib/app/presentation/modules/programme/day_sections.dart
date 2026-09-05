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

  /// The créneau backing this row, set only for a manual item — the only kind
  /// the editor can resize. A course's duration comes from its round.
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

/// Splits the réunion's créneaux into per-[Run.site] sections. Sections are
/// ordered by their earliest item so the day reads top to bottom.
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

int _byBegin(DayEntry a, DayEntry b) => a.begin.compareTo(b.begin);
