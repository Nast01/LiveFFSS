import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'FFSS-LIVE'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Sauvetage sportif en direct'**
  String get appTagline;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Compétition, ville, club…'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAll;

  /// No description provided for @filterFlatWater.
  ///
  /// In fr, this message translates to:
  /// **'Eau plate'**
  String get filterFlatWater;

  /// No description provided for @filterCoastal.
  ///
  /// In fr, this message translates to:
  /// **'Côtier'**
  String get filterCoastal;

  /// No description provided for @filterFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get filterFavorites;

  /// No description provided for @disciplineFlatWater.
  ///
  /// In fr, this message translates to:
  /// **'Eau plate'**
  String get disciplineFlatWater;

  /// No description provided for @disciplineCoastal.
  ///
  /// In fr, this message translates to:
  /// **'Côtier'**
  String get disciplineCoastal;

  /// No description provided for @disciplineMixed.
  ///
  /// In fr, this message translates to:
  /// **'Mixte'**
  String get disciplineMixed;

  /// No description provided for @liveBadge.
  ///
  /// In fr, this message translates to:
  /// **'EN DIRECT'**
  String get liveBadge;

  /// No description provided for @dayOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'Jour {current}/{total}'**
  String dayOfTotal(int current, int total);

  /// No description provided for @nowRunning.
  ///
  /// In fr, this message translates to:
  /// **'MAINTENANT'**
  String get nowRunning;

  /// No description provided for @nextUp.
  ///
  /// In fr, this message translates to:
  /// **'À SUIVRE'**
  String get nextUp;

  /// No description provided for @heatOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'Série {position}/{total}'**
  String heatOfTotal(int position, int total);

  /// No description provided for @genderFemale.
  ///
  /// In fr, this message translates to:
  /// **'Dames'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In fr, this message translates to:
  /// **'Messieurs'**
  String get genderMale;

  /// No description provided for @genderMixed.
  ///
  /// In fr, this message translates to:
  /// **'Mixte'**
  String get genderMixed;

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcoming;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get seeAll;

  /// No description provided for @recentlyFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminées récemment'**
  String get recentlyFinished;

  /// No description provided for @allCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions'**
  String get allCompetitions;

  /// No description provided for @noCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Aucune compétition'**
  String get noCompetition;

  /// No description provided for @loadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les compétitions.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @refreshFailed.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour impossible : les données affichées sont conservées.'**
  String get refreshFailed;

  /// No description provided for @addFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFavorite;

  /// No description provided for @tabHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// No description provided for @tabProgramme.
  ///
  /// In fr, this message translates to:
  /// **'Programme'**
  String get tabProgramme;

  /// No description provided for @tabLive.
  ///
  /// In fr, this message translates to:
  /// **'Live'**
  String get tabLive;

  /// No description provided for @tabResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get tabResults;

  /// No description provided for @tabMySpace.
  ///
  /// In fr, this message translates to:
  /// **'Mon espace'**
  String get tabMySpace;

  /// No description provided for @chooseCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une compétition'**
  String get chooseCompetition;

  /// No description provided for @chooseCompetitionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez une compétition depuis l\'accueil pour suivre son programme, son live et ses résultats.'**
  String get chooseCompetitionHint;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginField.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get loginField;

  /// No description provided for @passwordField.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordField;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @loginErrorRejected.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe refusé.'**
  String get loginErrorRejected;

  /// No description provided for @loginErrorUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable : vérifiez votre connexion et réessayez.'**
  String get loginErrorUnreachable;

  /// No description provided for @loginErrorOther.
  ///
  /// In fr, this message translates to:
  /// **'La connexion a échoué. Réessayez plus tard.'**
  String get loginErrorOther;

  /// No description provided for @sessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée, reconnectez-vous'**
  String get sessionExpired;

  /// No description provided for @accountType.
  ///
  /// In fr, this message translates to:
  /// **'Type de compte : {type}'**
  String accountType(String type);

  /// No description provided for @logOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logOut;

  /// No description provided for @logOutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get logOutConfirmTitle;

  /// No description provided for @logOutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 saisie attend d\'être envoyée} other{{count} saisies attendent d\'être envoyées}}. Elles resteront en file et partiront à votre prochaine connexion avec ce compte.'**
  String logOutConfirmBody(int count);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @languageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @liveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Live'**
  String get liveTitle;

  /// No description provided for @liveRunning.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get liveRunning;

  /// No description provided for @liveRecent.
  ///
  /// In fr, this message translates to:
  /// **'Dernières séries'**
  String get liveRecent;

  /// No description provided for @liveProvisional.
  ///
  /// In fr, this message translates to:
  /// **'Temporaire'**
  String get liveProvisional;

  /// No description provided for @liveValidated.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get liveValidated;

  /// No description provided for @liveMarshalling.
  ///
  /// In fr, this message translates to:
  /// **'Chambre d\'appel'**
  String get liveMarshalling;

  /// No description provided for @livePendingValidation.
  ///
  /// In fr, this message translates to:
  /// **'Résultats en attente de validation par les juges'**
  String get livePendingValidation;

  /// No description provided for @liveWaitingResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats en attente : ils s\'afficheront dès leur publication'**
  String get liveWaitingResults;

  /// No description provided for @liveNothingYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune série courue pour l\'instant'**
  String get liveNothingYet;

  /// No description provided for @liveNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine série : {label}'**
  String liveNext(String label);

  /// No description provided for @liveSeeProgramme.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout le programme'**
  String get liveSeeProgramme;

  /// No description provided for @liveLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le direct.'**
  String get liveLoadError;

  /// No description provided for @liveRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get liveRefresh;

  /// No description provided for @coastalComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Côtier : bientôt disponible'**
  String get coastalComingSoon;

  /// No description provided for @heatPlace.
  ///
  /// In fr, this message translates to:
  /// **'{place, select, 1{1er} other{{place}e}}'**
  String heatPlace(String place);

  /// No description provided for @durationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'≈ {minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In fr, this message translates to:
  /// **'≈ {hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'≈ {hours} h {minutes}'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @meetingItemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 créneau} other{{count} créneaux}}'**
  String meetingItemCount(int count);

  /// No description provided for @meetingEventCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 épreuve} other{{count} épreuves}}'**
  String meetingEventCount(int count);

  /// No description provided for @programmeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Programme'**
  String get programmeTitle;

  /// No description provided for @programmeEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Programme pas encore publié'**
  String get programmeEmpty;

  /// No description provided for @programmeLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le programme.'**
  String get programmeLoadError;

  /// No description provided for @itemLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger ce créneau.'**
  String get itemLoadError;

  /// No description provided for @itemNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce créneau n\'est plus au programme.'**
  String get itemNotFound;

  /// No description provided for @noLanes.
  ///
  /// In fr, this message translates to:
  /// **'Composition pas encore publiée'**
  String get noLanes;

  /// No description provided for @recordBadge.
  ///
  /// In fr, this message translates to:
  /// **'Record'**
  String get recordBadge;

  /// No description provided for @nationalRecordBadge.
  ///
  /// In fr, this message translates to:
  /// **'Record de France'**
  String get nationalRecordBadge;

  /// No description provided for @progressionToggle.
  ///
  /// In fr, this message translates to:
  /// **'Déroulement'**
  String get progressionToggle;

  /// No description provided for @statusFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get statusFinished;

  /// No description provided for @forfeit.
  ///
  /// In fr, this message translates to:
  /// **'Forfait'**
  String get forfeit;

  /// No description provided for @seriesPending.
  ///
  /// In fr, this message translates to:
  /// **'Séries à venir'**
  String get seriesPending;

  /// No description provided for @statusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get statusUpcoming;

  /// No description provided for @qualificationByStage.
  ///
  /// In fr, this message translates to:
  /// **'Classement au temps, toutes séries confondues'**
  String get qualificationByStage;

  /// No description provided for @qualificationByHeat.
  ///
  /// In fr, this message translates to:
  /// **'Les {n} premiers de chaque série'**
  String qualificationByHeat(int n);

  /// No description provided for @qualificationByHeatUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Qualification par série'**
  String get qualificationByHeatUnknown;

  /// No description provided for @stageLevelHeats.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get stageLevelHeats;

  /// No description provided for @stageLevelQuarterFinal.
  ///
  /// In fr, this message translates to:
  /// **'Quarts de finale'**
  String get stageLevelQuarterFinal;

  /// No description provided for @stageLevelSemiFinal.
  ///
  /// In fr, this message translates to:
  /// **'Demi-finales'**
  String get stageLevelSemiFinal;

  /// No description provided for @stageLevelFinal.
  ///
  /// In fr, this message translates to:
  /// **'Finale'**
  String get stageLevelFinal;

  /// No description provided for @progressionCollapsed.
  ///
  /// In fr, this message translates to:
  /// **'{first} › {following}'**
  String progressionCollapsed(String first, String following);

  /// No description provided for @followingFinals.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 finale} other{{count} finales}}'**
  String followingFinals(int count);

  /// No description provided for @followingStages.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 étape} other{{count} étapes}}'**
  String followingStages(int count);

  /// No description provided for @enterResults.
  ///
  /// In fr, this message translates to:
  /// **'Saisir'**
  String get enterResults;

  /// No description provided for @officialBadge.
  ///
  /// In fr, this message translates to:
  /// **'OFFICIEL'**
  String get officialBadge;

  /// No description provided for @entryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisie'**
  String get entryTitle;

  /// No description provided for @entryNotice.
  ///
  /// In fr, this message translates to:
  /// **'Saisies non définitives — validation par le juge des résultats (FFSSCompetition)'**
  String get entryNotice;

  /// No description provided for @entryLaneAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get entryLaneAll;

  /// No description provided for @entryLane.
  ///
  /// In fr, this message translates to:
  /// **'Couloir {lane}'**
  String entryLane(int lane);

  /// No description provided for @entryChrono.
  ///
  /// In fr, this message translates to:
  /// **'Chrono {number}'**
  String entryChrono(int number);

  /// No description provided for @entryManualTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps manuel : {time}'**
  String entryManualTime(String time);

  /// No description provided for @entryRuleSingle.
  ///
  /// In fr, this message translates to:
  /// **'1 chrono'**
  String get entryRuleSingle;

  /// No description provided for @entryRuleAverage.
  ///
  /// In fr, this message translates to:
  /// **'moyenne de 2'**
  String get entryRuleAverage;

  /// No description provided for @entryRuleMedian.
  ///
  /// In fr, this message translates to:
  /// **'médiane de 3'**
  String get entryRuleMedian;

  /// No description provided for @entryNotFinal.
  ///
  /// In fr, this message translates to:
  /// **'non définitif'**
  String get entryNotFinal;

  /// No description provided for @manualTimeNote.
  ///
  /// In fr, this message translates to:
  /// **'manuel, non définitif'**
  String get manualTimeNote;

  /// No description provided for @entryNoChrono.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chrono saisi'**
  String get entryNoChrono;

  /// No description provided for @entryInvalidChrono.
  ///
  /// In fr, this message translates to:
  /// **'Secondes au plus 59'**
  String get entryInvalidChrono;

  /// No description provided for @entryDisqualify.
  ///
  /// In fr, this message translates to:
  /// **'DQ…'**
  String get entryDisqualify;

  /// No description provided for @entryDisqualifyCodeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code de DQ'**
  String get entryDisqualifyCodeRequired;

  /// No description provided for @entryDisqualifyCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de DQ'**
  String get entryDisqualifyCode;

  /// No description provided for @entryCancelDisqualification.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la DQ'**
  String get entryCancelDisqualification;

  /// No description provided for @entryForfeitConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer forfait : {name} ?'**
  String entryForfeitConfirm(String name);

  /// No description provided for @entryCancelForfeit.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le forfait'**
  String get entryCancelForfeit;

  /// No description provided for @entryChronos.
  ///
  /// In fr, this message translates to:
  /// **'Chronos'**
  String get entryChronos;

  /// No description provided for @entryClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get entryClear;

  /// No description provided for @entryErase.
  ///
  /// In fr, this message translates to:
  /// **'Effacer le dernier chiffre'**
  String get entryErase;

  /// No description provided for @entrySave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get entrySave;

  /// No description provided for @entrySaveAndNext.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et passer à la série suivante'**
  String get entrySaveAndNext;

  /// No description provided for @entryAllLanes.
  ///
  /// In fr, this message translates to:
  /// **'Tous les couloirs'**
  String get entryAllLanes;

  /// No description provided for @entryPreviousHeat.
  ///
  /// In fr, this message translates to:
  /// **'Série précédente'**
  String get entryPreviousHeat;

  /// No description provided for @entryNextHeat.
  ///
  /// In fr, this message translates to:
  /// **'Série suivante'**
  String get entryNextHeat;

  /// No description provided for @entryDisqualified.
  ///
  /// In fr, this message translates to:
  /// **'DQ {code}'**
  String entryDisqualified(String code);

  /// No description provided for @entrySent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get entrySent;

  /// No description provided for @entryPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get entryPending;

  /// No description provided for @entryRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusé : {reason}'**
  String entryRejected(String reason);

  /// No description provided for @entryRejectedValidated.
  ///
  /// In fr, this message translates to:
  /// **'validé par le juge des résultats'**
  String get entryRejectedValidated;

  /// No description provided for @entryRejectedUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'résultat illisible sur le site'**
  String get entryRejectedUnreadable;

  /// No description provided for @entryRejectedEmptyPlace.
  ///
  /// In fr, this message translates to:
  /// **'plus personne dans ce couloir'**
  String get entryRejectedEmptyPlace;

  /// No description provided for @entryRejectedPlaceChanged.
  ///
  /// In fr, this message translates to:
  /// **'série recomposée : ce couloir a changé de nageur'**
  String get entryRejectedPlaceChanged;

  /// No description provided for @entryRejectedServer.
  ///
  /// In fr, this message translates to:
  /// **'refus du site'**
  String get entryRejectedServer;

  /// No description provided for @entryDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get entryDismiss;

  /// No description provided for @entryValidatedByJudge.
  ///
  /// In fr, this message translates to:
  /// **'Validé par le juge des résultats'**
  String get entryValidatedByJudge;

  /// No description provided for @entryUnsaved.
  ///
  /// In fr, this message translates to:
  /// **'Non enregistré'**
  String get entryUnsaved;

  /// No description provided for @entryEmptyLane.
  ///
  /// In fr, this message translates to:
  /// **'Personne au couloir {lane} dans cette série'**
  String entryEmptyLane(int lane);

  /// No description provided for @entryNoHeat.
  ///
  /// In fr, this message translates to:
  /// **'Aucune série à saisir dans ce créneau'**
  String get entryNoHeat;

  /// No description provided for @entryLastHeat.
  ///
  /// In fr, this message translates to:
  /// **'Dernière série : il n\'y en a pas d\'autre après'**
  String get entryLastHeat;

  /// No description provided for @entryNotPersisted.
  ///
  /// In fr, this message translates to:
  /// **'Saisie en file, mais pas enregistrée sur le téléphone : ne fermez pas l\'application avant son envoi'**
  String get entryNotPersisted;

  /// No description provided for @entryNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour saisir'**
  String get entryNotConnected;

  /// No description provided for @entryDenied.
  ///
  /// In fr, this message translates to:
  /// **'Saisie réservée aux officiels de la compétition'**
  String get entryDenied;

  /// No description provided for @entryLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger cette série.'**
  String get entryLoadError;

  /// No description provided for @entrySessionLost.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée — reconnectez-vous'**
  String get entrySessionLost;

  /// No description provided for @entryResuming.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de vos droits de saisie…'**
  String get entryResuming;

  /// No description provided for @entryUnverified.
  ///
  /// In fr, this message translates to:
  /// **'Droits de saisie non vérifiés : le site n\'a pas répondu. Vérifiez votre connexion et réessayez.'**
  String get entryUnverified;

  /// No description provided for @resultsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un athlète'**
  String get resultsSearch;

  /// No description provided for @resultsRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get resultsRefresh;

  /// No description provided for @resultsEvents.
  ///
  /// In fr, this message translates to:
  /// **'Épreuves'**
  String get resultsEvents;

  /// No description provided for @resultsStandings.
  ///
  /// In fr, this message translates to:
  /// **'Classements'**
  String get resultsStandings;

  /// No description provided for @resultsNoEvent.
  ///
  /// In fr, this message translates to:
  /// **'Aucune épreuve eau plate publiée'**
  String get resultsNoEvent;

  /// No description provided for @resultsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les résultats.'**
  String get resultsLoadError;

  /// No description provided for @resultsRankingProvisional.
  ///
  /// In fr, this message translates to:
  /// **'CLASSEMENT PROVISOIRE'**
  String get resultsRankingProvisional;

  /// No description provided for @resultsRankingFinal.
  ///
  /// In fr, this message translates to:
  /// **'CLASSEMENT'**
  String get resultsRankingFinal;

  /// No description provided for @resultsSeriesProgress.
  ///
  /// In fr, this message translates to:
  /// **'{finished}/{total} séries'**
  String resultsSeriesProgress(int finished, int total);

  /// No description provided for @standingsClubs.
  ///
  /// In fr, this message translates to:
  /// **'Clubs'**
  String get standingsClubs;

  /// No description provided for @standingsLicensees.
  ///
  /// In fr, this message translates to:
  /// **'Licenciés'**
  String get standingsLicensees;

  /// No description provided for @standingsPoints.
  ///
  /// In fr, this message translates to:
  /// **'{points} pts'**
  String standingsPoints(int points);

  /// No description provided for @standingsGap.
  ///
  /// In fr, this message translates to:
  /// **'Écart au précédent −{gap}'**
  String standingsGap(int gap);

  /// No description provided for @standingsRaces.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 course} other{{count} courses}}'**
  String standingsRaces(int count);

  /// No description provided for @standingsFooter.
  ///
  /// In fr, this message translates to:
  /// **'Provisoire · {finished} / {total} séries terminées · calculé à {time}'**
  String standingsFooter(int finished, int total, String time);

  /// No description provided for @standingsIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 épreuve n\'a pu être lue : classement incomplet} other{{count} épreuves n\'ont pu être lues : classement incomplet}}'**
  String standingsIncomplete(int count);

  /// No description provided for @standingsStale.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 épreuve n\'a pu être relue : son classement précédent est gardé} other{{count} épreuves n\'ont pu être relues : leur classement précédent est gardé}}'**
  String standingsStale(int count);

  /// No description provided for @standingsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun point marqué pour l\'instant'**
  String get standingsEmpty;

  /// No description provided for @standingsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de calculer les classements.'**
  String get standingsLoadError;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un athlète'**
  String get searchTitle;

  /// No description provided for @searchFieldHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, prénom'**
  String get searchFieldHint;

  /// No description provided for @searchTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Tapez au moins {count} lettres'**
  String searchTooShort(int count);

  /// No description provided for @searchNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun athlète trouvé'**
  String get searchNoResult;

  /// No description provided for @searchLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les participants.'**
  String get searchLoadError;

  /// No description provided for @athleteRun.
  ///
  /// In fr, this message translates to:
  /// **'Courues'**
  String get athleteRun;

  /// No description provided for @athleteToRun.
  ///
  /// In fr, this message translates to:
  /// **'À courir'**
  String get athleteToRun;

  /// No description provided for @athleteNoRace.
  ///
  /// In fr, this message translates to:
  /// **'Aucune épreuve eau plate'**
  String get athleteNoRace;

  /// No description provided for @athleteFindHeat.
  ///
  /// In fr, this message translates to:
  /// **'Trouver sa série'**
  String get athleteFindHeat;

  /// No description provided for @athleteNotPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore placé'**
  String get athleteNotPlaced;

  /// No description provided for @athleteFindError.
  ///
  /// In fr, this message translates to:
  /// **'Places illisibles : réessayez'**
  String get athleteFindError;

  /// No description provided for @athleteSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série {number}'**
  String athleteSeries(int number);

  /// No description provided for @athleteLane.
  ///
  /// In fr, this message translates to:
  /// **'ligne {lane}'**
  String athleteLane(int lane);

  /// No description provided for @athleteHeatPlace.
  ///
  /// In fr, this message translates to:
  /// **'{place} de la série'**
  String athleteHeatPlace(String place);

  /// No description provided for @athleteEventRank.
  ///
  /// In fr, this message translates to:
  /// **'{rank} de l\'épreuve'**
  String athleteEventRank(String rank);

  /// No description provided for @athleteEventRankProvisional.
  ///
  /// In fr, this message translates to:
  /// **'{rank} de l\'épreuve (provisoire)'**
  String athleteEventRankProvisional(String rank);

  /// No description provided for @athleteRaceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Résultats illisibles pour cette épreuve'**
  String get athleteRaceUnavailable;

  /// No description provided for @athleteNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cet athlète n\'est pas engagé dans cette compétition.'**
  String get athleteNotFound;

  /// No description provided for @athleteLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la fiche.'**
  String get athleteLoadError;

  /// No description provided for @followedMark.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get followedMark;

  /// No description provided for @followAthlete.
  ///
  /// In fr, this message translates to:
  /// **'Suivre cet athlète'**
  String get followAthlete;

  /// No description provided for @unfollowAthlete.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus suivre cet athlète'**
  String get unfollowAthlete;

  /// No description provided for @unfollowClub.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus suivre ce club'**
  String get unfollowClub;

  /// No description provided for @mySpaceSpaces.
  ///
  /// In fr, this message translates to:
  /// **'Mes espaces sur cette compétition'**
  String get mySpaceSpaces;

  /// No description provided for @mySpaceEveryone.
  ///
  /// In fr, this message translates to:
  /// **'Compétition (tout le monde)'**
  String get mySpaceEveryone;

  /// No description provided for @mySpacePreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get mySpacePreferences;

  /// No description provided for @mySpaceNoSpace.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte n\'a pas d\'espace sur cette compétition.'**
  String get mySpaceNoSpace;

  /// No description provided for @mySpaceRolesError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire vos espaces sur cette compétition.'**
  String get mySpaceRolesError;

  /// No description provided for @mySpaceAthlete.
  ///
  /// In fr, this message translates to:
  /// **'Athlète'**
  String get mySpaceAthlete;

  /// No description provided for @mySpaceAthleteSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning, résultats'**
  String get mySpaceAthleteSubtitle;

  /// No description provided for @mySpaceClub.
  ///
  /// In fr, this message translates to:
  /// **'Club · {label}'**
  String mySpaceClub(String label);

  /// No description provided for @mySpaceClubSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Athlètes, planning, résultats'**
  String get mySpaceClubSubtitle;

  /// No description provided for @mySpaceOfficial.
  ///
  /// In fr, this message translates to:
  /// **'Officiel'**
  String get mySpaceOfficial;

  /// No description provided for @mySpaceOfficialSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisies, séries à saisir'**
  String get mySpaceOfficialSubtitle;

  /// No description provided for @mySpaceAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get mySpaceAdmin;

  /// No description provided for @mySpaceAdminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'espace de n\'importe quel club'**
  String get mySpaceAdminSubtitle;

  /// No description provided for @mySpacePrincipalJudge.
  ///
  /// In fr, this message translates to:
  /// **'Juge principal'**
  String get mySpacePrincipalJudge;

  /// No description provided for @mySpaceStartsNow.
  ///
  /// In fr, this message translates to:
  /// **'maintenant'**
  String get mySpaceStartsNow;

  /// No description provided for @mySpaceStartsInMinutes.
  ///
  /// In fr, this message translates to:
  /// **'dans {minutes} min'**
  String mySpaceStartsInMinutes(int minutes);

  /// No description provided for @mySpaceStartsInHours.
  ///
  /// In fr, this message translates to:
  /// **'dans {hours} h'**
  String mySpaceStartsInHours(int hours);

  /// No description provided for @mySpaceRejected.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 refusée} other{{count} refusées}}'**
  String mySpaceRejected(int count);

  /// No description provided for @mySpaceFollows.
  ///
  /// In fr, this message translates to:
  /// **'Mes suivis'**
  String get mySpaceFollows;

  /// No description provided for @mySpaceNoFollow.
  ///
  /// In fr, this message translates to:
  /// **'Aucun suivi'**
  String get mySpaceNoFollow;

  /// No description provided for @mySpaceFollowsHint.
  ///
  /// In fr, this message translates to:
  /// **'On suit depuis une fiche d\'athlète ou l\'espace d\'un club (étoile). Les courses suivies ressortent dans le Live et les résultats.'**
  String get mySpaceFollowsHint;

  /// No description provided for @mySpaceNextRace.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine : {label}'**
  String mySpaceNextRace(String label);

  /// No description provided for @mySpaceNoNextRace.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course à venir'**
  String get mySpaceNoNextRace;

  /// No description provided for @mySpaceAthleteCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} athlète} other{{count} athlètes}}'**
  String mySpaceAthleteCount(int count);

  /// No description provided for @mySpaceClubCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} club} other{{count} clubs}}'**
  String mySpaceClubCount(int count);

  /// No description provided for @mySpaceEventCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} épreuve} other{{count} épreuves}}'**
  String mySpaceEventCount(int count);

  /// No description provided for @mySpaceInfos.
  ///
  /// In fr, this message translates to:
  /// **'Infos de la compétition'**
  String get mySpaceInfos;

  /// No description provided for @mySpaceInfosSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lieu, dates, engagés'**
  String get mySpaceInfosSubtitle;

  /// No description provided for @mySpaceInfosError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les infos de la compétition.'**
  String get mySpaceInfosError;

  /// No description provided for @mySpaceOrganizer.
  ///
  /// In fr, this message translates to:
  /// **'Organisateur'**
  String get mySpaceOrganizer;

  /// No description provided for @mySpaceClubs.
  ///
  /// In fr, this message translates to:
  /// **'Clubs'**
  String get mySpaceClubs;

  /// No description provided for @mySpaceOfficials.
  ///
  /// In fr, this message translates to:
  /// **'Officiels'**
  String get mySpaceOfficials;

  /// No description provided for @mySpaceOfficialsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Juge principal, niveaux, jours'**
  String get mySpaceOfficialsSubtitle;

  /// No description provided for @mySpaceOfficialsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun officiel publié pour cette compétition.'**
  String get mySpaceOfficialsEmpty;

  /// No description provided for @mySpaceOfficialsError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les officiels.'**
  String get mySpaceOfficialsError;

  /// No description provided for @mySpaceOfficialLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String mySpaceOfficialLevel(String level);

  /// No description provided for @mySpaceOfficialLevelUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Niveau non renseigné'**
  String get mySpaceOfficialLevelUnknown;

  /// No description provided for @mySpaceComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get mySpaceComingSoon;

  /// No description provided for @startTabTitle.
  ///
  /// In fr, this message translates to:
  /// **'Onglet d\'ouverture'**
  String get startTabTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
