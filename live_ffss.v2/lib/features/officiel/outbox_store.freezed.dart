// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxOperationDto {

 String get id; String get account; int get competitionId; int get placeId; int? get resultId; int get seriesId; int get entryId; List<int?>? get chronos; String? get mark; String? get code; String get state; String? get reason; int get attempts;
/// Create a copy of OutboxOperationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxOperationDtoCopyWith<OutboxOperationDto> get copyWith => _$OutboxOperationDtoCopyWithImpl<OutboxOperationDto>(this as OutboxOperationDto, _$identity);

  /// Serializes this OutboxOperationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboxOperationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxOperationDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.competitionId, _this.competitionId) || other.competitionId == _this.competitionId)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.resultId, _this.resultId) || other.resultId == _this.resultId)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&const DeepCollectionEquality().equals(other.chronos, _this.chronos)&&(identical(other.mark, _this.mark) || other.mark == _this.mark)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboxOperationDto;
  return Object.hash(runtimeType,_this.id,_this.account,_this.competitionId,_this.placeId,_this.resultId,_this.seriesId,_this.entryId,const DeepCollectionEquality().hash(_this.chronos),_this.mark,_this.code,_this.state,_this.reason,_this.attempts);
}

@override
String toString() {
  final _this = this as OutboxOperationDto;
  return 'OutboxOperationDto(id: ${_this.id}, account: ${_this.account}, competitionId: ${_this.competitionId}, placeId: ${_this.placeId}, resultId: ${_this.resultId}, seriesId: ${_this.seriesId}, entryId: ${_this.entryId}, chronos: ${_this.chronos}, mark: ${_this.mark}, code: ${_this.code}, state: ${_this.state}, reason: ${_this.reason}, attempts: ${_this.attempts})';
}


}

/// @nodoc
abstract mixin class $OutboxOperationDtoCopyWith<$Res>  {
  factory $OutboxOperationDtoCopyWith(OutboxOperationDto value, $Res Function(OutboxOperationDto) _then) = _$OutboxOperationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String account, int competitionId, int placeId, int? resultId, int seriesId, int entryId, List<int?>? chronos, String? mark, String? code, String state, String? reason, int attempts
});




}
/// @nodoc
class _$OutboxOperationDtoCopyWithImpl<$Res>
    implements $OutboxOperationDtoCopyWith<$Res> {
  _$OutboxOperationDtoCopyWithImpl(this._self, this._then);

  final OutboxOperationDto _self;
  final $Res Function(OutboxOperationDto) _then;

/// Create a copy of OutboxOperationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? account = null,Object? competitionId = null,Object? placeId = null,Object? resultId = freezed,Object? seriesId = null,Object? entryId = null,Object? chronos = freezed,Object? mark = freezed,Object? code = freezed,Object? state = null,Object? reason = freezed,Object? attempts = null,}) {
  return _then(OutboxOperationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as int,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,resultId: freezed == resultId ? _self.resultId : resultId // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,chronos: freezed == chronos ? _self.chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>?,mark: freezed == mark ? _self.mark : mark // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxOperationDto].
extension OutboxOperationDtoPatterns on OutboxOperationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxOperationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxOperationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxOperationDto value)  $default,){
final _that = this;
switch (_that) {
case _OutboxOperationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxOperationDto value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxOperationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  List<int?>? chronos,  String? mark,  String? code,  String state,  String? reason,  int attempts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxOperationDto() when $default != null:
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.chronos,_that.mark,_that.code,_that.state,_that.reason,_that.attempts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  List<int?>? chronos,  String? mark,  String? code,  String state,  String? reason,  int attempts)  $default,) {final _that = this;
switch (_that) {
case _OutboxOperationDto():
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.chronos,_that.mark,_that.code,_that.state,_that.reason,_that.attempts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  List<int?>? chronos,  String? mark,  String? code,  String state,  String? reason,  int attempts)?  $default,) {final _that = this;
switch (_that) {
case _OutboxOperationDto() when $default != null:
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.chronos,_that.mark,_that.code,_that.state,_that.reason,_that.attempts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxOperationDto implements OutboxOperationDto {
  const _OutboxOperationDto({required this.id, required this.account, required this.competitionId, required this.placeId, this.resultId, required this.seriesId, required this.entryId,  List<int?>? chronos, this.mark, this.code, required this.state, this.reason, this.attempts = 0}): _chronos = chronos;
  factory _OutboxOperationDto.fromJson(Map<String, dynamic> json) => _$OutboxOperationDtoFromJson(json);

@override final  String id;
@override final  String account;
@override final  int competitionId;
@override final  int placeId;
@override final  int? resultId;
@override final  int seriesId;
@override final  int entryId;
 final  List<int?>? _chronos;
@override List<int?>? get chronos {
  final value = _chronos;
  if (value == null) return null;
  if (_chronos is EqualUnmodifiableListView) return _chronos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? mark;
@override final  String? code;
@override final  String state;
@override final  String? reason;
@override@JsonKey() final  int attempts;

/// Create a copy of OutboxOperationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxOperationDtoCopyWith<_OutboxOperationDto> get copyWith => __$OutboxOperationDtoCopyWithImpl<_OutboxOperationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxOperationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxOperationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.account, account) || other.account == account)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.resultId, resultId) || other.resultId == resultId)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&const DeepCollectionEquality().equals(other.chronos, _chronos)&&(identical(other.mark, mark) || other.mark == mark)&&(identical(other.code, code) || other.code == code)&&(identical(other.state, state) || other.state == state)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.attempts, attempts) || other.attempts == attempts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,account,competitionId,placeId,resultId,seriesId,entryId,const DeepCollectionEquality().hash(_chronos),mark,code,state,reason,attempts);
}

@override
String toString() {
    return 'OutboxOperationDto(id: $id, account: $account, competitionId: $competitionId, placeId: $placeId, resultId: $resultId, seriesId: $seriesId, entryId: $entryId, chronos: $chronos, mark: $mark, code: $code, state: $state, reason: $reason, attempts: $attempts)';
}


}

/// @nodoc
abstract mixin class _$OutboxOperationDtoCopyWith<$Res> implements $OutboxOperationDtoCopyWith<$Res> {
  factory _$OutboxOperationDtoCopyWith(_OutboxOperationDto value, $Res Function(_OutboxOperationDto) _then) = __$OutboxOperationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String account, int competitionId, int placeId, int? resultId, int seriesId, int entryId, List<int?>? chronos, String? mark, String? code, String state, String? reason, int attempts
});




}
/// @nodoc
class __$OutboxOperationDtoCopyWithImpl<$Res>
    implements _$OutboxOperationDtoCopyWith<$Res> {
  __$OutboxOperationDtoCopyWithImpl(this._self, this._then);

  final _OutboxOperationDto _self;
  final $Res Function(_OutboxOperationDto) _then;

/// Create a copy of OutboxOperationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? account = null,Object? competitionId = null,Object? placeId = null,Object? resultId = freezed,Object? seriesId = null,Object? entryId = null,Object? chronos = freezed,Object? mark = freezed,Object? code = freezed,Object? state = null,Object? reason = freezed,Object? attempts = null,}) {
  return _then(_OutboxOperationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as int,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,resultId: freezed == resultId ? _self.resultId : resultId // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,chronos: freezed == chronos ? _self._chronos : chronos // ignore: cast_nullable_to_non_nullable
as List<int?>?,mark: freezed == mark ? _self.mark : mark // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
