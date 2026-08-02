import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailClubsController extends GetxController {
  CompetitionDetailClubsController(this._clubRepo);

  final ClubRepository _clubRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Club> allClubs = <Club>[].obs;
  final RxList<Club> filteredClubs = <Club>[].obs;

  /// Club details resolved for their logo/bonnet, keyed by club id. Kept for
  /// the session so a pull-to-refresh doesn't refetch them.
  final Map<int, Club> _imageCache = {};

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyClubFilter();
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadClubs(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadClubs(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _clubRepo.getClubs(competitionId);
      loaded.sort((a, b) => a.name.compareTo(b.name));

      allClubs.value = loaded;
      _applyClubFilter();
      // Progressive enhancement: the list is already on screen, images fill in
      // when they arrive. Deliberately not awaited.
      unawaited(_backfillClubImages());
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  static bool _hasImage(Club club) =>
      (club.logoUrl?.isNotEmpty ?? false) || (club.capUrl?.isNotEmpty ?? false);

  /// The competition's `organismes` endpoint returns no logo/bonnet at all —
  /// only `organisme/:id` carries them — so every club would otherwise fall
  /// back to its initial. Fetches the missing ones and patches them in.
  ///
  /// The detail record has no athletes/officiels, so only the image fields are
  /// merged; replacing the club outright would empty its member lists.
  Future<void> _backfillClubImages() async {
    final missing = allClubs
        .where((c) =>
            !c.isGuest && !_hasImage(c) && !_imageCache.containsKey(c.id))
        .map((c) => c.id)
        .toList();
    if (missing.isEmpty) return;

    try {
      _imageCache.addAll(await _clubRepo.getClubDetails(missing));
    } on AppException {
      return; // Best-effort: the initials stay.
    }
    if (_imageCache.isEmpty) return;

    allClubs.value = allClubs.map((club) {
      final detail = _imageCache[club.id];
      if (detail == null || _hasImage(club)) return club;
      return club.copyWith(
        shortName: club.shortName ?? detail.shortName,
        logoUrl: detail.logoUrl,
        capUrl: detail.capUrl,
      );
    }).toList();
    _applyClubFilter();
  }

  void _applyClubFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredClubs.value = List.from(allClubs);
      return;
    }
    final result = <Club>[];
    for (final club in allClubs) {
      final clubMatches = club.name.toLowerCase().contains(q);
      final matchingAthletes = club.athletes
          .where(
              (a) => '${a.firstName} ${a.lastName}'.toLowerCase().contains(q))
          .toList();
      final matchingReferees = club.referees
          .where(
              (r) => '${r.firstName} ${r.lastName}'.toLowerCase().contains(q))
          .toList();

      if (clubMatches) {
        // Club name matched: keep all members visible.
        result.add(club);
      } else if (matchingAthletes.isNotEmpty || matchingReferees.isNotEmpty) {
        // Only some members matched: narrow the lists to those.
        result.add(club.copyWith(
          athletes: matchingAthletes,
          referees: matchingReferees,
        ));
      }
      // No match anywhere → drop the club.
    }
    filteredClubs.value = result;
  }
}
