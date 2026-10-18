import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_providers.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/officiel/widgets/entry_lane_tile.dart';
import 'package:live_ffss_v2/features/officiel/widgets/lane_editor.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/programme/widgets/status_badge.dart';

/// La saisie d'un officiel (maquette B), ouverte sur une série d'un créneau.
class EntryPage extends ConsumerWidget {
  const EntryPage({
    super.key,
    required this.competitionId,
    required this.itemId,
    this.heatId,
  });

  final int competitionId;
  final int itemId;
  final int? heatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final access = ref.watch(entryAccessProvider(competitionId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.entryTitle),
        actions: [
          if (access == EntryAccess.allowed)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.officialBadge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: switch (access) {
        EntryAccess.checking => const Center(
          child: CircularProgressIndicator(),
        ),
        EntryAccess.denied => const _Denied(),
        EntryAccess.allowed => _EntryBody(
          entryKey: (
            competitionId: competitionId,
            itemId: itemId,
            heatId: heatId,
          ),
        ),
      },
    );
  }
}

class _Denied extends ConsumerWidget {
  const _Denied();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connected = ref.watch(sessionProvider).value != null;
    final expired = ref.watch(sessionExpiredProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expired
                  ? l10n.sessionExpired
                  : connected
                  ? l10n.entryDenied
                  : l10n.entryNotConnected,
              textAlign: TextAlign.center,
            ),
            if (!connected) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(Routes.mySpace),
                child: Text(l10n.signIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryBody extends ConsumerWidget {
  const _EntryBody({required this.entryKey});

  final EntryKey entryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cursor = ref.watch(entryNavigatorProvider(entryKey));
    final value = cursor.value;
    if (value == null) {
      if (cursor.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cursor.hasError ? l10n.entryLoadError : l10n.entryNoHeat,
                textAlign: TextAlign.center,
              ),
              if (cursor.hasError) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(programmeProvider(entryKey.competitionId)),
                  child: Text(l10n.retry),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return _HeatEntry(entryKey: entryKey, cursor: value);
  }
}

class _HeatEntry extends ConsumerWidget {
  const _HeatEntry({required this.entryKey, required this.cursor});

  final EntryKey entryKey;
  final EntryCursor cursor;

  EntryHeatKey get _heatKey =>
      (competitionId: entryKey.competitionId, heatId: cursor.entry.heat.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final competitionId = entryKey.competitionId;
    final editor = ref.read(entryEditorProvider(entryKey).notifier);
    final editorState = ref.watch(entryEditorProvider(entryKey));
    final filter = ref.watch(entryLaneFilterProvider(competitionId)).value;
    final lanes = ref.watch(entryLanesProvider(_heatKey));
    final notPersisted = ref.watch(outboxPersistenceFailedProvider);
    ref.listen(entryHeatProvider(_heatKey), (previous, next) {
      // Une relecture en échec garde la série affichée : on le dit sans la
      // vider.
      if (next.hasError && next.hasValue && !next.isLoading) {
        _snack(context, l10n.refreshFailed);
      }
    });

    final laneList = lanes.value;
    final focus = laneList == null
        ? null
        : entryFocus(
            laneList,
            filter: filter,
            openPlaceId: editorState.openPlaceId,
          );
    final focused = focus?.lane;
    final opened = filter == null && focused != null;

    final children = <Widget>[
      _Header(
        cursor: cursor,
        onPrevious: editor.previousHeat,
        onNext: editor.nextHeat,
      ),
      _Banner(
        text: l10n.entryNotice,
        color: AppColors.yellow.withValues(alpha: 0.25),
      ),
      if (notPersisted)
        _Banner(
          text: l10n.entryNotPersisted,
          color: AppColors.red.withValues(alpha: 0.12),
        ),
      if (laneList != null)
        _LaneFilter(
          options: laneFilterOptions(laneList, filter),
          selected: filter,
          onSelected: (lane) => _selectFilter(ref, lane),
        ),
      const SizedBox(height: 8),
      if (laneList == null)
        lanes.hasError
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(l10n.entryLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _refresh(ref),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
      else if (laneList.isEmpty)
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noLanes,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        )
      else
        ...switch (focus!.mode) {
          EntryMode.list => [
            for (final lane in laneList)
              EntryLaneTile(
                lane: lane,
                unsaved: hasUnsavedDraft(
                  lane,
                  editorState.drafts[lane.lane.id],
                ),
                onChronos: () => editor.openLane(lane.lane.id),
                onAction: (action) => _act(context, ref, lane, action),
                onRetry: (id) => _retry(context, ref, id),
                onDismiss: (id) => _dismiss(context, ref, id),
              ),
          ],
          EntryMode.emptyLane => [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.entryEmptyLane(filter ?? 0),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
          EntryMode.lane => [
            LaneEditor(
              lane: focused!,
              digits: laneDigits(focused, editorState.drafts[focused.lane.id]),
              field: editorState.field,
              unsaved: hasUnsavedDraft(
                focused,
                editorState.drafts[focused.lane.id],
              ),
              onSelectField: editor.selectField,
              onDigit: (d) => editor.typeDigit(focused, d),
              onErase: () => editor.eraseDigit(focused),
              onClear: () => editor.clearField(focused),
              onAction: (action) => _act(context, ref, focused, action),
              onRetry: (id) => _retry(context, ref, id),
              onDismiss: (id) => _dismiss(context, ref, id),
            ),
          ],
        },
      if (focus != null && focus.mode != EntryMode.list)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: opened
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: editor.closeLane,
                        child: Text(l10n.entryAllLanes),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: focused.editable
                            ? () => _saveAndClose(context, ref, focused)
                            : null,
                        child: Text(l10n.entrySave),
                      ),
                    ),
                  ],
                )
              : FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => _saveAndNext(context, ref, focused),
                  child: Text(l10n.entrySaveAndNext),
                ),
        ),
    ];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: children,
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(entryHeatProvider(_heatKey).notifier).refresh();
    } on AppException {
      // Signalé par le `ref.listen`, qui garde la série affichée.
    }
  }

  void _selectFilter(WidgetRef ref, int? lane) {
    final notifier = ref.read(
      entryLaneFilterProvider(entryKey.competitionId).notifier,
    );
    unawaited(notifier.select(lane));
  }

  Future<void> _saveAndNext(
    BuildContext context,
    WidgetRef ref,
    EntryLane? lane,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(entryEditorProvider(entryKey).notifier)
        .saveAndNext(lane);
    if (!context.mounted) return;
    final message = _outcomeMessage(result.outcome, l10n);
    if (message != null) {
      _snack(context, message);
    } else if (!result.moved) {
      _snack(context, l10n.entryLastHeat);
    }
  }

  Future<void> _saveAndClose(
    BuildContext context,
    WidgetRef ref,
    EntryLane lane,
  ) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref
        .read(entryEditorProvider(entryKey).notifier)
        .saveAndClose(lane);
    if (!context.mounted) return;
    final message = _outcomeMessage(outcome, l10n);
    if (message != null) _snack(context, message);
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    EntryLane lane,
    EntryLaneAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final editor = ref.read(entryEditorProvider(entryKey).notifier);
    final EntrySaveOutcome outcome;
    switch (action) {
      case EntryLaneAction.disqualify:
      case EntryLaneAction.editDisqualification:
        final code = await showDialog<String>(
          context: context,
          builder: (context) => _DisqualifyDialog(
            initial: action == EntryLaneAction.editDisqualification
                ? lane.result.complement
                : '',
          ),
        );
        if (code == null) return;
        outcome = await editor.disqualify(lane, code);
      case EntryLaneAction.forfeit:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => _ForfeitDialog(name: laneTitle(lane.lane)),
        );
        if (confirmed != true) return;
        outcome = await editor.forfeit(lane);
      case EntryLaneAction.cancelDisqualification:
      case EntryLaneAction.cancelForfeit:
        outcome = await editor.cancelMark(lane);
    }
    if (!context.mounted) return;
    final message = _outcomeMessage(outcome, l10n);
    if (message != null) _snack(context, message);
  }

  Future<void> _retry(BuildContext context, WidgetRef ref, String id) =>
      _outboxAction(context, () => ref.read(outboxProvider.notifier).retry(id));

  Future<void> _dismiss(BuildContext context, WidgetRef ref, String id) =>
      _outboxAction(
        context,
        () => ref.read(outboxProvider.notifier).dismiss(id),
      );

  Future<void> _outboxAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } on AppException {
      if (context.mounted) _snack(context, l10n.entryNotPersisted);
    }
  }
}

String? _outcomeMessage(EntrySaveOutcome outcome, AppLocalizations l10n) =>
    switch (outcome) {
      EntrySaveOutcome.invalid => l10n.entryInvalidChrono,
      EntrySaveOutcome.notConnected => l10n.entryNotConnected,
      EntrySaveOutcome.notPersisted => l10n.entryNotPersisted,
      // Le couloir le dit déjà ; il n'y avait rien à enregistrer.
      EntrySaveOutcome.readOnly ||
      EntrySaveOutcome.saved ||
      EntrySaveOutcome.unchanged => null,
    };

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _Header extends StatelessWidget {
  const _Header({
    required this.cursor,
    required this.onPrevious,
    required this.onNext,
  });

  final EntryCursor cursor;
  final bool Function() onPrevious;
  final bool Function() onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = cursor.entry;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.entryPreviousHeat,
            onPressed: cursor.previous == null ? null : () => onPrevious(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  liveCardTitle(entry, l10n),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  liveCardSubtitle(entry, cursor.position, l10n),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: heatStatus(entry.heat)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.entryNextHeat,
            onPressed: cursor.next == null ? null : () => onNext(),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
    ),
  );
}

class _LaneFilter extends StatelessWidget {
  const _LaneFilter({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<int> options;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget chip(String label, int? lane) => Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == lane,
        onSelected: (_) => onSelected(lane),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          chip(l10n.entryLaneAll, null),
          for (final lane in options) chip('$lane', lane),
        ],
      ),
    );
  }
}

class _DisqualifyDialog extends StatefulWidget {
  const _DisqualifyDialog({required this.initial});

  final String initial;

  @override
  State<_DisqualifyDialog> createState() => _DisqualifyDialogState();
}

class _DisqualifyDialogState extends State<_DisqualifyDialog> {
  late final _code = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.entryDisqualify),
      content: TextField(
        controller: _code,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.entryDisqualifyCode),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ValueListenableBuilder(
          valueListenable: _code,
          builder: (context, value, _) => TextButton(
            onPressed: value.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(value.text),
            child: Text(l10n.entrySave),
          ),
        ),
      ],
    );
  }
}

class _ForfeitDialog extends StatelessWidget {
  const _ForfeitDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      content: Text(l10n.entryForfeitConfirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.forfeit),
        ),
      ],
    );
  }
}
