import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

class CompetitionDetailPointsController extends GetxController {
  CompetitionDetailPointsController(this._rankingRepo);

  final RankingRepository _rankingRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxInt selectedPointsTab = 0.obs;
  final RxList<ClubRanking> clubRankings = <ClubRanking>[].obs;
  final RxList<IndividualRanking> individualRankings =
      <IndividualRanking>[].obs;
  final RxList<RelayRanking> relayRankings = <RelayRanking>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  void setPointsTab(int index) => selectedPointsTab.value = index;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadRankings(arg.id);
    }
  }

  Future<void> loadRankings(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final clubFuture = _rankingRepo.getClubRankings(competitionId);
      final individualFuture = _rankingRepo.getIndividualRankings(competitionId);
      final relayFuture = _rankingRepo.getRelayRankings(competitionId);
      clubRankings.value = await clubFuture;
      individualRankings.value = await individualFuture;
      relayRankings.value = await relayFuture;
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    final id = competition.value?.id;
    if (id != null) await loadRankings(id);
  }
}
