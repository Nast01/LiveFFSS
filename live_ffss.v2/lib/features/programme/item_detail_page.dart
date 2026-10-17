import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/programme/item_detail_providers.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/widgets/heat_card.dart';
import 'package:live_ffss_v2/features/programme/widgets/progression_strip.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';

class ItemDetailPage extends ConsumerStatefulWidget {
  const ItemDetailPage({
    super.key,
    required this.competitionId,
    required this.itemId,
  });

  final int competitionId;
  final int itemId;

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  @override
  void initState() {
    super.initState();
    // Ouvert par un lien profond, le créneau doit aussi rendre sa compétition
    // active aux autres onglets.
    unawaited(
      ref.read(activeCompetitionProvider.notifier).ensure(widget.competitionId),
    );
  }

  ItemKey get _key =>
      (competitionId: widget.competitionId, itemId: widget.itemId);

  Future<void> _refresh() =>
      ref.read(meetingItemDetailProvider(_key).notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = meetingItemDetailProvider(_key);
    ref.listen(provider, (previous, next) {
      // Une relecture en échec garde le créneau affiché : on le dit sans le
      // vider.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final detail = ref.watch(provider);
    final value = detail.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.programmeTitle)),
      body: value == null ? _placeholder(detail, l10n) : _body(value, l10n),
    );
  }

  Widget _placeholder(
    AsyncValue<MeetingItemDetail> detail,
    AppLocalizations l10n,
  ) {
    final error = detail.error;
    if (error == null) return const Center(child: CircularProgressIndicator());
    final notFound = error is NotFoundException;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notFound ? l10n.itemNotFound : l10n.itemLoadError,
              textAlign: TextAlign.center,
            ),
            if (!notFound) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: _refresh, child: Text(l10n.retry)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body(MeetingItemDetail detail, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final progression = detail.progression;
    final stage = detail.stage;
    final item = detail.item;
    final gender = progression?.gender;
    final title = [
      if (progression != null && progression.disciplineName.isNotEmpty)
        progression.disciplineName
      else
        item.name,
      if (gender != null) genderLabel(gender, l10n),
    ].join(' · ');
    final time = timeRangeLabel(item.startTime, item.endTime);
    final pending = item.heats.every((heat) => heat.seriesId == null);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur un créneau plus court que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemBreadcrumb(detail.meeting, l10n, locale),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  [item.name, time].where((p) => p.isNotEmpty).join(' · '),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (progression != null && stage != null)
            ProgressionStrip(
              competitionId: widget.competitionId,
              progression: progression,
              stage: stage,
            ),
          if (pending)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                l10n.seriesPending,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            for (final heat in item.heats)
              HeatCard(heat: heat, lanes: detail.lanesOf(heat)),
        ],
      ),
    );
  }
}
