/// Règle qui a produit le temps manuel, pour que l'écran dise d'où il vient.
enum ManualTimeRule { single, average, median }

/// Temps manuel (centièmes) déduit des chronos saisis. Les chronos nuls ou
/// <= 0 sont ignorés : le serveur range un chrono vidé en `0`.
({int hundredths, ManualTimeRule rule})? manualTime(List<int?> chronos) {
  final valid = [
    for (final c in chronos)
      if (c != null && c > 0) c,
  ]..sort();
  switch (valid.length) {
    case 0:
      return null;
    case 1:
      return (hundredths: valid[0], rule: ManualTimeRule.single);
    case 2:
      // Demi vers le haut : (a + b + 1) ~/ 2 sans passer par un flottant.
      return (
        hundredths: (valid[0] + valid[1] + 1) ~/ 2,
        rule: ManualTimeRule.average,
      );
    default:
      return (hundredths: valid[1], rule: ManualTimeRule.median);
  }
}

/// Lit les chiffres tapés au pavé comme `mmsscc` complété à gauche
/// (`4321` -> 43"21) et rend des centièmes. Nul si l'entrée est vide, trop
/// longue, non numérique ou si les secondes dépassent 59.
int? parseChronoDigits(String digits) {
  if (!RegExp(r'^\d{1,6}$').hasMatch(digits)) return null;
  final padded = digits.padLeft(6, '0');
  final minutes = int.parse(padded.substring(0, 2));
  final seconds = int.parse(padded.substring(2, 4));
  final hundredths = int.parse(padded.substring(4, 6));
  if (seconds > 59) return null;
  return minutes * 6000 + seconds * 100 + hundredths;
}

/// Affichage `mm'ss"cc` pendant la frappe : les minutes n'apparaissent qu'une
/// fois tapées, les secondes et centièmes sont toujours montrés.
String chronoDigitsLabel(String digits) {
  final padded = digits.padLeft(4, '0');
  final cc = padded.substring(padded.length - 2);
  final ss = padded.substring(padded.length - 4, padded.length - 2);
  final mm = padded.substring(0, padded.length - 4);
  final secondsPart = '${int.parse(ss)}"$cc';
  if (mm.isEmpty) return secondsPart;
  return "${int.parse(mm)}'${ss.padLeft(2, '0')}\"$cc";
}

const _entryRoles = {'officiel', 'juge_principal', 'admin'};

/// Seuls ces rôles peuvent saisir des résultats.
bool canEnterResults(Iterable<String> roles) => roles.any(_entryRoles.contains);
