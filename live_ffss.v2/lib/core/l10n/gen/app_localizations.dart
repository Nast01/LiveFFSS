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

  /// No description provided for @availableInLot.
  ///
  /// In fr, this message translates to:
  /// **'Disponible au lot {lot}'**
  String availableInLot(int lot);

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
