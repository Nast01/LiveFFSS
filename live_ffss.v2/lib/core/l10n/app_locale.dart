import 'dart:ui';

/// Langue de repli de l'application : celle de la FFSS.
const Locale defaultAppLocale = Locale('fr');

/// La première langue du téléphone que l'application sait afficher, sinon le
/// français. Sans cela, Flutter retombe sur la première langue de
/// `supportedLocales`, que gen-l10n trie par ordre alphabétique : un téléphone
/// en espagnol s'ouvrirait en anglais.
Locale resolveAppLocale(
  List<Locale>? deviceLocales,
  Iterable<Locale> supportedLocales,
) {
  for (final device in deviceLocales ?? const <Locale>[]) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == device.languageCode) return supported;
    }
  }
  return defaultAppLocale;
}
