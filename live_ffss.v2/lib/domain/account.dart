import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

/// Le compte FFSS connecté, tel que `GET /me` le décrit, comme `FfssAccount`
/// dans FFSSCompetition V3.
@freezed
abstract class Account with _$Account {
  const factory Account({
    /// « NOM Prénom » : le site ne donne pas d'identifiant de compte stable,
    /// c'est donc lui qui dit si un jeton repris est celui du même compte.
    required String label,

    /// Le type de compte (`licencie`, `organisme`…).
    String? type,
  }) = _Account;
}
