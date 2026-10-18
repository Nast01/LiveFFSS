import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

part 'outbox_store.freezed.dart';
part 'outbox_store.g.dart';

/// La forme enregistrée d'une [OutboxOperation] : le domaine reste sans JSON.
/// Les énumérations sont gardées par leur nom, pour qu'un ajout de valeur ne
/// décale pas celles déjà enregistrées.
@freezed
abstract class OutboxOperationDto with _$OutboxOperationDto {
  const factory OutboxOperationDto({
    required String id,
    required String account,
    required int competitionId,
    required int placeId,
    int? resultId,
    required int seriesId,
    required int entryId,
    List<int?>? chronos,
    String? mark,
    String? code,
    required String state,
    String? reason,
    @Default(0) int attempts,
  }) = _OutboxOperationDto;

  factory OutboxOperationDto.fromJson(Map<String, dynamic> json) =>
      _$OutboxOperationDtoFromJson(json);

  factory OutboxOperationDto.fromDomain(OutboxOperation op) =>
      OutboxOperationDto(
        id: op.id,
        account: op.account,
        competitionId: op.competitionId,
        placeId: op.placeId,
        resultId: op.resultId,
        seriesId: op.seriesId,
        entryId: op.entryId,
        chronos: op.change.chronos,
        mark: op.change.mark?.name,
        code: op.change.code,
        state: op.state.name,
        reason: op.reason,
        attempts: op.attempts,
      );
}

extension OutboxOperationDtoMapper on OutboxOperationDto {
  /// Nul si un état ou un statut enregistré n'est plus connu.
  OutboxOperation? toDomain() {
    final state = OutboxState.values.asNameMap()[this.state];
    final mark = this.mark;
    final resultMark = mark == null
        ? null
        : ResultMark.values.asNameMap()[mark];
    if (state == null || (mark != null && resultMark == null)) return null;
    return OutboxOperation(
      id: id,
      account: account,
      competitionId: competitionId,
      placeId: placeId,
      resultId: resultId,
      seriesId: seriesId,
      entryId: entryId,
      change: ResultChange(chronos: chronos, mark: resultMark, code: code),
      state: state,
      reason: reason,
      attempts: attempts,
    );
  }
}

/// La file d'envoi, gardée sur l'appareil ([LocalStore] la range sous la clé
/// de l'environnement).
class OutboxStore {
  OutboxStore(this._local);

  static const storageKey = 'outbox';

  final LocalStore _local;

  Future<List<OutboxOperation>> load() async =>
      decode(await _guard(() => _local.read(storageKey)));

  Future<void> save(List<OutboxOperation> queue) =>
      _guard(() => _local.write(storageKey, encode(queue)));

  /// Le stockage sécurisé lève ses propres erreurs (`PlatformException`…) :
  /// traduites en [AppException], la seule que les appelants attrapent.
  static Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  static String encode(List<OutboxOperation> queue) => jsonEncode([
    for (final op in queue) OutboxOperationDto.fromDomain(op).toJson(),
  ]);

  /// Une valeur illisible vaut une file vide, et une ligne illisible est
  /// écartée seule : le reste de la file doit encore partir.
  static List<OutboxOperation> decode(String? raw) {
    if (raw == null) return [];
    final Object? rows;
    try {
      rows = jsonDecode(raw);
    } on FormatException {
      return [];
    }
    if (rows is! List) return [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) ?_decodeRow(row),
    ];
  }

  static OutboxOperation? _decodeRow(Map<String, dynamic> row) {
    try {
      return OutboxOperationDto.fromJson(row).toDomain();
    } on TypeError {
      return null;
    }
  }
}

final outboxStoreProvider = Provider<OutboxStore>(
  (ref) => OutboxStore(ref.watch(localStoreProvider)),
);
