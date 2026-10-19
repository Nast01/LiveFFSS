import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';

/// Les dernières requêtes FFSS de cette session de l'app, pour comprendre
/// une lenteur ou un échec sans brancher d'outil.
class NetworkLogPage extends ConsumerStatefulWidget {
  const NetworkLogPage({super.key});

  @override
  ConsumerState<NetworkLogPage> createState() => _NetworkLogPageState();
}

class _NetworkLogPageState extends ConsumerState<NetworkLogPage> {
  bool _errorsOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = visibleEntries(
      ref.watch(networkLogProvider),
      errorsOnly: _errorsOnly,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.networkLogTitle),
        actions: [
          IconButton(
            tooltip: l10n.networkLogClear,
            icon: const Icon(Icons.delete_outline),
            onPressed: ref.read(networkLogProvider.notifier).clear,
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(l10n.networkLogErrorsOnly),
            value: _errorsOnly,
            onChanged: (value) => setState(() => _errorsOnly = value),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      _errorsOnly
                          ? l10n.networkLogEmptyErrors
                          : l10n.networkLogEmpty,
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _EntryTile(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = entry.status?.toString() ?? l10n.networkLogNoStatus;
    final result = entry.error == null ? status : '$status · ${entry.error}';
    return ListTile(
      dense: true,
      title: Text(
        '${entry.method} ${entry.path}',
        style: TextStyle(color: entry.failed ? AppColors.red : null),
      ),
      subtitle: Text(
        '${DateFormat.Hms().format(entry.at)} · ${entry.server} · $result · '
        '${formatDuration(entry.duration)} · ${formatBytes(entry.bytes)}',
      ),
    );
  }
}
