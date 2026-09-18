import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/config/environment_storage.dart';
import 'package:live_ffss/app/core/di/initial_binding.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

/// Bascule d'environnement : un démarrage à froid sans relancer le processus.
///
/// Appelé depuis une vue, jamais depuis un contrôleur — l'étape 3 détruit le
/// contrôleur appelant, et une méthode ne survit pas à sa propre destruction.
abstract class AppRestart {
  AppRestart._();

  static Future<void> switchTo(AppEnvironment environment) async {
    // 1. Avant le deleteAll, qui désenregistre EnvironmentStorage.
    await Get.find<EnvironmentStorage>().save(environment);

    // 2. Vide la pile de vues. Le Future d'offAllNamed ne se complète qu'au
    // dépilement de la route poussée : l'attendre ici bloquerait tout ce qui
    // suit, sur l'écran d'attente. Ce qu'il faut attendre, c'est la frame qui
    // démonte l'ancienne pile — /restarting n'a ni binding ni contrôleur, donc
    // une fois celle-ci écoulée, plus aucune vue ne peut faire de Get.find.
    //
    // Ceci tient à une condition, portée par la déclaration de /restarting
    // dans app_pages : sa transition est nulle. Animée, elle garderait
    // l'ancienne pile montée le temps de l'animation, et le deleteAll
    // ci-dessous détruirait le contrôleur sous une vue encore vivante — dont
    // le premier Obx redemanderait aussitôt ce contrôleur disparu.
    unawaited(Get.offAllNamed<void>(Routes.restarting));
    await WidgetsBinding.instance.endOfFrame;

    // Neutralise l'ancien gestionnaire d'échec d'authentification : il capture
    // l'AuthRepository actuel par référence (donc il ne lèvera pas), mais il
    // navigue. Une requête partie avant la bascule peut répondre après le
    // register() ci-dessous avec un 403 "Invalid token" ; sans ceci, ce
    // gestionnaire obsolète pousserait /login en course avec le retour vers
    // /home.
    Get.find<HttpClient>().onAuthFailure = () async {};

    // 3-4. Le conteneur repart de zéro, avec le nouvel environnement.
    // Get.deleteAll détruit aussi GetMaterialController, le contrôleur racine
    // que GetMaterialApp enregistre. Sans conséquence observable : la clé du
    // navigateur et les traductions sont des statiques hors conteneur, et
    // navigation, Get.updateLocale, Get.snackbar et .tr fonctionnent tous
    // après la reconstruction ci-dessous.
    Get.deleteAll(force: true);
    await InitialBinding.register();

    unawaited(Get.offAllNamed<void>(Routes.home));
  }
}
