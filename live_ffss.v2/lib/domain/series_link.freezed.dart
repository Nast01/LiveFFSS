// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkedSeries {

 EventSeries get series; Heat get heat; EventRound get round;
/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkedSeriesCopyWith<LinkedSeries> get copyWith => _$LinkedSeriesCopyWithImpl<LinkedSeries>(this as LinkedSeries, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LinkedSeries;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkedSeries&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.heat, _this.heat) || other.heat == _this.heat)&&(identical(other.round, _this.round) || other.round == _this.round));
}


@override
int get hashCode {
  final _this = this as LinkedSeries;
  return Object.hash(runtimeType,_this.series,_this.heat,_this.round);
}

@override
String toString() {
  final _this = this as LinkedSeries;
  return 'LinkedSeries(series: ${_this.series}, heat: ${_this.heat}, round: ${_this.round})';
}


}

/// @nodoc
abstract mixin class $LinkedSeriesCopyWith<$Res>  {
  factory $LinkedSeriesCopyWith(LinkedSeries value, $Res Function(LinkedSeries) _then) = _$LinkedSeriesCopyWithImpl;
@useResult
$Res call({
 EventSeries series, Heat heat, EventRound round
});


$EventSeriesCopyWith<$Res> get series;$HeatCopyWith<$Res> get heat;

}
/// @nodoc
class _$LinkedSeriesCopyWithImpl<$Res>
    implements $LinkedSeriesCopyWith<$Res> {
  _$LinkedSeriesCopyWithImpl(this._self, this._then);

  final LinkedSeries _self;
  final $Res Function(LinkedSeries) _then;

/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? series = null,Object? heat = null,Object? round = null,}) {
  return _then(LinkedSeries(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as EventSeries,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as EventRound,
  ));
}
/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventSeriesCopyWith<$Res> get series {
  
  return $EventSeriesCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [LinkedSeries].
extension LinkedSeriesPatterns on LinkedSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkedSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkedSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkedSeries value)  $default,){
final _that = this;
switch (_that) {
case _LinkedSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkedSeries value)?  $default,){
final _that = this;
switch (_that) {
case _LinkedSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EventSeries series,  Heat heat,  EventRound round)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkedSeries() when $default != null:
return $default(_that.series,_that.heat,_that.round);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EventSeries series,  Heat heat,  EventRound round)  $default,) {final _that = this;
switch (_that) {
case _LinkedSeries():
return $default(_that.series,_that.heat,_that.round);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EventSeries series,  Heat heat,  EventRound round)?  $default,) {final _that = this;
switch (_that) {
case _LinkedSeries() when $default != null:
return $default(_that.series,_that.heat,_that.round);case _:
  return null;

}
}

}

/// @nodoc


class _LinkedSeries extends LinkedSeries {
  const _LinkedSeries({required this.series, required this.heat, required this.round}): super._();
  

@override final  EventSeries series;
@override final  Heat heat;
@override final  EventRound round;

/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkedSeriesCopyWith<_LinkedSeries> get copyWith => __$LinkedSeriesCopyWithImpl<_LinkedSeries>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkedSeries&&(identical(other.series, series) || other.series == series)&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.round, round) || other.round == round));
}


@override
int get hashCode {
    return Object.hash(runtimeType,series,heat,round);
}

@override
String toString() {
    return 'LinkedSeries(series: $series, heat: $heat, round: $round)';
}


}

/// @nodoc
abstract mixin class _$LinkedSeriesCopyWith<$Res> implements $LinkedSeriesCopyWith<$Res> {
  factory _$LinkedSeriesCopyWith(_LinkedSeries value, $Res Function(_LinkedSeries) _then) = __$LinkedSeriesCopyWithImpl;
@override @useResult
$Res call({
 EventSeries series, Heat heat, EventRound round
});


@override $EventSeriesCopyWith<$Res> get series;@override $HeatCopyWith<$Res> get heat;

}
/// @nodoc
class __$LinkedSeriesCopyWithImpl<$Res>
    implements _$LinkedSeriesCopyWith<$Res> {
  __$LinkedSeriesCopyWithImpl(this._self, this._then);

  final _LinkedSeries _self;
  final $Res Function(_LinkedSeries) _then;

/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? series = null,Object? heat = null,Object? round = null,}) {
  return _then(_LinkedSeries(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as EventSeries,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as EventRound,
  ));
}

/// Create a copy of LinkedSeries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventSeriesCopyWith<$Res> get series {
  
  return $EventSeriesCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of LinkedSeries
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
