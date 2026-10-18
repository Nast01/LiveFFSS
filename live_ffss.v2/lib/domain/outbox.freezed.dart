// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutboxOperation {

 String get id;/// Le nom du compte qui a saisi : l'opération ne part qu'avec sa session.
 String get account; int get competitionId; int get placeId;/// L'id du résultat une fois connu (création réussie) ; nul avant.
 int? get resultId; int get seriesId; int get entryId; ResultChange get change; OutboxState get state;/// Pourquoi l'opération a été refusée.
 OutboxRejection? get rejection;/// Le message du site qui accompagne un refus [OutboxRejection.server].
 String? get reason;/// Les essais manqués d'affilée, qui règlent le délai du suivant.
 int get attempts;/// Parmi eux, ceux qu'une coupure n'explique pas : passé
/// [maxFaults], l'opération est refusée, pour qu'une seule ne bloque pas
/// toute la file du compte.
 int get faults;/// Quand l'opération est partie, pour l'oublier un jour plus tard.
 DateTime? get sentAt;
/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxOperationCopyWith<OutboxOperation> get copyWith => _$OutboxOperationCopyWithImpl<OutboxOperation>(this as OutboxOperation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutboxOperation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxOperation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.competitionId, _this.competitionId) || other.competitionId == _this.competitionId)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.resultId, _this.resultId) || other.resultId == _this.resultId)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.change, _this.change) || other.change == _this.change)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.rejection, _this.rejection) || other.rejection == _this.rejection)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.faults, _this.faults) || other.faults == _this.faults)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt));
}


@override
int get hashCode {
  final _this = this as OutboxOperation;
  return Object.hash(runtimeType,_this.id,_this.account,_this.competitionId,_this.placeId,_this.resultId,_this.seriesId,_this.entryId,_this.change,_this.state,_this.rejection,_this.reason,_this.attempts,_this.faults,_this.sentAt);
}

@override
String toString() {
  final _this = this as OutboxOperation;
  return 'OutboxOperation(id: ${_this.id}, account: ${_this.account}, competitionId: ${_this.competitionId}, placeId: ${_this.placeId}, resultId: ${_this.resultId}, seriesId: ${_this.seriesId}, entryId: ${_this.entryId}, change: ${_this.change}, state: ${_this.state}, rejection: ${_this.rejection}, reason: ${_this.reason}, attempts: ${_this.attempts}, faults: ${_this.faults}, sentAt: ${_this.sentAt})';
}


}

/// @nodoc
abstract mixin class $OutboxOperationCopyWith<$Res>  {
  factory $OutboxOperationCopyWith(OutboxOperation value, $Res Function(OutboxOperation) _then) = _$OutboxOperationCopyWithImpl;
@useResult
$Res call({
 String id, String account, int competitionId, int placeId, int? resultId, int seriesId, int entryId, ResultChange change, OutboxState state, OutboxRejection? rejection, String? reason, int attempts, int faults, DateTime? sentAt
});


$ResultChangeCopyWith<$Res> get change;

}
/// @nodoc
class _$OutboxOperationCopyWithImpl<$Res>
    implements $OutboxOperationCopyWith<$Res> {
  _$OutboxOperationCopyWithImpl(this._self, this._then);

  final OutboxOperation _self;
  final $Res Function(OutboxOperation) _then;

/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? account = null,Object? competitionId = null,Object? placeId = null,Object? resultId = freezed,Object? seriesId = null,Object? entryId = null,Object? change = null,Object? state = null,Object? rejection = freezed,Object? reason = freezed,Object? attempts = null,Object? faults = null,Object? sentAt = freezed,}) {
  return _then(OutboxOperation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as int,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,resultId: freezed == resultId ? _self.resultId : resultId // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as ResultChange,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutboxState,rejection: freezed == rejection ? _self.rejection : rejection // ignore: cast_nullable_to_non_nullable
as OutboxRejection?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,faults: null == faults ? _self.faults : faults // ignore: cast_nullable_to_non_nullable
as int,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultChangeCopyWith<$Res> get change {
  
  return $ResultChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutboxOperation].
extension OutboxOperationPatterns on OutboxOperation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxOperation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxOperation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxOperation value)  $default,){
final _that = this;
switch (_that) {
case _OutboxOperation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxOperation value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxOperation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  ResultChange change,  OutboxState state,  OutboxRejection? rejection,  String? reason,  int attempts,  int faults,  DateTime? sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxOperation() when $default != null:
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.change,_that.state,_that.rejection,_that.reason,_that.attempts,_that.faults,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  ResultChange change,  OutboxState state,  OutboxRejection? rejection,  String? reason,  int attempts,  int faults,  DateTime? sentAt)  $default,) {final _that = this;
switch (_that) {
case _OutboxOperation():
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.change,_that.state,_that.rejection,_that.reason,_that.attempts,_that.faults,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String account,  int competitionId,  int placeId,  int? resultId,  int seriesId,  int entryId,  ResultChange change,  OutboxState state,  OutboxRejection? rejection,  String? reason,  int attempts,  int faults,  DateTime? sentAt)?  $default,) {final _that = this;
switch (_that) {
case _OutboxOperation() when $default != null:
return $default(_that.id,_that.account,_that.competitionId,_that.placeId,_that.resultId,_that.seriesId,_that.entryId,_that.change,_that.state,_that.rejection,_that.reason,_that.attempts,_that.faults,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc


class _OutboxOperation implements OutboxOperation {
  const _OutboxOperation({required this.id, required this.account, required this.competitionId, required this.placeId, this.resultId, required this.seriesId, required this.entryId, required this.change, this.state = OutboxState.pending, this.rejection, this.reason, this.attempts = 0, this.faults = 0, this.sentAt});
  

@override final  String id;
/// Le nom du compte qui a saisi : l'opération ne part qu'avec sa session.
@override final  String account;
@override final  int competitionId;
@override final  int placeId;
/// L'id du résultat une fois connu (création réussie) ; nul avant.
@override final  int? resultId;
@override final  int seriesId;
@override final  int entryId;
@override final  ResultChange change;
@override@JsonKey() final  OutboxState state;
/// Pourquoi l'opération a été refusée.
@override final  OutboxRejection? rejection;
/// Le message du site qui accompagne un refus [OutboxRejection.server].
@override final  String? reason;
/// Les essais manqués d'affilée, qui règlent le délai du suivant.
@override@JsonKey() final  int attempts;
/// Parmi eux, ceux qu'une coupure n'explique pas : passé
/// [maxFaults], l'opération est refusée, pour qu'une seule ne bloque pas
/// toute la file du compte.
@override@JsonKey() final  int faults;
/// Quand l'opération est partie, pour l'oublier un jour plus tard.
@override final  DateTime? sentAt;

/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxOperationCopyWith<_OutboxOperation> get copyWith => __$OutboxOperationCopyWithImpl<_OutboxOperation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.account, account) || other.account == account)&&(identical(other.competitionId, competitionId) || other.competitionId == competitionId)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.resultId, resultId) || other.resultId == resultId)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.change, change) || other.change == change)&&(identical(other.state, state) || other.state == state)&&(identical(other.rejection, rejection) || other.rejection == rejection)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.faults, faults) || other.faults == faults)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,account,competitionId,placeId,resultId,seriesId,entryId,change,state,rejection,reason,attempts,faults,sentAt);
}

@override
String toString() {
    return 'OutboxOperation(id: $id, account: $account, competitionId: $competitionId, placeId: $placeId, resultId: $resultId, seriesId: $seriesId, entryId: $entryId, change: $change, state: $state, rejection: $rejection, reason: $reason, attempts: $attempts, faults: $faults, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$OutboxOperationCopyWith<$Res> implements $OutboxOperationCopyWith<$Res> {
  factory _$OutboxOperationCopyWith(_OutboxOperation value, $Res Function(_OutboxOperation) _then) = __$OutboxOperationCopyWithImpl;
@override @useResult
$Res call({
 String id, String account, int competitionId, int placeId, int? resultId, int seriesId, int entryId, ResultChange change, OutboxState state, OutboxRejection? rejection, String? reason, int attempts, int faults, DateTime? sentAt
});


@override $ResultChangeCopyWith<$Res> get change;

}
/// @nodoc
class __$OutboxOperationCopyWithImpl<$Res>
    implements _$OutboxOperationCopyWith<$Res> {
  __$OutboxOperationCopyWithImpl(this._self, this._then);

  final _OutboxOperation _self;
  final $Res Function(_OutboxOperation) _then;

/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? account = null,Object? competitionId = null,Object? placeId = null,Object? resultId = freezed,Object? seriesId = null,Object? entryId = null,Object? change = null,Object? state = null,Object? rejection = freezed,Object? reason = freezed,Object? attempts = null,Object? faults = null,Object? sentAt = freezed,}) {
  return _then(_OutboxOperation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,competitionId: null == competitionId ? _self.competitionId : competitionId // ignore: cast_nullable_to_non_nullable
as int,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,resultId: freezed == resultId ? _self.resultId : resultId // ignore: cast_nullable_to_non_nullable
as int?,seriesId: null == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as ResultChange,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutboxState,rejection: freezed == rejection ? _self.rejection : rejection // ignore: cast_nullable_to_non_nullable
as OutboxRejection?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,faults: null == faults ? _self.faults : faults // ignore: cast_nullable_to_non_nullable
as int,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of OutboxOperation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultChangeCopyWith<$Res> get change {
  
  return $ResultChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}

// dart format on
