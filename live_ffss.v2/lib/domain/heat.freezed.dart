// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Heat {

 int get id; String get name; int get number; RunStatus get status; DateTime? get plannedStart; DateTime? get plannedEnd; int? get raceId; String get raceName; Gender? get gender;/// Ids FFSS des places, dans l'ordre des couloirs.
 List<int> get placeIds;/// Nul tant que la série n'est pas générée (finale à venir).
 int? get seriesId;
/// Create a copy of Heat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeatCopyWith<Heat> get copyWith => _$HeatCopyWithImpl<Heat>(this as Heat, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Heat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Heat&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.plannedStart, _this.plannedStart) || other.plannedStart == _this.plannedStart)&&(identical(other.plannedEnd, _this.plannedEnd) || other.plannedEnd == _this.plannedEnd)&&(identical(other.raceId, _this.raceId) || other.raceId == _this.raceId)&&(identical(other.raceName, _this.raceName) || other.raceName == _this.raceName)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&const DeepCollectionEquality().equals(other.placeIds, _this.placeIds)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId));
}


@override
int get hashCode {
  final _this = this as Heat;
  return Object.hash(runtimeType,_this.id,_this.name,_this.number,_this.status,_this.plannedStart,_this.plannedEnd,_this.raceId,_this.raceName,_this.gender,const DeepCollectionEquality().hash(_this.placeIds),_this.seriesId);
}

@override
String toString() {
  final _this = this as Heat;
  return 'Heat(id: ${_this.id}, name: ${_this.name}, number: ${_this.number}, status: ${_this.status}, plannedStart: ${_this.plannedStart}, plannedEnd: ${_this.plannedEnd}, raceId: ${_this.raceId}, raceName: ${_this.raceName}, gender: ${_this.gender}, placeIds: ${_this.placeIds}, seriesId: ${_this.seriesId})';
}


}

/// @nodoc
abstract mixin class $HeatCopyWith<$Res>  {
  factory $HeatCopyWith(Heat value, $Res Function(Heat) _then) = _$HeatCopyWithImpl;
@useResult
$Res call({
 int id, String name, int number, RunStatus status, DateTime? plannedStart, DateTime? plannedEnd, int? raceId, String raceName, Gender? gender, List<int> placeIds, int? seriesId
});




}
/// @nodoc
class _$HeatCopyWithImpl<$Res>
    implements $HeatCopyWith<$Res> {
  _$HeatCopyWithImpl(this._self, this._then);

  final Heat _self;
  final $Res Function(Heat) _then;

/// Create a copy of Heat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? number = null,Object? status = null,Object? plannedStart = freezed,Object? plannedEnd = freezed,Object? raceId = freezed,Object? raceName = null,Object? gender = freezed,Object? placeIds = null,Object? seriesId = freezed,}) {
  return _then(Heat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunStatus,plannedStart: freezed == plannedStart ? _self.plannedStart : plannedStart // ignore: cast_nullable_to_non_nullable
as DateTime?,plannedEnd: freezed == plannedEnd ? _self.plannedEnd : plannedEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,raceId: freezed == raceId ? _self.raceId : raceId // ignore: cast_nullable_to_non_nullable
as int?,raceName: null == raceName ? _self.raceName : raceName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,placeIds: null == placeIds ? _self.placeIds : placeIds // ignore: cast_nullable_to_non_nullable
as List<int>,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Heat].
extension HeatPatterns on Heat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Heat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Heat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Heat value)  $default,){
final _that = this;
switch (_that) {
case _Heat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Heat value)?  $default,){
final _that = this;
switch (_that) {
case _Heat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int number,  RunStatus status,  DateTime? plannedStart,  DateTime? plannedEnd,  int? raceId,  String raceName,  Gender? gender,  List<int> placeIds,  int? seriesId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Heat() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.status,_that.plannedStart,_that.plannedEnd,_that.raceId,_that.raceName,_that.gender,_that.placeIds,_that.seriesId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int number,  RunStatus status,  DateTime? plannedStart,  DateTime? plannedEnd,  int? raceId,  String raceName,  Gender? gender,  List<int> placeIds,  int? seriesId)  $default,) {final _that = this;
switch (_that) {
case _Heat():
return $default(_that.id,_that.name,_that.number,_that.status,_that.plannedStart,_that.plannedEnd,_that.raceId,_that.raceName,_that.gender,_that.placeIds,_that.seriesId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int number,  RunStatus status,  DateTime? plannedStart,  DateTime? plannedEnd,  int? raceId,  String raceName,  Gender? gender,  List<int> placeIds,  int? seriesId)?  $default,) {final _that = this;
switch (_that) {
case _Heat() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.status,_that.plannedStart,_that.plannedEnd,_that.raceId,_that.raceName,_that.gender,_that.placeIds,_that.seriesId);case _:
  return null;

}
}

}

/// @nodoc


class _Heat implements Heat {
  const _Heat({required this.id, required this.name, required this.number, required this.status, this.plannedStart, this.plannedEnd, this.raceId, this.raceName = '', this.gender,  List<int> placeIds = const <int>[], this.seriesId}): _placeIds = placeIds;
  

@override final  int id;
@override final  String name;
@override final  int number;
@override final  RunStatus status;
@override final  DateTime? plannedStart;
@override final  DateTime? plannedEnd;
@override final  int? raceId;
@override@JsonKey() final  String raceName;
@override final  Gender? gender;
/// Ids FFSS des places, dans l'ordre des couloirs.
 final  List<int> _placeIds;
/// Ids FFSS des places, dans l'ordre des couloirs.
@override@JsonKey() List<int> get placeIds {
  if (_placeIds is EqualUnmodifiableListView) return _placeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_placeIds);
}

/// Nul tant que la série n'est pas générée (finale à venir).
@override final  int? seriesId;

/// Create a copy of Heat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeatCopyWith<_Heat> get copyWith => __$HeatCopyWithImpl<_Heat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Heat&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.status, status) || other.status == status)&&(identical(other.plannedStart, plannedStart) || other.plannedStart == plannedStart)&&(identical(other.plannedEnd, plannedEnd) || other.plannedEnd == plannedEnd)&&(identical(other.raceId, raceId) || other.raceId == raceId)&&(identical(other.raceName, raceName) || other.raceName == raceName)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.placeIds, _placeIds)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,number,status,plannedStart,plannedEnd,raceId,raceName,gender,const DeepCollectionEquality().hash(_placeIds),seriesId);
}

@override
String toString() {
    return 'Heat(id: $id, name: $name, number: $number, status: $status, plannedStart: $plannedStart, plannedEnd: $plannedEnd, raceId: $raceId, raceName: $raceName, gender: $gender, placeIds: $placeIds, seriesId: $seriesId)';
}


}

/// @nodoc
abstract mixin class _$HeatCopyWith<$Res> implements $HeatCopyWith<$Res> {
  factory _$HeatCopyWith(_Heat value, $Res Function(_Heat) _then) = __$HeatCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int number, RunStatus status, DateTime? plannedStart, DateTime? plannedEnd, int? raceId, String raceName, Gender? gender, List<int> placeIds, int? seriesId
});




}
/// @nodoc
class __$HeatCopyWithImpl<$Res>
    implements _$HeatCopyWith<$Res> {
  __$HeatCopyWithImpl(this._self, this._then);

  final _Heat _self;
  final $Res Function(_Heat) _then;

/// Create a copy of Heat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? number = null,Object? status = null,Object? plannedStart = freezed,Object? plannedEnd = freezed,Object? raceId = freezed,Object? raceName = null,Object? gender = freezed,Object? placeIds = null,Object? seriesId = freezed,}) {
  return _then(_Heat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunStatus,plannedStart: freezed == plannedStart ? _self.plannedStart : plannedStart // ignore: cast_nullable_to_non_nullable
as DateTime?,plannedEnd: freezed == plannedEnd ? _self.plannedEnd : plannedEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,raceId: freezed == raceId ? _self.raceId : raceId // ignore: cast_nullable_to_non_nullable
as int?,raceName: null == raceName ? _self.raceName : raceName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,placeIds: null == placeIds ? _self._placeIds : placeIds // ignore: cast_nullable_to_non_nullable
as List<int>,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
