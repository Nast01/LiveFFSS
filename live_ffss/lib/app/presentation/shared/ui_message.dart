sealed class UiMessage {
  const UiMessage(this.translationKey);
  final String translationKey;
}

class UiMessageSuccess extends UiMessage {
  const UiMessageSuccess(super.translationKey);
}

class UiMessageError extends UiMessage {
  const UiMessageError(super.translationKey);
}
