import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

part 'outbox.freezed.dart';

enum OutboxState { pending, sent, rejected }

/// Pourquoi une opération a été refusée ; l'écran en fait un texte traduit.
enum OutboxRejection {
  /// Le résultat a un `temps` : le juge des résultats l'a validé.
  validatedByJudge,

  /// Le résultat existe (la place a été relue) mais n'a pas pu l'être,
  /// essai après essai.
  unreadableResult,

  /// La place n'a plus de nageur.
  emptyPlace,

  /// La place ou son résultat ne porte plus l'engagement saisi : le bureau a
  /// recomposé la série, la saisie visait un autre nageur.
  placeChanged,

  /// Le site a refusé l'écriture, ou a échoué sans dire pourquoi ; son
  /// message est dans [OutboxOperation.reason].
  server,
}

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
    OutboxRejection? rejection,

    /// Le message du site qui accompagne un refus [OutboxRejection.server].
    String? reason,

    /// Les essais manqués d'affilée, qui règlent le délai du suivant.
    @Default(0) int attempts,

    /// Parmi eux, ceux qu'une coupure n'explique pas : passé
    /// [maxFaults], l'opération est refusée, pour qu'une seule ne bloque pas
    /// toute la file du compte.
    @Default(0) int faults,

    /// Quand l'opération est partie, pour l'oublier un jour plus tard.
    DateTime? sentAt,
  }) = _OutboxOperation;
}

/// [queue] avec [op] : fusionnée dans l'opération en attente du même compte
/// sur la même place et le même engagement, s'il y en a une, sinon ajoutée à la fin. Deux saisies du
/// même couloir avant l'envoi n'en font qu'une, qui garde la place de la
/// première dans l'ordre d'envoi.
List<OutboxOperation> enqueue(List<OutboxOperation> queue, OutboxOperation op) {
  final index = queue.indexWhere(
    (o) =>
        o.state == OutboxState.pending &&
        o.placeId == op.placeId &&
        // Une série recomposée met un autre nageur sur la place : sa saisie ne
        // se mêle pas à celle de l'ancien, refusée seule à l'envoi.
        o.entryId == op.entryId &&
        isSameAccount(o.account, op.account),
  );
  if (index < 0) return [...queue, op];
  final existing = queue[index];
  return [...queue]
    ..[index] = existing.copyWith(
      resultId: op.resultId ?? existing.resultId,
      change: mergeChanges(existing.change, op.change),
      // Une saisie neuve repart de zéro : elle n'hérite pas des échecs passés.
      attempts: 0,
      faults: 0,
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

/// Les échecs autres qu'une coupure tolérés avant de refuser l'opération.
const int maxFaults = 5;

/// Combien de temps une opération envoyée reste visible.
const Duration sentRetention = Duration(hours: 24);

/// [queue] sans les opérations envoyées depuis plus de [sentRetention]. Les
/// refusées restent jusqu'à ce que l'officiel les écarte.
List<OutboxOperation> pruneSent(List<OutboxOperation> queue, DateTime now) => [
  for (final op in queue)
    if (op.state != OutboxState.sent || _sentSince(op, now) < sentRetention) op,
];

/// Une opération envoyée sans date (qui ne devrait pas exister) est oubliée.
Duration _sentSince(OutboxOperation op, DateTime now) {
  final sentAt = op.sentAt;
  return sentAt == null ? sentRetention : now.difference(sentAt);
}
