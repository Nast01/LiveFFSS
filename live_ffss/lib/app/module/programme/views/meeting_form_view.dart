import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/core/utils/competition_days.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_form_controller.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingFormView extends StatefulWidget {
  const MeetingFormView({super.key});

  @override
  State<MeetingFormView> createState() => _MeetingFormViewState();
}

class _MeetingFormViewState extends State<MeetingFormView> {
  final _controller = Get.find<MeetingFormController>();
  late final TextEditingController _title;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: _controller.editing.value?.name ?? '');
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _title.dispose();
    _messageWorker.dispose();
    super.dispose();
  }

  String _hhmm(int minutes) => '${(minutes ~/ 60).toString().padLeft(2, '0')}'
      ':${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final days = _controller.days;
    if (days.isEmpty) return;
    // Une réunion peut porter une date hors des jours de la compétition —
    // FFSS en garde que cette appli n'a pas écrites elle-même, ou laissées
    // là après un resserrement des dates de la compétition. showDatePicker
    // plante si initialDate tombe hors de [firstDate, lastDate], donc un
    // jour hors plage retombe sur le premier jour plutôt que d'essayer de
    // l'approcher.
    final current = _controller.date.value;
    final initial = current != null && days.any((d) => sameDay(d, current))
        ? current
        : days.first;
    // Restreint aux jours de la compétition : une réunion hors de ses dates
    // n'aurait aucun sens sur le site fédéral.
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: days.first,
      lastDate: days.last,
      selectableDayPredicate: (day) => days.any((d) =>
          d.year == day.year && d.month == day.month && d.day == day.day),
    );
    if (picked != null) {
      _controller.date.value = DateTime(picked.year, picked.month, picked.day);
    }
  }

  Future<void> _pickTime() async {
    final current = _controller.startMinutes.value;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _controller.startMinutes.value = picked.hour * 60 + picked.minute;
    }
  }

  Future<void> _save() async {
    if (await _controller.save(_title.text)) Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
              _controller.isEditing ? 'meeting_edit'.tr : 'meeting_new'.tr,
              style: AppTypography.title
                  .copyWith(color: Colors.white, fontSize: 16),
            )),
      ),
      body: ListView(
        // Le bouton de validation ferme cette liste : sans le retrait de la
        // barre de navigation, il reste sous elle au bout du défilement.
        padding: AppSpacing.pageAll.add(
          EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        ),
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'meeting_title'.tr),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final day = _controller.date.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text('meeting_date'.tr, style: AppTypography.caption),
              subtitle: Text(
                day == null
                    ? 'no_days'.tr
                    : DateFormat('EEEE d MMMM y', Get.locale?.toString())
                        .format(day),
                style: AppTypography.body,
              ),
              onTap: _pickDate,
            );
          }),
          Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text('meeting_start'.tr, style: AppTypography.caption),
                subtitle: Text(_hhmm(_controller.startMinutes.value),
                    style: AppTypography.body),
                onTap: _pickTime,
              )),
          const SizedBox(height: AppSpacing.md),
          Text('meeting_site'.tr, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Obx(() {
            final sites = _controller.sites;
            if (sites.isEmpty) {
              return Row(
                children: [
                  Expanded(
                    child: Text('no_sites'.tr,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted)),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed<void>(Routes.programmeSites),
                    child: Text('manage_sites'.tr),
                  ),
                ],
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final site in sites)
                  ChoiceChip(
                    label: Text(site.name),
                    selected: _controller.site.value == site.name,
                    onSelected: (_) => _controller.site.value = site.name,
                  ),
                TextButton(
                  onPressed: () => Get.toNamed<void>(Routes.programmeSites),
                  child: Text('manage_sites'.tr),
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => FilledButton(
                onPressed: _controller.isSaving.value ? null : _save,
                child: _controller.isSaving.value
                    ? const LoadingIndicator(
                        compact: true, size: 18, color: Colors.white)
                    : Text(
                        _controller.isEditing ? 'save'.tr : 'meeting_new'.tr),
              )),
        ],
      ),
    );
  }
}
