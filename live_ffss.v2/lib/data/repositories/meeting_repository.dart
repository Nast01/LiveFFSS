import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/meeting.dart';

abstract class MeetingRepository {
  /// Les réunions d'une compétition, avec leurs créneaux et leurs séries,
  /// triées par jour puis par heure de début.
  Future<List<Meeting>> getMeetings(int competitionId);
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

  /// Les courses viennent de la réponse `reunion` elle-même, et non de
  /// `creneau/:id/course` : cette route refuse tous les créneaux depuis le
  /// 2026-08-31, et la v1 retombait de toute façon sur ces mêmes courses.
  /// Avec un rafraîchissement toutes les 30 s, l'appeler quand même ajouterait
  /// une requête vouée à l'échec par créneau et par passage.
  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.meetingList, {
      'id': competitionId.toString(),
    });
    final byId = <int, Meeting>{};
    for (var page = 0; page < maxPages; page++) {
      final start = page * pageSize;
      final body = await _http.get(
        path,
        query: {'start': start, 'length': pageSize},
      );
      final data = body['data'];
      final raw = data is List ? data : const <Object?>[];
      for (final row in raw.whereType<Map<String, dynamic>>()) {
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
      // Compté sur les entrées brutes : une entrée non-objet ne doit pas faire
      // passer une page pleine pour la dernière.
      if (raw.length < pageSize) break;
    }
    return byId.values.toList()..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) return byDay;
      final byTime = (a.startTime ?? a.day).compareTo(b.startTime ?? b.day);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  }
}

final meetingRepositoryProvider = Provider<MeetingRepository>(
  (ref) => MeetingRepositoryImpl(ref.watch(httpClientProvider)),
);
