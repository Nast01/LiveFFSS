import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/place_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/place_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';

abstract class MeetingRepository {
  /// Les réunions d'une compétition (triées par jour puis par heure de début,
  /// avec leurs créneaux et leurs séries) et le déroulement de ses épreuves.
  Future<Programme> getProgramme(int competitionId);

  /// Un créneau et ses courses, heures posées sur [day]. Nul si la réponse ne
  /// donne pas de créneau lisible.
  Future<MeetingItem?> getMeetingItem(int itemId, {required DateTime day});

  /// Les places de [placeIds]. Une clé présente est une place lue (valeur nulle
  /// : place vide) ; une clé absente est une place en échec. Ne lève jamais
  /// pour une place.
  Future<Map<int, LaneAssignment?>> getLanes(Iterable<int> placeIds);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._http);

  final HttpClient _http;

  /// FFSS retombe à 30 lignes quand on ne demande rien, bien en dessous d'un
  /// vrai programme.
  static const int pageSize = 100;

  /// Un serveur qui ignorerait `start` renverrait la première page à l'infini,
  /// à chaque passage de la minuterie de 30 s.
  static const int maxPages = 50;

  /// Une série compte jusqu'à une dizaine de places, une page de séries une
  /// centaine : sans borne, on ouvrirait autant de connexions en parallèle.
  static const int maxConcurrentLanes = 6;

  /// Les courses viennent de la réponse `reunion` elle-même, et non de
  /// `creneau/:id/course` : cette route refuse tous les créneaux depuis le
  /// 2026-08-31, et la v1 retombait de toute façon sur ces mêmes courses.
  /// Avec un rafraîchissement toutes les 30 s, l'appeler quand même ajouterait
  /// une requête vouée à l'échec par créneau et par passage.
  @override
  Future<Programme> getProgramme(int competitionId) async {
    // Lancés ensemble : deux listes paginées l'une après l'autre doubleraient
    // l'attente à chaque passage de la minuterie.
    // Le programme passe avant la frise : sans déroulement, les séries restent
    // sans épreuve mais la page s'affiche.
    final pendingProgressions = _progressions(competitionId).catchError(
      (Object _) => const <Progression>[],
      test: (error) => error is AppException,
    );
    // Si les réunions échouent, personne n'attendra plus les déroulements :
    // leur échec ne doit pas remonter comme une erreur non traitée.
    pendingProgressions.ignore();
    final meetings = await _meetings(competitionId);
    final progressions = await pendingProgressions;
    return Programme(
      meetings: withRaces(meetings, progressions),
      progressions: progressions,
    );
  }

  @override
  Future<MeetingItem?> getMeetingItem(
    int itemId, {
    required DateTime day,
  }) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.meetingItem, {
      'id': itemId.toString(),
    });
    final data = (await _http.get(path))['data'];
    if (data is! Map<String, dynamic>) return null;
    try {
      return CreneauDto.fromJson(data).toDomain(day);
    } on TypeError {
      return null;
    }
  }

  @override
  Future<Map<int, LaneAssignment?>> getLanes(Iterable<int> placeIds) async {
    final result = <int, LaneAssignment?>{};
    final ids = placeIds.toSet().iterator;
    // Les travailleurs tirent dans le même itérateur : le code n'est pas
    // préemptif, `moveNext` + `current` sans `await` entre les deux est sûr.
    Future<void> worker() async {
      while (ids.moveNext()) {
        final id = ids.current;
        try {
          final lane = await _lane(id);
          result[id] = lane == null || lane.isEmpty ? null : lane;
        } on AppException {
          // Place absente du résultat : l'appelant la réessaiera.
        } on TypeError {
          // Corps mal typé : même traitement qu'un échec réseau.
        }
      }
    }

    await Future.wait([for (var i = 0; i < maxConcurrentLanes; i++) worker()]);
    return result;
  }

  Future<LaneAssignment?> _lane(int placeId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.lane, {
      'id': placeId.toString(),
    });
    final data = (await _http.get(path))['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('place illisible');
    }
    return PlaceDto.fromJson(data).toDomain();
  }

  Future<List<Meeting>> _meetings(int competitionId) async {
    final byId = <int, Meeting>{};
    final rows = await _pagedRows(ApiEndpoints.meetingList, competitionId);
    for (final row in rows) {
      final ReunionDto dto;
      try {
        dto = ReunionDto.fromJson(row);
      } on TypeError {
        // Une valeur au mauvais type (`Nom: 123`) : la réunion est écartée
        // seule, plutôt que de faire échouer tout le programme.
        continue;
      }
      final meeting = dto.toDomain();
      if (meeting != null) byId.putIfAbsent(meeting.id, () => meeting);
    }
    return byId.values.toList()..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) return byDay;
      final byTime = (a.startTime ?? a.day).compareTo(b.startTime ?? b.day);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  }

  Future<List<Progression>> _progressions(int competitionId) async {
    final byId = <int, Progression>{};
    final rows = await _pagedRows(ApiEndpoints.progressionList, competitionId);
    for (final row in rows) {
      final DeroulementDto dto;
      try {
        dto = DeroulementDto.fromJson(row);
      } on TypeError {
        // Une partie qui n'est pas un objet : le déroulement est écarté seul.
        continue;
      }
      final progression = dto.toDomain();
      if (progression != null) {
        byId.putIfAbsent(progression.id, () => progression);
      }
    }
    return byId.values.toList();
  }

  /// Les lignes objet de toutes les pages d'une liste de la compétition.
  Future<List<Map<String, dynamic>>> _pagedRows(
    String endpoint,
    int competitionId,
  ) async {
    final path = ApiEndpoints.replacePath(endpoint, {
      'id': competitionId.toString(),
    });
    final rows = <Map<String, dynamic>>[];
    for (var page = 0; page < maxPages; page++) {
      final body = await _http.get(
        path,
        query: {'start': page * pageSize, 'length': pageSize},
      );
      final data = body['data'];
      final raw = data is List ? data : const <Object?>[];
      rows.addAll(raw.whereType<Map<String, dynamic>>());
      // Compté sur les entrées brutes : une entrée non-objet ne doit pas faire
      // passer une page pleine pour la dernière.
      if (raw.length < pageSize) break;
    }
    return rows;
  }
}

final meetingRepositoryProvider = Provider<MeetingRepository>(
  (ref) => MeetingRepositoryImpl(ref.watch(httpClientProvider)),
);
