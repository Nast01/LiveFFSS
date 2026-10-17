// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_detail_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeetingItemDetail {

 Meeting get meeting; MeetingItem get item; Progression? get progression; Stage? get stage;/// Par id de place. Une valeur nulle est une place vide ; une clé absente,
/// une place jamais lue.
 Map<int, LaneAssignment?> get lanes;
/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingItemDetailCopyWith<MeetingItemDetail> get copyWith => _$MeetingItemDetailCopyWithImpl<MeetingItemDetail>(this as MeetingItemDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MeetingItemDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingItemDetail&&(identical(other.meeting, _this.meeting) || other.meeting == _this.meeting)&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.progression, _this.progression) || other.progression == _this.progression)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&const DeepCollectionEquality().equals(other.lanes, _this.lanes));
}


@override
int get hashCode {
  final _this = this as MeetingItemDetail;
  return Object.hash(runtimeType,_this.meeting,_this.item,_this.progression,_this.stage,const DeepCollectionEquality().hash(_this.lanes));
}

@override
String toString() {
  final _this = this as MeetingItemDetail;
  return 'MeetingItemDetail(meeting: ${_this.meeting}, item: ${_this.item}, progression: ${_this.progression}, stage: ${_this.stage}, lanes: ${_this.lanes})';
}


}

/// @nodoc
abstract mixin class $MeetingItemDetailCopyWith<$Res>  {
  factory $MeetingItemDetailCopyWith(MeetingItemDetail value, $Res Function(MeetingItemDetail) _then) = _$MeetingItemDetailCopyWithImpl;
@useResult
$Res call({
 Meeting meeting, MeetingItem item, Progression? progression, Stage? stage, Map<int, LaneAssignment?> lanes
});


$MeetingCopyWith<$Res> get meeting;$MeetingItemCopyWith<$Res> get item;$ProgressionCopyWith<$Res>? get progression;$StageCopyWith<$Res>? get stage;

}
/// @nodoc
class _$MeetingItemDetailCopyWithImpl<$Res>
    implements $MeetingItemDetailCopyWith<$Res> {
  _$MeetingItemDetailCopyWithImpl(this._self, this._then);

  final MeetingItemDetail _self;
  final $Res Function(MeetingItemDetail) _then;

/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meeting = null,Object? item = null,Object? progression = freezed,Object? stage = freezed,Object? lanes = null,}) {
  return _then(MeetingItemDetail(
meeting: null == meeting ? _self.meeting : meeting // ignore: cast_nullable_to_non_nullable
as Meeting,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MeetingItem,progression: freezed == progression ? _self.progression : progression // ignore: cast_nullable_to_non_nullable
as Progression?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as Stage?,lanes: null == lanes ? _self.lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,
  ));
}
/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingCopyWith<$Res> get meeting {
  
  return $MeetingCopyWith<$Res>(_self.meeting, (value) {
    return _then(_self.copyWith(meeting: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<$Res> get item {
  
  return $MeetingItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressionCopyWith<$Res>? get progression {
    if (_self.progression == null) {
    return null;
  }

  return $ProgressionCopyWith<$Res>(_self.progression!, (value) {
    return _then(_self.copyWith(progression: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StageCopyWith<$Res>? get stage {
    if (_self.stage == null) {
    return null;
  }

  return $StageCopyWith<$Res>(_self.stage!, (value) {
    return _then(_self.copyWith(stage: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeetingItemDetail].
extension MeetingItemDetailPatterns on MeetingItemDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingItemDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingItemDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingItemDetail value)  $default,){
final _that = this;
switch (_that) {
case _MeetingItemDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingItemDetail value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingItemDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Meeting meeting,  MeetingItem item,  Progression? progression,  Stage? stage,  Map<int, LaneAssignment?> lanes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingItemDetail() when $default != null:
return $default(_that.meeting,_that.item,_that.progression,_that.stage,_that.lanes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Meeting meeting,  MeetingItem item,  Progression? progression,  Stage? stage,  Map<int, LaneAssignment?> lanes)  $default,) {final _that = this;
switch (_that) {
case _MeetingItemDetail():
return $default(_that.meeting,_that.item,_that.progression,_that.stage,_that.lanes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Meeting meeting,  MeetingItem item,  Progression? progression,  Stage? stage,  Map<int, LaneAssignment?> lanes)?  $default,) {final _that = this;
switch (_that) {
case _MeetingItemDetail() when $default != null:
return $default(_that.meeting,_that.item,_that.progression,_that.stage,_that.lanes);case _:
  return null;

}
}

}

/// @nodoc


class _MeetingItemDetail extends MeetingItemDetail {
  const _MeetingItemDetail({required this.meeting, required this.item, this.progression, this.stage,  Map<int, LaneAssignment?> lanes = const <int, LaneAssignment?>{}}): _lanes = lanes,super._();
  

@override final  Meeting meeting;
@override final  MeetingItem item;
@override final  Progression? progression;
@override final  Stage? stage;
/// Par id de place. Une valeur nulle est une place vide ; une clé absente,
/// une place jamais lue.
 final  Map<int, LaneAssignment?> _lanes;
/// Par id de place. Une valeur nulle est une place vide ; une clé absente,
/// une place jamais lue.
@override@JsonKey() Map<int, LaneAssignment?> get lanes {
  if (_lanes is EqualUnmodifiableMapView) return _lanes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lanes);
}


/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingItemDetailCopyWith<_MeetingItemDetail> get copyWith => __$MeetingItemDetailCopyWithImpl<_MeetingItemDetail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingItemDetail&&(identical(other.meeting, meeting) || other.meeting == meeting)&&(identical(other.item, item) || other.item == item)&&(identical(other.progression, progression) || other.progression == progression)&&(identical(other.stage, stage) || other.stage == stage)&&const DeepCollectionEquality().equals(other.lanes, _lanes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,meeting,item,progression,stage,const DeepCollectionEquality().hash(_lanes));
}

@override
String toString() {
    return 'MeetingItemDetail(meeting: $meeting, item: $item, progression: $progression, stage: $stage, lanes: $lanes)';
}


}

/// @nodoc
abstract mixin class _$MeetingItemDetailCopyWith<$Res> implements $MeetingItemDetailCopyWith<$Res> {
  factory _$MeetingItemDetailCopyWith(_MeetingItemDetail value, $Res Function(_MeetingItemDetail) _then) = __$MeetingItemDetailCopyWithImpl;
@override @useResult
$Res call({
 Meeting meeting, MeetingItem item, Progression? progression, Stage? stage, Map<int, LaneAssignment?> lanes
});


@override $MeetingCopyWith<$Res> get meeting;@override $MeetingItemCopyWith<$Res> get item;@override $ProgressionCopyWith<$Res>? get progression;@override $StageCopyWith<$Res>? get stage;

}
/// @nodoc
class __$MeetingItemDetailCopyWithImpl<$Res>
    implements _$MeetingItemDetailCopyWith<$Res> {
  __$MeetingItemDetailCopyWithImpl(this._self, this._then);

  final _MeetingItemDetail _self;
  final $Res Function(_MeetingItemDetail) _then;

/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meeting = null,Object? item = null,Object? progression = freezed,Object? stage = freezed,Object? lanes = null,}) {
  return _then(_MeetingItemDetail(
meeting: null == meeting ? _self.meeting : meeting // ignore: cast_nullable_to_non_nullable
as Meeting,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MeetingItem,progression: freezed == progression ? _self.progression : progression // ignore: cast_nullable_to_non_nullable
as Progression?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as Stage?,lanes: null == lanes ? _self._lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,
  ));
}

/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingCopyWith<$Res> get meeting {
  
  return $MeetingCopyWith<$Res>(_self.meeting, (value) {
    return _then(_self.copyWith(meeting: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<$Res> get item {
  
  return $MeetingItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressionCopyWith<$Res>? get progression {
    if (_self.progression == null) {
    return null;
  }

  return $ProgressionCopyWith<$Res>(_self.progression!, (value) {
    return _then(_self.copyWith(progression: value));
  });
}/// Create a copy of MeetingItemDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StageCopyWith<$Res>? get stage {
    if (_self.stage == null) {
    return null;
  }

  return $StageCopyWith<$Res>(_self.stage!, (value) {
    return _then(_self.copyWith(stage: value));
  });
}
}

// dart format on
