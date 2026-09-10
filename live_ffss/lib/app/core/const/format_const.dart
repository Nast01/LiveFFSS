import 'package:intl/intl.dart';

class FormatConst {
  FormatConst._();

  /// Motifs non localisés : ni l'un ni l'autre ne porte de nom de mois ou de
  /// jour, donc ils rendent la même chose quelle que soit la locale. Les figer
  /// ne perd rien et retire deux globales réassignables.
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');
}
