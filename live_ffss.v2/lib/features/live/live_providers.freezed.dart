// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiveView {

 List<Meeting> get meetings; List<LiveEntry> get running; List<LiveEntry> get recent;/// Par id de place. Une valeur nulle est une place vide ; une clé absente,
/// une place jamais lue.
 Map<int, LaneAssignment?> get lanes;
/// Create a copy of LiveView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveViewCopyWith<LiveView> get copyWith => _$LiveViewCopyWithImpl<LiveView>(this as LiveView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveView&&const DeepCollectionEquality().equals(other.meetings, _this.meetings)&&const DeepCollectionEquality().equals(other.running, _this.running)&&const DeepCollectionEquality().equals(other.recent, _this.recent)&&const DeepCollectionEquality().equals(other.lanes, _this.lanes));
}


@override
int get hashCode {
  final _this = this as LiveView;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.meetings),const DeepCollectionEquality().hash(_this.running),const DeepCollectionEquality().hash(_this.recent),const DeepCollectionEquality().hash(_this.lanes));
}

@override
String toString() {
  final _this = this as LiveView;
  return 'LiveView(meetings: ${_this.meetings}, running: ${_this.running}, recent: ${_this.recent}, lanes: ${_this.lanes})';
}


}

/// @nodoc
abstract mixin class $LiveViewCopyWith<$Res>  {
  factory $LiveViewCopyWith(LiveView value, $Res Function(LiveView) _then) = _$LiveViewCopyWithImpl;
@useResult
$Res call({
 List<Meeting> meetings, List<LiveEntry> running, List<LiveEntry> recent, Map<int, LaneAssignment?> lanes
});




}
/// @nodoc
class _$LiveViewCopyWithImpl<$Res>
    implements $LiveViewCopyWith<$Res> {
  _$LiveViewCopyWithImpl(this._self, this._then);

  final LiveView _self;
  final $Res Function(LiveView) _then;

/// Create a copy of LiveView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meetings = null,Object? running = null,Object? recent = null,Object? lanes = null,}) {
  return _then(LiveView(
meetings: null == meetings ? _self.meetings : meetings // ignore: cast_nullable_to_non_nullable
as List<Meeting>,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as List<LiveEntry>,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<LiveEntry>,lanes: null == lanes ? _self.lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveView].
extension LiveViewPatterns on LiveView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveView value)  $default,){
final _that = this;
switch (_that) {
case _LiveView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveView value)?  $default,){
final _that = this;
switch (_that) {
case _LiveView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Meeting> meetings,  List<LiveEntry> running,  List<LiveEntry> recent,  Map<int, LaneAssignment?> lanes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveView() when $default != null:
return $default(_that.meetings,_that.running,_that.recent,_that.lanes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Meeting> meetings,  List<LiveEntry> running,  List<LiveEntry> recent,  Map<int, LaneAssignment?> lanes)  $default,) {final _that = this;
switch (_that) {
case _LiveView():
return $default(_that.meetings,_that.running,_that.recent,_that.lanes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Meeting> meetings,  List<LiveEntry> running,  List<LiveEntry> recent,  Map<int, LaneAssignment?> lanes)?  $default,) {final _that = this;
switch (_that) {
case _LiveView() when $default != null:
return $default(_that.meetings,_that.running,_that.recent,_that.lanes);case _:
  return null;

}
}

}

/// @nodoc


class _LiveView extends LiveView {
  const _LiveView({required  List<Meeting> meetings, required  List<LiveEntry> running, required  List<LiveEntry> recent,  Map<int, LaneAssignment?> lanes = const <int, LaneAssignment?>{}}): _meetings = meetings,_running = running,_recent = recent,_lanes = lanes,super._();
  

 final  List<Meeting> _meetings;
@override List<Meeting> get meetings {
  if (_meetings is EqualUnmodifiableListView) return _meetings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meetings);
}

 final  List<LiveEntry> _running;
@override List<LiveEntry> get running {
  if (_running is EqualUnmodifiableListView) return _running;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_running);
}

 final  List<LiveEntry> _recent;
@override List<LiveEntry> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}

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


/// Create a copy of LiveView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveViewCopyWith<_LiveView> get copyWith => __$LiveViewCopyWithImpl<_LiveView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveView&&const DeepCollectionEquality().equals(other.meetings, _meetings)&&const DeepCollectionEquality().equals(other.running, _running)&&const DeepCollectionEquality().equals(other.recent, _recent)&&const DeepCollectionEquality().equals(other.lanes, _lanes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_meetings),const DeepCollectionEquality().hash(_running),const DeepCollectionEquality().hash(_recent),const DeepCollectionEquality().hash(_lanes));
}

@override
String toString() {
    return 'LiveView(meetings: $meetings, running: $running, recent: $recent, lanes: $lanes)';
}


}

/// @nodoc
abstract mixin class _$LiveViewCopyWith<$Res> implements $LiveViewCopyWith<$Res> {
  factory _$LiveViewCopyWith(_LiveView value, $Res Function(_LiveView) _then) = __$LiveViewCopyWithImpl;
@override @useResult
$Res call({
 List<Meeting> meetings, List<LiveEntry> running, List<LiveEntry> recent, Map<int, LaneAssignment?> lanes
});




}
/// @nodoc
class __$LiveViewCopyWithImpl<$Res>
    implements _$LiveViewCopyWith<$Res> {
  __$LiveViewCopyWithImpl(this._self, this._then);

  final _LiveView _self;
  final $Res Function(_LiveView) _then;

/// Create a copy of LiveView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meetings = null,Object? running = null,Object? recent = null,Object? lanes = null,}) {
  return _then(_LiveView(
meetings: null == meetings ? _self._meetings : meetings // ignore: cast_nullable_to_non_nullable
as List<Meeting>,running: null == running ? _self._running : running // ignore: cast_nullable_to_non_nullable
as List<LiveEntry>,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<LiveEntry>,lanes: null == lanes ? _self._lanes : lanes // ignore: cast_nullable_to_non_nullable
as Map<int, LaneAssignment?>,
  ));
}


}

// dart format on
