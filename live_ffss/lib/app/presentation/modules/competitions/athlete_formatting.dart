/// Comment un athlète se lit à l'écran. Partagé par les quatre vues qui
/// affichent un engagé — tirage, saisie de course, engagements, séries — qui
/// doivent toutes le nommer pareil.
library;

import 'package:live_ffss/app/domain/models/athlete.dart';

extension AthleteFormatting on Athlete {
  /// « DUPONT Jean ». Le nom d'abord et en capitales, comme sur une feuille de
  /// course FFSS : c'est le nom que l'œil cherche en balayant une ligne de
  /// départ. Le `trim` couvre l'engagé dont le prénom manque, qui laisserait
  /// sinon une espace en fin de chaîne.
  String get displayName => '${lastName.toUpperCase()} $firstName'.trim();
}
