// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'now_running.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NowRunning {

 Heat get heat; NowRunningKind get kind; int get position; int get total;
/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowRunningCopyWith<NowRunning> get copyWith => _$NowRunningCopyWithImpl<NowRunning>(this as NowRunning, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowRunning&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.position, position) || other.position == position)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,heat,kind,position,total);

@override
String toString() {
  return 'NowRunning(heat: $heat, kind: $kind, position: $position, total: $total)';
}


}

/// @nodoc
abstract mixin class $NowRunningCopyWith<$Res>  {
  factory $NowRunningCopyWith(NowRunning value, $Res Function(NowRunning) _then) = _$NowRunningCopyWithImpl;
@useResult
$Res call({
 Heat heat, NowRunningKind kind, int position, int total
});


$HeatCopyWith<$Res> get heat;

}
/// @nodoc
class _$NowRunningCopyWithImpl<$Res>
    implements $NowRunningCopyWith<$Res> {
  _$NowRunningCopyWithImpl(this._self, this._then);

  final NowRunning _self;
  final $Res Function(NowRunning) _then;

/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heat = null,Object? kind = null,Object? position = null,Object? total = null,}) {
  return _then(_self.copyWith(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NowRunningKind,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [NowRunning].
extension NowRunningPatterns on NowRunning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NowRunning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NowRunning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NowRunning value)  $default,){
final _that = this;
switch (_that) {
case _NowRunning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NowRunning value)?  $default,){
final _that = this;
switch (_that) {
case _NowRunning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Heat heat,  NowRunningKind kind,  int position,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NowRunning() when $default != null:
return $default(_that.heat,_that.kind,_that.position,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Heat heat,  NowRunningKind kind,  int position,  int total)  $default,) {final _that = this;
switch (_that) {
case _NowRunning():
return $default(_that.heat,_that.kind,_that.position,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Heat heat,  NowRunningKind kind,  int position,  int total)?  $default,) {final _that = this;
switch (_that) {
case _NowRunning() when $default != null:
return $default(_that.heat,_that.kind,_that.position,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _NowRunning implements NowRunning {
  const _NowRunning({required this.heat, required this.kind, required this.position, required this.total});
  

@override final  Heat heat;
@override final  NowRunningKind kind;
@override final  int position;
@override final  int total;

/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NowRunningCopyWith<_NowRunning> get copyWith => __$NowRunningCopyWithImpl<_NowRunning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NowRunning&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.position, position) || other.position == position)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,heat,kind,position,total);

@override
String toString() {
  return 'NowRunning(heat: $heat, kind: $kind, position: $position, total: $total)';
}


}

/// @nodoc
abstract mixin class _$NowRunningCopyWith<$Res> implements $NowRunningCopyWith<$Res> {
  factory _$NowRunningCopyWith(_NowRunning value, $Res Function(_NowRunning) _then) = __$NowRunningCopyWithImpl;
@override @useResult
$Res call({
 Heat heat, NowRunningKind kind, int position, int total
});


@override $HeatCopyWith<$Res> get heat;

}
/// @nodoc
class __$NowRunningCopyWithImpl<$Res>
    implements _$NowRunningCopyWith<$Res> {
  __$NowRunningCopyWithImpl(this._self, this._then);

  final _NowRunning _self;
  final $Res Function(_NowRunning) _then;

/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heat = null,Object? kind = null,Object? position = null,Object? total = null,}) {
  return _then(_NowRunning(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NowRunningKind,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of NowRunning
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}

// dart format on
