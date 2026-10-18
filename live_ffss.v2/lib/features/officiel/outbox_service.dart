import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/outbox_store.dart';

/// Motifs de refus que l'app pose elle-même (les autres viennent du site).
const rejectedByJudge = 'validé par le juge des résultats';
const rejectedUnreadable = 'résultat illisible';
const rejectedEmptyPlace = 'place vide';

enum _Outcome {
  /// L'opération est réglée (envoyée ou refusée) : on passe à la suivante.
  done,

  /// Plus rien ne part avant un nouvel essai ou une reconnexion.
  stop,
}

/// La file d'envoi des saisies d'officiel : gardée sur l'appareil, envoyée
/// dans l'ordre, une opération à la fois, avec la session du compte qui l'a
/// saisie. Vit tant que l'app est ouverte (lue dès le lancement par l'app).
class OutboxService extends Notifier<List<OutboxOperation>> {
  Timer? _retry;
  bool _running = false;
  bool _rerun = false;

  /// Le site a refusé le jeton : rien ne part avant que la session change,
  /// sinon chaque essai reprendrait le même refus.
  bool _blocked = false;

  late Future<void> _loaded;
  Future<void> _saving = Future.value();
  int _sequence = 0;

  @override
  List<OutboxOperation> build() {
    ref.onDispose(() => _retry?.cancel());
    // Écouter la session la construit dès le lancement, ce qui branche aussi
    // l'expiration du jeton sur le client HTTP.
    ref.listen(sessionProvider, (_, _) => _sessionChanged());
    _loaded = _load();
    return const [];
  }

  /// Met en file une saisie du compte connecté. Lève une [AuthException] si
  /// personne ne l'est : une saisie sans compte ne partirait jamais.
  Future<void> add({
    required int competitionId,
    required int placeId,
    required int seriesId,
    required int entryId,
    int? resultId,
    required ResultChange change,
  }) async {
    await _loaded;
    if (!ref.mounted) return;
    final account = ref.read(sessionProvider).value;
    if (account == null) throw const AuthException('non connecté');
    final now = ref.read(clockProvider)();
    final op = OutboxOperation(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      account: account.label,
      competitionId: competitionId,
      placeId: placeId,
      resultId: resultId,
      seriesId: seriesId,
      entryId: entryId,
      change: change,
    );
    _set(enqueue(state, op));
    _kick();
  }

  Future<void> _load() async {
    final store = ref.read(outboxStoreProvider);
    List<OutboxOperation> saved;
    try {
      saved = await store.load();
    } on AppException {
      saved = [];
    }
    if (!ref.mounted) return;
    state = [...saved, ...state];
    _kick();
  }

  void _sessionChanged() {
    _blocked = false;
    // Une nouvelle session est une raison de réessayer tout de suite.
    _retry?.cancel();
    _retry = null;
    _kick();
  }

  void _set(List<OutboxOperation> queue) {
    state = queue;
    final store = ref.read(outboxStoreProvider);
    // Enchaînées : deux écritures concurrentes pourraient arriver dans le
    // désordre et laisser la plus ancienne enregistrée.
    _saving = _saving
        .then((_) => store.save(queue))
        .onError<AppException>(
          // La file reste en mémoire et sera réenregistrée au prochain changement.
          (_, _) {},
        );
  }

  /// Un nouvel essai programmé garde la main : la file attend son délai.
  void _kick() {
    if (!ref.mounted || _retry != null) return;
    if (_running) {
      _rerun = true;
      return;
    }
    unawaited(_process());
  }

  Future<void> _process() async {
    _running = true;
    try {
      do {
        _rerun = false;
        while (!_blocked) {
          final op = _next();
          if (op == null) break;
          final outcome = await _send(op);
          if (!ref.mounted || outcome == _Outcome.stop) return;
        }
      } while (_rerun);
    } finally {
      _running = false;
    }
  }

  OutboxOperation? _next() {
    final account = ref.read(sessionProvider).value?.label;
    if (account == null) return null;
    for (final op in state) {
      if (op.state == OutboxState.pending &&
          isSameAccount(op.account, account)) {
        return op;
      }
    }
    return null;
  }

  Future<_Outcome> _send(OutboxOperation op) async {
    final meetings = ref.read(meetingRepositoryProvider);
    final results = ref.read(resultRepositoryProvider);
    try {
      // Relire la place trouve le résultat d'une création arrivée sur le
      // site malgré une réponse perdue : la renvoyer ferait un doublon.
      final lanes = await meetings.getLanes([op.placeId]);
      if (!ref.mounted) return _Outcome.stop;
      if (!lanes.containsKey(op.placeId)) return _retryLater(op);
      final lane = lanes[op.placeId];
      if (lane == null) {
        return _settle(op, OutboxState.rejected, reason: rejectedEmptyPlace);
      }

      final resultId = lane.resultId ?? op.resultId;
      RaceResult current;
      if (resultId == null) {
        current = RaceResult(seriesId: op.seriesId, entryId: op.entryId);
      } else {
        // Relu juste avant l'écriture : l'envoi renvoie tous les champs, et
        // ne doit pas effacer ce que le juge a posé depuis la saisie.
        final read = await results.getResult(resultId);
        if (!ref.mounted) return _Outcome.stop;
        if (read == null) {
          return _settle(op, OutboxState.rejected, reason: rejectedUnreadable);
        }
        if (isValidatedByJudge(read)) {
          return _settle(op, OutboxState.rejected, reason: rejectedByJudge);
        }
        current = read;
      }

      final id = await results.submit(applyChange(current, op.change));
      if (!ref.mounted) return _Outcome.stop;
      return _settle(op, OutboxState.sent, resultId: id);
    } on AppException catch (e) {
      if (!ref.mounted) return _Outcome.stop;
      switch (e) {
        case AuthException():
          _blocked = true;
          return _Outcome.stop;
        case NetworkException() || UnknownException():
          return _retryLater(op);
        case ApiException(:final statusCode?) when statusCode >= 500:
          // Une panne du serveur, pas un refus de la saisie.
          return _retryLater(op);
        case ApiException() || NotFoundException():
          return _settle(op, OutboxState.rejected, reason: e.message);
      }
    }
  }

  /// [sent] est l'opération telle qu'elle est partie : si une saisie s'y est
  /// fusionnée entre-temps, celle-ci n'est pas encore écrite et l'opération
  /// reste en attente (avec l'id du résultat, s'il vient d'être créé).
  _Outcome _settle(
    OutboxOperation sent,
    OutboxState outcome, {
    String? reason,
    int? resultId,
  }) {
    final index = state.indexWhere((o) => o.id == sent.id);
    if (index < 0) return _Outcome.done;
    final current = state[index];
    final known = current.copyWith(
      resultId: resultId ?? current.resultId,
      attempts: 0,
    );
    final settled = current.change != sent.change
        ? known
        : known.copyWith(state: outcome, reason: reason);
    _set([...state]..[index] = settled);
    return _Outcome.done;
  }

  _Outcome _retryLater(OutboxOperation sent) {
    final index = state.indexWhere((o) => o.id == sent.id);
    if (index < 0) return _Outcome.done;
    final attempts = state[index].attempts + 1;
    _set([...state]..[index] = state[index].copyWith(attempts: attempts));
    _retry = Timer(retryDelay(attempts), () {
      _retry = null;
      _kick();
    });
    return _Outcome.stop;
  }
}

final outboxProvider = NotifierProvider<OutboxService, List<OutboxOperation>>(
  OutboxService.new,
);
