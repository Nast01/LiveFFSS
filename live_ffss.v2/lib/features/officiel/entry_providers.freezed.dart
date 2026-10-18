// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryHeatData {

 Heat get heat;/// Par id de place, comme dans le détail d'un créneau.
 Map<int, LaneAssignment?> get lanes;/// Par id d'engagement.
 Map<int, RaceResult> get results;/// Quand la lecture a commencé : une saisie envoyée depuis n'y est pas.
 DateTime get readAt;
/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryHeatDataCopyWith<EntryHeatData> get copyWith => _$EntryHeatDataCopyWithImpl<EntryHeatData>(this as EntryHeatData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntryHeatData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryHeatData&&(identical(other.heat, _this.heat) || other.heat == _this.heat)&&const DeepCollectionEquality().equals(other.lanes, _this.lanes)&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt));
}


@override
int get hashCode {
  final _this = this as EntryHeatData;
  return Object.hash(runtimeType,_this.heat,const DeepCollectionEquality().hash(_this.lanes),const DeepCollectionEquality().hash(_this.results),_this.readAt);
}

@override
String toString() {
  final _this = this as EntryHeatData;
  return 'EntryHeatData(heat: ${_this.heat}, lanes: ${_this.lanes}, results: ${_this.results}, readAt: ${_this.readAt})';
}


}

/// @nodoc
abstract mixin class $EntryHeatDataCopyWith<$Res>  {
  factory $EntryHeatDataCopyWith(EntryHeatData value, $Res Function(EntryHeatData) _then) = _$EntryHeatDataCopyWithImpl;
@useResult
$Res call({
 Heat heat, Map<int, LaneAssignment?> lanes, Map<int, RaceResult> results, DateTime readAt
});


$HeatCopyWith<$Res> get heat;

}
/// @nodoc
class _$EntryHeatDataCopyWithImpl<$Res>
    implements $EntryHeatDataCopyWith<$Res> {
  _$EntryHeatDataCopyWithImpl(this._self, this._then);

  final EntryHeatData _self;
  final $Res Function(EntryHeatData) _then;

/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heat = null,Object? lanes = null,Object? results = null,Object? readAt = null,}) {
  return _then(EntryHeatData(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,lanes: null == lanes ? _self.lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as Map<int, RaceResult>,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntryHeatData].
extension EntryHeatDataPatterns on EntryHeatData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryHeatData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryHeatData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryHeatData value)  $default,){
final _that = this;
switch (_that) {
case _EntryHeatData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryHeatData value)?  $default,){
final _that = this;
switch (_that) {
case _EntryHeatData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Heat heat,  Map<int, LaneAssignment?> lanes,  Map<int, RaceResult> results,  DateTime readAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryHeatData() when $default != null:
return $default(_that.heat,_that.lanes,_that.results,_that.readAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Heat heat,  Map<int, LaneAssignment?> lanes,  Map<int, RaceResult> results,  DateTime readAt)  $default,) {final _that = this;
switch (_that) {
case _EntryHeatData():
return $default(_that.heat,_that.lanes,_that.results,_that.readAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Heat heat,  Map<int, LaneAssignment?> lanes,  Map<int, RaceResult> results,  DateTime readAt)?  $default,) {final _that = this;
switch (_that) {
case _EntryHeatData() when $default != null:
return $default(_that.heat,_that.lanes,_that.results,_that.readAt);case _:
  return null;

}
}

}

/// @nodoc


class _EntryHeatData extends EntryHeatData {
  const _EntryHeatData({required this.heat,  Map<int, LaneAssignment?> lanes = const <int, LaneAssignment?>{},  Map<int, RaceResult> results = const <int, RaceResult>{}, required this.readAt}): _lanes = lanes,_results = results,super._();
  

@override final  Heat heat;
/// Par id de place, comme dans le détail d'un créneau.
 final  Map<int, LaneAssignment?> _lanes;
/// Par id de place, comme dans le détail d'un créneau.
@override@JsonKey() Map<int, LaneAssignment?> get lanes {
  if (_lanes is EqualUnmodifiableMapView) return _lanes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lanes);
}

/// Par id d'engagement.
 final  Map<int, RaceResult> _results;
/// Par id d'engagement.
@override@JsonKey() Map<int, RaceResult> get results {
  if (_results is EqualUnmodifiableMapView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_results);
}

/// Quand la lecture a commencé : une saisie envoyée depuis n'y est pas.
@override final  DateTime readAt;

/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryHeatDataCopyWith<_EntryHeatData> get copyWith => __$EntryHeatDataCopyWithImpl<_EntryHeatData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryHeatData&&(identical(other.heat, heat) || other.heat == heat)&&const DeepCollectionEquality().equals(other.lanes, _lanes)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.readAt, readAt) || other.readAt == readAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,heat,const DeepCollectionEquality().hash(_lanes),const DeepCollectionEquality().hash(_results),readAt);
}

@override
String toString() {
    return 'EntryHeatData(heat: $heat, lanes: $lanes, results: $results, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class _$EntryHeatDataCopyWith<$Res> implements $EntryHeatDataCopyWith<$Res> {
  factory _$EntryHeatDataCopyWith(_EntryHeatData value, $Res Function(_EntryHeatData) _then) = __$EntryHeatDataCopyWithImpl;
@override @useResult
$Res call({
 Heat heat, Map<int, LaneAssignment?> lanes, Map<int, RaceResult> results, DateTime readAt
});


@override $HeatCopyWith<$Res> get heat;

}
/// @nodoc
class __$EntryHeatDataCopyWithImpl<$Res>
    implements _$EntryHeatDataCopyWith<$Res> {
  __$EntryHeatDataCopyWithImpl(this._self, this._then);

  final _EntryHeatData _self;
  final $Res Function(_EntryHeatData) _then;

/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heat = null,Object? lanes = null,Object? results = null,Object? readAt = null,}) {
  return _then(_EntryHeatData(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,lanes: null == lanes ? _self._lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as Map<int, RaceResult>,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of EntryHeatData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}

/// @nodoc
mixin _$EntryEditorState {

 int? get openPlaceId;/// Par id de place : les trois champs, en chiffres tapés au pavé.
 Map<int, List<String>> get drafts; int get field;/// Le champ vient d'être choisi : le prochain chiffre le remplace.
 bool get replaceNext;
/// Create a copy of EntryEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryEditorStateCopyWith<EntryEditorState> get copyWith => _$EntryEditorStateCopyWithImpl<EntryEditorState>(this as EntryEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntryEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryEditorState&&(identical(other.openPlaceId, _this.openPlaceId) || other.openPlaceId == _this.openPlaceId)&&const DeepCollectionEquality().equals(other.drafts, _this.drafts)&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.replaceNext, _this.replaceNext) || other.replaceNext == _this.replaceNext));
}


@override
int get hashCode {
  final _this = this as EntryEditorState;
  return Object.hash(runtimeType,_this.openPlaceId,const DeepCollectionEquality().hash(_this.drafts),_this.field,_this.replaceNext);
}

@override
String toString() {
  final _this = this as EntryEditorState;
  return 'EntryEditorState(openPlaceId: ${_this.openPlaceId}, drafts: ${_this.drafts}, field: ${_this.field}, replaceNext: ${_this.replaceNext})';
}


}

/// @nodoc
abstract mixin class $EntryEditorStateCopyWith<$Res>  {
  factory $EntryEditorStateCopyWith(EntryEditorState value, $Res Function(EntryEditorState) _then) = _$EntryEditorStateCopyWithImpl;
@useResult
$Res call({
 int? openPlaceId, Map<int, List<String>> drafts, int field, bool replaceNext
});




}
/// @nodoc
class _$EntryEditorStateCopyWithImpl<$Res>
    implements $EntryEditorStateCopyWith<$Res> {
  _$EntryEditorStateCopyWithImpl(this._self, this._then);

  final EntryEditorState _self;
  final $Res Function(EntryEditorState) _then;

/// Create a copy of EntryEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openPlaceId = freezed,Object? drafts = null,Object? field = null,Object? replaceNext = null,}) {
  return _then(EntryEditorState(
openPlaceId: freezed == openPlaceId ? _self.openPlaceId : openPlaceId // ignore: cast_nullable_to_non_nullable
as int?,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<int, List<String>>,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as int,replaceNext: null == replaceNext ? _self.replaceNext : replaceNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryEditorState].
extension EntryEditorStatePatterns on EntryEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryEditorState value)  $default,){
final _that = this;
switch (_that) {
case _EntryEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EntryEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? openPlaceId,  Map<int, List<String>> drafts,  int field,  bool replaceNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryEditorState() when $default != null:
return $default(_that.openPlaceId,_that.drafts,_that.field,_that.replaceNext);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? openPlaceId,  Map<int, List<String>> drafts,  int field,  bool replaceNext)  $default,) {final _that = this;
switch (_that) {
case _EntryEditorState():
return $default(_that.openPlaceId,_that.drafts,_that.field,_that.replaceNext);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? openPlaceId,  Map<int, List<String>> drafts,  int field,  bool replaceNext)?  $default,) {final _that = this;
switch (_that) {
case _EntryEditorState() when $default != null:
return $default(_that.openPlaceId,_that.drafts,_that.field,_that.replaceNext);case _:
  return null;

}
}

}

/// @nodoc


class _EntryEditorState implements EntryEditorState {
  const _EntryEditorState({this.openPlaceId,  Map<int, List<String>> drafts = const <int, List<String>>{}, this.field = 0, this.replaceNext = true}): _drafts = drafts;
  

@override final  int? openPlaceId;
/// Par id de place : les trois champs, en chiffres tapés au pavé.
 final  Map<int, List<String>> _drafts;
/// Par id de place : les trois champs, en chiffres tapés au pavé.
@override@JsonKey() Map<int, List<String>> get drafts {
  if (_drafts is EqualUnmodifiableMapView) return _drafts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_drafts);
}

@override@JsonKey() final  int field;
/// Le champ vient d'être choisi : le prochain chiffre le remplace.
@override@JsonKey() final  bool replaceNext;

/// Create a copy of EntryEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryEditorStateCopyWith<_EntryEditorState> get copyWith => __$EntryEditorStateCopyWithImpl<_EntryEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryEditorState&&(identical(other.openPlaceId, openPlaceId) || other.openPlaceId == openPlaceId)&&const DeepCollectionEquality().equals(other.drafts, _drafts)&&(identical(other.field, field) || other.field == field)&&(identical(other.replaceNext, replaceNext) || other.replaceNext == replaceNext));
}


@override
int get hashCode {
    return Object.hash(runtimeType,openPlaceId,const DeepCollectionEquality().hash(_drafts),field,replaceNext);
}

@override
String toString() {
    return 'EntryEditorState(openPlaceId: $openPlaceId, drafts: $drafts, field: $field, replaceNext: $replaceNext)';
}


}

/// @nodoc
abstract mixin class _$EntryEditorStateCopyWith<$Res> implements $EntryEditorStateCopyWith<$Res> {
  factory _$EntryEditorStateCopyWith(_EntryEditorState value, $Res Function(_EntryEditorState) _then) = __$EntryEditorStateCopyWithImpl;
@override @useResult
$Res call({
 int? openPlaceId, Map<int, List<String>> drafts, int field, bool replaceNext
});




}
/// @nodoc
class __$EntryEditorStateCopyWithImpl<$Res>
    implements _$EntryEditorStateCopyWith<$Res> {
  __$EntryEditorStateCopyWithImpl(this._self, this._then);

  final _EntryEditorState _self;
  final $Res Function(_EntryEditorState) _then;

/// Create a copy of EntryEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openPlaceId = freezed,Object? drafts = null,Object? field = null,Object? replaceNext = null,}) {
  return _then(_EntryEditorState(
openPlaceId: freezed == openPlaceId ? _self.openPlaceId : openPlaceId // ignore: cast_nullable_to_non_nullable
as int?,drafts: null == drafts ? _self._drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<int, List<String>>,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as int,replaceNext: null == replaceNext ? _self.replaceNext : replaceNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
