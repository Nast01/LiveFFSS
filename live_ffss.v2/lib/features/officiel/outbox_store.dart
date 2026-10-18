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
    String? rejection,
    String? reason,
    @Default(0) int attempts,
    @Default(0) int faults,
    String? sentAt,
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
        rejection: op.rejection?.name,
        reason: op.reason,
        attempts: op.attempts,
        faults: op.faults,
        sentAt: op.sentAt?.toIso8601String(),
      );
}

extension OutboxOperationDtoMapper on OutboxOperationDto {
  /// Nul si un nom enregistré n'est plus connu (une version plus récente de
  /// l'app l'a écrit, par exemple).
  OutboxOperation? toDomain() {
    final state = OutboxState.values.asNameMap()[this.state];
    final mark = this.mark;
    final resultMark = mark == null
        ? null
        : ResultMark.values.asNameMap()[mark];
    final rejection = this.rejection;
    final outboxRejection = rejection == null
        ? null
        : OutboxRejection.values.asNameMap()[rejection];
    final sentAt = this.sentAt;
    final sentTime = sentAt == null ? null : DateTime.tryParse(sentAt);
    if (state == null ||
        (mark != null && resultMark == null) ||
        (rejection != null && outboxRejection == null) ||
        (sentAt != null && sentTime == null)) {
      return null;
    }
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
      rejection: outboxRejection,
      reason: reason,
      attempts: attempts,
      faults: faults,
      sentAt: sentTime,
    );
  }
}

/// Ce que [OutboxStore.load] a trouvé.
sealed class OutboxContent {
  const OutboxContent();
}

/// Les opérations relues, et les lignes que cette version ne sait pas lire :
/// gardées telles quelles et réécrites à chaque enregistrement, elles ne sont
/// jamais effacées.
final class OutboxLoaded extends OutboxContent {
  const OutboxLoaded(this.operations, [this.unknown = const []]);

  final List<OutboxOperation> operations;
  final List<Object?> unknown;
}

/// La valeur enregistrée n'est pas une liste lisible : [raw] doit être mis de
/// côté avant d'être remplacé.
final class OutboxUnreadable extends OutboxContent {
  const OutboxUnreadable(this.raw);

  final String raw;
}

/// La file d'envoi, gardée sur l'appareil ([LocalStore] la range sous la clé
/// de l'environnement).
class OutboxStore {
  OutboxStore(this._local);

  static const storageKey = 'outbox';
  static const backupKeyPrefix = 'outbox_backup_';

  /// La liste des copies de côté, du plus ancien au plus récent :
  /// [LocalStore] ne sait pas énumérer ses clés.
  static const backupIndexKey = 'outbox_backups';

  /// Assez pour remonter quelques incidents, sans remplir l'appareil.
  static const maxBackups = 3;

  final LocalStore _local;

  /// Lève une [AppException] si le stockage ne répond pas.
  Future<OutboxContent> load() async =>
      decode(await _guard(() => _local.read(storageKey)));

  Future<void> save(
    List<OutboxOperation> queue, {
    List<Object?> unknown = const [],
  }) => _guard(() => _local.write(storageKey, encode(queue, unknown: unknown)));

  /// Met de côté une valeur illisible, sous une clé à part, avant qu'un
  /// enregistrement ne la remplace : elle contient peut-être des saisies.
  /// Seules les [maxBackups] plus récentes sont gardées.
  Future<void> backup(String raw, DateTime at) => _guard(() async {
    final key = '$backupKeyPrefix${at.millisecondsSinceEpoch}';
    // La copie d'abord : un index en échec ne doit pas la faire perdre.
    await _local.write(key, raw);
    final keys = [..._decodeIndex(await _local.read(backupIndexKey))]
      ..remove(key)
      ..add(key);
    final dropped = keys.length > maxBackups
        ? keys.sublist(0, keys.length - maxBackups)
        : const <String>[];
    final kept = keys.sublist(dropped.length);
    await _local.write(backupIndexKey, jsonEncode(kept));
    for (final old in dropped) {
      await _local.delete(old);
    }
  });

  static List<String> _decodeIndex(String? raw) {
    if (raw == null) return const [];
    try {
      final keys = jsonDecode(raw);
      return keys is List ? keys.whereType<String>().toList() : const [];
    } on FormatException {
      return const [];
    }
  }

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

  static String encode(
    List<OutboxOperation> queue, {
    List<Object?> unknown = const [],
  }) => jsonEncode([
    for (final op in queue) OutboxOperationDto.fromDomain(op).toJson(),
    ...unknown,
  ]);

  static OutboxContent decode(String? raw) {
    if (raw == null) return const OutboxLoaded([]);
    final Object? rows;
    try {
      rows = jsonDecode(raw);
    } on FormatException {
      return OutboxUnreadable(raw);
    }
    if (rows is! List) return OutboxUnreadable(raw);
    final operations = <OutboxOperation>[];
    final unknown = <Object?>[];
    for (final row in rows) {
      final op = row is Map<String, dynamic> ? _decodeRow(row) : null;
      if (op == null) {
        unknown.add(row);
      } else {
        operations.add(op);
      }
    }
    return OutboxLoaded(operations, unknown);
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
