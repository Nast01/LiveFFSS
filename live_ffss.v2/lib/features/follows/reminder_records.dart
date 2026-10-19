import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/core/storage/write_queue.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';

part 'reminder_records.freezed.dart';
part 'reminder_records.g.dart';

// Ce que les rappels gardent sur l'appareil pour se calculer au lancement
// sans lire le réseau : l'athlète du compte connecté et les séries connues.
// Sous des clés par compétition, que [LocalStore] préfixe par environnement.
//
// Chaque modification attend la fin de `build` : posée avant, elle serait
// écrasée par la valeur que `build` avait lue plus tôt.

@freezed
abstract class KnownHeatDto with _$KnownHeatDto {
  const factory KnownHeatDto({int? entryId, int? eventId, int? heatId}) =
      _KnownHeatDto;

  factory KnownHeatDto.fromJson(Map<String, dynamic> json) =>
      _$KnownHeatDtoFromJson(json);
}

/// L'athlète du compte connecté, et ce compte : enregistré par un autre, il
/// ne vaut plus.
@freezed
abstract class SelfAthleteDto with _$SelfAthleteDto {
  const factory SelfAthleteDto({String? account, FollowedAthleteDto? athlete}) =
      _SelfAthleteDto;

  factory SelfAthleteDto.fromJson(Map<String, dynamic> json) =>
      _$SelfAthleteDtoFromJson(json);
}

typedef KnownHeat = ({int entryId, int eventId, int heatId});

/// La course de chaque engagement, apprise d'une fiche (série rattachée) ou
/// de « Trouver sa série ». La dernière apprise l'emporte : une finale
/// remplace la série du tour. Seuls les engagements des athlètes suivis et
/// de l'athlète connecté sont gardés : les rappels ne visent qu'eux, et la
/// page d'un club, qui lit la fiche de chacun de ses nageurs, remplirait
/// sinon l'appareil.
class KnownHeatsNotifier extends AsyncNotifier<KnownHeats> {
  KnownHeatsNotifier(this.competitionId);

  final int competitionId;

  final _writes = WriteQueue();

  /// Se termine quand les écritures déjà demandées sont finies.
  Future<void> get writesDone => _writes.idle;

  String get storageKey => storageKeyOf(competitionId);

  static String storageKeyOf(int competitionId) => 'known_heats_$competitionId';

  @override
  Future<KnownHeats> build() async {
    try {
      return _decode(await ref.watch(localStoreProvider).read(storageKey));
    } on AppException {
      return const {};
    }
  }

  /// Rien n'est écrit si rien ne change : une fiche relue redonne les mêmes.
  Future<void> record(Iterable<KnownHeat> heats) async {
    if (heats.isEmpty) return;
    final reminded = await _remindedEntries();
    if (!ref.mounted) return;
    final kept = [
      for (final heat in heats)
        if (reminded.contains(heat.entryId)) heat,
    ];
    if (kept.isEmpty) return;
    await future;
    if (!ref.mounted) return;
    // Lu après la dernière attente : deux enregistrements simultanés
    // partent chacun de ce que l'autre a posé.
    final current = state.value ?? const {};
    final next = {
      ...current,
      for (final heat in kept)
        (entryId: heat.entryId, eventId: heat.eventId): heat.heatId,
    };
    if (mapEquals(current, next)) return;
    state = AsyncData(next);
    final store = ref.read(localStoreProvider);
    await _writes.run(() async {
      try {
        await store.write(
          storageKey,
          jsonEncode([
            for (final MapEntry(:key, :value) in next.entries)
              KnownHeatDto(
                entryId: key.entryId,
                eventId: key.eventId,
                heatId: value,
              ),
          ]),
        );
      } on AppException {
        // Gardées en mémoire.
      }
    });
  }

  /// Les engagements des athlètes suivis et de l'athlète connecté. Une
  /// lecture en échec n'en donne aucun : la série sera apprise à la
  /// prochaine fiche.
  Future<Set<int>> _remindedEntries() async {
    final followsRead = ref.read(followsProvider(competitionId).future);
    final selfRead = ref.read(selfAthleteProvider(competitionId).future)
      ..ignore();
    final Follows follows;
    try {
      follows = await followsRead;
    } on AppException {
      return const {};
    }
    FollowedAthlete? self;
    try {
      self = await selfRead;
    } on AppException {
      self = null;
    }
    return {
      for (final athlete in [?self, ...follows.athletes]) ...athlete.entryIds,
    };
  }

  /// Une valeur illisible vaut « aucune » : on retombe sur l'heure du tour.
  static KnownHeats _decode(String? raw) {
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<Object?>) return const {};
      return {
        for (final dto in decodeRows(
          decoded,
          KnownHeatDto.fromJson,
          (KnownHeatDto d) => d,
        ))
          if ((dto.entryId, dto.eventId, dto.heatId) case (
            final entryId?,
            final eventId?,
            final heatId?,
          ))
            (entryId: entryId, eventId: eventId): heatId,
      };
    } on FormatException {
      return const {};
    }
  }
}

final knownHeatsProvider =
    AsyncNotifierProvider.family<KnownHeatsNotifier, KnownHeats, int>(
      KnownHeatsNotifier.new,
    );

/// L'athlète du compte connecté sur la compétition, enregistré quand
/// « Mes espaces » le trouve parmi les participants : les rappels le
/// retrouvent au lancement sans relire les participants (3,6 Mo). Suit la
/// session : une déconnexion ou un autre compte l'efface.
class SelfAthleteNotifier extends AsyncNotifier<FollowedAthlete?> {
  SelfAthleteNotifier(this.competitionId);

  final int competitionId;

  final _writes = WriteQueue();

  /// Se termine quand les écritures déjà demandées sont finies.
  Future<void> get writesDone => _writes.idle;

  String get storageKey => storageKeyOf(competitionId);

  static String storageKeyOf(int competitionId) =>
      'reminder_self_$competitionId';

  @override
  Future<FollowedAthlete?> build() async {
    final store = ref.watch(localStoreProvider);
    final account = await ref.watch(sessionProvider.future);
    final SelfAthleteDto? record;
    try {
      record = _decode(await store.read(storageKey));
    } on AppException {
      return null;
    }
    if (record == null) return null;
    final owner = record.account;
    if (account == null ||
        owner == null ||
        !isSameAccount(owner, account.label)) {
      await _delete(store);
      return null;
    }
    return record.athlete?.toDomain();
  }

  Future<void> save(String account, Participant participant) async {
    final athlete = FollowedAthlete.fromParticipant(participant);
    if (!await _settled()) return;
    if (state.value == athlete) return;
    state = AsyncData(athlete);
    final store = ref.read(localStoreProvider);
    await _writes.run(() async {
      try {
        await store.write(
          storageKey,
          jsonEncode(
            SelfAthleteDto(
              account: account,
              athlete: FollowedAthleteDto(
                participantId: athlete.participantId,
                name: athlete.name,
                club: athlete.club,
                entryIds: athlete.entryIds,
                eventIds: athlete.eventIds,
              ),
            ),
          ),
        );
      } on AppException {
        // Gardé en mémoire.
      }
    });
  }

  Future<void> clear() async {
    if (!await _settled()) return;
    if (state.hasValue && state.value == null) return;
    state = const AsyncData(null);
    final store = ref.read(localStoreProvider);
    await _writes.run(() => _delete(store));
  }

  /// Attend la fin de `build`, même en échec : faux si le fournisseur a été
  /// jeté entre-temps.
  Future<bool> _settled() async {
    try {
      await future;
    } on AppException {
      // L'échec est dans l'état, que la modification remplace.
    }
    return ref.mounted;
  }

  Future<void> _delete(LocalStore store) async {
    try {
      await store.delete(storageKey);
    } on AppException {
      // Ignoré à la prochaine lecture si le compte a changé.
    }
  }

  static SelfAthleteDto? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return SelfAthleteDto.fromJson(decoded);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

final selfAthleteProvider =
    AsyncNotifierProvider.family<SelfAthleteNotifier, FollowedAthlete?, int>(
      SelfAthleteNotifier.new,
    );
