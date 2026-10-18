import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/resultat_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/resultat_mapper.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

abstract class ResultRepository {
  /// Nul si la réponse ne donne pas de résultat complet.
  Future<RaceResult?> getResult(int id);

  /// Les chronos de chaque engagement d'une série (id de l'engagement →
  /// TempsLive1..3), lus en une requête plutôt qu'un résultat par couloir.
  Future<Map<int, List<int?>>> getHeatChronos(int seriesId);

  /// Crée ou met à jour [result] et rend l'id du résultat.
  Future<int> submit(RaceResult result);
}

class ResultRepositoryImpl implements ResultRepository {
  ResultRepositoryImpl(this._http);

  final HttpClient _http;

  @override
  Future<RaceResult?> getResult(int id) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.result, {
      'id': id.toString(),
    });
    final data = (await _http.get(path))['data'];
    if (data is! Map<String, dynamic>) return null;
    try {
      return ResultatDto.fromJson(data).toDomain();
    } on TypeError {
      return null;
    }
  }

  @override
  Future<Map<int, List<int?>>> getHeatChronos(int seriesId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.series, {
      'id': seriesId.toString(),
    });
    final data = (await _http.get(path))['data'];
    final rows = data is Map<String, dynamic> ? data['resultats'] : null;
    final chronos = <int, List<int?>>{};
    for (final row in rows is List ? rows : const <Object?>[]) {
      if (row is! Map<String, dynamic>) continue;
      try {
        final dto = ResultatDto.fromJson(row);
        final entryId = dto.entry?.id;
        if (entryId != null) chronos[entryId] = dto.chronos;
      } on TypeError {
        // Une ligne mal typée est écartée seule, comme dans les listes.
        continue;
      }
    }
    return chronos;
  }

  /// Les paramètres passent dans l'adresse et sans corps : un corps JSON
  /// répond HTTP 500. Tous les champs sont renvoyés à chaque fois, car un
  /// `statut` omis retombe à 3. Un chrono vide part en `''` (stocké 0).
  @override
  Future<int> submit(RaceResult result) async {
    String field(int? value) => value?.toString() ?? '';
    final body = await _http.post(
      ApiEndpoints.resultSubmit,
      query: {
        'id': ?result.id,
        'serie': result.seriesId,
        'engagement': result.entryId,
        'temps': field(result.time),
        'tempsLive1': field(result.chronos[0]),
        'tempsLive2': field(result.chronos[1]),
        'tempsLive3': field(result.chronos[2]),
        'rang': result.rank,
        'statut': result.status,
        'complement': result.complement,
        'points': field(result.points),
      },
    );
    final id = body['id'];
    final parsed = id is String ? int.tryParse(id) : id;
    if (parsed is! int) throw const ApiException('réponse sans id');
    return parsed;
  }
}

final resultRepositoryProvider = Provider<ResultRepository>(
  (ref) => ResultRepositoryImpl(ref.watch(httpClientProvider)),
);
