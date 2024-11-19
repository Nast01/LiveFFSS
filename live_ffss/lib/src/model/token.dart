import 'package:intl/intl.dart';

class Token{
  late String token;
  late DateTime expiration;
  late bool status;

  Token({
      required this.token,
      required this.expiration,
      required this.status
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
      token: json["token"],
      expiration: DateFormat("yyyy-MM-dd").parse(json["expiration"]),
      status : json["success"],
      );

  Map<String, dynamic> toJson() => {
      "token": token,
      "expiration": expiration,
      "status":status,
      };
}