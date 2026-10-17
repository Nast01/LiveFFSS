import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(retry: noRetry);
    addTearDown(container.dispose);
  });

  test('sans geste : déplié si la réunion n\'est pas terminée', () {
    final expansion = container.read(meetingExpansionProvider);

    expect(isMeetingExpanded(expansion, 1, finished: false), isTrue);
    expect(isMeetingExpanded(expansion, 1, finished: true), isFalse);
  });

  test('toggle inverse l\'état affiché et le garde', () {
    final notifier = container.read(meetingExpansionProvider.notifier);

    notifier.toggle(1, currentlyExpanded: false);
    expect(
      isMeetingExpanded(
        container.read(meetingExpansionProvider),
        1,
        finished: true,
      ),
      isTrue,
    );

    notifier.toggle(1, currentlyExpanded: true);
    expect(
      isMeetingExpanded(
        container.read(meetingExpansionProvider),
        1,
        finished: false,
      ),
      isFalse,
    );
  });

  test('une réunion touchée ne change pas les autres', () {
    container
        .read(meetingExpansionProvider.notifier)
        .toggle(1, currentlyExpanded: true);

    expect(
      isMeetingExpanded(
        container.read(meetingExpansionProvider),
        2,
        finished: false,
      ),
      isTrue,
    );
  });
}
