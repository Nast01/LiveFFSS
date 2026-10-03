import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class Entry with _$Entry {
  const factory Entry({
    required int id,
    @Default(0) int raceId,
    required Category category,
    Club? organisme,
    required int status,
    required String statusLabel,
    @Default(0) int entryTime,
    @Default('') String entryTimeLabel,
    @Default(false) bool isForfeit,
    @Default(<Athlete>[]) List<Athlete> athletes,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}

/// Les mêmes engagements, chaque athlète portant le club que [clubs] lui
/// associe ; un athlète absent de l'index garde ce qu'il avait.
///
/// Les engagements arrivent de `competition/engagement` **sans club** — aucun
/// mapper n'en pose — et c'est pourtant ce club que chaque ligne affiche, par
/// son logo ou son bonnet. Quatre contrôleurs déroulaient cette boucle à
/// l'identique ; `ClubRepository.withAthleteClubs` l'enchaîne avec la lecture,
/// et cette fonction-ci reste pour qui détient déjà l'index.
List<Entry> entriesWithClubs(List<Entry> entries, Map<int, Club> clubs) => [
      for (final entry in entries)
        entry.copyWith(
          athletes: [
            for (final athlete in entry.athletes)
              athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
          ],
        ),
    ];
