import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/write_queue.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/features/settings/reminder_lead.dart';

part 'follows_providers.freezed.dart';
part 'follows_providers.g.dart';

/// La forme enregistrée de [Follows] : le domaine reste sans JSON.
@freezed
abstract class FollowsDto with _$FollowsDto {
  const factory FollowsDto({
    List<FollowedAthleteDto>? athletes,
    List<FollowedClubDto>? clubs,
  }) = _FollowsDto;

  factory FollowsDto.fromJson(Map<String, dynamic> json) =>
      _$FollowsDtoFromJson(json);

  factory FollowsDto.fromDomain(Follows follows) => FollowsDto(
    athletes: [
      for (final a in follows.athletes)
        FollowedAthleteDto(
          participantId: a.participantId,
          name: a.name,
          club: a.club,
          entryIds: a.entryIds,
          eventIds: a.eventIds,
        ),
    ],
    clubs: [
      for (final c in follows.clubs) FollowedClubDto(id: c.id, label: c.label),
    ],
  );
}

@freezed
abstract class FollowedAthleteDto with _$FollowedAthleteDto {
  const factory FollowedAthleteDto({
    int? participantId,
    String? name,
    String? club,
    List<int>? entryIds,

    /// Absente d'un suivi enregistré avant qu'on les garde.
    List<int>? eventIds,
  }) = _FollowedAthleteDto;

  factory FollowedAthleteDto.fromJson(Map<String, dynamic> json) =>
      _$FollowedAthleteDtoFromJson(json);
}

@freezed
abstract class FollowedClubDto with _$FollowedClubDto {
  const factory FollowedClubDto({int? id, String? label}) = _FollowedClubDto;

  factory FollowedClubDto.fromJson(Map<String, dynamic> json) =>
      _$FollowedClubDtoFromJson(json);
}

extension FollowedAthleteDtoMapper on FollowedAthleteDto {
  /// Nul sans identifiant ou sans nom : la ligne ne pourrait ni marquer une
  /// place ni se retirer.
  FollowedAthlete? toDomain() {
    final id = participantId;
    final name = this.name;
    if (id == null || name == null) return null;
    return FollowedAthlete(
      participantId: id,
      name: name,
      club: club ?? '',
      entryIds: entryIds ?? const [],
      eventIds: eventIds ?? const [],
    );
  }
}

extension FollowedClubDtoMapper on FollowedClubDto {
  FollowedClub? toDomain() {
    final id = this.id;
    final label = this.label;
    return id == null || label == null
        ? null
        : FollowedClub(id: id, label: label);
  }
}

/// Les athlètes et clubs suivis d'une compétition, gardés sur l'appareil
/// sous `follows_<id>` ([LocalStore] y ajoute le préfixe de l'environnement).
class FollowsNotifier extends AsyncNotifier<Follows> {
  FollowsNotifier(this.competitionId);

  final int competitionId;

  final _writes = WriteQueue();

  /// Se termine quand les écritures déjà demandées sont finies.
  Future<void> get writesDone => _writes.idle;

  String get storageKey => storageKeyOf(competitionId);

  static String storageKeyOf(int competitionId) => 'follows_$competitionId';

  @override
  Future<Follows> build() async {
    try {
      return _decode(await ref.watch(localStoreProvider).read(storageKey));
    } on AppException {
      // Une lecture en panne ne doit pas fermer la compétition : on repart
      // de rien, comme pour une valeur illisible.
      return const Follows();
    }
  }

  Future<void> toggleAthlete(Participant participant) => _update((current) {
    final others = [
      for (final a in current.athletes)
        if (a.participantId != participant.id) a,
    ];
    return current.copyWith(
      athletes: others.length == current.athletes.length
          ? [...others, FollowedAthlete.fromParticipant(participant)]
          : others,
    );
  });

  /// Le retrait depuis « Mes suivis », qui n'a que l'athlète suivi, pas le
  /// participant : relire les participants (3,6 Mo) pour une étoile serait
  /// démesuré.
  Future<void> unfollowAthlete(int participantId) => _update(
    (current) => current.copyWith(
      athletes: [
        for (final a in current.athletes)
          if (a.participantId != participantId) a,
      ],
    ),
  );

  Future<void> toggleClub(int id, String label) => _update((current) {
    final others = [
      for (final c in current.clubs)
        if (c.id != id) c,
    ];
    return current.copyWith(
      clubs: others.length == current.clubs.length
          ? [...others, FollowedClub(id: id, label: label)]
          : others,
    );
  });

  /// L'état d'abord : un stockage en panne ne doit pas défaire le choix de
  /// l'utilisateur, il le perdra seulement à la fermeture de l'app.
  Future<void> _update(Follows Function(Follows current) change) async {
    final next = change(state.value ?? await future);
    state = AsyncData(next);
    final local = ref.read(localStoreProvider);
    await _writes.run(() async {
      try {
        await local.write(storageKey, jsonEncode(FollowsDto.fromDomain(next)));
      } on AppException {
        // Choix gardé en mémoire.
      }
    });
  }

  /// Une valeur illisible vaut « aucun suivi » : comme pour les favoris,
  /// mieux vaut les perdre qu'une compétition qui ne s'ouvre plus.
  static Follows _decode(String? raw) {
    if (raw == null) return const Follows();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const Follows();
      // Chaque ligne seule : une ligne abîmée ne fait pas perdre les autres.
      final athletes = decoded['athletes'];
      final clubs = decoded['clubs'];
      return Follows(
        athletes: athletes is List<Object?>
            ? decodeRows(
                athletes,
                FollowedAthleteDto.fromJson,
                (FollowedAthleteDto d) => d.toDomain(),
              )
            : const [],
        clubs: clubs is List<Object?>
            ? decodeRows(
                clubs,
                FollowedClubDto.fromJson,
                (FollowedClubDto d) => d.toDomain(),
              )
            : const [],
      );
    } on FormatException {
      return const Follows();
    }
  }
}

final followsProvider =
    AsyncNotifierProvider.family<FollowsNotifier, Follows, int>(
      FollowsNotifier.new,
    );

/// L'étoile de la fiche : suivre un athlète, rappels actifs, demande la
/// permission si elle manque. La page passe le conteneur de son
/// `ProviderScope`.
Future<void> toggleAthleteFollow(
  ProviderContainer container,
  int competitionId,
  Participant participant,
) async {
  final follows = container.read(followsProvider(competitionId).notifier);
  await follows.toggleAthlete(participant);
  final followed =
      container
          .read(followsProvider(competitionId))
          .value
          ?.followsAthlete(participant.id) ??
      false;
  if (followed) {
    await container.read(reminderLeadProvider.notifier).ensurePermission();
  }
}
