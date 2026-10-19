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

enum _Outcome {
  /// L'opération est réglée : on passe à la suivante si rien ne l'interdit.
  done,

  /// Plus rien ne part avant un nouvel essai, une reconnexion ou un
  /// changement de session.
  stop,
}

/// La file d'envoi des saisies d'officiel : gardée sur l'appareil, envoyée
/// dans l'ordre, une opération à la fois, avec la session du compte qui l'a
/// saisie. Vit tant que l'app est ouverte (lue dès le lancement par l'app).
///
/// Une saisie n'est jamais perdue : tant que la file enregistrée n'a pas été
/// relue, rien n'est enregistré par-dessus, et une valeur illisible est mise
/// de côté avant d'être remplacée.
class OutboxService extends Notifier<List<OutboxOperation>> {
  Timer? _retry;
  Timer? _loadRetry;
  int _loadAttempts = 0;
  bool _running = false;
  bool _rerun = false;

  /// Le site a refusé le jeton : rien ne part avant que la session change,
  /// sinon chaque essai reprendrait le même refus.
  bool _blocked = false;

  bool _loaded = false;
  Future<bool>? _loading;

  /// Les lignes enregistrées que cette version ne sait pas lire, réécrites
  /// telles quelles.
  List<Object?> _unknown = const [];
  Future<void> _saving = Future.value();
  int _sequence = 0;

  @override
  List<OutboxOperation> build() {
    ref.onDispose(() {
      _retry?.cancel();
      _loadRetry?.cancel();
    });
    // Écouter la session la construit dès le lancement, ce qui branche aussi
    // l'expiration du jeton sur le client HTTP.
    ref.listen(sessionProvider, (_, _) => _sessionChanged());
    scheduleMicrotask(_kick);
    return const [];
  }

  /// Met en file une saisie du compte connecté, et ne rend la main qu'une
  /// fois la file enregistrée. Lève une [AuthException] si personne n'est
  /// connecté, une autre [AppException] si l'enregistrement échoue : la
  /// saisie reste alors en mémoire (elle partira quand même), et l'écran doit
  /// prévenir.
  Future<void> add({
    required int competitionId,
    required int placeId,
    required int seriesId,
    required int entryId,
    int? resultId,
    required ResultChange change,
  }) async {
    // Une session en cours de reprise ou de connexion n'a pas encore dit à
    // qui est la saisie.
    final session = ref.read(sessionProvider);
    final account = session.isLoading
        ? await ref.read(sessionProvider.future)
        : session.value;
    if (!ref.mounted) return;
    if (account == null) throw const AuthException('non connecté');
    // Non relue, la saisie est gardée en mémoire et `_persist` lève.
    await _ensureLoaded(now: true);
    if (!ref.mounted) return;

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
    state = enqueue(state, op);
    _kick();
    await _persist();
  }

  /// Écarte de la file une opération réglée (refusée, le plus souvent). Une
  /// opération en attente ne s'écarte pas. Refusé (une [AppException]) tant
  /// que la file enregistrée n'a pas été relue : l'opération y reviendrait.
  Future<void> dismiss(String id) async {
    await _requireLoaded();
    if (!ref.mounted) return;
    state = [
      for (final op in state)
        if (op.id != id || op.state == OutboxState.pending) op,
    ];
    await _persist();
  }

  /// Abandonne les saisies non envoyées (en attente ou refusées) du compte
  /// [account], à sa déconnexion : elles ne partiront jamais. Celles des
  /// autres comptes et les envoyées restent. Refusé (une [AppException]) tant
  /// que la file enregistrée n'a pas été relue : elles y reviendraient.
  Future<void> discardAccount(String account) async {
    await _requireLoaded();
    if (!ref.mounted) return;
    state = [
      for (final op in state)
        if (op.state == OutboxState.sent || !isSameAccount(op.account, account))
          op,
    ];
    await _persist();
  }

  /// Remet en attente une opération refusée, avec un compte d'échecs neuf,
  /// et relance l'envoi. Lève une [AppException] si la file ne peut être
  /// relue ou enregistrée.
  Future<void> retry(String id) async {
    await _requireLoaded();
    if (!ref.mounted) return;
    final index = state.indexWhere((o) => o.id == id);
    if (index < 0 || state[index].state != OutboxState.rejected) return;
    state = [...state]
      ..[index] = state[index].copyWith(
        state: OutboxState.pending,
        rejection: null,
        reason: null,
        attempts: 0,
        faults: 0,
      );
    _kick();
    await _persist();
  }

  /// La file une fois relue de l'appareil : avant, `state` ne montre que
  /// les saisies faites depuis le lancement. Lève une [AppException] si elle
  /// ne peut être relue.
  Future<List<OutboxOperation>> loadedQueue() async {
    await _requireLoaded();
    return state;
  }

  Future<void> _requireLoaded() async {
    if (!await _ensureLoaded(now: true)) {
      throw const UnknownException("file d'envoi enregistrée non relue");
    }
  }

  /// Une relecture déjà programmée n'est pas devancée par chaque relance de
  /// la file, seulement par un geste de l'officiel ([now]).
  Future<bool> _ensureLoaded({bool now = false}) {
    if (_loaded) return Future.value(true);
    if (!now && _loadRetry != null) return Future.value(false);
    return _loading ??= () async {
      try {
        return await _load();
      } finally {
        _loading = null;
      }
    }();
  }

  /// Les saisies faites avant la relecture (gardées en mémoire) sont fondues
  /// dans la file relue, comme si elles venaient d'être saisies.
  Future<bool> _load() async {
    final store = ref.read(outboxStoreProvider);
    final now = ref.read(clockProvider)();
    try {
      final content = await store.load();
      if (!ref.mounted) return false;
      final OutboxLoaded loaded;
      switch (content) {
        case OutboxLoaded():
          loaded = content;
        case OutboxUnreadable(:final raw):
          await store.backup(raw, now);
          if (!ref.mounted) return false;
          loaded = const OutboxLoaded([]);
      }
      var queue = loaded.operations;
      final known = {for (final op in queue) op.id};
      for (final op in state) {
        if (!known.contains(op.id)) queue = enqueue(queue, op);
      }
      _unknown = loaded.unknown;
      _loaded = true;
      _loadAttempts = 0;
      _loadRetry?.cancel();
      _loadRetry = null;
      _set(pruneSent(queue, now));
      return true;
    } on AppException {
      if (!ref.mounted) return false;
      _setPersistenceFailed(true);
      _loadRetry?.cancel();
      _loadRetry = Timer(retryDelay(++_loadAttempts), () {
        _loadRetry = null;
        _kick();
      });
      return false;
    }
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
    // L'échec est signalé par le drapeau ; la file reste en mémoire et sera
    // réenregistrée au prochain changement.
    unawaited(_persist().onError<AppException>((_, _) {}));
  }

  /// Enregistre la file telle qu'elle est maintenant. Refuse tant que la file
  /// enregistrée n'a pas été relue : l'écrire effacerait ce qu'elle contient.
  Future<void> _persist() async {
    if (!_loaded) {
      _setPersistenceFailed(true);
      throw const UnknownException("file d'envoi enregistrée non relue");
    }
    final store = ref.read(outboxStoreProvider);
    final queue = state;
    final unknown = _unknown;
    // Enchaînées : deux écritures concurrentes pourraient arriver dans le
    // désordre et laisser la plus ancienne enregistrée.
    final write = _saving.then((_) => store.save(queue, unknown: unknown));
    _saving = write.onError<AppException>((_, _) {});
    try {
      await write;
    } on AppException {
      if (ref.mounted) _setPersistenceFailed(true);
      rethrow;
    }
    if (ref.mounted) _setPersistenceFailed(false);
  }

  void _setPersistenceFailed(bool failed) =>
      ref.read(outboxPersistenceFailedProvider.notifier)._set(failed);

  void _kick() {
    if (!ref.mounted) return;
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
        // Rien ne part avant la relecture : un échec programme la suivante.
        if (!await _ensureLoaded()) return;
        // Un nouvel essai programmé garde la main : la file attend son délai.
        while (ref.mounted && !_blocked && _retry == null) {
          final op = _next();
          if (op == null) break;
          if (await _send(op) == _Outcome.stop) break;
        }
      } while (ref.mounted && _rerun);
    } finally {
      _running = false;
    }
  }

  OutboxOperation? _next() {
    for (final op in state) {
      if (op.state == OutboxState.pending && _ownedBySession(op)) return op;
    }
    return null;
  }

  bool _ownedBySession(OutboxOperation op) {
    final label = ref.read(sessionProvider).value?.label;
    return label != null && isSameAccount(op.account, label);
  }

  Future<_Outcome> _send(OutboxOperation op) async {
    final meetings = ref.read(meetingRepositoryProvider);
    final results = ref.read(resultRepositoryProvider);
    // Revérifié après chaque attente : la session peut avoir changé de
    // compte, et une saisie ne part jamais sous un autre que le sien.
    bool lost() => !ref.mounted || !_ownedBySession(op);
    try {
      // Relire la place trouve le résultat d'une création arrivée sur le
      // site malgré une réponse perdue : la renvoyer ferait un doublon.
      final lanes = await meetings.getLanes([op.placeId]);
      if (lost()) return _Outcome.stop;
      if (!lanes.containsKey(op.placeId)) {
        // Une place absente ne se distingue pas d'une coupure : jamais
        // refusée pour autant.
        return _retryLater(op);
      }
      final lane = lanes[op.placeId];
      if (lane == null) {
        return _settle(
          op,
          OutboxState.rejected,
          rejection: OutboxRejection.emptyPlace,
        );
      }

      // Le bureau a recomposé la série : écrire ici mettrait les chronos d'un
      // nageur sur un autre. Rien à réessayer, la saisie ne vaut plus.
      if (lane.entryId != null && lane.entryId != op.entryId) {
        return _settle(
          op,
          OutboxState.rejected,
          rejection: OutboxRejection.placeChanged,
        );
      }

      final resultId = lane.resultId ?? op.resultId;
      RaceResult current;
      if (resultId == null) {
        current = RaceResult(seriesId: op.seriesId, entryId: op.entryId);
      } else {
        // Relu juste avant l'écriture : l'envoi renvoie le statut, le code
        // et les chronos, et ne doit pas effacer ce que le juge a posé
        // depuis la saisie.
        final read = await results.getResult(resultId);
        if (lost()) return _Outcome.stop;
        if (read == null) return _fault(op, OutboxRejection.unreadableResult);
        if (read.entryId != op.entryId) {
          return _settle(
            op,
            OutboxState.rejected,
            rejection: OutboxRejection.placeChanged,
          );
        }
        if (isValidatedByJudge(read)) {
          return _settle(
            op,
            OutboxState.rejected,
            rejection: OutboxRejection.validatedByJudge,
          );
        }
        current = read;
      }

      if (lost()) return _Outcome.stop;
      final id = await results.submit(applyChange(current, op.change));
      if (!ref.mounted) return _Outcome.stop;
      return _settle(op, OutboxState.sent, resultId: id);
    } on AppException catch (e) {
      if (!ref.mounted) return _Outcome.stop;
      switch (e) {
        case AuthException():
          // La session a peut-être déjà changé : ce refus ne concerne alors
          // plus la nouvelle.
          if (_ownedBySession(op)) _blocked = true;
          return _Outcome.stop;
        case NetworkException():
          return _retryLater(op);
        case ApiException(malformedResponse: true):
          // Une page de portail captif ou de proxy : hors ligne, en somme.
          return _retryLater(op);
        case ApiException(:final statusCode?) when _isTransient(statusCode):
          return _retryLater(op);
        case UnknownException() || StorageException():
          return _fault(op, OutboxRejection.server, reason: e.message);
        case ApiException() || NotFoundException():
          return _settle(
            op,
            OutboxState.rejected,
            rejection: OutboxRejection.server,
            reason: e.message,
          );
      }
    }
  }

  /// Une panne ou un engorgement du serveur, pas un refus de la saisie.
  static bool _isTransient(int statusCode) =>
      statusCode >= 500 || statusCode == 408 || statusCode == 429;

  /// [sent] est l'opération telle qu'elle est partie : si une saisie s'y est
  /// fusionnée entre-temps, celle-ci n'est pas encore écrite et l'opération
  /// reste en attente (avec l'id du résultat, s'il vient d'être créé).
  _Outcome _settle(
    OutboxOperation sent,
    OutboxState outcome, {
    OutboxRejection? rejection,
    String? reason,
    int? resultId,
  }) {
    final index = state.indexWhere((o) => o.id == sent.id);
    if (index < 0) return _Outcome.done;
    final now = ref.read(clockProvider)();
    final current = state[index];
    final known = current.copyWith(
      resultId: resultId ?? current.resultId,
      attempts: 0,
      faults: 0,
    );
    final settled = current.change != sent.change
        ? known
        : known.copyWith(
            state: outcome,
            rejection: rejection,
            reason: reason,
            sentAt: outcome == OutboxState.sent ? now : null,
          );
    _set(pruneSent([...state]..[index] = settled, now));
    return _Outcome.done;
  }

  /// Un échec qu'une coupure n'explique pas : réessayé, puis refusé passé
  /// [maxFaults], pour qu'une seule opération ne bloque pas la file du compte
  /// pour toujours.
  _Outcome _fault(
    OutboxOperation sent,
    OutboxRejection rejection, {
    String? reason,
  }) {
    final index = state.indexWhere((o) => o.id == sent.id);
    if (index < 0) return _Outcome.done;
    final faults = state[index].faults + 1;
    if (faults >= maxFaults) {
      return _settle(
        sent,
        OutboxState.rejected,
        rejection: rejection,
        reason: reason,
      );
    }
    return _retryLater(sent, faults: faults);
  }

  _Outcome _retryLater(OutboxOperation sent, {int? faults}) {
    final index = state.indexWhere((o) => o.id == sent.id);
    if (index < 0) return _Outcome.done;
    final current = state[index];
    final attempts = current.attempts + 1;
    _set(
      [...state]
        ..[index] = current.copyWith(
          attempts: attempts,
          faults: faults ?? current.faults,
        ),
    );
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

/// Vrai quand la file d'envoi n'a pas pu être enregistrée (ou relue) sur
/// l'appareil : les saisies ne tiennent alors qu'en mémoire, et l'écran doit
/// le dire. Revient à faux au premier enregistrement réussi.
class OutboxPersistenceNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void _set(bool failed) => state = failed;
}

final outboxPersistenceFailedProvider =
    NotifierProvider<OutboxPersistenceNotifier, bool>(
      OutboxPersistenceNotifier.new,
    );
