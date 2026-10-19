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
  String get chooseCompetition => 'Choisir une compétition';

  @override
  String get chooseCompetitionHint =>
      'Ouvrez une compétition depuis l\'accueil pour suivre son programme, son live et ses résultats.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginField => 'Identifiant';

  @override
  String get passwordField => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get loginErrorRejected => 'Identifiant ou mot de passe refusé.';

  @override
  String get loginErrorUnreachable =>
      'Serveur injoignable : vérifiez votre connexion et réessayez.';

  @override
  String get loginErrorOther => 'La connexion a échoué. Réessayez plus tard.';

  @override
  String get sessionExpired => 'Session expirée, reconnectez-vous';

  @override
  String accountType(String type) {
    return 'Type de compte : $type';
  }

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutConfirmTitle => 'Se déconnecter ?';

  @override
  String logOutConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saisies n\'ont pas été envoyées',
      one: '1 saisie n\'a pas été envoyée',
    );
    return '$_temp0. Gardées, elles restent sur le téléphone jusqu\'à votre prochaine connexion avec ce compte. Abandonnées, elles sont effacées et ne partiront jamais.';
  }

  @override
  String get logOutDiscard => 'Abandonner les saisies et se déconnecter';

  @override
  String get logOutDiscardFailed =>
      'Les saisies n\'ont pas pu être effacées du téléphone : vous restez connecté. Réessayez.';

  @override
  String get cancel => 'Annuler';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get liveTitle => 'Live';

  @override
  String get liveRunning => 'En cours';

  @override
  String get liveRecent => 'Dernières séries';

  @override
  String get liveProvisional => 'Temporaire';

  @override
  String get liveValidated => 'Validé';

  @override
  String get liveMarshalling => 'Chambre d\'appel';

  @override
  String get livePendingValidation =>
      'Résultats en attente de validation par les juges';

  @override
  String get liveWaitingResults =>
      'Résultats en attente : ils s\'afficheront dès leur publication';

  @override
  String get liveNothingYet => 'Aucune série courue pour l\'instant';

  @override
  String liveNext(String label) {
    return 'Prochaine série : $label';
  }

  @override
  String get liveSeeProgramme => 'Voir tout le programme';

  @override
  String get liveLoadError => 'Impossible de charger le direct.';

  @override
  String get liveRefresh => 'Rafraîchir';

  @override
  String get coastalComingSoon => 'Côtier : bientôt disponible';

  @override
  String heatPlace(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      '1': '1er',
      'other': '${place}e',
    });
    return '$_temp0';
  }

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

  @override
  String get enterResults => 'Saisir';

  @override
  String get officialBadge => 'OFFICIEL';

  @override
  String get entryTitle => 'Saisie';

  @override
  String get entryNotice =>
      'Saisies non définitives — validation par le juge des résultats (FFSSCompetition)';

  @override
  String get entryLaneAll => 'Tous';

  @override
  String entryLane(int lane) {
    return 'Couloir $lane';
  }

  @override
  String entryChrono(int number) {
    return 'Chrono $number';
  }

  @override
  String entryManualTime(String time) {
    return 'Temps manuel : $time';
  }

  @override
  String get entryRuleSingle => '1 chrono';

  @override
  String get entryRuleAverage => 'moyenne de 2';

  @override
  String get entryRuleMedian => 'médiane de 3';

  @override
  String get entryNotFinal => 'non définitif';

  @override
  String get manualTimeNote => 'manuel, non définitif';

  @override
  String get entryNoChrono => 'Aucun chrono saisi';

  @override
  String get entryForfeitNoChrono =>
      'Forfait : pas de chrono. Annulez le forfait pour saisir un temps';

  @override
  String get entryInvalidChrono => 'Secondes au plus 59';

  @override
  String get entryDisqualify => 'DQ…';

  @override
  String get entryDisqualifyCodeRequired => 'Saisissez le code de DQ';

  @override
  String get entryDisqualifyCode => 'Code de DQ';

  @override
  String get entryCancelDisqualification => 'Annuler la DQ';

  @override
  String entryForfeitConfirm(String name) {
    return 'Déclarer forfait : $name ?';
  }

  @override
  String get entryCancelForfeit => 'Annuler le forfait';

  @override
  String get entryChronos => 'Chronos';

  @override
  String get entryClear => 'Effacer';

  @override
  String get entryErase => 'Effacer le dernier chiffre';

  @override
  String get entrySave => 'Enregistrer';

  @override
  String get entrySaveAndNext => 'Enregistrer et passer à la série suivante';

  @override
  String get entryAllLanes => 'Tous les couloirs';

  @override
  String get entryPreviousHeat => 'Série précédente';

  @override
  String get entryNextHeat => 'Série suivante';

  @override
  String entryDisqualified(String code) {
    return 'DQ $code';
  }

  @override
  String get entrySent => 'Envoyé';

  @override
  String get entryPending => 'En attente d\'envoi';

  @override
  String entryRejected(String reason) {
    return 'Refusé : $reason';
  }

  @override
  String get entryRejectedValidated => 'validé par le juge des résultats';

  @override
  String get entryRejectedUnreadable => 'résultat illisible sur le site';

  @override
  String get entryRejectedEmptyPlace => 'plus personne dans ce couloir';

  @override
  String get entryRejectedPlaceChanged =>
      'série recomposée : ce couloir a changé de nageur';

  @override
  String get entryRejectedServer => 'refus du site';

  @override
  String get entryDismiss => 'Ignorer';

  @override
  String get entryValidatedByJudge => 'Validé par le juge des résultats';

  @override
  String get entryUnsaved => 'Non enregistré';

  @override
  String entryEmptyLane(int lane) {
    return 'Personne au couloir $lane dans cette série';
  }

  @override
  String get entryNoHeat => 'Aucune série à saisir dans ce créneau';

  @override
  String get entryLastHeat =>
      'Dernière série : il n\'y en a pas d\'autre après';

  @override
  String get entryNotPersisted =>
      'Saisie en file, mais pas enregistrée sur le téléphone : ne fermez pas l\'application avant son envoi';

  @override
  String get entryNotConnected => 'Connectez-vous pour saisir';

  @override
  String get entryForfeitChronosDropped =>
      'Couloir forfait : les chronos tapés ne sont pas enregistrés';

  @override
  String get entryDenied => 'Saisie réservée aux officiels de la compétition';

  @override
  String get entryLoadError => 'Impossible de charger cette série.';

  @override
  String get entrySessionLost => 'Session expirée — reconnectez-vous';

  @override
  String get entryResuming => 'Vérification de vos droits de saisie…';

  @override
  String get entryUnverified =>
      'Droits de saisie non vérifiés : le site n\'a pas répondu. Vérifiez votre connexion et réessayez.';

  @override
  String get resultsSearch => 'Rechercher un athlète';

  @override
  String get resultsRefresh => 'Rafraîchir';

  @override
  String get resultsEvents => 'Épreuves';

  @override
  String get resultsStandings => 'Classements';

  @override
  String get resultsNoEvent => 'Aucune épreuve eau plate publiée';

  @override
  String get resultsLoadError => 'Impossible de charger les résultats.';

  @override
  String get resultsRankingProvisional => 'CLASSEMENT PROVISOIRE';

  @override
  String get resultsRankingFinal => 'CLASSEMENT';

  @override
  String resultsSeriesProgress(int finished, int total) {
    return '$finished/$total séries';
  }

  @override
  String get standingsClubs => 'Clubs';

  @override
  String get standingsLicensees => 'Licenciés';

  @override
  String standingsPoints(int points) {
    return '$points pts';
  }

  @override
  String standingsGap(int gap) {
    return 'Écart au précédent −$gap';
  }

  @override
  String standingsRaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
    );
    return '$_temp0';
  }

  @override
  String standingsFooter(int finished, int total, String time) {
    return 'Provisoire · $finished / $total séries terminées · calculé à $time';
  }

  @override
  String standingsIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves n\'ont pu être lues : classement incomplet',
      one: '1 épreuve n\'a pu être lue : classement incomplet',
    );
    return '$_temp0';
  }

  @override
  String standingsStale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count épreuves n\'ont pu être relues : leur classement précédent est gardé',
      one: '1 épreuve n\'a pu être relue : son classement précédent est gardé',
    );
    return '$_temp0';
  }

  @override
  String get standingsEmpty => 'Aucun point marqué pour l\'instant';

  @override
  String get standingsLoadError => 'Impossible de calculer les classements.';

  @override
  String get searchTitle => 'Rechercher un athlète';

  @override
  String get searchFieldHint => 'Nom, prénom';

  @override
  String searchTooShort(int count) {
    return 'Tapez au moins $count lettres';
  }

  @override
  String get searchNoResult => 'Aucun athlète trouvé';

  @override
  String get searchLoadError => 'Impossible de charger les participants.';

  @override
  String get athleteRun => 'Courues';

  @override
  String get athleteToRun => 'À courir';

  @override
  String get athleteNoRace => 'Aucune épreuve eau plate';

  @override
  String get athleteFindHeat => 'Trouver sa série';

  @override
  String get athleteNotPlaced => 'Pas encore placé';

  @override
  String get athleteFindError => 'Places illisibles : réessayez';

  @override
  String athleteSeries(int number) {
    return 'Série $number';
  }

  @override
  String athleteLane(int lane) {
    return 'ligne $lane';
  }

  @override
  String athleteHeatPlace(String place) {
    return '$place de la série';
  }

  @override
  String athleteEventRank(String rank) {
    return '$rank de l\'épreuve';
  }

  @override
  String athleteEventRankProvisional(String rank) {
    return '$rank de l\'épreuve (provisoire)';
  }

  @override
  String get athleteRaceUnavailable =>
      'Résultats illisibles pour cette épreuve';

  @override
  String get athleteNotFound =>
      'Cet athlète n\'est pas engagé dans cette compétition.';

  @override
  String get athleteLoadError => 'Impossible de charger la fiche.';

  @override
  String get followedMark => 'Suivi';

  @override
  String get followAthlete => 'Suivre cet athlète';

  @override
  String get unfollowAthlete => 'Ne plus suivre cet athlète';

  @override
  String get unfollowClub => 'Ne plus suivre ce club';

  @override
  String get mySpaceSpaces => 'Mes espaces sur cette compétition';

  @override
  String get mySpaceEveryone => 'Compétition (tout le monde)';

  @override
  String get mySpacePreferences => 'Préférences';

  @override
  String get mySpaceNoSpace =>
      'Ce compte n\'a pas d\'espace sur cette compétition.';

  @override
  String get mySpaceRolesError =>
      'Impossible de lire vos espaces sur cette compétition.';

  @override
  String get mySpaceAthlete => 'Athlète';

  @override
  String get mySpaceAthleteSubtitle => 'Planning, résultats';

  @override
  String mySpaceClub(String label) {
    return 'Club · $label';
  }

  @override
  String get mySpaceClubSubtitle => 'Athlètes, planning, résultats';

  @override
  String get mySpaceOfficial => 'Officiel';

  @override
  String get mySpaceOfficialSubtitle => 'Saisies, séries à saisir';

  @override
  String get mySpaceAdmin => 'Admin';

  @override
  String mySpaceAdminSubtitle(String server) {
    return 'Serveur : $server';
  }

  @override
  String get mySpacePrincipalJudge => 'Juge principal';

  @override
  String get mySpaceStartsNow => 'maintenant';

  @override
  String mySpaceStartsInMinutes(int minutes) {
    return 'dans $minutes min';
  }

  @override
  String mySpaceStartsInHours(int hours) {
    return 'dans $hours h';
  }

  @override
  String mySpaceRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refusées',
      one: '1 refusée',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceFollows => 'Mes suivis';

  @override
  String get mySpaceNoFollow => 'Aucun suivi';

  @override
  String get mySpaceFollowsHint =>
      'On suit depuis une fiche d\'athlète ou l\'espace d\'un club (étoile). Les courses suivies ressortent dans le Live et les résultats.';

  @override
  String mySpaceNextRace(String label) {
    return 'Prochaine : $label';
  }

  @override
  String get mySpaceNoNextRace => 'Aucune course à venir';

  @override
  String mySpaceAthleteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count athlètes',
      one: '$count athlète',
    );
    return '$_temp0';
  }

  @override
  String mySpaceClubCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clubs',
      one: '$count club',
    );
    return '$_temp0';
  }

  @override
  String mySpaceFlatWaterEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves d\'eau plate',
      one: '$count épreuve d\'eau plate',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceInfos => 'Infos de la compétition';

  @override
  String get mySpaceInfosSubtitle => 'Lieu, dates, engagés';

  @override
  String get mySpaceInfosError =>
      'Impossible de charger les infos de la compétition.';

  @override
  String get mySpaceOrganizer => 'Organisateur';

  @override
  String get mySpaceClubs => 'Clubs';

  @override
  String get mySpaceOfficials => 'Officiels';

  @override
  String get mySpaceOfficialsSubtitle => 'Juge principal, niveaux, jours';

  @override
  String get mySpaceOfficialsEmpty =>
      'Aucun officiel publié pour cette compétition.';

  @override
  String get mySpaceOfficialsError => 'Impossible de charger les officiels.';

  @override
  String mySpaceOfficialLevel(String level) {
    return 'Niveau $level';
  }

  @override
  String get mySpaceOfficialLevelUnknown => 'Niveau non renseigné';

  @override
  String get startTabTitle => 'Onglet d\'ouverture';

  @override
  String get mySpaceAthleteUnknown => 'Impossible de vérifier votre engagement';

  @override
  String get mySpaceFollowsError => 'Impossible de lire vos suivis';

  @override
  String get mySpaceAthleteSpaceTitle => 'Mon espace athlète';

  @override
  String get mySpaceNextRaceTitle => 'Ma prochaine course';

  @override
  String get mySpaceCellTime => 'Heure';

  @override
  String get mySpaceCellSeries => 'Série';

  @override
  String get mySpaceCellLane => 'Ligne';

  @override
  String get mySpaceMyPlanning => 'Mon planning';

  @override
  String get mySpaceMyResults => 'Mes résultats';

  @override
  String get mySpaceNotEngaged =>
      'Votre compte n\'est engagé sur aucune épreuve de cette compétition.';

  @override
  String get mySpaceNoRaceRun => 'Aucune course courue pour le moment';

  @override
  String get mySpaceRefereeTag => 'RÉFÉRENT';

  @override
  String get mySpaceAdminTag => 'ADMIN';

  @override
  String mySpaceFigureAthletes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'athlètes',
      one: 'athlète',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceFigureRank => 'clubs (prov.)';

  @override
  String mySpaceFigureForfeits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'forfaits',
      one: 'forfait',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceCompute => 'Calculer';

  @override
  String get mySpacePlanning => 'Planning';

  @override
  String get mySpaceForfeits => 'Forfaits';

  @override
  String get mySpaceUpcoming => 'À venir';

  @override
  String mySpaceCardsFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fiches d\'athlète n\'ont pu être lues',
      one: '1 fiche d\'athlète n\'a pu être lue',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceForfeitsHint => 'Forfaits tirés des résultats publiés.';

  @override
  String mySpaceForfeitsDeadline(int minutes) {
    return 'Déclarer ou annuler un forfait jusqu\'à $minutes min avant la course';
  }

  @override
  String mySpaceForfeitPlace(int heat, int lane) {
    return 'Série $heat · couloir $lane';
  }

  @override
  String get mySpaceForfeitNotPlacedUnknown =>
      'pas encore placé · état inconnu';

  @override
  String mySpaceForfeitSentDeclared(String time) {
    return 'Forfait envoyé à $time (vérifiable une fois placé)';
  }

  @override
  String mySpaceForfeitSentCancelled(String time) {
    return 'Annulation envoyée à $time (vérifiable une fois placé)';
  }

  @override
  String get mySpaceForfeitDeclare => 'Déclarer forfait';

  @override
  String get mySpaceForfeitCancel => 'Annuler le forfait';

  @override
  String get mySpaceForfeitUnconfirmed =>
      'Envoyé, mais la place relue montre encore l\'état d\'avant : rafraîchissez dans un instant';

  @override
  String get mySpaceForfeitUnknown => 'état inconnu (place illisible)';

  @override
  String mySpaceForfeitLocked(int minutes) {
    return 'Forfait non modifiable : course courue, sans horaire, ou à moins de $minutes min';
  }

  @override
  String get mySpaceForfeitNotAllowed =>
      'Seul le référent du club ou un admin peut déclarer un forfait';

  @override
  String get mySpaceForfeitFailed =>
      'Forfait non enregistré (réseau, droits ou session expirée) : réessayez';

  @override
  String get mySpaceForfeitNoEntry => 'Aucun engagement';

  @override
  String get mySpaceNoForfeit => 'Aucun forfait dans les résultats publiés';

  @override
  String get mySpaceClubError => 'Impossible de charger l\'espace du club.';

  @override
  String get mySpaceClubNoAthlete => 'Aucun athlète de ce club n\'est engagé.';

  @override
  String get mySpaceClubFallback => 'Club';

  @override
  String get followClub => 'Suivre ce club';

  @override
  String get officialSpaceTitle => 'Mon espace officiel';

  @override
  String get officialNothingRunning => 'Aucune série en cours ni à venir';

  @override
  String officialFollowing(String heat) {
    return 'Suivante : $heat';
  }

  @override
  String get officialMyEntries => 'Mes saisies';

  @override
  String get officialNoEntries => 'Aucune saisie sur cette compétition';

  @override
  String officialSentAt(String time) {
    return 'Envoyée à $time';
  }

  @override
  String get officialStatusCleared => 'Statut remis à OK';

  @override
  String get officialUnknownSeries => 'Série hors programme';

  @override
  String get officialCompetition => 'Compétition';

  @override
  String get officialHeatsToEnter => 'Séries à saisir';

  @override
  String get officialHeatsToEnterSubtitle => 'Courues sans chrono ni temps';

  @override
  String get officialHeatsToEnterEmpty =>
      'Aucune série courue sans chrono ni temps.';

  @override
  String officialHeatsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries non lues',
      one: '1 série non lue',
    );
    return '$_temp0';
  }

  @override
  String get officialHeatsError => 'Impossible de lire les séries.';

  @override
  String get officialDecisions => 'DQ et forfaits';

  @override
  String get officialDecisionsSubtitle => 'Tirés des classements d\'épreuve';

  @override
  String get officialDecisionsEmpty => 'Aucune DQ ni aucun forfait publié.';

  @override
  String officialDecisionsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves non lues',
      one: '1 épreuve non lue',
    );
    return '$_temp0';
  }

  @override
  String get officialDecisionsError => 'Impossible de lire les classements.';

  @override
  String get officialQueued => 'En file d\'envoi';

  @override
  String get reminderLeadTitle => 'Rappel avant une course';

  @override
  String get reminderLeadSubtitle =>
      'Vos athlètes suivis et vous-même, d\'après le programme';

  @override
  String get reminderLeadOff => 'Désactivé';

  @override
  String reminderLeadMinutes(int minutes) {
    return '$minutes min avant';
  }

  @override
  String get reminderPermissionDenied =>
      'Notifications refusées : les rappels sont désactivés. Autorisez-les dans les réglages du téléphone pour les réactiver.';

  @override
  String reminderTitle(String name, int minutes) {
    return '$name : départ dans $minutes min';
  }

  @override
  String reminderTitleEvent(String name, int minutes) {
    return '$name : épreuve dans $minutes min';
  }

  @override
  String get reminderPermissionMissing =>
      'Notifications non autorisées : choisissez un délai pour les autoriser.';

  @override
  String get reminderChannelName => 'Rappels de course';

  @override
  String reminderBody(String event, String time) {
    return '$event · prévu à $time';
  }

  @override
  String get serverTitle => 'Serveur';

  @override
  String get serverProduction => 'Production';

  @override
  String get serverStaging => 'Recette';

  @override
  String get serverBanner => 'RECETTE';

  @override
  String serverSwitchTitle(String server) {
    return 'Passer sur $server ?';
  }

  @override
  String get serverSwitchBody =>
      'L\'app repart de l\'onglet d\'ouverture sur ce serveur, avec le compte qui y est enregistré s\'il y en a un. Rien n\'est effacé : comptes, suivis et préférences de chaque serveur restent sur le téléphone.';

  @override
  String serverSwitchUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count saisies n\'ont pas été envoyées : elles restent sur le téléphone et partiront au retour sur ce serveur.',
      one:
          '1 saisie n\'a pas été envoyée : elle reste sur le téléphone et partira au retour sur ce serveur.',
    );
    return '$_temp0';
  }

  @override
  String get serverSwitchConfirm => 'Changer de serveur';

  @override
  String get remountWaiting =>
      'Une saisie est en cours d\'envoi : l\'app attend sa réponse…';

  @override
  String get remountBusy =>
      'La saisie en cours d\'envoi n\'a pas répondu : rien n\'a changé. Réessayez dans un instant.';

  @override
  String get networkLogTitle => 'Journal réseau';

  @override
  String get networkLogErrorsOnly => 'Erreurs seulement';

  @override
  String get networkLogClear => 'Effacer';

  @override
  String get networkLogEmpty => 'Aucune requête enregistrée';

  @override
  String get networkLogEmptyErrors => 'Aucune requête en erreur';

  @override
  String get networkLogNoStatus => 'sans réponse';

  @override
  String get adminTitle => 'Espace admin';

  @override
  String get adminServerHint => 'À changer dans les Préférences de Mon espace';

  @override
  String get adminCompetition => 'Compétition active';

  @override
  String get adminDecisions => 'Forfaits et DQ de tous les clubs';

  @override
  String get adminOpenSpace => 'Ouvrir un espace';

  @override
  String get adminClubsSubtitle => 'L\'espace de n\'importe quel club';

  @override
  String get adminDiagnostic => 'Diagnostic';

  @override
  String get adminDataCheck => 'Contrôle des données';

  @override
  String get adminMaintenance => 'Maintenance';

  @override
  String get adminOnly => 'Réservé aux admins.';

  @override
  String get adminAllClubs => 'Tous les clubs';

  @override
  String get adminAllEvents => 'Toutes les épreuves';

  @override
  String get adminFilteredEmpty =>
      'Aucune DQ ni aucun forfait publié pour ce filtre.';

  @override
  String get adminClubForfeits => 'Forfaits déclarés du club';

  @override
  String get adminDataCheckSubtitle =>
      'Épreuves et leurs séries relues (une requête par épreuve) ; résultats et places à la demande';

  @override
  String get dataCheckNone => 'Aucune anomalie trouvée.';

  @override
  String get dataCheckError => 'Impossible de faire le contrôle.';

  @override
  String get dataCheckOrphanSeries => 'Séries orphelines';

  @override
  String get dataCheckOrphanSeriesConsequence =>
      'Aucune course du programme ne leur correspond : absentes des résultats de l\'app.';

  @override
  String get dataCheckNoSpeciality => 'Épreuves sans spécialité';

  @override
  String get dataCheckNoSpecialityConsequence =>
      'Masquées partout dans l\'app.';

  @override
  String get dataCheckStatus3 => 'Résultats au statut 3';

  @override
  String get dataCheckStatus3Consequence =>
      'Valeur de repli du site quand l\'envoi n\'a pas donné de statut : ni temps, ni décision montrés.';

  @override
  String get dataCheckNoResult => 'Séries terminées sans résultat publié';

  @override
  String get dataCheckNoResultConsequence =>
      'Places sans temps ni classement dans l\'app, et proposées à la saisie.';

  @override
  String get dataCheckNoTime => 'Courses sans horaire';

  @override
  String get dataCheckNoTimeConsequence =>
      'Sans heure au programme ni rappel ; leurs séries ne se rattachent que par le numéro.';

  @override
  String get dataCheckUnreadPlaces => 'Places non lues';

  @override
  String get dataCheckUnreadPlacesConsequence =>
      'Couloirs en attente dans le détail du créneau et le Live (échec réseau ou réponse illisible).';

  @override
  String get dataCheckRolesFailed => 'Rôles non lus';

  @override
  String get dataCheckRolesFailedConsequence =>
      'Les droits du compte sur la compétition sont inconnus : Mon espace n\'en montre aucun.';

  @override
  String get dataCheckParticipantsFailed => 'Participants non lus';

  @override
  String get dataCheckParticipantsFailedConsequence =>
      'Recherche d\'athlète, fiches et clubs indisponibles.';

  @override
  String get dataCheckEventsFailed => 'Épreuves non lues';

  @override
  String get dataCheckEventsFailedConsequence =>
      'Épreuves et séries non contrôlées.';

  @override
  String get dataCheckProgrammeFailed => 'Programme non lu';

  @override
  String get dataCheckProgrammeFailedConsequence =>
      'Rattachement des séries, courses et places non contrôlés.';

  @override
  String get dataCheckSeriesFailed => 'Séries d\'épreuve non lues';

  @override
  String get dataCheckSeriesFailedConsequence =>
      'Rattachement des séries de ces épreuves non contrôlé.';

  @override
  String get dataCheckResultsFailed => 'Résultats de série non lus';

  @override
  String get dataCheckResultsFailedConsequence =>
      'Statut 3 et publication de ces séries non contrôlés.';

  @override
  String dataCheckResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String dataCheckPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String dataCheckSeriesCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Séries orphelines : $count lectures des séries d\'épreuve, une par épreuve eau plate.',
      one:
          'Séries orphelines : 1 lecture des séries d\'épreuve, une par épreuve eau plate.',
      zero: 'Séries orphelines : aucune épreuve eau plate à lire.',
    );
    return '$_temp0';
  }

  @override
  String get dataCheckOnDemand => 'À la demande';

  @override
  String get dataCheckResultsAction => 'Vérifier les résultats';

  @override
  String dataCheckResultsCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lectures, une par course terminée',
      one: '1 lecture, une par course terminée',
      zero: 'Aucune course terminée',
    );
    return '$_temp0';
  }

  @override
  String get dataCheckPlacesAction => 'Vérifier les places';

  @override
  String dataCheckPlacesCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lectures, une par place : la plus longue',
      one: '1 lecture, une par place : la plus longue',
      zero: 'Aucune place',
    );
    return '$_temp0';
  }

  @override
  String get dataCheckStepRunning => 'Lecture en cours…';

  @override
  String get dataCheckStepDone => 'Vérifié';

  @override
  String get adminMaintenanceSubtitle =>
      'Données locales, relecture, rappels, rapport';

  @override
  String get maintenanceClearTitle => 'Effacer les données locales';

  @override
  String get maintenanceClearSubtitle =>
      'Suivis, séries connues, athlète du compte, couloir suivi';

  @override
  String get maintenanceClearBody =>
      'Les suivis, les séries connues, l\'athlète du compte et le couloir suivi de cette compétition seront effacés de ce téléphone. Les saisies non envoyées et la session sont gardées.';

  @override
  String get maintenanceClearConfirm => 'Effacer';

  @override
  String get maintenanceCleared => 'Données locales effacées.';

  @override
  String get maintenanceClearFailed =>
      'Certaines données n\'ont pas pu être effacées.';

  @override
  String get maintenanceReloadTitle => 'Forcer une relecture complète';

  @override
  String get maintenanceReloadBody =>
      'L\'app relit tout depuis le serveur et repart de l\'onglet d\'ouverture. Rien de ce qui est enregistré n\'est effacé.';

  @override
  String get maintenanceReloadConfirm => 'Relire';

  @override
  String get maintenanceReminders => 'Rappels';

  @override
  String get maintenanceTestNotification => 'Envoyer une notification de test';

  @override
  String get maintenanceTestTitle => 'Notification de test';

  @override
  String get maintenanceTestBody =>
      'Les rappels de course s\'afficheront ainsi.';

  @override
  String get maintenanceTestSent => 'Notification envoyée.';

  @override
  String get maintenanceTestUnsupported => 'Rappels sur Android seulement.';

  @override
  String get maintenanceTestFailed =>
      'La notification n\'a pas pu être envoyée.';

  @override
  String get maintenancePlannedNone => 'Aucun rappel planifié.';

  @override
  String get maintenancePlannedError => 'Impossible de lire les rappels.';

  @override
  String get maintenanceReportTitle => 'Copier le rapport de diagnostic';

  @override
  String get maintenanceReportSubtitle =>
      'Version, serveur, compétition, file d\'envoi, dernières erreurs ; ni jeton ni nom';

  @override
  String get maintenanceReportCopied => 'Rapport copié dans le presse-papiers.';

  @override
  String get maintenanceReportFailed => 'Impossible de préparer le rapport.';
}
