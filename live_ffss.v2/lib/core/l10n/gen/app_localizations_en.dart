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
  String availableInLot(int lot) {
    return 'Coming in batch $lot';
  }

  @override
  String get chooseCompetition => 'Choose a competition';

  @override
  String get chooseCompetitionHint =>
      'Open a competition from the home screen to follow its programme, live heats and results.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get mySpaceComingSoon =>
      'Sign-in and your personal space are coming soon.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

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
  String get chooseFinal => 'Choose the race';

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
}
