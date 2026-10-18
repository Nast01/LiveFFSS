import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

part 'outbox.freezed.dart';

enum OutboxState { pending, sent, rejected }

/// Une saisie d'officiel en attente d'écriture sur le site FFSS. Elle ne garde
/// que ce qu'elle change ([change]) : le résultat est relu au moment de
/// l'envoi, pour ne pas écraser ce que le juge a posé entre-temps.
@freezed
abstract class OutboxOperation with _$OutboxOperation {
  const factory OutboxOperation({
    required String id,

    /// Le nom du compte qui a saisi : l'opération ne part qu'avec sa session.
    required String account,
    required int competitionId,
    required int placeId,

    /// L'id du résultat une fois connu (création réussie) ; nul avant.
    int? resultId,
    required int seriesId,
    required int entryId,
    required ResultChange change,
    @Default(OutboxState.pending) OutboxState state,

    /// Pourquoi l'opération a été refusée.
    String? reason,

    /// Les essais manqués d'affilée, qui règlent le délai du suivant.
    @Default(0) int attempts,
  }) = _OutboxOperation;
}

/// [queue] avec [op] : fusionnée dans l'opération en attente du même compte
/// sur la même place, s'il y en a une, sinon ajoutée à la fin. Deux saisies du
/// même couloir avant l'envoi n'en font qu'une, qui garde la place de la
/// première dans l'ordre d'envoi.
List<OutboxOperation> enqueue(List<OutboxOperation> queue, OutboxOperation op) {
  final index = queue.indexWhere(
    (o) =>
        o.state == OutboxState.pending &&
        o.placeId == op.placeId &&
        isSameAccount(o.account, op.account),
  );
  if (index < 0) return [...queue, op];
  final existing = queue[index];
  return [...queue]
    ..[index] = existing.copyWith(
      resultId: op.resultId ?? existing.resultId,
      change: mergeChanges(existing.change, op.change),
    );
}

/// La dernière saisie gagne champ par champ. Le code suit son statut : un
/// forfait saisi après une DQ n'en garde pas le code.
ResultChange mergeChanges(ResultChange earlier, ResultChange later) =>
    ResultChange(
      chronos: later.chronos ?? earlier.chronos,
      mark: later.mark ?? earlier.mark,
      code: later.mark != null ? later.code : earlier.code,
    );

/// Le délai avant le nouvel essai d'un envoi manqué [attempts] fois.
Duration retryDelay(int attempts) => switch (attempts) {
  <= 1 => const Duration(seconds: 5),
  2 => const Duration(seconds: 15),
  _ => const Duration(seconds: 60),
};
