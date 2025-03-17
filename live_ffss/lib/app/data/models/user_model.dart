class UserModel {
  final String? token;
  final DateTime? tokenExpirationDate;
  final String label;
  final String type;
  final String role;
  final String? lastName;
  final String? firstName;
  final String? number;
  final String? club;

  UserModel({
    required this.token,
    required this.tokenExpirationDate,
    required this.label,
    required this.type,
    required this.role,
    this.lastName,
    this.firstName,
    this.number,
    this.club,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      tokenExpirationDate: DateTime.parse(json['expiration']),
      label: json['label'],
      type: json['type'],
      role: json['data']['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tokenExpirationDate': tokenExpirationDate?.toIso8601String(),
      'label': label,
      'type': type,
      'role': role,
    };
  }
}
