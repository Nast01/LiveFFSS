// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return _Entry.fromJson(json);
}

/// @nodoc
mixin _$Entry {
  int get id => throw _privateConstructorUsedError;
  int get raceId => throw _privateConstructorUsedError;
  Category get category => throw _privateConstructorUsedError;
  Club? get organisme => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String get statusLabel => throw _privateConstructorUsedError;
  int get entryTime => throw _privateConstructorUsedError;
  String get entryTimeLabel => throw _privateConstructorUsedError;
  bool get isForfeit => throw _privateConstructorUsedError;
  List<Athlete> get athletes => throw _privateConstructorUsedError;

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntryCopyWith<Entry> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryCopyWith<$Res> {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) then) =
      _$EntryCopyWithImpl<$Res, Entry>;
  @useResult
  $Res call(
      {int id,
      int raceId,
      Category category,
      Club? organisme,
      int status,
      String statusLabel,
      int entryTime,
      String entryTimeLabel,
      bool isForfeit,
      List<Athlete> athletes});

  $CategoryCopyWith<$Res> get category;
  $ClubCopyWith<$Res>? get organisme;
}

/// @nodoc
class _$EntryCopyWithImpl<$Res, $Val extends Entry>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raceId = null,
    Object? category = null,
    Object? organisme = freezed,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? isForfeit = null,
    Object? athletes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      organisme: freezed == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as Club?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isForfeit: null == isForfeit
          ? _value.isForfeit
          : isForfeit // ignore: cast_nullable_to_non_nullable
              as bool,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
    ) as $Val);
  }

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res> get category {
    return $CategoryCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClubCopyWith<$Res>? get organisme {
    if (_value.organisme == null) {
      return null;
    }

    return $ClubCopyWith<$Res>(_value.organisme!, (value) {
      return _then(_value.copyWith(organisme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EntryImplCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$$EntryImplCopyWith(
          _$EntryImpl value, $Res Function(_$EntryImpl) then) =
      __$$EntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int raceId,
      Category category,
      Club? organisme,
      int status,
      String statusLabel,
      int entryTime,
      String entryTimeLabel,
      bool isForfeit,
      List<Athlete> athletes});

  @override
  $CategoryCopyWith<$Res> get category;
  @override
  $ClubCopyWith<$Res>? get organisme;
}

/// @nodoc
class __$$EntryImplCopyWithImpl<$Res>
    extends _$EntryCopyWithImpl<$Res, _$EntryImpl>
    implements _$$EntryImplCopyWith<$Res> {
  __$$EntryImplCopyWithImpl(
      _$EntryImpl _value, $Res Function(_$EntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raceId = null,
    Object? category = null,
    Object? organisme = freezed,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? isForfeit = null,
    Object? athletes = null,
  }) {
    return _then(_$EntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as Category,
      organisme: freezed == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as Club?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isForfeit: null == isForfeit
          ? _value.isForfeit
          : isForfeit // ignore: cast_nullable_to_non_nullable
              as bool,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntryImpl implements _Entry {
  const _$EntryImpl(
      {required this.id,
      this.raceId = 0,
      required this.category,
      this.organisme,
      required this.status,
      required this.statusLabel,
      this.entryTime = 0,
      this.entryTimeLabel = '',
      this.isForfeit = false,
      final List<Athlete> athletes = const <Athlete>[]})
      : _athletes = athletes;

  factory _$EntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final int raceId;
  @override
  final Category category;
  @override
  final Club? organisme;
  @override
  final int status;
  @override
  final String statusLabel;
  @override
  @JsonKey()
  final int entryTime;
  @override
  @JsonKey()
  final String entryTimeLabel;
  @override
  @JsonKey()
  final bool isForfeit;
  final List<Athlete> _athletes;
  @override
  @JsonKey()
  List<Athlete> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  @override
  String toString() {
    return 'Entry(id: $id, raceId: $raceId, category: $category, organisme: $organisme, status: $status, statusLabel: $statusLabel, entryTime: $entryTime, entryTimeLabel: $entryTimeLabel, isForfeit: $isForfeit, athletes: $athletes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.raceId, raceId) || other.raceId == raceId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.organisme, organisme) ||
                other.organisme == organisme) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.entryTime, entryTime) ||
                other.entryTime == entryTime) &&
            (identical(other.entryTimeLabel, entryTimeLabel) ||
                other.entryTimeLabel == entryTimeLabel) &&
            (identical(other.isForfeit, isForfeit) ||
                other.isForfeit == isForfeit) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      raceId,
      category,
      organisme,
      status,
      statusLabel,
      entryTime,
      entryTimeLabel,
      isForfeit,
      const DeepCollectionEquality().hash(_athletes));

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      __$$EntryImplCopyWithImpl<_$EntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryImplToJson(
      this,
    );
  }
}

abstract class _Entry implements Entry {
  const factory _Entry(
      {required final int id,
      final int raceId,
      required final Category category,
      final Club? organisme,
      required final int status,
      required final String statusLabel,
      final int entryTime,
      final String entryTimeLabel,
      final bool isForfeit,
      final List<Athlete> athletes}) = _$EntryImpl;

  factory _Entry.fromJson(Map<String, dynamic> json) = _$EntryImpl.fromJson;

  @override
  int get id;
  @override
  int get raceId;
  @override
  Category get category;
  @override
  Club? get organisme;
  @override
  int get status;
  @override
  String get statusLabel;
  @override
  int get entryTime;
  @override
  String get entryTimeLabel;
  @override
  bool get isForfeit;
  @override
  List<Athlete> get athletes;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
