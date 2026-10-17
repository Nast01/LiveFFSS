import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/app_locale.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  test('un téléphone dans une langue non prise en charge : français', () {
    expect(
      resolveAppLocale([const Locale('es', 'ES')], supported),
      const Locale('fr'),
    );
  });

  test('sans langue connue du téléphone : français', () {
    expect(resolveAppLocale(null, supported), const Locale('fr'));
    expect(resolveAppLocale(const [], supported), const Locale('fr'));
  });

  test('un téléphone en français, quelle que soit la région : français', () {
    expect(
      resolveAppLocale([const Locale('fr', 'BE')], supported),
      const Locale('fr'),
    );
  });

  test('un téléphone en anglais : anglais', () {
    expect(
      resolveAppLocale([const Locale('en', 'GB')], supported),
      const Locale('en'),
    );
  });

  test('la première langue prise en charge dans la liste du téléphone', () {
    expect(
      resolveAppLocale([
        const Locale('de'),
        const Locale('fr'),
        const Locale('en'),
      ], supported),
      const Locale('fr'),
    );
  });
}
