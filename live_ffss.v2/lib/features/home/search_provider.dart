import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

const Duration searchDebounce = Duration(milliseconds: 300);

/// En dessous, une recherche rend presque toute la base : on n'appelle pas.
const int searchMinLength = 2;

/// Chaque frappe crée un nouveau fournisseur (paramétré par le texte) et
/// libère le précédent : seul celui qui survit [searchDebounce] appelle l'API.
/// Un fournisseur libéré entre-temps rend une liste vide que personne ne lit,
/// plutôt qu'une erreur que personne n'attrape.
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<CompetitionSummary>, String>((ref, query) async {
      final text = query.trim();
      if (text.length < searchMinLength) return const [];
      var disposed = false;
      ref.onDispose(() => disposed = true);
      await Future<void>.delayed(searchDebounce);
      if (disposed) return const [];
      return ref.read(competitionRepositoryProvider).search(text);
    });
