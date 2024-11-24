import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:live_ffss/src/model/competition.dart';
import 'package:live_ffss/src/model/token.dart';

class CompetitionService {
  static const String baseUrl = "https://ffss.fr/api/v1.0";
  static const String endpoint = "/competition/evenement";
  var startDateFormat = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<List<Competition>> fetchCompetitions(Token? token) async {
    final url =
        Uri.parse("$baseUrl$endpoint?length=1000&debut=$startDateFormat");
    final headers = {
      'Authorization': 'Bearer ${token?.token}',
      'Content-Type': 'application/json; charset=UTF-8'
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Extract the list from the correct key
        List<dynamic> competitionsList = jsonData['data'];

        return competitionsList
            .map((json) => Competition.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load competition: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching competitions: $e');
    }
  }
}
