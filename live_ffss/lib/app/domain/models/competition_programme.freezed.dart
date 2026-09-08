// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition_programme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompetitionProgramme _$CompetitionProgrammeFromJson(Map<String, dynamic> json) {
  return _CompetitionProgramme.fromJson(json);
}

/// @nodoc
mixin _$CompetitionProgramme {
  int get competitionId =>
      throw _privateConstructorUsedError; // Monotonic counter for local entity ids (races, sites). Starts at 1.
  int get nextLocalId => throw _privateConstructorUsedError;
  List<ProgrammeSite> get sites => throw _privateConstructorUsedError;
  List<EventStructure> get structures => throw _privateConstructorUsedError;

  /// Serializes this CompetitionProgramme to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompetitionProgramme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompetitionProgrammeCopyWith<CompetitionProgramme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetitionProgrammeCopyWith<$Res> {
  factory $CompetitionProgrammeCopyWith(CompetitionProgramme value,
          $Res Function(CompetitionProgramme) then) =
      _$CompetitionProgrammeCopyWithImpl<$Res, CompetitionProgramme>;
  @useResult
  $Res call(
      {int competitionId,
      int nextLocalId,
      List<ProgrammeSite> sites,
      List<EventStructure> structures});
}

/// @nodoc
class _$CompetitionProgrammeCopyWithImpl<$Res,
        $Val extends CompetitionProgramme>
    implements $CompetitionProgrammeCopyWith<$Res> {
  _$CompetitionProgrammeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompetitionProgramme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competitionId = null,
    Object? nextLocalId = null,
    Object? sites = null,
    Object? structures = null,
  }) {
    return _then(_value.copyWith(
      competitionId: null == competitionId
          ? _value.competitionId
          : competitionId // ignore: cast_nullable_to_non_nullable
              as int,
      nextLocalId: null == nextLocalId
          ? _value.nextLocalId
          : nextLocalId // ignore: cast_nullable_to_non_nullable
              as int,
      sites: null == sites
          ? _value.sites
          : sites // ignore: cast_nullable_to_non_nullable
              as List<ProgrammeSite>,
      structures: null == structures
          ? _value.structures
          : structures // ignore: cast_nullable_to_non_nullable
              as List<EventStructure>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompetitionProgrammeImplCopyWith<$Res>
    implements $CompetitionProgrammeCopyWith<$Res> {
  factory _$$CompetitionProgrammeImplCopyWith(_$CompetitionProgrammeImpl value,
          $Res Function(_$CompetitionProgrammeImpl) then) =
      __$$CompetitionProgrammeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int competitionId,
      int nextLocalId,
      List<ProgrammeSite> sites,
      List<EventStructure> structures});
}

/// @nodoc
class __$$CompetitionProgrammeImplCopyWithImpl<$Res>
    extends _$CompetitionProgrammeCopyWithImpl<$Res, _$CompetitionProgrammeImpl>
    implements _$$CompetitionProgrammeImplCopyWith<$Res> {
  __$$CompetitionProgrammeImplCopyWithImpl(_$CompetitionProgrammeImpl _value,
      $Res Function(_$CompetitionProgrammeImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompetitionProgramme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competitionId = null,
    Object? nextLocalId = null,
    Object? sites = null,
    Object? structures = null,
  }) {
    return _then(_$CompetitionProgrammeImpl(
      competitionId: null == competitionId
          ? _value.competitionId
          : competitionId // ignore: cast_nullable_to_non_nullable
              as int,
      nextLocalId: null == nextLocalId
          ? _value.nextLocalId
          : nextLocalId // ignore: cast_nullable_to_non_nullable
              as int,
      sites: null == sites
          ? _value._sites
          : sites // ignore: cast_nullable_to_non_nullable
              as List<ProgrammeSite>,
      structures: null == structures
          ? _value._structures
          : structures // ignore: cast_nullable_to_non_nullable
              as List<EventStructure>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetitionProgrammeImpl implements _CompetitionProgramme {
  const _$CompetitionProgrammeImpl(
      {required this.competitionId,
      this.nextLocalId = 1,
      final List<ProgrammeSite> sites = const <ProgrammeSite>[],
      final List<EventStructure> structures = const <EventStructure>[]})
      : _sites = sites,
        _structures = structures;

  factory _$CompetitionProgrammeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetitionProgrammeImplFromJson(json);

  @override
  final int competitionId;
// Monotonic counter for local entity ids (races, sites). Starts at 1.
  @override
  @JsonKey()
  final int nextLocalId;
  final List<ProgrammeSite> _sites;
  @override
  @JsonKey()
  List<ProgrammeSite> get sites {
    if (_sites is EqualUnmodifiableListView) return _sites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sites);
  }

  final List<EventStructure> _structures;
  @override
  @JsonKey()
  List<EventStructure> get structures {
    if (_structures is EqualUnmodifiableListView) return _structures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_structures);
  }

  @override
  String toString() {
    return 'CompetitionProgramme(competitionId: $competitionId, nextLocalId: $nextLocalId, sites: $sites, structures: $structures)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetitionProgrammeImpl &&
            (identical(other.competitionId, competitionId) ||
                other.competitionId == competitionId) &&
            (identical(other.nextLocalId, nextLocalId) ||
                other.nextLocalId == nextLocalId) &&
            const DeepCollectionEquality().equals(other._sites, _sites) &&
            const DeepCollectionEquality()
                .equals(other._structures, _structures));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      competitionId,
      nextLocalId,
      const DeepCollectionEquality().hash(_sites),
      const DeepCollectionEquality().hash(_structures));

  /// Create a copy of CompetitionProgramme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetitionProgrammeImplCopyWith<_$CompetitionProgrammeImpl>
      get copyWith =>
          __$$CompetitionProgrammeImplCopyWithImpl<_$CompetitionProgrammeImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetitionProgrammeImplToJson(
      this,
    );
  }
}

abstract class _CompetitionProgramme implements CompetitionProgramme {
  const factory _CompetitionProgramme(
      {required final int competitionId,
      final int nextLocalId,
      final List<ProgrammeSite> sites,
      final List<EventStructure> structures}) = _$CompetitionProgrammeImpl;

  factory _CompetitionProgramme.fromJson(Map<String, dynamic> json) =
      _$CompetitionProgrammeImpl.fromJson;

  @override
  int get competitionId; // Monotonic counter for local entity ids (races, sites). Starts at 1.
  @override
  int get nextLocalId;
  @override
  List<ProgrammeSite> get sites;
  @override
  List<EventStructure> get structures;

  /// Create a copy of CompetitionProgramme
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompetitionProgrammeImplCopyWith<_$CompetitionProgrammeImpl>
      get copyWith => throw _privateConstructorUsedError;
}
