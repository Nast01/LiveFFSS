import 'package:flutter/material.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/widgets/live_card.dart';

/// Les compétitions en direct, une carte par page. La carte voisine dépasse
/// au bord de l'écran pour montrer qu'on peut glisser.
class LiveCarousel extends StatefulWidget {
  const LiveCarousel({super.key, required this.competitions});

  final List<CompetitionSummary> competitions;

  @override
  State<LiveCarousel> createState() => _LiveCarouselState();
}

class _LiveCarouselState extends State<LiveCarousel> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _controllerFor(widget.competitions.length);
  }

  @override
  void didUpdateWidget(LiveCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSingle = oldWidget.competitions.length <= 1;
    final isSingle = widget.competitions.length <= 1;
    if (wasSingle != isSingle) {
      _controller.dispose();
      _controller = _controllerFor(widget.competitions.length);
    }
  }

  PageController _controllerFor(int count) =>
      PageController(viewportFraction: count > 1 ? 0.92 : 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.competitions.length > 1;
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.competitions.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(right: multiple ? 12 : 0),
          child: LiveCard(competition: widget.competitions[index]),
        ),
      ),
    );
  }
}
