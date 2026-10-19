/// Les écritures d'un enregistrement, une à la fois et dans l'ordre : deux
/// écritures en vol pourraient finir dans le désordre et laisser la plus
/// vieille sur l'appareil.
class WriteQueue {
  Future<void> _last = Future.value();

  Future<void> run(Future<void> Function() write) {
    final done = _last.then((_) => write());
    // Une écriture en échec ne bloque pas les suivantes ; son appelant reçoit
    // l'échec par [done].
    _last = done.then((_) {}, onError: (Object _) {});
    return done;
  }

  /// Se termine quand les écritures déjà demandées sont finies, réussies ou
  /// non : un effacement qui partirait avant serait recouvert.
  Future<void> get idle => _last;
}
