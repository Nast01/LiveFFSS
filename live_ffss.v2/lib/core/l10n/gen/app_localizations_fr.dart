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

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String durationMinutes(int minutes) {
    return '≈ $minutes min';
  }

  @override
  String durationHours(int hours) {
    return '≈ $hours h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '≈ $hours h $minutes';
  }

  @override
  String meetingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créneaux',
      one: '1 créneau',
    );
    return '$_temp0';
  }

  @override
  String meetingEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves',
      one: '1 épreuve',
    );
    return '$_temp0';
  }

  @override
  String get programmeTitle => 'Programme';

  @override
  String get programmeEmpty => 'Programme pas encore publié';

  @override
  String get programmeLoadError => 'Impossible de charger le programme.';

  @override
  String get itemLoadError => 'Impossible de charger ce créneau.';

  @override
  String get itemNotFound => 'Ce créneau n\'est plus au programme.';

  @override
  String get noLanes => 'Composition pas encore publiée';

  @override
  String get recordBadge => 'Record';

  @override
  String get nationalRecordBadge => 'Record de France';

  @override
  String get chooseFinal => 'Choisir la course';

  @override
  String get progressionToggle => 'Déroulement';

  @override
  String get statusFinished => 'Terminé';

  @override
  String get forfeit => 'Forfait';

  @override
  String get seriesPending => 'Séries à venir';

  @override
  String get statusUpcoming => 'À venir';

  @override
  String get qualificationByStage =>
      'Classement au temps, toutes séries confondues';

  @override
  String qualificationByHeat(int n) {
    return 'Les $n premiers de chaque série';
  }

  @override
  String get qualificationByHeatUnknown => 'Qualification par série';

  @override
  String get stageLevelHeats => 'Séries';

  @override
  String get stageLevelQuarterFinal => 'Quarts de finale';

  @override
  String get stageLevelSemiFinal => 'Demi-finales';

  @override
  String get stageLevelFinal => 'Finale';

  @override
  String progressionCollapsed(String first, String following) {
    return '$first › $following';
  }

  @override
  String followingFinals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finales',
      one: '1 finale',
    );
    return '$_temp0';
  }

  @override
  String followingStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }
}
