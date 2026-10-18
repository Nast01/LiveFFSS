const _accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _plain = 'aaaaaaceeeeiiiinooooouuuuyy';

// Une lettre qui en donne deux : « Cœur » se tape « coeur ».
const _expanded = {'œ': 'oe', 'æ': 'ae', 'ß': 'ss'};

/// Minuscules sans accents (Latin-1, ligatures) : « Élodie » se trouve en
/// tapant « elodie », et se range avec les « E ».
String foldForSearch(String value) {
  final lower = value.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final i = _accented.indexOf(char);
    out.write(i < 0 ? (_expanded[char] ?? char) : _plain[i]);
  }
  return out.toString();
}
