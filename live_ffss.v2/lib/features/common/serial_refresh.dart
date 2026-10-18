import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';

/// Les relectures d'un fournisseur relu par minuterie et par le
/// rafraîchissement manuel, une seule à la fois : deux relectures qui se
/// chevauchent écriraient l'une sur l'autre, la plus lente gagnant avec des
/// données plus vieilles.
mixin SerialRefresh<T> on AsyncNotifier<T> {
  Future<void>? _inFlight;

  /// Le tour de minuterie : ne relit que ce qui peut avoir changé.
  @protected
  Future<void> reloadIncremental();

  /// Le rafraîchissement manuel : relit tout.
  @protected
  Future<void> reloadAll();

  /// Avant de reconstruire après un premier chargement en échec : invalider
  /// ce qui garderait cet échec en cache.
  @protected
  void beforeReloadFromScratch() {}

  Future<void> refresh() async {
    final runRef = ref;
    // En boucle : un autre `refresh` peut avoir pris la place entre-temps.
    for (var running = _inFlight; running != null; running = _inFlight) {
      await running;
      // Page fermée pendant l'attente : `state` et `ref` ne servent plus.
      if (!runRef.mounted) return;
    }
    await _run(state.hasValue ? reloadAll : _reloadFromScratch);
  }

  /// À appeler par la minuterie, qui tient aussi lieu de nouvel essai après
  /// un premier chargement en échec.
  @protected
  void tick() {
    if (_inFlight != null) return;
    if (state.hasValue) {
      _run(reloadIncremental);
    } else if (state.hasError && !state.isLoading) {
      _run(_reloadFromScratch);
    }
  }

  /// Une lecture qui ne vient ni de la minuterie ni du rafraîchissement
  /// manuel (la suite d'un premier chargement) : eux l'attendent au lieu de
  /// la chevaucher, et elle attend la relecture en cours.
  @protected
  void runInSeries(Future<void> Function() reload) {
    // Derrière une relecture en cours, pas en même temps qu'elle.
    final previous = _inFlight;
    _run(() async {
      if (previous != null) await previous.then<void>((_) {}, onError: (_) {});
      await reload();
    });
  }

  Future<void> _run(Future<void> Function() reload) {
    late final Future<void> run;
    run = reload().whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    _inFlight = run;
    return run;
  }

  Future<void> _reloadFromScratch() async {
    beforeReloadFromScratch();
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est déjà dans l'état, que la page affiche.
    }
  }
}
