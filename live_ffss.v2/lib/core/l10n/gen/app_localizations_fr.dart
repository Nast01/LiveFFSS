// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FFSS-LIVE';

  @override
  String get appTagline => 'Sauvetage sportif en direct';

  @override
  String get signIn => 'Se connecter';

  @override
  String get searchHint => 'Compétition, ville, club…';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterFlatWater => 'Eau plate';

  @override
  String get filterCoastal => 'Côtier';

  @override
  String get filterFavorites => 'Mes favoris';

  @override
  String get disciplineFlatWater => 'Eau plate';

  @override
  String get disciplineCoastal => 'Côtier';

  @override
  String get disciplineMixed => 'Mixte';

  @override
  String get liveBadge => 'EN DIRECT';

  @override
  String dayOfTotal(int current, int total) {
    return 'Jour $current/$total';
  }

  @override
  String get nowRunning => 'MAINTENANT';

  @override
  String get nextUp => 'À SUIVRE';

  @override
  String heatOfTotal(int position, int total) {
    return 'Série $position/$total';
  }

  @override
  String get genderFemale => 'Dames';

  @override
  String get genderMale => 'Messieurs';

  @override
  String get genderMixed => 'Mixte';

  @override
  String get upcoming => 'À venir';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get recentlyFinished => 'Terminées récemment';

  @override
  String get allCompetitions => 'Compétitions';

  @override
  String get noCompetition => 'Aucune compétition';

  @override
  String get loadError => 'Impossible de charger les compétitions.';

  @override
  String get retry => 'Réessayer';

  @override
  String get refreshFailed =>
      'Mise à jour impossible : les données affichées sont conservées.';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabProgramme => 'Programme';

  @override
  String get tabLive => 'Live';

  @override
  String get tabResults => 'Résultats';

  @override
  String get tabMySpace => 'Mon espace';

  @override
  String availableInLot(int lot) {
    return 'Disponible au lot $lot';
  }

  @override
  String get chooseCompetition => 'Choisir une compétition';

  @override
  String get chooseCompetitionHint =>
      'Ouvrez une compétition depuis l\'accueil pour suivre son programme, son live et ses résultats.';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get mySpaceComingSoon =>
      'La connexion et votre espace arrivent bientôt.';
}
