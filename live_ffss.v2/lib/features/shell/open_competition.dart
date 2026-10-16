import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

/// Rend [competition] active et ouvre l'onglet [route] (Programme par défaut).
/// La navigation part tout de suite : l'enregistrement de l'id ne la retarde
/// pas.
Future<void> openCompetition(
  BuildContext context,
  WidgetRef ref,
  CompetitionSummary competition, {
  String route = Routes.programme,
}) {
  final saved = ref
      .read(activeCompetitionProvider.notifier)
      .select(competition);
  context.go(route);
  return saved;
}
