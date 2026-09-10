import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/user.dart';

part 'session_probe.freezed.dart';

/// Ce que le serveur répond quand on lui demande qui nous sommes.
///
/// Pas d'arm `unknown` : cette énumération n'est pas décodée d'une réponse API,
/// elle est construite par l'application à partir de ce qu'elle observe. La
/// règle de forward-compat du dépôt ne vise que les énumérations qui viennent
/// du serveur.
enum SessionProbeOutcome { signedIn, anonymous, unreachable }

@freezed
class SessionProbe with _$SessionProbe {
  const factory SessionProbe({
    required SessionProbeOutcome outcome,
    String? label,
    UserType? type,
    String? message,
  }) = _SessionProbe;
}
