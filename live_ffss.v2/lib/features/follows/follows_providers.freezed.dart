// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follows_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowsDto {

 List<FollowedAthleteDto>? get athletes; List<FollowedClubDto>? get clubs;
/// Create a copy of FollowsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowsDtoCopyWith<FollowsDto> get copyWith => _$FollowsDtoCopyWithImpl<FollowsDto>(this as FollowsDto, _$identity);

  /// Serializes this FollowsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FollowsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowsDto&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&const DeepCollectionEquality().equals(other.clubs, _this.clubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FollowsDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.athletes),const DeepCollectionEquality().hash(_this.clubs));
}

@override
String toString() {
  final _this = this as FollowsDto;
  return 'FollowsDto(athletes: ${_this.athletes}, clubs: ${_this.clubs})';
}


}

/// @nodoc
abstract mixin class $FollowsDtoCopyWith<$Res>  {
  factory $FollowsDtoCopyWith(FollowsDto value, $Res Function(FollowsDto) _then) = _$FollowsDtoCopyWithImpl;
@useResult
$Res call({
 List<FollowedAthleteDto>? athletes, List<FollowedClubDto>? clubs
});




}
/// @nodoc
class _$FollowsDtoCopyWithImpl<$Res>
    implements $FollowsDtoCopyWith<$Res> {
  _$FollowsDtoCopyWithImpl(this._self, this._then);

  final FollowsDto _self;
  final $Res Function(FollowsDto) _then;

/// Create a copy of FollowsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? athletes = freezed,Object? clubs = freezed,}) {
  return _then(FollowsDto(
athletes: freezed == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<FollowedAthleteDto>?,clubs: freezed == clubs ? _self.clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<FollowedClubDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowsDto].
extension FollowsDtoPatterns on FollowsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowsDto value)  $default,){
final _that = this;
switch (_that) {
case _FollowsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowsDto value)?  $default,){
final _that = this;
switch (_that) {
case _FollowsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FollowedAthleteDto>? athletes,  List<FollowedClubDto>? clubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowsDto() when $default != null:
return $default(_that.athletes,_that.clubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FollowedAthleteDto>? athletes,  List<FollowedClubDto>? clubs)  $default,) {final _that = this;
switch (_that) {
case _FollowsDto():
return $default(_that.athletes,_that.clubs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FollowedAthleteDto>? athletes,  List<FollowedClubDto>? clubs)?  $default,) {final _that = this;
switch (_that) {
case _FollowsDto() when $default != null:
return $default(_that.athletes,_that.clubs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowsDto implements FollowsDto {
  const _FollowsDto({ List<FollowedAthleteDto>? athletes,  List<FollowedClubDto>? clubs}): _athletes = athletes,_clubs = clubs;
  factory _FollowsDto.fromJson(Map<String, dynamic> json) => _$FollowsDtoFromJson(json);

 final  List<FollowedAthleteDto>? _athletes;
@override List<FollowedAthleteDto>? get athletes {
  final value = _athletes;
  if (value == null) return null;
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<FollowedClubDto>? _clubs;
@override List<FollowedClubDto>? get clubs {
  final value = _clubs;
  if (value == null) return null;
  if (_clubs is EqualUnmodifiableListView) return _clubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of FollowsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowsDtoCopyWith<_FollowsDto> get copyWith => __$FollowsDtoCopyWithImpl<_FollowsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowsDto&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&const DeepCollectionEquality().equals(other.clubs, _clubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_athletes),const DeepCollectionEquality().hash(_clubs));
}

@override
String toString() {
    return 'FollowsDto(athletes: $athletes, clubs: $clubs)';
}


}

/// @nodoc
abstract mixin class _$FollowsDtoCopyWith<$Res> implements $FollowsDtoCopyWith<$Res> {
  factory _$FollowsDtoCopyWith(_FollowsDto value, $Res Function(_FollowsDto) _then) = __$FollowsDtoCopyWithImpl;
@override @useResult
$Res call({
 List<FollowedAthleteDto>? athletes, List<FollowedClubDto>? clubs
});




}
/// @nodoc
class __$FollowsDtoCopyWithImpl<$Res>
    implements _$FollowsDtoCopyWith<$Res> {
  __$FollowsDtoCopyWithImpl(this._self, this._then);

  final _FollowsDto _self;
  final $Res Function(_FollowsDto) _then;

/// Create a copy of FollowsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? athletes = freezed,Object? clubs = freezed,}) {
  return _then(_FollowsDto(
athletes: freezed == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<FollowedAthleteDto>?,clubs: freezed == clubs ? _self._clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<FollowedClubDto>?,
  ));
}


}


/// @nodoc
mixin _$FollowedAthleteDto {

 int? get participantId; String? get name; String? get club; List<int>? get entryIds;
/// Create a copy of FollowedAthleteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowedAthleteDtoCopyWith<FollowedAthleteDto> get copyWith => _$FollowedAthleteDtoCopyWithImpl<FollowedAthleteDto>(this as FollowedAthleteDto, _$identity);

  /// Serializes this FollowedAthleteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FollowedAthleteDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowedAthleteDto&&(identical(other.participantId, _this.participantId) || other.participantId == _this.participantId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.club, _this.club) || other.club == _this.club)&&const DeepCollectionEquality().equals(other.entryIds, _this.entryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FollowedAthleteDto;
  return Object.hash(runtimeType,_this.participantId,_this.name,_this.club,const DeepCollectionEquality().hash(_this.entryIds));
}

@override
String toString() {
  final _this = this as FollowedAthleteDto;
  return 'FollowedAthleteDto(participantId: ${_this.participantId}, name: ${_this.name}, club: ${_this.club}, entryIds: ${_this.entryIds})';
}


}

/// @nodoc
abstract mixin class $FollowedAthleteDtoCopyWith<$Res>  {
  factory $FollowedAthleteDtoCopyWith(FollowedAthleteDto value, $Res Function(FollowedAthleteDto) _then) = _$FollowedAthleteDtoCopyWithImpl;
@useResult
$Res call({
 int? participantId, String? name, String? club, List<int>? entryIds
});




}
/// @nodoc
class _$FollowedAthleteDtoCopyWithImpl<$Res>
    implements $FollowedAthleteDtoCopyWith<$Res> {
  _$FollowedAthleteDtoCopyWithImpl(this._self, this._then);

  final FollowedAthleteDto _self;
  final $Res Function(FollowedAthleteDto) _then;

/// Create a copy of FollowedAthleteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = freezed,Object? name = freezed,Object? club = freezed,Object? entryIds = freezed,}) {
  return _then(FollowedAthleteDto(
participantId: freezed == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,entryIds: freezed == entryIds ? _self.entryIds : entryIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowedAthleteDto].
extension FollowedAthleteDtoPatterns on FollowedAthleteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowedAthleteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowedAthleteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowedAthleteDto value)  $default,){
final _that = this;
switch (_that) {
case _FollowedAthleteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowedAthleteDto value)?  $default,){
final _that = this;
switch (_that) {
case _FollowedAthleteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? participantId,  String? name,  String? club,  List<int>? entryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowedAthleteDto() when $default != null:
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? participantId,  String? name,  String? club,  List<int>? entryIds)  $default,) {final _that = this;
switch (_that) {
case _FollowedAthleteDto():
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? participantId,  String? name,  String? club,  List<int>? entryIds)?  $default,) {final _that = this;
switch (_that) {
case _FollowedAthleteDto() when $default != null:
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowedAthleteDto implements FollowedAthleteDto {
  const _FollowedAthleteDto({this.participantId, this.name, this.club,  List<int>? entryIds}): _entryIds = entryIds;
  factory _FollowedAthleteDto.fromJson(Map<String, dynamic> json) => _$FollowedAthleteDtoFromJson(json);

@override final  int? participantId;
@override final  String? name;
@override final  String? club;
 final  List<int>? _entryIds;
@override List<int>? get entryIds {
  final value = _entryIds;
  if (value == null) return null;
  if (_entryIds is EqualUnmodifiableListView) return _entryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of FollowedAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowedAthleteDtoCopyWith<_FollowedAthleteDto> get copyWith => __$FollowedAthleteDtoCopyWithImpl<_FollowedAthleteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowedAthleteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowedAthleteDto&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.club, club) || other.club == club)&&const DeepCollectionEquality().equals(other.entryIds, _entryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,participantId,name,club,const DeepCollectionEquality().hash(_entryIds));
}

@override
String toString() {
    return 'FollowedAthleteDto(participantId: $participantId, name: $name, club: $club, entryIds: $entryIds)';
}


}

/// @nodoc
abstract mixin class _$FollowedAthleteDtoCopyWith<$Res> implements $FollowedAthleteDtoCopyWith<$Res> {
  factory _$FollowedAthleteDtoCopyWith(_FollowedAthleteDto value, $Res Function(_FollowedAthleteDto) _then) = __$FollowedAthleteDtoCopyWithImpl;
@override @useResult
$Res call({
 int? participantId, String? name, String? club, List<int>? entryIds
});




}
/// @nodoc
class __$FollowedAthleteDtoCopyWithImpl<$Res>
    implements _$FollowedAthleteDtoCopyWith<$Res> {
  __$FollowedAthleteDtoCopyWithImpl(this._self, this._then);

  final _FollowedAthleteDto _self;
  final $Res Function(_FollowedAthleteDto) _then;

/// Create a copy of FollowedAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = freezed,Object? name = freezed,Object? club = freezed,Object? entryIds = freezed,}) {
  return _then(_FollowedAthleteDto(
participantId: freezed == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,entryIds: freezed == entryIds ? _self._entryIds : entryIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}


}


/// @nodoc
mixin _$FollowedClubDto {

 int? get id; String? get label;
/// Create a copy of FollowedClubDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowedClubDtoCopyWith<FollowedClubDto> get copyWith => _$FollowedClubDtoCopyWithImpl<FollowedClubDto>(this as FollowedClubDto, _$identity);

  /// Serializes this FollowedClubDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FollowedClubDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowedClubDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FollowedClubDto;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as FollowedClubDto;
  return 'FollowedClubDto(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $FollowedClubDtoCopyWith<$Res>  {
  factory $FollowedClubDtoCopyWith(FollowedClubDto value, $Res Function(FollowedClubDto) _then) = _$FollowedClubDtoCopyWithImpl;
@useResult
$Res call({
 int? id, String? label
});




}
/// @nodoc
class _$FollowedClubDtoCopyWithImpl<$Res>
    implements $FollowedClubDtoCopyWith<$Res> {
  _$FollowedClubDtoCopyWithImpl(this._self, this._then);

  final FollowedClubDto _self;
  final $Res Function(FollowedClubDto) _then;

/// Create a copy of FollowedClubDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,}) {
  return _then(FollowedClubDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowedClubDto].
extension FollowedClubDtoPatterns on FollowedClubDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowedClubDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowedClubDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowedClubDto value)  $default,){
final _that = this;
switch (_that) {
case _FollowedClubDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowedClubDto value)?  $default,){
final _that = this;
switch (_that) {
case _FollowedClubDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowedClubDto() when $default != null:
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? label)  $default,) {final _that = this;
switch (_that) {
case _FollowedClubDto():
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _FollowedClubDto() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowedClubDto implements FollowedClubDto {
  const _FollowedClubDto({this.id, this.label});
  factory _FollowedClubDto.fromJson(Map<String, dynamic> json) => _$FollowedClubDtoFromJson(json);

@override final  int? id;
@override final  String? label;

/// Create a copy of FollowedClubDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowedClubDtoCopyWith<_FollowedClubDto> get copyWith => __$FollowedClubDtoCopyWithImpl<_FollowedClubDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowedClubDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowedClubDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'FollowedClubDto(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$FollowedClubDtoCopyWith<$Res> implements $FollowedClubDtoCopyWith<$Res> {
  factory _$FollowedClubDtoCopyWith(_FollowedClubDto value, $Res Function(_FollowedClubDto) _then) = __$FollowedClubDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? label
});




}
/// @nodoc
class __$FollowedClubDtoCopyWithImpl<$Res>
    implements _$FollowedClubDtoCopyWith<$Res> {
  __$FollowedClubDtoCopyWithImpl(this._self, this._then);

  final _FollowedClubDto _self;
  final $Res Function(_FollowedClubDto) _then;

/// Create a copy of FollowedClubDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,}) {
  return _then(_FollowedClubDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
