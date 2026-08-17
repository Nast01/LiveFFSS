import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/heat_plan.dart';

/// What the operator decided. [plan] is the structure to draw with; when
/// [editStructure] is true they asked for the editor instead and the caller
/// reopens this dialog on the way back. A null result means cancelled.
typedef HeatStructureResult = ({HeatPlan? plan, bool editStructure});

/// Confirms the structure before a coastal série is drawn. Presented even when
/// the two plans agree: the operator is validating the structure, not being
/// warned about a mismatch.
class HeatStructureDialog extends StatefulWidget {
  const HeatStructureDialog({
    super.key,
    required this.presentCount,
    required this.engagedCount,
    required this.declared,
    required this.proposed,
  });

  final int presentCount;
  final int engagedCount;
  final HeatPlan declared;
  final HeatPlan proposed;

  @override
  State<HeatStructureDialog> createState() => _HeatStructureDialogState();
}

class _HeatStructureDialogState extends State<HeatStructureDialog> {
  static const int _proposedOption = 0;
  static const int _declaredOption = 1;

  /// Which row is picked, NOT the plan it carries. `HeatPlan` is a record, so
  /// two plans holding the same numbers are `==` — deriving the selection by
  /// comparing values made the declared row impossible to select whenever it
  /// matched the proposal, which is the normal state on any visit after a save.
  ///
  /// The authored structure is preselected: confirming without reading leaves
  /// the operator's own structure standing, and adopting the recomputed one is
  /// the deliberate act.
  int _selectedOption = _declaredOption;

  HeatPlan get _selected =>
      _selectedOption == _proposedOption ? widget.proposed : widget.declared;

  String _label(HeatPlan plan) => 'heat_draw_structure_plan'.trParams({
        'races': '${plan.raceCount}',
        'spots': '${plan.spotsPerRace}',
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('heat_draw_structure_title'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'heat_draw_presence'.trParams({
              'present': '${widget.presentCount}',
              'engaged': '${widget.engagedCount}',
            }),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          RadioListTile<int>(
            value: _proposedOption,
            groupValue: _selectedOption,
            contentPadding: EdgeInsets.zero,
            title: Text('heat_draw_structure_proposed'.tr),
            subtitle: Text(_label(widget.proposed)),
            onChanged: (_) => setState(() => _selectedOption = _proposedOption),
          ),
          RadioListTile<int>(
            value: _declaredOption,
            groupValue: _selectedOption,
            contentPadding: EdgeInsets.zero,
            title: Text('heat_draw_structure_declared'.tr),
            subtitle: Text(_label(widget.declared)),
            onChanged: (_) => setState(() => _selectedOption = _declaredOption),
          ),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('heat_draw_structure_edit'.tr),
            onPressed: () => Navigator.of(context).pop<HeatStructureResult>(
              (plan: null, editStructure: true),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _selected.raceCount <= 0
              ? null
              : () => Navigator.of(context).pop<HeatStructureResult>(
                    (plan: _selected, editStructure: false),
                  ),
          child: Text('confirm'.tr),
        ),
      ],
    );
  }
}
