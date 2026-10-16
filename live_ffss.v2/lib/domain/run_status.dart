/// Statut d'une course sur le site FFSS. Les codes sont ceux des constantes de
/// `ResultPublisher` dans FFSSCompetition V3, qui les publie : « En cours »
/// dès que l'heure de début prévue est passée ou qu'un résultat est saisi,
/// « Terminé » une fois la série validée.
enum RunStatus {
  waiting(0),
  marshalling(1),
  inProgress(2),
  finished(3);

  const RunStatus(this.code);

  final int code;

  /// Un code inconnu vaut « En attente », comme `ResultPublisher.StatusName`
  /// dans V3.
  static RunStatus fromCode(int? code) {
    for (final status in values) {
      if (status.code == code) return status;
    }
    return waiting;
  }
}
