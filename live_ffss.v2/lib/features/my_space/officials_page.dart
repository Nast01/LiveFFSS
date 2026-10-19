import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Les officiels de la compétition : juge principal d'abord, puis par niveau.
class OfficialsPage extends ConsumerStatefulWidget {
  const OfficialsPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<OfficialsPage> createState() => _OfficialsPageState();
}

class _OfficialsPageState extends ConsumerState<OfficialsPage> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = officialsProvider(widget.competitionId);
    final groups = ref.watch(provider);
    final value = groups.value;
    final Widget body;
    if (value == null) {
      body = groups.hasError
          ? ResultsMessage(
              text: l10n.mySpaceOfficialsError,
              onRetry: () => ref.invalidate(provider),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (value.isEmpty) {
      body = ResultsMessage(text: l10n.mySpaceOfficialsEmpty);
    } else {
      body = ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          for (final group in value) ...[
            MySpaceHeader(officialGroupLabel(group.label, l10n)),
            MySpaceBox(
              children: [
                for (final official in group.officials)
                  MySpaceRow(
                    title: official.name,
                    subtitle: officialDetail(official),
                  ),
              ],
            ),
          ],
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySpaceOfficials)),
      body: body,
    );
  }
}
