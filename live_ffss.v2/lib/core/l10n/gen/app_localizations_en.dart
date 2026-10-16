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
}
