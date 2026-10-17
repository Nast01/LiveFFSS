// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lane_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Performance {

 String? get time; String? get statusLabel; int? get timeHundredths; bool get isDisqualified; bool get isRecord; bool get isNationalRecord;
/// Create a copy of Performance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceCopyWith<Performance> get copyWith => _$PerformanceCopyWithImpl<Performance>(this as Performance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Performance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Performance&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.statusLabel, _this.statusLabel) || other.statusLabel == _this.statusLabel)&&(identical(other.timeHundredths, _this.timeHundredths) || other.timeHundredths == _this.timeHundredths)&&(identical(other.isDisqualified, _this.isDisqualified) || other.isDisqualified == _this.isDisqualified)&&(identical(other.isRecord, _this.isRecord) || other.isRecord == _this.isRecord)&&(identical(other.isNationalRecord, _this.isNationalRecord) || other.isNationalRecord == _this.isNationalRecord));
}


@override
int get hashCode {
  final _this = this as Performance;
  return Object.hash(runtimeType,_this.time,_this.statusLabel,_this.timeHundredths,_this.isDisqualified,_this.isRecord,_this.isNationalRecord);
}

@override
String toString() {
  final _this = this as Performance;
  return 'Performance(time: ${_this.time}, statusLabel: ${_this.statusLabel}, timeHundredths: ${_this.timeHundredths}, isDisqualified: ${_this.isDisqualified}, isRecord: ${_this.isRecord}, isNationalRecord: ${_this.isNationalRecord})';
}


}

/// @nodoc
abstract mixin class $PerformanceCopyWith<$Res>  {
  factory $PerformanceCopyWith(Performance value, $Res Function(Performance) _then) = _$PerformanceCopyWithImpl;
@useResult
$Res call({
 String? time, String? statusLabel, int? timeHundredths, bool isDisqualified, bool isRecord, bool isNationalRecord
});




}
/// @nodoc
class _$PerformanceCopyWithImpl<$Res>
    implements $PerformanceCopyWith<$Res> {
  _$PerformanceCopyWithImpl(this._self, this._then);

  final Performance _self;
  final $Res Function(Performance) _then;

/// Create a copy of Performance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = freezed,Object? statusLabel = freezed,Object? timeHundredths = freezed,Object? isDisqualified = null,Object? isRecord = null,Object? isNationalRecord = null,}) {
  return _then(Performance(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,timeHundredths: freezed == timeHundredths ? _self.timeHundredths : timeHundredths // ignore: cast_nullable_to_non_nullable
as int?,isDisqualified: null == isDisqualified ? _self.isDisqualified : isDisqualified // ignore: cast_nullable_to_non_nullable
as bool,isRecord: null == isRecord ? _self.isRecord : isRecord // ignore: cast_nullable_to_non_nullable
as bool,isNationalRecord: null == isNationalRecord ? _self.isNationalRecord : isNationalRecord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Performance].
extension PerformancePatterns on Performance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Performance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Performance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Performance value)  $default,){
final _that = this;
switch (_that) {
case _Performance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Performance value)?  $default,){
final _that = this;
switch (_that) {
case _Performance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? time,  String? statusLabel,  int? timeHundredths,  bool isDisqualified,  bool isRecord,  bool isNationalRecord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Performance() when $default != null:
return $default(_that.time,_that.statusLabel,_that.timeHundredths,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? time,  String? statusLabel,  int? timeHundredths,  bool isDisqualified,  bool isRecord,  bool isNationalRecord)  $default,) {final _that = this;
switch (_that) {
case _Performance():
return $default(_that.time,_that.statusLabel,_that.timeHundredths,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? time,  String? statusLabel,  int? timeHundredths,  bool isDisqualified,  bool isRecord,  bool isNationalRecord)?  $default,) {final _that = this;
switch (_that) {
case _Performance() when $default != null:
return $default(_that.time,_that.statusLabel,_that.timeHundredths,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
  return null;

}
}

}

/// @nodoc


class _Performance extends Performance {
  const _Performance({this.time, this.statusLabel, this.timeHundredths, this.isDisqualified = false, this.isRecord = false, this.isNationalRecord = false}): super._();
  

@override final  String? time;
@override final  String? statusLabel;
@override final  int? timeHundredths;
@override@JsonKey() final  bool isDisqualified;
@override@JsonKey() final  bool isRecord;
@override@JsonKey() final  bool isNationalRecord;

/// Create a copy of Performance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceCopyWith<_Performance> get copyWith => __$PerformanceCopyWithImpl<_Performance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Performance&&(identical(other.time, time) || other.time == time)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.timeHundredths, timeHundredths) || other.timeHundredths == timeHundredths)&&(identical(other.isDisqualified, isDisqualified) || other.isDisqualified == isDisqualified)&&(identical(other.isRecord, isRecord) || other.isRecord == isRecord)&&(identical(other.isNationalRecord, isNationalRecord) || other.isNationalRecord == isNationalRecord));
}


@override
int get hashCode {
    return Object.hash(runtimeType,time,statusLabel,timeHundredths,isDisqualified,isRecord,isNationalRecord);
}

@override
String toString() {
    return 'Performance(time: $time, statusLabel: $statusLabel, timeHundredths: $timeHundredths, isDisqualified: $isDisqualified, isRecord: $isRecord, isNationalRecord: $isNationalRecord)';
}


}

/// @nodoc
abstract mixin class _$PerformanceCopyWith<$Res> implements $PerformanceCopyWith<$Res> {
  factory _$PerformanceCopyWith(_Performance value, $Res Function(_Performance) _then) = __$PerformanceCopyWithImpl;
@override @useResult
$Res call({
 String? time, String? statusLabel, int? timeHundredths, bool isDisqualified, bool isRecord, bool isNationalRecord
});




}
/// @nodoc
class __$PerformanceCopyWithImpl<$Res>
    implements _$PerformanceCopyWith<$Res> {
  __$PerformanceCopyWithImpl(this._self, this._then);

  final _Performance _self;
  final $Res Function(_Performance) _then;

/// Create a copy of Performance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = freezed,Object? statusLabel = freezed,Object? timeHundredths = freezed,Object? isDisqualified = null,Object? isRecord = null,Object? isNationalRecord = null,}) {
  return _then(_Performance(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,timeHundredths: freezed == timeHundredths ? _self.timeHundredths : timeHundredths // ignore: cast_nullable_to_non_nullable
as int?,isDisqualified: null == isDisqualified ? _self.isDisqualified : isDisqualified // ignore: cast_nullable_to_non_nullable
as bool,isRecord: null == isRecord ? _self.isRecord : isRecord // ignore: cast_nullable_to_non_nullable
as bool,isNationalRecord: null == isNationalRecord ? _self.isNationalRecord : isNationalRecord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LaneAssignment {

/// Id FFSS de la place.
 int get id; int get lane; List<String> get athletes; String get club; String? get category; bool get forfeit; bool get isRelay; Performance? get performance;
/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaneAssignmentCopyWith<LaneAssignment> get copyWith => _$LaneAssignmentCopyWithImpl<LaneAssignment>(this as LaneAssignment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LaneAssignment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaneAssignment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lane, _this.lane) || other.lane == _this.lane)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.forfeit, _this.forfeit) || other.forfeit == _this.forfeit)&&(identical(other.isRelay, _this.isRelay) || other.isRelay == _this.isRelay)&&(identical(other.performance, _this.performance) || other.performance == _this.performance));
}


@override
int get hashCode {
  final _this = this as LaneAssignment;
  return Object.hash(runtimeType,_this.id,_this.lane,const DeepCollectionEquality().hash(_this.athletes),_this.club,_this.category,_this.forfeit,_this.isRelay,_this.performance);
}

@override
String toString() {
  final _this = this as LaneAssignment;
  return 'LaneAssignment(id: ${_this.id}, lane: ${_this.lane}, athletes: ${_this.athletes}, club: ${_this.club}, category: ${_this.category}, forfeit: ${_this.forfeit}, isRelay: ${_this.isRelay}, performance: ${_this.performance})';
}


}

/// @nodoc
abstract mixin class $LaneAssignmentCopyWith<$Res>  {
  factory $LaneAssignmentCopyWith(LaneAssignment value, $Res Function(LaneAssignment) _then) = _$LaneAssignmentCopyWithImpl;
@useResult
$Res call({
 int id, int lane, List<String> athletes, String club, String? category, bool forfeit, bool isRelay, Performance? performance
});


$PerformanceCopyWith<$Res>? get performance;

}
/// @nodoc
class _$LaneAssignmentCopyWithImpl<$Res>
    implements $LaneAssignmentCopyWith<$Res> {
  _$LaneAssignmentCopyWithImpl(this._self, this._then);

  final LaneAssignment _self;
  final $Res Function(LaneAssignment) _then;

/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lane = null,Object? athletes = null,Object? club = null,Object? category = freezed,Object? forfeit = null,Object? isRelay = null,Object? performance = freezed,}) {
  return _then(LaneAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<String>,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,forfeit: null == forfeit ? _self.forfeit : forfeit // ignore: cast_nullable_to_non_nullable
as bool,isRelay: null == isRelay ? _self.isRelay : isRelay // ignore: cast_nullable_to_non_nullable
as bool,performance: freezed == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as Performance?,
  ));
}
/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceCopyWith<$Res>? get performance {
    if (_self.performance == null) {
    return null;
  }

  return $PerformanceCopyWith<$Res>(_self.performance!, (value) {
    return _then(_self.copyWith(performance: value));
  });
}
}


/// Adds pattern-matching-related methods to [LaneAssignment].
extension LaneAssignmentPatterns on LaneAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaneAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaneAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaneAssignment value)  $default,){
final _that = this;
switch (_that) {
case _LaneAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaneAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _LaneAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lane,  List<String> athletes,  String club,  String? category,  bool forfeit,  bool isRelay,  Performance? performance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaneAssignment() when $default != null:
return $default(_that.id,_that.lane,_that.athletes,_that.club,_that.category,_that.forfeit,_that.isRelay,_that.performance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lane,  List<String> athletes,  String club,  String? category,  bool forfeit,  bool isRelay,  Performance? performance)  $default,) {final _that = this;
switch (_that) {
case _LaneAssignment():
return $default(_that.id,_that.lane,_that.athletes,_that.club,_that.category,_that.forfeit,_that.isRelay,_that.performance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lane,  List<String> athletes,  String club,  String? category,  bool forfeit,  bool isRelay,  Performance? performance)?  $default,) {final _that = this;
switch (_that) {
case _LaneAssignment() when $default != null:
return $default(_that.id,_that.lane,_that.athletes,_that.club,_that.category,_that.forfeit,_that.isRelay,_that.performance);case _:
  return null;

}
}

}

/// @nodoc


class _LaneAssignment extends LaneAssignment {
  const _LaneAssignment({required this.id, required this.lane,  List<String> athletes = const <String>[], this.club = '', this.category, this.forfeit = false, this.isRelay = false, this.performance}): _athletes = athletes,super._();
  

/// Id FFSS de la place.
@override final  int id;
@override final  int lane;
 final  List<String> _athletes;
@override@JsonKey() List<String> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

@override@JsonKey() final  String club;
@override final  String? category;
@override@JsonKey() final  bool forfeit;
@override@JsonKey() final  bool isRelay;
@override final  Performance? performance;

/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaneAssignmentCopyWith<_LaneAssignment> get copyWith => __$LaneAssignmentCopyWithImpl<_LaneAssignment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaneAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.lane, lane) || other.lane == lane)&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&(identical(other.club, club) || other.club == club)&&(identical(other.category, category) || other.category == category)&&(identical(other.forfeit, forfeit) || other.forfeit == forfeit)&&(identical(other.isRelay, isRelay) || other.isRelay == isRelay)&&(identical(other.performance, performance) || other.performance == performance));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,lane,const DeepCollectionEquality().hash(_athletes),club,category,forfeit,isRelay,performance);
}

@override
String toString() {
    return 'LaneAssignment(id: $id, lane: $lane, athletes: $athletes, club: $club, category: $category, forfeit: $forfeit, isRelay: $isRelay, performance: $performance)';
}


}

/// @nodoc
abstract mixin class _$LaneAssignmentCopyWith<$Res> implements $LaneAssignmentCopyWith<$Res> {
  factory _$LaneAssignmentCopyWith(_LaneAssignment value, $Res Function(_LaneAssignment) _then) = __$LaneAssignmentCopyWithImpl;
@override @useResult
$Res call({
 int id, int lane, List<String> athletes, String club, String? category, bool forfeit, bool isRelay, Performance? performance
});


@override $PerformanceCopyWith<$Res>? get performance;

}
/// @nodoc
class __$LaneAssignmentCopyWithImpl<$Res>
    implements _$LaneAssignmentCopyWith<$Res> {
  __$LaneAssignmentCopyWithImpl(this._self, this._then);

  final _LaneAssignment _self;
  final $Res Function(_LaneAssignment) _then;

/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lane = null,Object? athletes = null,Object? club = null,Object? category = freezed,Object? forfeit = null,Object? isRelay = null,Object? performance = freezed,}) {
  return _then(_LaneAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<String>,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,forfeit: null == forfeit ? _self.forfeit : forfeit // ignore: cast_nullable_to_non_nullable
as bool,isRelay: null == isRelay ? _self.isRelay : isRelay // ignore: cast_nullable_to_non_nullable
as bool,performance: freezed == performance ? _self.performance : performance // ignore: cast_nullable_to_non_nullable
as Performance?,
  ));
}

/// Create a copy of LaneAssignment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PerformanceCopyWith<$Res>? get performance {
    if (_self.performance == null) {
    return null;
  }

  return $PerformanceCopyWith<$Res>(_self.performance!, (value) {
    return _then(_self.copyWith(performance: value));
  });
}
}

// dart format on
