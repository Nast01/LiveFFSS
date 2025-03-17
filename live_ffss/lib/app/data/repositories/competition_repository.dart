import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import '../services/api_service.dart';
import '../models/competition_model.dart';

class CompetitionRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get competitions with pagination
  Future<List<CompetitionModel>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
    int page = 1,
  }) async {
    return await _apiService.getCompetitions(
      type: type,
      visibility: visibility,
      pageSize: pageSize,
      page: page,
    );
  }

  // Get all competitions (handles pagination internally)
  Future<List<CompetitionModel>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
  }) async {
    return await _apiService.getAllCompetitions(
      type: type,
      visibility: visibility,
    );
  }

  // Get next 5 upcoming competitions
  Future<List<CompetitionModel>> getNext5Competitions() async {
    return await _apiService.getNext5Competitions();
  }
}
