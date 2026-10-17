// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompetitionSummary {

 int get id; String get name; DateTime get startDate; DateTime get endDate; Set<Discipline> get disciplines; String? get organizer; String? get location;
/// Create a copy of CompetitionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionSummaryCopyWith<CompetitionSummary> get copyWith => _$CompetitionSummaryCopyWithImpl<CompetitionSummary>(this as CompetitionSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompetitionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&const DeepCollectionEquality().equals(other.disciplines, _this.disciplines)&&(identical(other.organizer, _this.organizer) || other.organizer == _this.organizer)&&(identical(other.location, _this.location) || other.location == _this.location));
}


@override
int get hashCode {
  final _this = this as CompetitionSummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.startDate,_this.endDate,const DeepCollectionEquality().hash(_this.disciplines),_this.organizer,_this.location);
}

@override
String toString() {
  final _this = this as CompetitionSummary;
  return 'CompetitionSummary(id: ${_this.id}, name: ${_this.name}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, disciplines: ${_this.disciplines}, organizer: ${_this.organizer}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $CompetitionSummaryCopyWith<$Res>  {
  factory $CompetitionSummaryCopyWith(CompetitionSummary value, $Res Function(CompetitionSummary) _then) = _$CompetitionSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, DateTime startDate, DateTime endDate, Set<Discipline> disciplines, String? organizer, String? location
});




}
/// @nodoc
class _$CompetitionSummaryCopyWithImpl<$Res>
    implements $CompetitionSummaryCopyWith<$Res> {
  _$CompetitionSummaryCopyWithImpl(this._self, this._then);

  final CompetitionSummary _self;
  final $Res Function(CompetitionSummary) _then;

/// Create a copy of CompetitionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? disciplines = null,Object? organizer = freezed,Object? location = freezed,}) {
  return _then(CompetitionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,disciplines: null == disciplines ? _self.disciplines : disciplines // ignore: cast_nullable_to_non_nullable
as Set<Discipline>,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompetitionSummary].
extension CompetitionSummaryPatterns on CompetitionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionSummary value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  DateTime startDate,  DateTime endDate,  Set<Discipline> disciplines,  String? organizer,  String? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionSummary() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.disciplines,_that.organizer,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  DateTime startDate,  DateTime endDate,  Set<Discipline> disciplines,  String? organizer,  String? location)  $default,) {final _that = this;
switch (_that) {
case _CompetitionSummary():
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.disciplines,_that.organizer,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  DateTime startDate,  DateTime endDate,  Set<Discipline> disciplines,  String? organizer,  String? location)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionSummary() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.disciplines,_that.organizer,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class _CompetitionSummary implements CompetitionSummary {
  const _CompetitionSummary({required this.id, required this.name, required this.startDate, required this.endDate, required  Set<Discipline> disciplines, this.organizer, this.location}): _disciplines = disciplines;
  

@override final  int id;
@override final  String name;
@override final  DateTime startDate;
@override final  DateTime endDate;
 final  Set<Discipline> _disciplines;
@override Set<Discipline> get disciplines {
  if (_disciplines is EqualUnmodifiableSetView) return _disciplines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_disciplines);
}

@override final  String? organizer;
@override final  String? location;

/// Create a copy of CompetitionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionSummaryCopyWith<_CompetitionSummary> get copyWith => __$CompetitionSummaryCopyWithImpl<_CompetitionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.disciplines, _disciplines)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,startDate,endDate,const DeepCollectionEquality().hash(_disciplines),organizer,location);
}

@override
String toString() {
    return 'CompetitionSummary(id: $id, name: $name, startDate: $startDate, endDate: $endDate, disciplines: $disciplines, organizer: $organizer, location: $location)';
}


}

/// @nodoc
abstract mixin class _$CompetitionSummaryCopyWith<$Res> implements $CompetitionSummaryCopyWith<$Res> {
  factory _$CompetitionSummaryCopyWith(_CompetitionSummary value, $Res Function(_CompetitionSummary) _then) = __$CompetitionSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DateTime startDate, DateTime endDate, Set<Discipline> disciplines, String? organizer, String? location
});




}
/// @nodoc
class __$CompetitionSummaryCopyWithImpl<$Res>
    implements _$CompetitionSummaryCopyWith<$Res> {
  __$CompetitionSummaryCopyWithImpl(this._self, this._then);

  final _CompetitionSummary _self;
  final $Res Function(_CompetitionSummary) _then;

/// Create a copy of CompetitionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? disciplines = null,Object? organizer = freezed,Object? location = freezed,}) {
  return _then(_CompetitionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,disciplines: null == disciplines ? _self._disciplines : disciplines // ignore: cast_nullable_to_non_nullable
as Set<Discipline>,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
