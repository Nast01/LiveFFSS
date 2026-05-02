import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailClubsController extends GetxController {
  CompetitionDetailClubsController(this._clubRepo);

  final ClubRepository _clubRepo;

  Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Club> allClubs = <Club>[].obs;
  final RxList<Club> filteredClubs = <Club>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

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
    } catch (e, st) {
      // TEMP DIAGNOSTIC: keep until the Clubs-tab error is root-caused, then
      // restore the bare `catch (_)` (or, better, `on AppException`).
      // ignore: avoid_print
      print('[ClubsController.loadClubs] competitionId=$competitionId '
          'error type=${e.runtimeType} message=$e');
      // ignore: avoid_print
      print(st);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _applyClubFilter() {
    filteredClubs.value = List.from(allClubs);
  }
}
