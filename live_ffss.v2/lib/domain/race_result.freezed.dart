// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RaceResult {

/// Nul tant que le résultat n'existe pas : l'envoi le crée.
 int? get id; int get seriesId; int get entryId;/// `Temps` : le temps du juge, en centièmes. Jamais modifié par la saisie.
 int? get time;/// `TempsLive1..3` : les trois chronos, en centièmes ; nul = pas de chrono.
 List<int?> get chronos; int? get rank;/// 0 = OK, 1 = disqualifié, 2 = forfait, 3 = « F/DQ » (valeur de repli de
/// FFSS quand l'envoi n'indique pas de statut).
 int get status;/// Le code de disqualification, ou `F` pour un forfait.
 String get complement; int? get points;
/// Create a copy of RaceResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaceResultCopyWith<RaceResult> get copyWith => _$RaceResultCopyWithImpl<RaceResult>(this as RaceResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RaceResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaceResult&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.time, _this.time) || other.time == _this.time)&&const DeepCollectionEquality().equals(other.chronos, _this.chronos)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.complement, _this.complement) || other.complement == _this.complement)&&(identical(other.points, _this.points) || other.points == _this.points));
}


@override
int get hashCode {
  final _this = this as RaceResult;
  return Object.hash(runtimeType,_this.id,_this.seriesId,_this.entryId,_this.time,const DeepCollectionEquality().hash(_this.chronos),_this.rank,_this.status,_this.complement,_this.points);
}

@override
String toString() {
  final _this = this as RaceResult;
  return 'RaceResult(id: ${_this.id}, seriesId: ${_this.seriesId}, entryId: ${_this.entryId}, time: ${_this.time}, chronos: ${_this.chronos}, rank: ${_this.rank}, status: ${_this.status}, complement: ${_this.complement}, points: ${_this.points})';
}


}

/// @nodoc
abstract mixin class $RaceResultCopyWith<$Res>  {
  factory $RaceResultCopyWith(RaceResult value, $Res Function(RaceResult) _then) = _$RaceResultCopyWithImpl;
@useResult
$Res call({
 int? id, int seriesId, int entryId, int? time, List<int?> chronos, int? rank, int status, String complement, int? points
});




}
/// @nodoc
class _$RaceResultCopyWithImpl<$Res>
    implements $RaceResultCopyWith<$Res> {
  _$RaceResultCopyWithImpl(this._self, this._then);

  final RaceResult _self;
  final $Res Function(RaceResult) _then;

/// Create a copy of RaceResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? seriesId = null,Object? entryId = null,Object? time = freezed,Object? chronos = null,Object? rank = freezed,Object? status = null,Object? complement = null,Object? points = freezed,}) {
  return _then(RaceResult(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,chronos: null == chronos ? _self.chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,complement: null == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RaceResult].
extension RaceResultPatterns on RaceResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaceResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaceResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaceResult value)  $default,){
final _that = this;
switch (_that) {
case _RaceResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaceResult value)?  $default,){
final _that = this;
switch (_that) {
case _RaceResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int seriesId,  int entryId,  int? time,  List<int?> chronos,  int? rank,  int status,  String complement,  int? points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaceResult() when $default != null:
return $default(_that.id,_that.seriesId,_that.entryId,_that.time,_that.chronos,_that.rank,_that.status,_that.complement,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int seriesId,  int entryId,  int? time,  List<int?> chronos,  int? rank,  int status,  String complement,  int? points)  $default,) {final _that = this;
switch (_that) {
case _RaceResult():
return $default(_that.id,_that.seriesId,_that.entryId,_that.time,_that.chronos,_that.rank,_that.status,_that.complement,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int seriesId,  int entryId,  int? time,  List<int?> chronos,  int? rank,  int status,  String complement,  int? points)?  $default,) {final _that = this;
switch (_that) {
case _RaceResult() when $default != null:
return $default(_that.id,_that.seriesId,_that.entryId,_that.time,_that.chronos,_that.rank,_that.status,_that.complement,_that.points);case _:
  return null;

}
}

}

/// @nodoc


class _RaceResult implements RaceResult {
  const _RaceResult({this.id, required this.seriesId, required this.entryId, this.time,  List<int?> chronos = const <int?>[null, null, null], this.rank, this.status = 0, this.complement = '', this.points}): _chronos = chronos;
  

/// Nul tant que le résultat n'existe pas : l'envoi le crée.
@override final  int? id;
@override final  int seriesId;
@override final  int entryId;
/// `Temps` : le temps du juge, en centièmes. Jamais modifié par la saisie.
@override final  int? time;
/// `TempsLive1..3` : les trois chronos, en centièmes ; nul = pas de chrono.
 final  List<int?> _chronos;
/// `TempsLive1..3` : les trois chronos, en centièmes ; nul = pas de chrono.
@override@JsonKey() List<int?> get chronos {
  if (_chronos is EqualUnmodifiableListView) return _chronos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chronos);
}

@override final  int? rank;
/// 0 = OK, 1 = disqualifié, 2 = forfait, 3 = « F/DQ » (valeur de repli de
/// FFSS quand l'envoi n'indique pas de statut).
@override@JsonKey() final  int status;
/// Le code de disqualification, ou `F` pour un forfait.
@override@JsonKey() final  String complement;
@override final  int? points;

/// Create a copy of RaceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaceResultCopyWith<_RaceResult> get copyWith => __$RaceResultCopyWithImpl<_RaceResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaceResult&&(identical(other.id, id) || other.id == id)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.time, time) || other.time == time)&&const DeepCollectionEquality().equals(other.chronos, _chronos)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.status, status) || other.status == status)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.points, points) || other.points == points));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,seriesId,entryId,time,const DeepCollectionEquality().hash(_chronos),rank,status,complement,points);
}

@override
String toString() {
    return 'RaceResult(id: $id, seriesId: $seriesId, entryId: $entryId, time: $time, chronos: $chronos, rank: $rank, status: $status, complement: $complement, points: $points)';
}


}

/// @nodoc
abstract mixin class _$RaceResultCopyWith<$Res> implements $RaceResultCopyWith<$Res> {
  factory _$RaceResultCopyWith(_RaceResult value, $Res Function(_RaceResult) _then) = __$RaceResultCopyWithImpl;
@override @useResult
$Res call({
 int? id, int seriesId, int entryId, int? time, List<int?> chronos, int? rank, int status, String complement, int? points
});




}
/// @nodoc
class __$RaceResultCopyWithImpl<$Res>
    implements _$RaceResultCopyWith<$Res> {
  __$RaceResultCopyWithImpl(this._self, this._then);

  final _RaceResult _self;
  final $Res Function(_RaceResult) _then;

/// Create a copy of RaceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? seriesId = null,Object? entryId = null,Object? time = freezed,Object? chronos = null,Object? rank = freezed,Object? status = null,Object? complement = null,Object? points = freezed,}) {
  return _then(_RaceResult(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,chronos: null == chronos ? _self._chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,complement: null == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ResultChange {

/// Remplace les trois chronos d'un coup.
 List<int?>? get chronos; ResultMark? get mark;/// Le code de disqualification, pour [ResultMark.disqualified].
 String? get code;
/// Create a copy of ResultChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultChangeCopyWith<ResultChange> get copyWith => _$ResultChangeCopyWithImpl<ResultChange>(this as ResultChange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResultChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultChange&&const DeepCollectionEquality().equals(other.chronos, _this.chronos)&&(identical(other.mark, _this.mark) || other.mark == _this.mark)&&(identical(other.code, _this.code) || other.code == _this.code));
}


@override
int get hashCode {
  final _this = this as ResultChange;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.chronos),_this.mark,_this.code);
}

@override
String toString() {
  final _this = this as ResultChange;
  return 'ResultChange(chronos: ${_this.chronos}, mark: ${_this.mark}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $ResultChangeCopyWith<$Res>  {
  factory $ResultChangeCopyWith(ResultChange value, $Res Function(ResultChange) _then) = _$ResultChangeCopyWithImpl;
@useResult
$Res call({
 List<int?>? chronos, ResultMark? mark, String? code
});




}
/// @nodoc
class _$ResultChangeCopyWithImpl<$Res>
    implements $ResultChangeCopyWith<$Res> {
  _$ResultChangeCopyWithImpl(this._self, this._then);

  final ResultChange _self;
  final $Res Function(ResultChange) _then;

/// Create a copy of ResultChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chronos = freezed,Object? mark = freezed,Object? code = freezed,}) {
  return _then(ResultChange(
chronos: freezed == chronos ? _self.chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>?,mark: freezed == mark ? _self.mark : mark // ignore: cast_nullable_to_non_nullable
as ResultMark?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultChange].
extension ResultChangePatterns on ResultChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultChange value)  $default,){
final _that = this;
switch (_that) {
case _ResultChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultChange value)?  $default,){
final _that = this;
switch (_that) {
case _ResultChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int?>? chronos,  ResultMark? mark,  String? code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultChange() when $default != null:
return $default(_that.chronos,_that.mark,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int?>? chronos,  ResultMark? mark,  String? code)  $default,) {final _that = this;
switch (_that) {
case _ResultChange():
return $default(_that.chronos,_that.mark,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int?>? chronos,  ResultMark? mark,  String? code)?  $default,) {final _that = this;
switch (_that) {
case _ResultChange() when $default != null:
return $default(_that.chronos,_that.mark,_that.code);case _:
  return null;

}
}

}

/// @nodoc


class _ResultChange implements ResultChange {
  const _ResultChange({ List<int?>? chronos, this.mark, this.code}): _chronos = chronos;
  

/// Remplace les trois chronos d'un coup.
 final  List<int?>? _chronos;
/// Remplace les trois chronos d'un coup.
@override List<int?>? get chronos {
  final value = _chronos;
  if (value == null) return null;
  if (_chronos is EqualUnmodifiableListView) return _chronos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  ResultMark? mark;
/// Le code de disqualification, pour [ResultMark.disqualified].
@override final  String? code;

/// Create a copy of ResultChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultChangeCopyWith<_ResultChange> get copyWith => __$ResultChangeCopyWithImpl<_ResultChange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultChange&&const DeepCollectionEquality().equals(other.chronos, _chronos)&&(identical(other.mark, mark) || other.mark == mark)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_chronos),mark,code);
}

@override
String toString() {
    return 'ResultChange(chronos: $chronos, mark: $mark, code: $code)';
}


}

/// @nodoc
abstract mixin class _$ResultChangeCopyWith<$Res> implements $ResultChangeCopyWith<$Res> {
  factory _$ResultChangeCopyWith(_ResultChange value, $Res Function(_ResultChange) _then) = __$ResultChangeCopyWithImpl;
@override @useResult
$Res call({
 List<int?>? chronos, ResultMark? mark, String? code
});




}
/// @nodoc
class __$ResultChangeCopyWithImpl<$Res>
    implements _$ResultChangeCopyWith<$Res> {
  __$ResultChangeCopyWithImpl(this._self, this._then);

  final _ResultChange _self;
  final $Res Function(_ResultChange) _then;

/// Create a copy of ResultChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chronos = freezed,Object? mark = freezed,Object? code = freezed,}) {
  return _then(_ResultChange(
chronos: freezed == chronos ? _self._chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>?,mark: freezed == mark ? _self.mark : mark // ignore: cast_nullable_to_non_nullable
as ResultMark?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
