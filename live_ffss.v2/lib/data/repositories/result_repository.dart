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

  /// Les résultats d'une série par engagement, en une requête, pour
  /// l'affichage (`toHeatResult`) : jamais renvoyés tels quels au site.
  Future<Map<int, RaceResult>> getHeatResults(int seriesId);

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
  Future<Map<int, List<int?>>> getHeatChronos(int seriesId) async => {
    for (final dto in await _heatRows(seriesId)) ?dto.entry?.id: dto.chronos,
  };

  @override
  Future<Map<int, RaceResult>> getHeatResults(int seriesId) async {
    final results = <int, RaceResult>{};
    for (final dto in await _heatRows(seriesId)) {
      if (dto.toHeatResult(seriesId) case final result?) {
        results[result.entryId] = result;
      }
    }
    return results;
  }

  Future<List<ResultatDto>> _heatRows(int seriesId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.series, {
      'id': seriesId.toString(),
    });
    final data = (await _http.get(path))['data'];
    final rows = data is Map<String, dynamic> ? data['resultats'] : null;
    return [
      for (final row in rows is List ? rows : const <Object?>[])
        if (row is Map<String, dynamic>) ?_decode(row),
    ];
  }

  /// Une ligne mal typée est écartée seule, comme dans les listes.
  static ResultatDto? _decode(Map<String, dynamic> row) {
    try {
      return ResultatDto.fromJson(row);
    } on TypeError {
      return null;
    }
  }

  /// Les paramètres passent dans l'adresse et sans corps : un corps JSON
  /// répond HTTP 500. `statut`, `complement` et les chronos relus sont
  /// renvoyés à chaque fois, car un `statut` omis retombe à 3. Un chrono vide
  /// part en `''` (stocké 0). `temps` et `rang` ne partent jamais : omis, le
  /// site les garde, alors que les renvoyer écraserait un temps publié par le
  /// juge entre notre lecture et notre écriture. Des points nuls sont omis.
  @override
  Future<int> submit(RaceResult result) async {
    // Des points absents sont omis : FFSS les conserve, alors qu'un `''` les
    // remettrait à 0.
    String chrono(int i) => result.chronos.elementAtOrNull(i)?.toString() ?? '';
    final body = await _http.post(
      ApiEndpoints.resultSubmit,
      query: {
        'id': ?result.id,
        'serie': result.seriesId,
        'engagement': result.entryId,
        'tempsLive1': chrono(0),
        'tempsLive2': chrono(1),
        'tempsLive3': chrono(2),
        'statut': result.status,
        'complement': result.complement,
        'points': ?result.points,
      },
    );
    final id = body['id'];
    final parsed = id is String ? int.tryParse(id) : id;
    // Pas un refus : l'écriture a pu aboutir, et la file d'envoi qui réessaie
    // relit la place avant (sans doublon).
    if (parsed is! int) throw const UnknownException('réponse sans id');
    return parsed;
  }
}

final resultRepositoryProvider = Provider<ResultRepository>(
  (ref) => ResultRepositoryImpl(ref.watch(httpClientProvider)),
);
