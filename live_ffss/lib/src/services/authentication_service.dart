import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:live_ffss/src/model/token.dart';

class AuthenticationService {
    static const String baseUrl = "https://ffss.fr/api/v1.0";
    static const String endpoint = "/requestToken";

    Future<Token?> authenticate(String login, String password) async {
      final url = Uri.parse("$baseUrl$endpoint?login=$login&password=$password");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

        return Token.fromJson(responseJson); // Return the response data (likely containing a token)
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
  }
}