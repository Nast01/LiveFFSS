import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/const/api_const.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import '../models/competition_model.dart';

class ApiService extends GetxService {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  // Pagination control
  final int defaultPageSize = 10;
  RxInt currentPage = 1.obs;
  RxBool hasMoreData = true.obs;
  RxBool isLoading = false.obs;

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Get competitions with filters and pagination
  Future<List<CompetitionModel>> getCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
    int pageSize = 10,
    int page = 1,
  }) async {
    try {
      isLoading.value = true;

      // Get token
      final token = await getToken();
      // if (token == null) {
      //   throw Exception('token_not_found'.tr);
      // }

      // Build URL with query parameters
      // final url =
      //     Uri.parse('$qualBaseUrl$competitionList').replace(queryParameters: {
      //   'type': type.index,
      //   'visibility': visibility.toString(),
      //   'length': pageSize.toString(),
      //   'page': page.toString(),
      // });

      final url = Uri.parse(
          "$qualBaseUrl$apiVersion$competitionList?saison='2024-2025'&type=${type.index}&visibility=${visibility.name}&length=$pageSize&start=${pageSize * (page - 1)}");
      var headers = {'Content-Type': 'application/json; charset=UTF-8'};
      headers.addIf(token != null, 'Authorization', 'Bearer $token');

      // Make API request
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Check if response has data
        if (data['data'] != null && data['data'] is List) {
          // Update pagination state
          if ((data['data'] as List).length < pageSize) {
            hasMoreData.value = false;
          }

          // Parse competitions
          return (data['data'] as List)
              .map((item) => CompetitionModel.fromJson(item))
              .toList();
        }
        return [];
      } else {
        String error = 'failed_to_load_competition'.tr;
        throw Exception('$error: ${response.statusCode}');
      }
    } catch (e) {
      String error = 'error_fetching_competition'.tr;
      debugPrint('$error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Get all competitions (handles pagination automatically)
  Future<List<CompetitionModel>> getAllCompetitions({
    CompetitionType type = CompetitionType.mixte,
    CompetitionVisibility visibility = CompetitionVisibility.incoming,
  }) async {
    List<CompetitionModel> allCompetitions = [];
    hasMoreData.value = true;
    currentPage.value = 1;

    while (hasMoreData.value) {
      final competitions = await getCompetitions(
        type: type,
        visibility: visibility,
        page: currentPage.value,
        pageSize: defaultPageSize,
      );

      if (competitions.isEmpty) {
        hasMoreData.value = false;
        break;
      }

      allCompetitions.addAll(competitions);
      currentPage.value++;
    }

    return allCompetitions;
  }

  // Get next 5 upcoming competitions
  Future<List<CompetitionModel>> getNext5Competitions() async {
    try {
      // Get competitions
      final competitions = await getCompetitions(
        visibility: CompetitionVisibility.incoming,
        type: CompetitionType.mixte,
        pageSize: 5,
        page: 1,
      );

      return competitions.take(5).toList();
    } catch (e) {
      debugPrint('Error fetching next 5 competitions: $e');
      rethrow;
    }
  }
}
