// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'programme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Programme {

 List<Meeting> get meetings; List<Progression> get progressions;
/// Create a copy of Programme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgrammeCopyWith<Programme> get copyWith => _$ProgrammeCopyWithImpl<Programme>(this as Programme, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Programme;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Programme&&const DeepCollectionEquality().equals(other.meetings, _this.meetings)&&const DeepCollectionEquality().equals(other.progressions, _this.progressions));
}


@override
int get hashCode {
  final _this = this as Programme;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.meetings),const DeepCollectionEquality().hash(_this.progressions));
}

@override
String toString() {
  final _this = this as Programme;
  return 'Programme(meetings: ${_this.meetings}, progressions: ${_this.progressions})';
}


}

/// @nodoc
abstract mixin class $ProgrammeCopyWith<$Res>  {
  factory $ProgrammeCopyWith(Programme value, $Res Function(Programme) _then) = _$ProgrammeCopyWithImpl;
@useResult
$Res call({
 List<Meeting> meetings, List<Progression> progressions
});




}
/// @nodoc
class _$ProgrammeCopyWithImpl<$Res>
    implements $ProgrammeCopyWith<$Res> {
  _$ProgrammeCopyWithImpl(this._self, this._then);

  final Programme _self;
  final $Res Function(Programme) _then;

/// Create a copy of Programme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meetings = null,Object? progressions = null,}) {
  return _then(Programme(
meetings: null == meetings ? _self.meetings : meetings // ignore: cast_nullable_to_non_nullable
as List<Meeting>,progressions: null == progressions ? _self.progressions : progressions // ignore: cast_nullable_to_non_nullable
as List<Progression>,
  ));
}

}


/// Adds pattern-matching-related methods to [Programme].
extension ProgrammePatterns on Programme {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Programme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Programme() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Programme value)  $default,){
final _that = this;
switch (_that) {
case _Programme():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Programme value)?  $default,){
final _that = this;
switch (_that) {
case _Programme() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Meeting> meetings,  List<Progression> progressions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Programme() when $default != null:
return $default(_that.meetings,_that.progressions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Meeting> meetings,  List<Progression> progressions)  $default,) {final _that = this;
switch (_that) {
case _Programme():
return $default(_that.meetings,_that.progressions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Meeting> meetings,  List<Progression> progressions)?  $default,) {final _that = this;
switch (_that) {
case _Programme() when $default != null:
return $default(_that.meetings,_that.progressions);case _:
  return null;

}
}

}

/// @nodoc


class _Programme extends Programme {
  const _Programme({ List<Meeting> meetings = const <Meeting>[],  List<Progression> progressions = const <Progression>[]}): _meetings = meetings,_progressions = progressions,super._();
  

 final  List<Meeting> _meetings;
@override@JsonKey() List<Meeting> get meetings {
  if (_meetings is EqualUnmodifiableListView) return _meetings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meetings);
}

 final  List<Progression> _progressions;
@override@JsonKey() List<Progression> get progressions {
  if (_progressions is EqualUnmodifiableListView) return _progressions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_progressions);
}


/// Create a copy of Programme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgrammeCopyWith<_Programme> get copyWith => __$ProgrammeCopyWithImpl<_Programme>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Programme&&const DeepCollectionEquality().equals(other.meetings, _meetings)&&const DeepCollectionEquality().equals(other.progressions, _progressions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_meetings),const DeepCollectionEquality().hash(_progressions));
}

@override
String toString() {
    return 'Programme(meetings: $meetings, progressions: $progressions)';
}


}

/// @nodoc
abstract mixin class _$ProgrammeCopyWith<$Res> implements $ProgrammeCopyWith<$Res> {
  factory _$ProgrammeCopyWith(_Programme value, $Res Function(_Programme) _then) = __$ProgrammeCopyWithImpl;
@override @useResult
$Res call({
 List<Meeting> meetings, List<Progression> progressions
});




}
/// @nodoc
class __$ProgrammeCopyWithImpl<$Res>
    implements _$ProgrammeCopyWith<$Res> {
  __$ProgrammeCopyWithImpl(this._self, this._then);

  final _Programme _self;
  final $Res Function(_Programme) _then;

/// Create a copy of Programme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meetings = null,Object? progressions = null,}) {
  return _then(_Programme(
meetings: null == meetings ? _self._meetings : meetings // ignore: cast_nullable_to_non_nullable
as List<Meeting>,progressions: null == progressions ? _self._progressions : progressions // ignore: cast_nullable_to_non_nullable
as List<Progression>,
  ));
}


}

// dart format on
