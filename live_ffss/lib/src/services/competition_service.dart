import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:live_ffss/src/model/competition.dart';
import 'package:live_ffss/src/model/token.dart';

class CompetitionService{
    static const String baseUrl = "https://ffss.fr/api/v1.0";
    static const String endpoint = "/competition/evenement";

    Future<List<Competition>?> getCompetionList(Token? token) async {
      final url = Uri.parse("$baseUrl$endpoint?length=1100");
      
      final headers = {
          'Authorization': 'Bearer ${token?.token}',
          'Content-Type': 'application/json; charset=UTF-8'
      };

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load competition: ${response.statusCode}');
      }
    }
}