import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/const/api_const.dart';
import 'package:live_ffss/app/data/models/user_model.dart';

class AuthProvider {
  Future<UserModel?> login(String login, String password) async {
    String errorText = '';
    try {
      final url = Uri.parse(
          "$qualBaseUrl$apiVersion$requestToken?login=$login&password=$password");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);

        String? token = body['token'];
        DateTime? expiration = DateTime.parse(body['expiration']);

        // final meUrl = Uri.parse("$qualBaseUrl$apiVersion$me?token=$token");
        final meUrl = Uri.parse("$qualBaseUrl$apiVersion$me");
        var headers = {'Content-Type': 'application/json; charset=UTF-8'};
        headers.addIf(token != null, 'Authorization', 'Bearer $token');

        final meResponse = await http.get(
          meUrl,
          headers: headers,
        );

        if (meResponse.statusCode == 201) {
          final meBody = jsonDecode(meResponse.body);
          String label = meBody['label'];
          String type = meBody['type'];
          String role;
          String lastName;
          String firstName;
          String number;
          String club;

          if (type == 'licencie') {
            role = meBody['data']['role'];
            lastName = meBody['data']['nom'];
            firstName = meBody['data']['prenom'];
            number = meBody['data']['numero'];
            club = meBody['data']['club']['label'];
            return UserModel(
              token: token,
              tokenExpirationDate: expiration,
              label: label,
              type: type,
              role: role,
              lastName: lastName,
              firstName: firstName,
              number: number,
              club: club,
            );
          } else if (type == 'organisme') {
            role = meBody['data']['role'];
            if (role == 'admin') {
              return UserModel(
                token: token,
                tokenExpirationDate: expiration,
                label: label,
                type: type,
                role: role,
              );
            } else if (role == 'user') {
              return UserModel(
                token: token,
                tokenExpirationDate: expiration,
                label: label,
                type: type,
                role: role,
              );
            }
          }
        } else {
          errorText = 'login_error'.tr;
          throw Exception('$errorText: ${response.body}');
        }
      } else {
        errorText = 'login_error'.tr;
        throw Exception('$errorText: ${response.body}');
      }
    } catch (e) {
      errorText = 'network_error'.tr;
      throw Exception('$errorText: $e');
    }
    return null;
  }
}
