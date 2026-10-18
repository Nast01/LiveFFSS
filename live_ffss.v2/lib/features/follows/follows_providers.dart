import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';

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

extension FollowsDtoMapper on FollowsDto {
  /// Une ligne sans identifiant ou sans nom est écartée : elle ne pourrait
  /// ni marquer une ligne ni se retirer.
  Follows toDomain() => Follows(
    athletes: [
      for (final a in athletes ?? const <FollowedAthleteDto>[])
        if (a.participantId case final id? when a.name != null)
          FollowedAthlete(
            participantId: id,
            name: a.name!,
            club: a.club ?? '',
            entryIds: a.entryIds ?? const [],
          ),
    ],
    clubs: [
      for (final c in clubs ?? const <FollowedClubDto>[])
        if (c.id case final id? when c.label != null)
          FollowedClub(id: id, label: c.label!),
    ],
  );
}

/// Les athlètes et clubs suivis d'une compétition, gardés sur l'appareil
/// sous `follows_<id>` ([LocalStore] y ajoute le préfixe de l'environnement).
class FollowsNotifier extends AsyncNotifier<Follows> {
  FollowsNotifier(this.competitionId);

  final int competitionId;

  String get storageKey => 'follows_$competitionId';

  @override
  Future<Follows> build() async =>
      _decode(await ref.watch(localStoreProvider).read(storageKey));

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
    try {
      await local.write(storageKey, jsonEncode(FollowsDto.fromDomain(next)));
    } on AppException {
      // Choix gardé en mémoire.
    }
  }

  /// Une valeur illisible vaut « aucun suivi » : comme pour les favoris,
  /// mieux vaut les perdre qu'une compétition qui ne s'ouvre plus.
  static Follows _decode(String? raw) {
    if (raw == null) return const Follows();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const Follows();
      return FollowsDto.fromJson(decoded).toDomain();
    } on FormatException {
      return const Follows();
    } on TypeError {
      return const Follows();
    }
  }
}

final followsProvider =
    AsyncNotifierProvider.family<FollowsNotifier, Follows, int>(
      FollowsNotifier.new,
    );
