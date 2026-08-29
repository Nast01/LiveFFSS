import 'package:get/get.dart';

/// A one-shot message a controller hands to its view, which translates
/// [translationKey] and shows it.
///
/// Publish it with `message.trigger(...)`, never `message.value = ...`: GetX
/// drops a write whose value equals the current one, and a `const UiMessage`
/// is the *same instance* every time — so the second identical failure in a
/// row would never reach the view.
sealed class UiMessage {
  const UiMessage(this.translationKey, {this.details});

  final String translationKey;

  /// The raw reason behind a failure — an API message, a status code — shown
  /// after the translated line. Untranslated on purpose: it is what the server
  /// or the platform said, and paraphrasing it would lose the diagnosis.
  final String? details;
}

class UiMessageSuccess extends UiMessage {
  const UiMessageSuccess(super.translationKey, {super.details});
}

class UiMessageError extends UiMessage {
  const UiMessageError(super.translationKey, {super.details});
}

extension UiMessageFormatting on UiMessage {
  /// What a view shows: the translated line, then the raw reason when the
  /// failure came with one. Translation happens here rather than in the
  /// controller, which never sees `.tr`.
  String get text =>
      details == null ? translationKey.tr : '${translationKey.tr} · $details';
}
