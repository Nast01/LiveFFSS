// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_probe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SessionProbe {
  SessionProbeOutcome get outcome => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  UserType? get type => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Create a copy of SessionProbe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionProbeCopyWith<SessionProbe> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionProbeCopyWith<$Res> {
  factory $SessionProbeCopyWith(
          SessionProbe value, $Res Function(SessionProbe) then) =
      _$SessionProbeCopyWithImpl<$Res, SessionProbe>;
  @useResult
  $Res call(
      {SessionProbeOutcome outcome,
      String? label,
      UserType? type,
      String? message});
}

/// @nodoc
class _$SessionProbeCopyWithImpl<$Res, $Val extends SessionProbe>
    implements $SessionProbeCopyWith<$Res> {
  _$SessionProbeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionProbe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outcome = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      outcome: null == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as SessionProbeOutcome,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UserType?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionProbeImplCopyWith<$Res>
    implements $SessionProbeCopyWith<$Res> {
  factory _$$SessionProbeImplCopyWith(
          _$SessionProbeImpl value, $Res Function(_$SessionProbeImpl) then) =
      __$$SessionProbeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SessionProbeOutcome outcome,
      String? label,
      UserType? type,
      String? message});
}

/// @nodoc
class __$$SessionProbeImplCopyWithImpl<$Res>
    extends _$SessionProbeCopyWithImpl<$Res, _$SessionProbeImpl>
    implements _$$SessionProbeImplCopyWith<$Res> {
  __$$SessionProbeImplCopyWithImpl(
      _$SessionProbeImpl _value, $Res Function(_$SessionProbeImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionProbe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outcome = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? message = freezed,
  }) {
    return _then(_$SessionProbeImpl(
      outcome: null == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as SessionProbeOutcome,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UserType?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SessionProbeImpl implements _SessionProbe {
  const _$SessionProbeImpl(
      {required this.outcome, this.label, this.type, this.message});

  @override
  final SessionProbeOutcome outcome;
  @override
  final String? label;
  @override
  final UserType? type;
  @override
  final String? message;

  @override
  String toString() {
    return 'SessionProbe(outcome: $outcome, label: $label, type: $type, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionProbeImpl &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, outcome, label, type, message);

  /// Create a copy of SessionProbe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionProbeImplCopyWith<_$SessionProbeImpl> get copyWith =>
      __$$SessionProbeImplCopyWithImpl<_$SessionProbeImpl>(this, _$identity);
}

abstract class _SessionProbe implements SessionProbe {
  const factory _SessionProbe(
      {required final SessionProbeOutcome outcome,
      final String? label,
      final UserType? type,
      final String? message}) = _$SessionProbeImpl;

  @override
  SessionProbeOutcome get outcome;
  @override
  String? get label;
  @override
  UserType? get type;
  @override
  String? get message;

  /// Create a copy of SessionProbe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionProbeImplCopyWith<_$SessionProbeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
