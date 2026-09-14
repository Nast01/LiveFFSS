import 'package:live_ffss/app/domain/models/slot.dart';

/// Minutes depuis minuit, en ignorant la date portée par [t].
///
/// Les horaires d'un [Slot] ou d'une course sont parsés d'un `HH:mm` nu et
/// atterrissent sur 1970-01-01, alors que `Meeting.beginHour` porte la vraie
/// date de la réunion : les comparer en `DateTime` se lirait toujours comme
/// « avant ». Tout ce que fait une réunion tient dans une journée, donc les
/// minutes suffisent — et les mappers, partagés avec d'autres modules,
/// restent intouchés.
int minutesOf(DateTime t) => t.hour * 60 + t.minute;

/// Une course, une fois la réunion posée bout à bout.
class TimetableRun {
  const TimetableRun({
    required this.runId,
    required this.beginMinutes,
    required this.endMinutes,
  });

  final int runId;
  final int beginMinutes;
  final int endMinutes;
}

/// Un item de la réunion — un créneau — une fois la réunion posée bout à bout.
class TimetableItem {
  const TimetableItem({
    required this.slotId,
    required this.beginMinutes,
    required this.endMinutes,
    required this.runs,
  });

  final int slotId;
  final int beginMinutes;
  final int endMinutes;

  /// Les courses du créneau, en ordre de passage. Vide pour un item manuel.
  final List<TimetableRun> runs;
}

/// Une réunion posée bout à bout depuis son heure de début.
class Timetable {
  const Timetable({required this.items, required this.endMinutes});

  final List<TimetableItem> items;

  /// La fin de la réunion : la fin de son dernier item, ou son heure de début
  /// quand elle n'en porte aucun — une réunion vide ne « dure » pas.
  final int endMinutes;
}

/// Pose [slots] bout à bout depuis [startMinutes], dans l'ordre donné, en
/// conservant la durée de chacun.
///
/// L'ordre donné EST l'ordre posé : un créneau ne porte aucun rang côté FFSS,
/// son heure de début est sa place dans la journée. Réordonner et recompacter
/// sont donc le même geste.
Timetable layOut(List<Slot> slots, int startMinutes) {
  final items = <TimetableItem>[];
  var cursor = startMinutes;

  for (final slot in slots) {
    final ordered = [...slot.runs]
      ..sort((a, b) => a.beginTime.compareTo(b.beginTime));

    // Un créneau portant des courses est exactement aussi long qu'elles.
    // Lire sa propre étendue garderait la place qu'une course supprimée
    // occupait : FFSS conserve l'étendue avec laquelle il a été créé.
    final duration = ordered.isEmpty
        ? minutesOf(slot.endHour) - minutesOf(slot.beginHour)
        : ordered.fold<int>(
            0,
            (sum, run) =>
                sum + minutesOf(run.endTime) - minutesOf(run.beginTime),
          );

    var runCursor = cursor;
    final runs = <TimetableRun>[];
    for (final run in ordered) {
      final runDuration = minutesOf(run.endTime) - minutesOf(run.beginTime);
      runs.add(TimetableRun(
        runId: run.id,
        beginMinutes: runCursor,
        endMinutes: runCursor + runDuration,
      ));
      runCursor += runDuration;
    }

    items.add(TimetableItem(
      slotId: slot.id,
      beginMinutes: cursor,
      endMinutes: cursor + duration,
      runs: runs,
    ));
    cursor += duration;
  }

  return Timetable(items: items, endMinutes: cursor);
}

/// Une écriture à envoyer pour que FFSS corresponde à la cible.
class TimetableMove {
  const TimetableMove({
    required this.slotId,
    required this.beginMinutes,
    required this.endMinutes,
    this.runId,
  });

  final int slotId;

  /// Null pour le créneau lui-même, renseigné pour une de ses courses.
  final int? runId;
  final int beginMinutes;
  final int endMinutes;
}

/// Les seuls items dont l'horaire diffère entre ce que FFSS porte ([current])
/// et [target].
///
/// Ne rendre que ce qui bouge n'est pas une optimisation gratuite : sur une
/// journée de vingt items, supprimer le dernier ne doit pas réécrire les
/// dix-neuf d'avant. Un item de [target] absent de [current] est ignoré —
/// rien à déplacer sur un serveur qui ne l'a pas.
List<TimetableMove> moves(List<Slot> current, Timetable target) {
  final bySlotId = {for (final slot in current) slot.id: slot};
  final result = <TimetableMove>[];

  for (final item in target.items) {
    final slot = bySlotId[item.slotId];
    if (slot == null) continue;

    if (minutesOf(slot.beginHour) != item.beginMinutes ||
        minutesOf(slot.endHour) != item.endMinutes) {
      result.add(TimetableMove(
        slotId: item.slotId,
        beginMinutes: item.beginMinutes,
        endMinutes: item.endMinutes,
      ));
    }

    final byRunId = {for (final run in slot.runs) run.id: run};
    for (final run in item.runs) {
      final held = byRunId[run.runId];
      if (held == null) continue;
      // La fin compte autant que le début : un raccourcissement laisse le
      // début en place et doit tout de même partir.
      if (minutesOf(held.beginTime) != run.beginMinutes ||
          minutesOf(held.endTime) != run.endMinutes) {
        result.add(TimetableMove(
          slotId: item.slotId,
          runId: run.runId,
          beginMinutes: run.beginMinutes,
          endMinutes: run.endMinutes,
        ));
      }
    }
  }

  return result;
}
