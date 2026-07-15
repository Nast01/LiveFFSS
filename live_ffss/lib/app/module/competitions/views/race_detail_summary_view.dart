import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class RaceDetailSummaryView extends StatelessWidget {
  const RaceDetailSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.summarize_outlined,
      title: 'summary'.tr,
      description: 'summary_coming_soon'.tr,
    );
  }
}
