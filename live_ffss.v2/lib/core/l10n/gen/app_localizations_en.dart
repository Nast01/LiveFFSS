// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FFSS-LIVE';

  @override
  String get appTagline => 'Lifesaving sport, live';

  @override
  String get signIn => 'Sign in';

  @override
  String get searchHint => 'Competition, city, club…';

  @override
  String get filterAll => 'All';

  @override
  String get filterFlatWater => 'Flat water';

  @override
  String get filterCoastal => 'Coastal';

  @override
  String get filterFavorites => 'My favourites';

  @override
  String get disciplineFlatWater => 'Flat water';

  @override
  String get disciplineCoastal => 'Coastal';

  @override
  String get disciplineMixed => 'Mixed';

  @override
  String get liveBadge => 'LIVE';

  @override
  String dayOfTotal(int current, int total) {
    return 'Day $current/$total';
  }

  @override
  String get nowRunning => 'NOW';

  @override
  String get nextUp => 'UP NEXT';

  @override
  String heatOfTotal(int position, int total) {
    return 'Heat $position/$total';
  }

  @override
  String get genderFemale => 'Women';

  @override
  String get genderMale => 'Men';

  @override
  String get genderMixed => 'Mixed';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get seeAll => 'See all';

  @override
  String get recentlyFinished => 'Recently finished';

  @override
  String get allCompetitions => 'Competitions';

  @override
  String get noCompetition => 'No competition';

  @override
  String get loadError => 'Could not load competitions.';

  @override
  String get retry => 'Retry';

  @override
  String get refreshFailed => 'Update failed: the data shown is kept.';

  @override
  String get addFavorite => 'Add to favourites';

  @override
  String get removeFavorite => 'Remove from favourites';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProgramme => 'Programme';

  @override
  String get tabLive => 'Live';

  @override
  String get tabResults => 'Results';

  @override
  String get tabMySpace => 'My space';

  @override
  String get chooseCompetition => 'Choose a competition';

  @override
  String get chooseCompetitionHint =>
      'Open a competition from the home screen to follow its programme, live heats and results.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginField => 'Username';

  @override
  String get passwordField => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginErrorRejected => 'Username or password refused.';

  @override
  String get loginErrorUnreachable =>
      'Server unreachable: check your connection and try again.';

  @override
  String get loginErrorOther => 'Sign-in failed. Try again later.';

  @override
  String get sessionExpired => 'Session expired, please sign in again';

  @override
  String accountType(String type) {
    return 'Account type: $type';
  }

  @override
  String get logOut => 'Sign out';

  @override
  String get logOutConfirmTitle => 'Sign out?';

  @override
  String logOutConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries are waiting to be sent',
      one: '1 entry is waiting to be sent',
    );
    return '$_temp0. They stay queued and are sent when you next sign in with this account.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get liveTitle => 'Live';

  @override
  String get liveRunning => 'Running';

  @override
  String get liveRecent => 'Latest heats';

  @override
  String get liveProvisional => 'Provisional';

  @override
  String get liveValidated => 'Validated';

  @override
  String get liveMarshalling => 'Marshalling';

  @override
  String get livePendingValidation =>
      'Results awaiting validation by the judges';

  @override
  String get liveWaitingResults =>
      'Results pending: they will show as soon as they are published';

  @override
  String get liveNothingYet => 'No heat has been run yet';

  @override
  String liveNext(String label) {
    return 'Next heat: $label';
  }

  @override
  String get liveSeeProgramme => 'See the full programme';

  @override
  String get liveLoadError => 'Could not load the live feed.';

  @override
  String get liveRefresh => 'Refresh';

  @override
  String get coastalComingSoon => 'Coastal: coming soon';

  @override
  String heatPlace(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      '1': '1st',
      '2': '2nd',
      '3': '3rd',
      'other': '${place}th',
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
      other: '$count slots',
      one: '1 slot',
    );
    return '$_temp0';
  }

  @override
  String meetingEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get programmeTitle => 'Programme';

  @override
  String get programmeEmpty => 'Programme not published yet';

  @override
  String get programmeLoadError => 'Couldn\'t load the programme.';

  @override
  String get itemLoadError => 'Couldn\'t load this slot.';

  @override
  String get itemNotFound => 'This slot is no longer in the programme.';

  @override
  String get noLanes => 'Lane draw not published yet';

  @override
  String get recordBadge => 'Record';

  @override
  String get nationalRecordBadge => 'French record';

  @override
  String get progressionToggle => 'Format';

  @override
  String get statusFinished => 'Finished';

  @override
  String get forfeit => 'Withdrawn';

  @override
  String get seriesPending => 'Heats to come';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get qualificationByStage => 'Ranked on time, all heats combined';

  @override
  String qualificationByHeat(int n) {
    return 'Top $n of each heat';
  }

  @override
  String get qualificationByHeatUnknown => 'Qualification by heat';

  @override
  String get stageLevelHeats => 'Heats';

  @override
  String get stageLevelQuarterFinal => 'Quarter-finals';

  @override
  String get stageLevelSemiFinal => 'Semi-finals';

  @override
  String get stageLevelFinal => 'Final';

  @override
  String progressionCollapsed(String first, String following) {
    return '$first › $following';
  }

  @override
  String followingFinals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finals',
      one: '1 final',
    );
    return '$_temp0';
  }

  @override
  String followingStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stages',
      one: '1 stage',
    );
    return '$_temp0';
  }

  @override
  String get enterResults => 'Enter results';

  @override
  String get officialBadge => 'OFFICIAL';

  @override
  String get entryTitle => 'Results entry';

  @override
  String get entryNotice =>
      'Entries are not final — validated by the results judge (FFSSCompetition)';

  @override
  String get entryLaneAll => 'All';

  @override
  String entryLane(int lane) {
    return 'Lane $lane';
  }

  @override
  String entryChrono(int number) {
    return 'Timer $number';
  }

  @override
  String entryManualTime(String time) {
    return 'Manual time: $time';
  }

  @override
  String get entryRuleSingle => '1 timer';

  @override
  String get entryRuleAverage => 'average of 2';

  @override
  String get entryRuleMedian => 'median of 3';

  @override
  String get entryNotFinal => 'not final';

  @override
  String get manualTimeNote => 'manual, not final';

  @override
  String get entryNoChrono => 'No time entered';

  @override
  String get entryInvalidChrono => 'Seconds must be 59 or less';

  @override
  String get entryDisqualify => 'DQ…';

  @override
  String get entryDisqualifyCodeRequired => 'Enter the DQ code';

  @override
  String get entryDisqualifyCode => 'DQ code';

  @override
  String get entryCancelDisqualification => 'Cancel DQ';

  @override
  String entryForfeitConfirm(String name) {
    return 'Declare withdrawn: $name?';
  }

  @override
  String get entryCancelForfeit => 'Cancel withdrawal';

  @override
  String get entryChronos => 'Times';

  @override
  String get entryClear => 'Clear';

  @override
  String get entryErase => 'Delete last digit';

  @override
  String get entrySave => 'Save';

  @override
  String get entrySaveAndNext => 'Save and go to the next heat';

  @override
  String get entryAllLanes => 'All lanes';

  @override
  String get entryPreviousHeat => 'Previous heat';

  @override
  String get entryNextHeat => 'Next heat';

  @override
  String entryDisqualified(String code) {
    return 'DQ $code';
  }

  @override
  String get entrySent => 'Sent';

  @override
  String get entryPending => 'Waiting to be sent';

  @override
  String entryRejected(String reason) {
    return 'Rejected: $reason';
  }

  @override
  String get entryRejectedValidated => 'validated by the results judge';

  @override
  String get entryRejectedUnreadable => 'result unreadable on the website';

  @override
  String get entryRejectedEmptyPlace => 'nobody in this lane any more';

  @override
  String get entryRejectedPlaceChanged =>
      'heat rearranged: this lane has a different swimmer';

  @override
  String get entryRejectedServer => 'rejected by the website';

  @override
  String get entryDismiss => 'Dismiss';

  @override
  String get entryValidatedByJudge => 'Validated by the results judge';

  @override
  String get entryUnsaved => 'Not saved';

  @override
  String entryEmptyLane(int lane) {
    return 'Nobody in lane $lane in this heat';
  }

  @override
  String get entryNoHeat => 'No heat to enter in this slot';

  @override
  String get entryLastHeat => 'Last heat: there is none after it';

  @override
  String get entryNotPersisted =>
      'Entry queued but not saved on the phone: keep the app open until it is sent';

  @override
  String get entryNotConnected => 'Sign in to enter results';

  @override
  String get entryDenied =>
      'Entry is reserved for the competition\'s officials';

  @override
  String get entryLoadError => 'Couldn\'t load this heat.';

  @override
  String get entrySessionLost => 'Session expired — sign in again';

  @override
  String get entryResuming => 'Checking your entry rights…';

  @override
  String get entryUnverified =>
      'Entry rights not checked: the site didn\'t respond. Check your connection and try again.';

  @override
  String get resultsSearch => 'Search for an athlete';

  @override
  String get resultsRefresh => 'Refresh';

  @override
  String get resultsEvents => 'Events';

  @override
  String get resultsStandings => 'Standings';

  @override
  String get resultsNoEvent => 'No flat water event published';

  @override
  String get resultsLoadError => 'Couldn\'t load the results.';

  @override
  String get resultsRankingProvisional => 'PROVISIONAL RANKING';

  @override
  String get resultsRankingFinal => 'RANKING';

  @override
  String resultsSeriesProgress(int finished, int total) {
    return '$finished/$total heats';
  }

  @override
  String get standingsClubs => 'Clubs';

  @override
  String get standingsLicensees => 'Athletes';

  @override
  String standingsPoints(int points) {
    return '$points pts';
  }

  @override
  String standingsGap(int gap) {
    return 'Gap to previous −$gap';
  }

  @override
  String standingsRaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races',
      one: '1 race',
    );
    return '$_temp0';
  }

  @override
  String standingsFooter(int finished, int total, String time) {
    return 'Provisional · $finished / $total heats finished · computed at $time';
  }

  @override
  String standingsIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events couldn\'t be read: standings incomplete',
      one: '1 event couldn\'t be read: standings incomplete',
    );
    return '$_temp0';
  }

  @override
  String standingsStale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count events couldn\'t be re-read: their previous standings are kept',
      one: '1 event couldn\'t be re-read: its previous standings are kept',
    );
    return '$_temp0';
  }

  @override
  String get standingsEmpty => 'No points scored yet';

  @override
  String get standingsLoadError => 'Couldn\'t compute the standings.';

  @override
  String get searchTitle => 'Search for an athlete';

  @override
  String get searchFieldHint => 'Last name, first name';

  @override
  String searchTooShort(int count) {
    return 'Type at least $count letters';
  }

  @override
  String get searchNoResult => 'No athlete found';

  @override
  String get searchLoadError => 'Couldn\'t load the participants.';

  @override
  String get athleteRun => 'Raced';

  @override
  String get athleteToRun => 'To race';

  @override
  String get athleteNoRace => 'No flat water event';

  @override
  String get athleteFindHeat => 'Find their heat';

  @override
  String get athleteNotPlaced => 'Not placed yet';

  @override
  String get athleteFindError => 'Lanes unreadable: try again';

  @override
  String athleteSeries(int number) {
    return 'Heat $number';
  }

  @override
  String athleteLane(int lane) {
    return 'lane $lane';
  }

  @override
  String athleteHeatPlace(String place) {
    return '$place in heat';
  }

  @override
  String athleteEventRank(String rank) {
    return '$rank in the event';
  }

  @override
  String athleteEventRankProvisional(String rank) {
    return '$rank in the event (provisional)';
  }

  @override
  String get athleteRaceUnavailable => 'Results unreadable for this event';

  @override
  String get athleteNotFound =>
      'This athlete isn\'t entered in this competition.';

  @override
  String get athleteLoadError => 'Couldn\'t load the athlete card.';

  @override
  String get followedMark => 'Following';

  @override
  String get followAthlete => 'Follow this athlete';

  @override
  String get unfollowAthlete => 'Stop following this athlete';

  @override
  String get unfollowClub => 'Stop following this club';

  @override
  String get mySpaceSpaces => 'My spaces in this competition';

  @override
  String get mySpaceEveryone => 'Competition (everyone)';

  @override
  String get mySpacePreferences => 'Preferences';

  @override
  String get mySpaceNoSpace => 'This account has no space in this competition.';

  @override
  String get mySpaceRolesError =>
      'Couldn\'t read your spaces in this competition.';

  @override
  String get mySpaceAthlete => 'Athlete';

  @override
  String get mySpaceAthleteSubtitle => 'Schedule, results';

  @override
  String mySpaceClub(String label) {
    return 'Club · $label';
  }

  @override
  String get mySpaceClubSubtitle => 'Athletes, schedule, results';

  @override
  String get mySpaceOfficial => 'Official';

  @override
  String get mySpaceOfficialSubtitle => 'Entries, heats to enter';

  @override
  String get mySpaceAdmin => 'Admin';

  @override
  String get mySpaceAdminSubtitle => 'Any club\'s space';

  @override
  String get mySpacePrincipalJudge => 'Chief judge';

  @override
  String get mySpaceStartsNow => 'now';

  @override
  String mySpaceStartsInMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String mySpaceStartsInHours(int hours) {
    return 'in $hours h';
  }

  @override
  String mySpaceRejected(int count) {
    return '$count rejected';
  }

  @override
  String get mySpaceFollows => 'Following';

  @override
  String get mySpaceNoFollow => 'Nothing followed';

  @override
  String get mySpaceFollowsHint =>
      'Follow from an athlete card or a club\'s space (star). Followed races stand out in Live and results.';

  @override
  String mySpaceNextRace(String label) {
    return 'Next: $label';
  }

  @override
  String get mySpaceNoNextRace => 'No race to come';

  @override
  String mySpaceAthleteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count athletes',
      one: '$count athlete',
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
  String mySpaceEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '$count event',
    );
    return '$_temp0';
  }

  @override
  String get mySpaceInfos => 'Competition info';

  @override
  String get mySpaceInfosSubtitle => 'Venue, dates, entries';

  @override
  String get mySpaceInfosError => 'Couldn\'t load the competition info.';

  @override
  String get mySpaceOrganizer => 'Organiser';

  @override
  String get mySpaceClubs => 'Clubs';

  @override
  String get mySpaceOfficials => 'Officials';

  @override
  String get mySpaceOfficialsSubtitle => 'Chief judge, levels, days';

  @override
  String get mySpaceOfficialsEmpty =>
      'No official published for this competition.';

  @override
  String get mySpaceOfficialsError => 'Couldn\'t load the officials.';

  @override
  String mySpaceOfficialLevel(String level) {
    return 'Level $level';
  }

  @override
  String get mySpaceOfficialLevelUnknown => 'Level not given';

  @override
  String get mySpaceComingSoon => 'Coming soon';

  @override
  String get startTabTitle => 'Start tab';

  @override
  String get mySpaceAthleteUnknown => 'Couldn\'t check your entry';

  @override
  String get mySpaceFollowsError => 'Couldn\'t read your follows';
}
