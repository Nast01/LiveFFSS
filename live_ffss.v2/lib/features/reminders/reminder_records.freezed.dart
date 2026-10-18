// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KnownHeatDto implements DiagnosticableTreeMixin {

 int? get entryId; int? get eventId; int? get heatId;
/// Create a copy of KnownHeatDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnownHeatDtoCopyWith<KnownHeatDto> get copyWith => _$KnownHeatDtoCopyWithImpl<KnownHeatDto>(this as KnownHeatDto, _$identity);

  /// Serializes this KnownHeatDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as KnownHeatDto;
  properties
    ..add(DiagnosticsProperty('type', 'KnownHeatDto'))
    ..add(DiagnosticsProperty('entryId', _this.entryId))..add(DiagnosticsProperty('eventId', _this.eventId))..add(DiagnosticsProperty('heatId', _this.heatId));
}

@override
bool operator ==(Object other) {
  final _this = this as KnownHeatDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnownHeatDto&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.heatId, _this.heatId) || other.heatId == _this.heatId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KnownHeatDto;
  return Object.hash(runtimeType,_this.entryId,_this.eventId,_this.heatId);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as KnownHeatDto;
  return 'KnownHeatDto(entryId: ${_this.entryId}, eventId: ${_this.eventId}, heatId: ${_this.heatId})';
}


}

/// @nodoc
abstract mixin class $KnownHeatDtoCopyWith<$Res>  {
  factory $KnownHeatDtoCopyWith(KnownHeatDto value, $Res Function(KnownHeatDto) _then) = _$KnownHeatDtoCopyWithImpl;
@useResult
$Res call({
 int? entryId, int? eventId, int? heatId
});




}
/// @nodoc
class _$KnownHeatDtoCopyWithImpl<$Res>
    implements $KnownHeatDtoCopyWith<$Res> {
  _$KnownHeatDtoCopyWithImpl(this._self, this._then);

  final KnownHeatDto _self;
  final $Res Function(KnownHeatDto) _then;

/// Create a copy of KnownHeatDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entryId = freezed,Object? eventId = freezed,Object? heatId = freezed,}) {
  return _then(KnownHeatDto(
entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,heatId: freezed == heatId ? _self.heatId : heatId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [KnownHeatDto].
extension KnownHeatDtoPatterns on KnownHeatDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KnownHeatDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KnownHeatDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KnownHeatDto value)  $default,){
final _that = this;
switch (_that) {
case _KnownHeatDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KnownHeatDto value)?  $default,){
final _that = this;
switch (_that) {
case _KnownHeatDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? entryId,  int? eventId,  int? heatId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KnownHeatDto() when $default != null:
return $default(_that.entryId,_that.eventId,_that.heatId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? entryId,  int? eventId,  int? heatId)  $default,) {final _that = this;
switch (_that) {
case _KnownHeatDto():
return $default(_that.entryId,_that.eventId,_that.heatId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? entryId,  int? eventId,  int? heatId)?  $default,) {final _that = this;
switch (_that) {
case _KnownHeatDto() when $default != null:
return $default(_that.entryId,_that.eventId,_that.heatId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KnownHeatDto with DiagnosticableTreeMixin implements KnownHeatDto {
  const _KnownHeatDto({this.entryId, this.eventId, this.heatId});
  factory _KnownHeatDto.fromJson(Map<String, dynamic> json) => _$KnownHeatDtoFromJson(json);

@override final  int? entryId;
@override final  int? eventId;
@override final  int? heatId;

/// Create a copy of KnownHeatDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnownHeatDtoCopyWith<_KnownHeatDto> get copyWith => __$KnownHeatDtoCopyWithImpl<_KnownHeatDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KnownHeatDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'KnownHeatDto'))
    ..add(DiagnosticsProperty('entryId', entryId))..add(DiagnosticsProperty('eventId', eventId))..add(DiagnosticsProperty('heatId', heatId));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KnownHeatDto&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.heatId, heatId) || other.heatId == heatId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entryId,eventId,heatId);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'KnownHeatDto(entryId: $entryId, eventId: $eventId, heatId: $heatId)';
}


}

/// @nodoc
abstract mixin class _$KnownHeatDtoCopyWith<$Res> implements $KnownHeatDtoCopyWith<$Res> {
  factory _$KnownHeatDtoCopyWith(_KnownHeatDto value, $Res Function(_KnownHeatDto) _then) = __$KnownHeatDtoCopyWithImpl;
@override @useResult
$Res call({
 int? entryId, int? eventId, int? heatId
});




}
/// @nodoc
class __$KnownHeatDtoCopyWithImpl<$Res>
    implements _$KnownHeatDtoCopyWith<$Res> {
  __$KnownHeatDtoCopyWithImpl(this._self, this._then);

  final _KnownHeatDto _self;
  final $Res Function(_KnownHeatDto) _then;

/// Create a copy of KnownHeatDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entryId = freezed,Object? eventId = freezed,Object? heatId = freezed,}) {
  return _then(_KnownHeatDto(
entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,heatId: freezed == heatId ? _self.heatId : heatId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SelfAthleteDto implements DiagnosticableTreeMixin {

 String? get account; FollowedAthleteDto? get athlete;
/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelfAthleteDtoCopyWith<SelfAthleteDto> get copyWith => _$SelfAthleteDtoCopyWithImpl<SelfAthleteDto>(this as SelfAthleteDto, _$identity);

  /// Serializes this SelfAthleteDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as SelfAthleteDto;
  properties
    ..add(DiagnosticsProperty('type', 'SelfAthleteDto'))
    ..add(DiagnosticsProperty('account', _this.account))..add(DiagnosticsProperty('athlete', _this.athlete));
}

@override
bool operator ==(Object other) {
  final _this = this as SelfAthleteDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelfAthleteDto&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.athlete, _this.athlete) || other.athlete == _this.athlete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SelfAthleteDto;
  return Object.hash(runtimeType,_this.account,_this.athlete);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as SelfAthleteDto;
  return 'SelfAthleteDto(account: ${_this.account}, athlete: ${_this.athlete})';
}


}

/// @nodoc
abstract mixin class $SelfAthleteDtoCopyWith<$Res>  {
  factory $SelfAthleteDtoCopyWith(SelfAthleteDto value, $Res Function(SelfAthleteDto) _then) = _$SelfAthleteDtoCopyWithImpl;
@useResult
$Res call({
 String? account, FollowedAthleteDto? athlete
});


$FollowedAthleteDtoCopyWith<$Res>? get athlete;

}
/// @nodoc
class _$SelfAthleteDtoCopyWithImpl<$Res>
    implements $SelfAthleteDtoCopyWith<$Res> {
  _$SelfAthleteDtoCopyWithImpl(this._self, this._then);

  final SelfAthleteDto _self;
  final $Res Function(SelfAthleteDto) _then;

/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = freezed,Object? athlete = freezed,}) {
  return _then(SelfAthleteDto(
account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String?,athlete: freezed == athlete ? _self.athlete : athlete // ignore: cast_nullable_to_non_nullable
as FollowedAthleteDto?,
  ));
}
/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FollowedAthleteDtoCopyWith<$Res>? get athlete {
    if (_self.athlete == null) {
    return null;
  }

  return $FollowedAthleteDtoCopyWith<$Res>(_self.athlete!, (value) {
    return _then(_self.copyWith(athlete: value));
  });
}
}


/// Adds pattern-matching-related methods to [SelfAthleteDto].
extension SelfAthleteDtoPatterns on SelfAthleteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelfAthleteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelfAthleteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelfAthleteDto value)  $default,){
final _that = this;
switch (_that) {
case _SelfAthleteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelfAthleteDto value)?  $default,){
final _that = this;
switch (_that) {
case _SelfAthleteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? account,  FollowedAthleteDto? athlete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelfAthleteDto() when $default != null:
return $default(_that.account,_that.athlete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? account,  FollowedAthleteDto? athlete)  $default,) {final _that = this;
switch (_that) {
case _SelfAthleteDto():
return $default(_that.account,_that.athlete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? account,  FollowedAthleteDto? athlete)?  $default,) {final _that = this;
switch (_that) {
case _SelfAthleteDto() when $default != null:
return $default(_that.account,_that.athlete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SelfAthleteDto with DiagnosticableTreeMixin implements SelfAthleteDto {
  const _SelfAthleteDto({this.account, this.athlete});
  factory _SelfAthleteDto.fromJson(Map<String, dynamic> json) => _$SelfAthleteDtoFromJson(json);

@override final  String? account;
@override final  FollowedAthleteDto? athlete;

/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelfAthleteDtoCopyWith<_SelfAthleteDto> get copyWith => __$SelfAthleteDtoCopyWithImpl<_SelfAthleteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelfAthleteDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'SelfAthleteDto'))
    ..add(DiagnosticsProperty('account', account))..add(DiagnosticsProperty('athlete', athlete));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelfAthleteDto&&(identical(other.account, account) || other.account == account)&&(identical(other.athlete, athlete) || other.athlete == athlete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,account,athlete);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'SelfAthleteDto(account: $account, athlete: $athlete)';
}


}

/// @nodoc
abstract mixin class _$SelfAthleteDtoCopyWith<$Res> implements $SelfAthleteDtoCopyWith<$Res> {
  factory _$SelfAthleteDtoCopyWith(_SelfAthleteDto value, $Res Function(_SelfAthleteDto) _then) = __$SelfAthleteDtoCopyWithImpl;
@override @useResult
$Res call({
 String? account, FollowedAthleteDto? athlete
});


@override $FollowedAthleteDtoCopyWith<$Res>? get athlete;

}
/// @nodoc
class __$SelfAthleteDtoCopyWithImpl<$Res>
    implements _$SelfAthleteDtoCopyWith<$Res> {
  __$SelfAthleteDtoCopyWithImpl(this._self, this._then);

  final _SelfAthleteDto _self;
  final $Res Function(_SelfAthleteDto) _then;

/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = freezed,Object? athlete = freezed,}) {
  return _then(_SelfAthleteDto(
account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String?,athlete: freezed == athlete ? _self.athlete : athlete // ignore: cast_nullable_to_non_nullable
as FollowedAthleteDto?,
  ));
}

/// Create a copy of SelfAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FollowedAthleteDtoCopyWith<$Res>? get athlete {
    if (_self.athlete == null) {
    return null;
  }

  return $FollowedAthleteDtoCopyWith<$Res>(_self.athlete!, (value) {
    return _then(_self.copyWith(athlete: value));
  });
}
}

// dart format on
