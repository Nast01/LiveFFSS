/// Combien de temps avant une course le téléphone la rappelle.
enum ReminderLead {
  off(0),
  five(5),
  fifteen(15),
  thirty(30);

  const ReminderLead(this.minutes);

  final int minutes;

  /// Nul : pas de rappel.
  Duration? get before => this == off ? null : Duration(minutes: minutes);

  /// La valeur enregistrée.
  String get code => '$minutes';

  /// Rien d'enregistré, ou une valeur inconnue : 15 min, le défaut de la
  /// spec.
  static ReminderLead fromCode(String? code) {
    for (final lead in values) {
      if (lead.code == code) return lead;
    }
    return fifteen;
  }
}
