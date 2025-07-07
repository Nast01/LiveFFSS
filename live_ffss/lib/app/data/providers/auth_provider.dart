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
          "${ApiConstants.qualBaseUrl}${ApiConstants.apiVersion}${ApiConstants.requestToken}?login=$login&password=$password");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true) {
        // final body = jsonDecode(response.body);

        String? token = jsonData['token'];
        DateTime? expiration = DateTime.parse(jsonData['expiration']);

        // final meUrl = Uri.parse("$qualBaseUrl$apiVersion$me?token=$token");
        final meUrl = Uri.parse(
            "${ApiConstants.qualBaseUrl}${ApiConstants.apiVersion}${ApiConstants.me}?token=$token");
        //var headers = {'Content-Type': 'application/json; charset=UTF-8'};
        //headers.addIf(token != null, 'Authorization', 'Bearer $token');

        final meResponse = await http.get(
          meUrl,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        Map<String, dynamic> meJsonData = jsonDecode(meResponse.body);
        if (meJsonData['success'] == true) {
          String label = meJsonData['label'];
          String type = meJsonData['type'];
          String role;
          String lastName;
          String firstName;
          String number;
          String club;

          if (type == 'licencie') {
            role = meJsonData['data']['role'];
            lastName = meJsonData['data']['nom'];
            firstName = meJsonData['data']['prenom'];
            number = meJsonData['data']['numero'];
            club = meJsonData['data']['club']['label'];
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
            role = meJsonData['data']['role'];
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
