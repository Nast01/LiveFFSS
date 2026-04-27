import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserType { licensee, organisme, unknown }

enum UserRole { admin, user, unknown }

@freezed
class User with _$User {
  const factory User({
    required String token,
    required DateTime tokenExpiration,
    required String label,
    required UserType type,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? licenseeNumber,
    String? clubName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
