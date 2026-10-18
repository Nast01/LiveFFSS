import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';

/// L'onglet où l'application s'ouvre. Mon espace n'en est pas : on y va pour
/// régler, pas pour suivre une compétition.
enum StartTab {
  home('home'),
  programme('programme'),
  live('live'),
  results('results');

  const StartTab(this.code);

  /// La valeur enregistrée.
  final String code;

  static StartTab fromCode(String? code) {
    for (final tab in values) {
      if (tab.code == code) return tab;
    }
    return home;
  }
}

class StartTabNotifier extends AsyncNotifier<StartTab> {
  /// Clé globale (`AppEnvironment.globalKeys`) : comme la langue, une
  /// préférence d'interface qui ne vient pas du serveur, et qui survit donc à
  /// un changement d'environnement.
  static const storageKey = 'start_tab';

  @override
  Future<StartTab> build() async {
    try {
      return StartTab.fromCode(
        await ref.watch(localStoreProvider).read(storageKey),
      );
    } on AppException {
      // Un stockage en panne ne doit pas empêcher l'application de s'ouvrir.
      return StartTab.home;
    }
  }

  /// L'état d'abord : un stockage en panne garde le choix jusqu'à la
  /// fermeture de l'app.
  Future<void> select(StartTab tab) async {
    state = AsyncData(tab);
    final store = ref.read(localStoreProvider);
    try {
      if (tab == StartTab.home) {
        await store.delete(storageKey);
      } else {
        await store.write(storageKey, tab.code);
      }
    } on AppException {
      // Choix gardé en mémoire.
    }
  }
}

final startTabProvider = AsyncNotifierProvider<StartTabNotifier, StartTab>(
  StartTabNotifier.new,
);
