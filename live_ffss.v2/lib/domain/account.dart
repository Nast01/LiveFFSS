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

    /// Le rôle global du compte (`data.role` de `/me` : `user`, `admin`…),
    /// indépendant de toute compétition.
    String? role,
  }) = _Account;

  const Account._();

  /// Montre les outils de l'espace admin ; les actions restent soumises aux
  /// rôles de la compétition, que le site vérifie de toute façon.
  bool get isAdmin => role == 'admin';
}

/// Même personne : même nom affiché, à la casse et aux espaces près. Le site
/// ne donne pas d'identifiant de compte stable (comme dans V3).
bool isSameAccount(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();
