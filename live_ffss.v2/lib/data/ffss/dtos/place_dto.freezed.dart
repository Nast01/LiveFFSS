// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'Numero', readValue: readInt) int? get lane;@JsonKey(name: 'engagement', readValue: readMap) PlaceEngagementDto? get engagement;@JsonKey(name: 'resultat', readValue: readMap) PlaceResultDto? get result;
/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceDtoCopyWith<PlaceDto> get copyWith => _$PlaceDtoCopyWithImpl<PlaceDto>(this as PlaceDto, _$identity);

  /// Serializes this PlaceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.lane, _this.lane) || other.lane == _this.lane)&&(identical(other.engagement, _this.engagement) || other.engagement == _this.engagement)&&(identical(other.result, _this.result) || other.result == _this.result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceDto;
  return Object.hash(runtimeType,_this.id,_this.lane,_this.engagement,_this.result);
}

@override
String toString() {
  final _this = this as PlaceDto;
  return 'PlaceDto(id: ${_this.id}, lane: ${_this.lane}, engagement: ${_this.engagement}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $PlaceDtoCopyWith<$Res>  {
  factory $PlaceDtoCopyWith(PlaceDto value, $Res Function(PlaceDto) _then) = _$PlaceDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? lane,@JsonKey(name: 'engagement', readValue: readMap) PlaceEngagementDto? engagement,@JsonKey(name: 'resultat', readValue: readMap) PlaceResultDto? result
});


$PlaceEngagementDtoCopyWith<$Res>? get engagement;$PlaceResultDtoCopyWith<$Res>? get result;

}
/// @nodoc
class _$PlaceDtoCopyWithImpl<$Res>
    implements $PlaceDtoCopyWith<$Res> {
  _$PlaceDtoCopyWithImpl(this._self, this._then);

  final PlaceDto _self;
  final $Res Function(PlaceDto) _then;

/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? lane = freezed,Object? engagement = freezed,Object? result = freezed,}) {
  return _then(PlaceDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,lane: freezed == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int?,engagement: freezed == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as PlaceEngagementDto?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PlaceResultDto?,
  ));
}
/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEngagementDtoCopyWith<$Res>? get engagement {
    if (_self.engagement == null) {
    return null;
  }

  return $PlaceEngagementDtoCopyWith<$Res>(_self.engagement!, (value) {
    return _then(_self.copyWith(engagement: value));
  });
}/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceResultDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PlaceResultDtoCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceDto].
extension PlaceDtoPatterns on PlaceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? lane, @JsonKey(name: 'engagement', readValue: readMap)  PlaceEngagementDto? engagement, @JsonKey(name: 'resultat', readValue: readMap)  PlaceResultDto? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceDto() when $default != null:
return $default(_that.id,_that.lane,_that.engagement,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? lane, @JsonKey(name: 'engagement', readValue: readMap)  PlaceEngagementDto? engagement, @JsonKey(name: 'resultat', readValue: readMap)  PlaceResultDto? result)  $default,) {final _that = this;
switch (_that) {
case _PlaceDto():
return $default(_that.id,_that.lane,_that.engagement,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? lane, @JsonKey(name: 'engagement', readValue: readMap)  PlaceEngagementDto? engagement, @JsonKey(name: 'resultat', readValue: readMap)  PlaceResultDto? result)?  $default,) {final _that = this;
switch (_that) {
case _PlaceDto() when $default != null:
return $default(_that.id,_that.lane,_that.engagement,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceDto implements PlaceDto {
  const _PlaceDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'Numero', readValue: readInt) this.lane, @JsonKey(name: 'engagement', readValue: readMap) this.engagement, @JsonKey(name: 'resultat', readValue: readMap) this.result});
  factory _PlaceDto.fromJson(Map<String, dynamic> json) => _$PlaceDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Numero', readValue: readInt) final  int? lane;
@override@JsonKey(name: 'engagement', readValue: readMap) final  PlaceEngagementDto? engagement;
@override@JsonKey(name: 'resultat', readValue: readMap) final  PlaceResultDto? result;

/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceDtoCopyWith<_PlaceDto> get copyWith => __$PlaceDtoCopyWithImpl<_PlaceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.lane, lane) || other.lane == lane)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,lane,engagement,result);
}

@override
String toString() {
    return 'PlaceDto(id: $id, lane: $lane, engagement: $engagement, result: $result)';
}


}

/// @nodoc
abstract mixin class _$PlaceDtoCopyWith<$Res> implements $PlaceDtoCopyWith<$Res> {
  factory _$PlaceDtoCopyWith(_PlaceDto value, $Res Function(_PlaceDto) _then) = __$PlaceDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? lane,@JsonKey(name: 'engagement', readValue: readMap) PlaceEngagementDto? engagement,@JsonKey(name: 'resultat', readValue: readMap) PlaceResultDto? result
});


@override $PlaceEngagementDtoCopyWith<$Res>? get engagement;@override $PlaceResultDtoCopyWith<$Res>? get result;

}
/// @nodoc
class __$PlaceDtoCopyWithImpl<$Res>
    implements _$PlaceDtoCopyWith<$Res> {
  __$PlaceDtoCopyWithImpl(this._self, this._then);

  final _PlaceDto _self;
  final $Res Function(_PlaceDto) _then;

/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? lane = freezed,Object? engagement = freezed,Object? result = freezed,}) {
  return _then(_PlaceDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,lane: freezed == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int?,engagement: freezed == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as PlaceEngagementDto?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PlaceResultDto?,
  ));
}

/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEngagementDtoCopyWith<$Res>? get engagement {
    if (_self.engagement == null) {
    return null;
  }

  return $PlaceEngagementDtoCopyWith<$Res>(_self.engagement!, (value) {
    return _then(_self.copyWith(engagement: value));
  });
}/// Create a copy of PlaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceResultDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $PlaceResultDtoCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// @nodoc
mixin _$PlaceEngagementDto {

@JsonKey(name: 'clubLabel') String? get clubLabel;@JsonKey(name: 'isForfait') bool? get isForfeit;@JsonKey(name: 'athletes') List<PlaceAthleteDto> get athletes;@JsonKey(name: 'EpreuveCategorie', readValue: readMap) PlaceEpreuveCategorieDto? get epreuveCategorie;
/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceEngagementDtoCopyWith<PlaceEngagementDto> get copyWith => _$PlaceEngagementDtoCopyWithImpl<PlaceEngagementDto>(this as PlaceEngagementDto, _$identity);

  /// Serializes this PlaceEngagementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceEngagementDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceEngagementDto&&(identical(other.clubLabel, _this.clubLabel) || other.clubLabel == _this.clubLabel)&&(identical(other.isForfeit, _this.isForfeit) || other.isForfeit == _this.isForfeit)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&(identical(other.epreuveCategorie, _this.epreuveCategorie) || other.epreuveCategorie == _this.epreuveCategorie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceEngagementDto;
  return Object.hash(runtimeType,_this.clubLabel,_this.isForfeit,const DeepCollectionEquality().hash(_this.athletes),_this.epreuveCategorie);
}

@override
String toString() {
  final _this = this as PlaceEngagementDto;
  return 'PlaceEngagementDto(clubLabel: ${_this.clubLabel}, isForfeit: ${_this.isForfeit}, athletes: ${_this.athletes}, epreuveCategorie: ${_this.epreuveCategorie})';
}


}

/// @nodoc
abstract mixin class $PlaceEngagementDtoCopyWith<$Res>  {
  factory $PlaceEngagementDtoCopyWith(PlaceEngagementDto value, $Res Function(PlaceEngagementDto) _then) = _$PlaceEngagementDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'clubLabel') String? clubLabel,@JsonKey(name: 'isForfait') bool? isForfeit,@JsonKey(name: 'athletes') List<PlaceAthleteDto> athletes,@JsonKey(name: 'EpreuveCategorie', readValue: readMap) PlaceEpreuveCategorieDto? epreuveCategorie
});


$PlaceEpreuveCategorieDtoCopyWith<$Res>? get epreuveCategorie;

}
/// @nodoc
class _$PlaceEngagementDtoCopyWithImpl<$Res>
    implements $PlaceEngagementDtoCopyWith<$Res> {
  _$PlaceEngagementDtoCopyWithImpl(this._self, this._then);

  final PlaceEngagementDto _self;
  final $Res Function(PlaceEngagementDto) _then;

/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clubLabel = freezed,Object? isForfeit = freezed,Object? athletes = null,Object? epreuveCategorie = freezed,}) {
  return _then(PlaceEngagementDto(
clubLabel: freezed == clubLabel ? _self.clubLabel : clubLabel // ignore: cast_nullable_to_non_nullable
as String?,isForfeit: freezed == isForfeit ? _self.isForfeit : isForfeit // ignore: cast_nullable_to_non_nullable
as bool?,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<PlaceAthleteDto>,epreuveCategorie: freezed == epreuveCategorie ? _self.epreuveCategorie : epreuveCategorie // ignore: cast_nullable_to_non_nullable
as PlaceEpreuveCategorieDto?,
  ));
}
/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEpreuveCategorieDtoCopyWith<$Res>? get epreuveCategorie {
    if (_self.epreuveCategorie == null) {
    return null;
  }

  return $PlaceEpreuveCategorieDtoCopyWith<$Res>(_self.epreuveCategorie!, (value) {
    return _then(_self.copyWith(epreuveCategorie: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceEngagementDto].
extension PlaceEngagementDtoPatterns on PlaceEngagementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceEngagementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceEngagementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceEngagementDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceEngagementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceEngagementDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceEngagementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'clubLabel')  String? clubLabel, @JsonKey(name: 'isForfait')  bool? isForfeit, @JsonKey(name: 'athletes')  List<PlaceAthleteDto> athletes, @JsonKey(name: 'EpreuveCategorie', readValue: readMap)  PlaceEpreuveCategorieDto? epreuveCategorie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceEngagementDto() when $default != null:
return $default(_that.clubLabel,_that.isForfeit,_that.athletes,_that.epreuveCategorie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'clubLabel')  String? clubLabel, @JsonKey(name: 'isForfait')  bool? isForfeit, @JsonKey(name: 'athletes')  List<PlaceAthleteDto> athletes, @JsonKey(name: 'EpreuveCategorie', readValue: readMap)  PlaceEpreuveCategorieDto? epreuveCategorie)  $default,) {final _that = this;
switch (_that) {
case _PlaceEngagementDto():
return $default(_that.clubLabel,_that.isForfeit,_that.athletes,_that.epreuveCategorie);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'clubLabel')  String? clubLabel, @JsonKey(name: 'isForfait')  bool? isForfeit, @JsonKey(name: 'athletes')  List<PlaceAthleteDto> athletes, @JsonKey(name: 'EpreuveCategorie', readValue: readMap)  PlaceEpreuveCategorieDto? epreuveCategorie)?  $default,) {final _that = this;
switch (_that) {
case _PlaceEngagementDto() when $default != null:
return $default(_that.clubLabel,_that.isForfeit,_that.athletes,_that.epreuveCategorie);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceEngagementDto implements PlaceEngagementDto {
  const _PlaceEngagementDto({@JsonKey(name: 'clubLabel') this.clubLabel, @JsonKey(name: 'isForfait') this.isForfeit, @JsonKey(name: 'athletes')  List<PlaceAthleteDto> athletes = const <PlaceAthleteDto>[], @JsonKey(name: 'EpreuveCategorie', readValue: readMap) this.epreuveCategorie}): _athletes = athletes;
  factory _PlaceEngagementDto.fromJson(Map<String, dynamic> json) => _$PlaceEngagementDtoFromJson(json);

@override@JsonKey(name: 'clubLabel') final  String? clubLabel;
@override@JsonKey(name: 'isForfait') final  bool? isForfeit;
 final  List<PlaceAthleteDto> _athletes;
@override@JsonKey(name: 'athletes') List<PlaceAthleteDto> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

@override@JsonKey(name: 'EpreuveCategorie', readValue: readMap) final  PlaceEpreuveCategorieDto? epreuveCategorie;

/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceEngagementDtoCopyWith<_PlaceEngagementDto> get copyWith => __$PlaceEngagementDtoCopyWithImpl<_PlaceEngagementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceEngagementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceEngagementDto&&(identical(other.clubLabel, clubLabel) || other.clubLabel == clubLabel)&&(identical(other.isForfeit, isForfeit) || other.isForfeit == isForfeit)&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&(identical(other.epreuveCategorie, epreuveCategorie) || other.epreuveCategorie == epreuveCategorie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,clubLabel,isForfeit,const DeepCollectionEquality().hash(_athletes),epreuveCategorie);
}

@override
String toString() {
    return 'PlaceEngagementDto(clubLabel: $clubLabel, isForfeit: $isForfeit, athletes: $athletes, epreuveCategorie: $epreuveCategorie)';
}


}

/// @nodoc
abstract mixin class _$PlaceEngagementDtoCopyWith<$Res> implements $PlaceEngagementDtoCopyWith<$Res> {
  factory _$PlaceEngagementDtoCopyWith(_PlaceEngagementDto value, $Res Function(_PlaceEngagementDto) _then) = __$PlaceEngagementDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'clubLabel') String? clubLabel,@JsonKey(name: 'isForfait') bool? isForfeit,@JsonKey(name: 'athletes') List<PlaceAthleteDto> athletes,@JsonKey(name: 'EpreuveCategorie', readValue: readMap) PlaceEpreuveCategorieDto? epreuveCategorie
});


@override $PlaceEpreuveCategorieDtoCopyWith<$Res>? get epreuveCategorie;

}
/// @nodoc
class __$PlaceEngagementDtoCopyWithImpl<$Res>
    implements _$PlaceEngagementDtoCopyWith<$Res> {
  __$PlaceEngagementDtoCopyWithImpl(this._self, this._then);

  final _PlaceEngagementDto _self;
  final $Res Function(_PlaceEngagementDto) _then;

/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clubLabel = freezed,Object? isForfeit = freezed,Object? athletes = null,Object? epreuveCategorie = freezed,}) {
  return _then(_PlaceEngagementDto(
clubLabel: freezed == clubLabel ? _self.clubLabel : clubLabel // ignore: cast_nullable_to_non_nullable
as String?,isForfeit: freezed == isForfeit ? _self.isForfeit : isForfeit // ignore: cast_nullable_to_non_nullable
as bool?,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<PlaceAthleteDto>,epreuveCategorie: freezed == epreuveCategorie ? _self.epreuveCategorie : epreuveCategorie // ignore: cast_nullable_to_non_nullable
as PlaceEpreuveCategorieDto?,
  ));
}

/// Create a copy of PlaceEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEpreuveCategorieDtoCopyWith<$Res>? get epreuveCategorie {
    if (_self.epreuveCategorie == null) {
    return null;
  }

  return $PlaceEpreuveCategorieDtoCopyWith<$Res>(_self.epreuveCategorie!, (value) {
    return _then(_self.copyWith(epreuveCategorie: value));
  });
}
}


/// @nodoc
mixin _$PlaceAthleteDto {

@JsonKey(name: 'publicLabel') String? get publicLabel;
/// Create a copy of PlaceAthleteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceAthleteDtoCopyWith<PlaceAthleteDto> get copyWith => _$PlaceAthleteDtoCopyWithImpl<PlaceAthleteDto>(this as PlaceAthleteDto, _$identity);

  /// Serializes this PlaceAthleteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceAthleteDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceAthleteDto&&(identical(other.publicLabel, _this.publicLabel) || other.publicLabel == _this.publicLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceAthleteDto;
  return Object.hash(runtimeType,_this.publicLabel);
}

@override
String toString() {
  final _this = this as PlaceAthleteDto;
  return 'PlaceAthleteDto(publicLabel: ${_this.publicLabel})';
}


}

/// @nodoc
abstract mixin class $PlaceAthleteDtoCopyWith<$Res>  {
  factory $PlaceAthleteDtoCopyWith(PlaceAthleteDto value, $Res Function(PlaceAthleteDto) _then) = _$PlaceAthleteDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'publicLabel') String? publicLabel
});




}
/// @nodoc
class _$PlaceAthleteDtoCopyWithImpl<$Res>
    implements $PlaceAthleteDtoCopyWith<$Res> {
  _$PlaceAthleteDtoCopyWithImpl(this._self, this._then);

  final PlaceAthleteDto _self;
  final $Res Function(PlaceAthleteDto) _then;

/// Create a copy of PlaceAthleteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicLabel = freezed,}) {
  return _then(PlaceAthleteDto(
publicLabel: freezed == publicLabel ? _self.publicLabel : publicLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceAthleteDto].
extension PlaceAthleteDtoPatterns on PlaceAthleteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceAthleteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceAthleteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceAthleteDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceAthleteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceAthleteDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceAthleteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'publicLabel')  String? publicLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceAthleteDto() when $default != null:
return $default(_that.publicLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'publicLabel')  String? publicLabel)  $default,) {final _that = this;
switch (_that) {
case _PlaceAthleteDto():
return $default(_that.publicLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'publicLabel')  String? publicLabel)?  $default,) {final _that = this;
switch (_that) {
case _PlaceAthleteDto() when $default != null:
return $default(_that.publicLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceAthleteDto implements PlaceAthleteDto {
  const _PlaceAthleteDto({@JsonKey(name: 'publicLabel') this.publicLabel});
  factory _PlaceAthleteDto.fromJson(Map<String, dynamic> json) => _$PlaceAthleteDtoFromJson(json);

@override@JsonKey(name: 'publicLabel') final  String? publicLabel;

/// Create a copy of PlaceAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceAthleteDtoCopyWith<_PlaceAthleteDto> get copyWith => __$PlaceAthleteDtoCopyWithImpl<_PlaceAthleteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceAthleteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceAthleteDto&&(identical(other.publicLabel, publicLabel) || other.publicLabel == publicLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,publicLabel);
}

@override
String toString() {
    return 'PlaceAthleteDto(publicLabel: $publicLabel)';
}


}

/// @nodoc
abstract mixin class _$PlaceAthleteDtoCopyWith<$Res> implements $PlaceAthleteDtoCopyWith<$Res> {
  factory _$PlaceAthleteDtoCopyWith(_PlaceAthleteDto value, $Res Function(_PlaceAthleteDto) _then) = __$PlaceAthleteDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'publicLabel') String? publicLabel
});




}
/// @nodoc
class __$PlaceAthleteDtoCopyWithImpl<$Res>
    implements _$PlaceAthleteDtoCopyWith<$Res> {
  __$PlaceAthleteDtoCopyWithImpl(this._self, this._then);

  final _PlaceAthleteDto _self;
  final $Res Function(_PlaceAthleteDto) _then;

/// Create a copy of PlaceAthleteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicLabel = freezed,}) {
  return _then(_PlaceAthleteDto(
publicLabel: freezed == publicLabel ? _self.publicLabel : publicLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlaceEpreuveCategorieDto {

@JsonKey(name: 'Categorie', readValue: readMap) PlaceCategorieDto? get categorie;@JsonKey(name: 'Epreuve', readValue: readMap) PlaceEpreuveDto? get epreuve;
/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceEpreuveCategorieDtoCopyWith<PlaceEpreuveCategorieDto> get copyWith => _$PlaceEpreuveCategorieDtoCopyWithImpl<PlaceEpreuveCategorieDto>(this as PlaceEpreuveCategorieDto, _$identity);

  /// Serializes this PlaceEpreuveCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceEpreuveCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceEpreuveCategorieDto&&(identical(other.categorie, _this.categorie) || other.categorie == _this.categorie)&&(identical(other.epreuve, _this.epreuve) || other.epreuve == _this.epreuve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceEpreuveCategorieDto;
  return Object.hash(runtimeType,_this.categorie,_this.epreuve);
}

@override
String toString() {
  final _this = this as PlaceEpreuveCategorieDto;
  return 'PlaceEpreuveCategorieDto(categorie: ${_this.categorie}, epreuve: ${_this.epreuve})';
}


}

/// @nodoc
abstract mixin class $PlaceEpreuveCategorieDtoCopyWith<$Res>  {
  factory $PlaceEpreuveCategorieDtoCopyWith(PlaceEpreuveCategorieDto value, $Res Function(PlaceEpreuveCategorieDto) _then) = _$PlaceEpreuveCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Categorie', readValue: readMap) PlaceCategorieDto? categorie,@JsonKey(name: 'Epreuve', readValue: readMap) PlaceEpreuveDto? epreuve
});


$PlaceCategorieDtoCopyWith<$Res>? get categorie;$PlaceEpreuveDtoCopyWith<$Res>? get epreuve;

}
/// @nodoc
class _$PlaceEpreuveCategorieDtoCopyWithImpl<$Res>
    implements $PlaceEpreuveCategorieDtoCopyWith<$Res> {
  _$PlaceEpreuveCategorieDtoCopyWithImpl(this._self, this._then);

  final PlaceEpreuveCategorieDto _self;
  final $Res Function(PlaceEpreuveCategorieDto) _then;

/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categorie = freezed,Object? epreuve = freezed,}) {
  return _then(PlaceEpreuveCategorieDto(
categorie: freezed == categorie ? _self.categorie : categorie // ignore: cast_nullable_to_non_nullable
as PlaceCategorieDto?,epreuve: freezed == epreuve ? _self.epreuve : epreuve // ignore: cast_nullable_to_non_nullable
as PlaceEpreuveDto?,
  ));
}
/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCategorieDtoCopyWith<$Res>? get categorie {
    if (_self.categorie == null) {
    return null;
  }

  return $PlaceCategorieDtoCopyWith<$Res>(_self.categorie!, (value) {
    return _then(_self.copyWith(categorie: value));
  });
}/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEpreuveDtoCopyWith<$Res>? get epreuve {
    if (_self.epreuve == null) {
    return null;
  }

  return $PlaceEpreuveDtoCopyWith<$Res>(_self.epreuve!, (value) {
    return _then(_self.copyWith(epreuve: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceEpreuveCategorieDto].
extension PlaceEpreuveCategorieDtoPatterns on PlaceEpreuveCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceEpreuveCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceEpreuveCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceEpreuveCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Categorie', readValue: readMap)  PlaceCategorieDto? categorie, @JsonKey(name: 'Epreuve', readValue: readMap)  PlaceEpreuveDto? epreuve)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto() when $default != null:
return $default(_that.categorie,_that.epreuve);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Categorie', readValue: readMap)  PlaceCategorieDto? categorie, @JsonKey(name: 'Epreuve', readValue: readMap)  PlaceEpreuveDto? epreuve)  $default,) {final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto():
return $default(_that.categorie,_that.epreuve);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Categorie', readValue: readMap)  PlaceCategorieDto? categorie, @JsonKey(name: 'Epreuve', readValue: readMap)  PlaceEpreuveDto? epreuve)?  $default,) {final _that = this;
switch (_that) {
case _PlaceEpreuveCategorieDto() when $default != null:
return $default(_that.categorie,_that.epreuve);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceEpreuveCategorieDto implements PlaceEpreuveCategorieDto {
  const _PlaceEpreuveCategorieDto({@JsonKey(name: 'Categorie', readValue: readMap) this.categorie, @JsonKey(name: 'Epreuve', readValue: readMap) this.epreuve});
  factory _PlaceEpreuveCategorieDto.fromJson(Map<String, dynamic> json) => _$PlaceEpreuveCategorieDtoFromJson(json);

@override@JsonKey(name: 'Categorie', readValue: readMap) final  PlaceCategorieDto? categorie;
@override@JsonKey(name: 'Epreuve', readValue: readMap) final  PlaceEpreuveDto? epreuve;

/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceEpreuveCategorieDtoCopyWith<_PlaceEpreuveCategorieDto> get copyWith => __$PlaceEpreuveCategorieDtoCopyWithImpl<_PlaceEpreuveCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceEpreuveCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceEpreuveCategorieDto&&(identical(other.categorie, categorie) || other.categorie == categorie)&&(identical(other.epreuve, epreuve) || other.epreuve == epreuve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,categorie,epreuve);
}

@override
String toString() {
    return 'PlaceEpreuveCategorieDto(categorie: $categorie, epreuve: $epreuve)';
}


}

/// @nodoc
abstract mixin class _$PlaceEpreuveCategorieDtoCopyWith<$Res> implements $PlaceEpreuveCategorieDtoCopyWith<$Res> {
  factory _$PlaceEpreuveCategorieDtoCopyWith(_PlaceEpreuveCategorieDto value, $Res Function(_PlaceEpreuveCategorieDto) _then) = __$PlaceEpreuveCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Categorie', readValue: readMap) PlaceCategorieDto? categorie,@JsonKey(name: 'Epreuve', readValue: readMap) PlaceEpreuveDto? epreuve
});


@override $PlaceCategorieDtoCopyWith<$Res>? get categorie;@override $PlaceEpreuveDtoCopyWith<$Res>? get epreuve;

}
/// @nodoc
class __$PlaceEpreuveCategorieDtoCopyWithImpl<$Res>
    implements _$PlaceEpreuveCategorieDtoCopyWith<$Res> {
  __$PlaceEpreuveCategorieDtoCopyWithImpl(this._self, this._then);

  final _PlaceEpreuveCategorieDto _self;
  final $Res Function(_PlaceEpreuveCategorieDto) _then;

/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categorie = freezed,Object? epreuve = freezed,}) {
  return _then(_PlaceEpreuveCategorieDto(
categorie: freezed == categorie ? _self.categorie : categorie // ignore: cast_nullable_to_non_nullable
as PlaceCategorieDto?,epreuve: freezed == epreuve ? _self.epreuve : epreuve // ignore: cast_nullable_to_non_nullable
as PlaceEpreuveDto?,
  ));
}

/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCategorieDtoCopyWith<$Res>? get categorie {
    if (_self.categorie == null) {
    return null;
  }

  return $PlaceCategorieDtoCopyWith<$Res>(_self.categorie!, (value) {
    return _then(_self.copyWith(categorie: value));
  });
}/// Create a copy of PlaceEpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceEpreuveDtoCopyWith<$Res>? get epreuve {
    if (_self.epreuve == null) {
    return null;
  }

  return $PlaceEpreuveDtoCopyWith<$Res>(_self.epreuve!, (value) {
    return _then(_self.copyWith(epreuve: value));
  });
}
}


/// @nodoc
mixin _$PlaceCategorieDto {

@JsonKey(name: 'Nom') String? get name;
/// Create a copy of PlaceCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceCategorieDtoCopyWith<PlaceCategorieDto> get copyWith => _$PlaceCategorieDtoCopyWithImpl<PlaceCategorieDto>(this as PlaceCategorieDto, _$identity);

  /// Serializes this PlaceCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceCategorieDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceCategorieDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as PlaceCategorieDto;
  return 'PlaceCategorieDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $PlaceCategorieDtoCopyWith<$Res>  {
  factory $PlaceCategorieDtoCopyWith(PlaceCategorieDto value, $Res Function(PlaceCategorieDto) _then) = _$PlaceCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$PlaceCategorieDtoCopyWithImpl<$Res>
    implements $PlaceCategorieDtoCopyWith<$Res> {
  _$PlaceCategorieDtoCopyWithImpl(this._self, this._then);

  final PlaceCategorieDto _self;
  final $Res Function(PlaceCategorieDto) _then;

/// Create a copy of PlaceCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(PlaceCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceCategorieDto].
extension PlaceCategorieDtoPatterns on PlaceCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceCategorieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Nom')  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceCategorieDto() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Nom')  String? name)  $default,) {final _that = this;
switch (_that) {
case _PlaceCategorieDto():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Nom')  String? name)?  $default,) {final _that = this;
switch (_that) {
case _PlaceCategorieDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceCategorieDto implements PlaceCategorieDto {
  const _PlaceCategorieDto({@JsonKey(name: 'Nom') this.name});
  factory _PlaceCategorieDto.fromJson(Map<String, dynamic> json) => _$PlaceCategorieDtoFromJson(json);

@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of PlaceCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceCategorieDtoCopyWith<_PlaceCategorieDto> get copyWith => __$PlaceCategorieDtoCopyWithImpl<_PlaceCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceCategorieDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'PlaceCategorieDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$PlaceCategorieDtoCopyWith<$Res> implements $PlaceCategorieDtoCopyWith<$Res> {
  factory _$PlaceCategorieDtoCopyWith(_PlaceCategorieDto value, $Res Function(_PlaceCategorieDto) _then) = __$PlaceCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$PlaceCategorieDtoCopyWithImpl<$Res>
    implements _$PlaceCategorieDtoCopyWith<$Res> {
  __$PlaceCategorieDtoCopyWithImpl(this._self, this._then);

  final _PlaceCategorieDto _self;
  final $Res Function(_PlaceCategorieDto) _then;

/// Create a copy of PlaceCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_PlaceCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlaceEpreuveDto {

@JsonKey(name: 'Discipline', readValue: readMap) PlaceDisciplineDto? get discipline;
/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceEpreuveDtoCopyWith<PlaceEpreuveDto> get copyWith => _$PlaceEpreuveDtoCopyWithImpl<PlaceEpreuveDto>(this as PlaceEpreuveDto, _$identity);

  /// Serializes this PlaceEpreuveDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceEpreuveDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceEpreuveDto&&(identical(other.discipline, _this.discipline) || other.discipline == _this.discipline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceEpreuveDto;
  return Object.hash(runtimeType,_this.discipline);
}

@override
String toString() {
  final _this = this as PlaceEpreuveDto;
  return 'PlaceEpreuveDto(discipline: ${_this.discipline})';
}


}

/// @nodoc
abstract mixin class $PlaceEpreuveDtoCopyWith<$Res>  {
  factory $PlaceEpreuveDtoCopyWith(PlaceEpreuveDto value, $Res Function(PlaceEpreuveDto) _then) = _$PlaceEpreuveDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Discipline', readValue: readMap) PlaceDisciplineDto? discipline
});


$PlaceDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class _$PlaceEpreuveDtoCopyWithImpl<$Res>
    implements $PlaceEpreuveDtoCopyWith<$Res> {
  _$PlaceEpreuveDtoCopyWithImpl(this._self, this._then);

  final PlaceEpreuveDto _self;
  final $Res Function(PlaceEpreuveDto) _then;

/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? discipline = freezed,}) {
  return _then(PlaceEpreuveDto(
discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as PlaceDisciplineDto?,
  ));
}
/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $PlaceDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceEpreuveDto].
extension PlaceEpreuveDtoPatterns on PlaceEpreuveDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceEpreuveDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceEpreuveDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceEpreuveDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceEpreuveDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceEpreuveDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceEpreuveDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Discipline', readValue: readMap)  PlaceDisciplineDto? discipline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceEpreuveDto() when $default != null:
return $default(_that.discipline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Discipline', readValue: readMap)  PlaceDisciplineDto? discipline)  $default,) {final _that = this;
switch (_that) {
case _PlaceEpreuveDto():
return $default(_that.discipline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Discipline', readValue: readMap)  PlaceDisciplineDto? discipline)?  $default,) {final _that = this;
switch (_that) {
case _PlaceEpreuveDto() when $default != null:
return $default(_that.discipline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceEpreuveDto implements PlaceEpreuveDto {
  const _PlaceEpreuveDto({@JsonKey(name: 'Discipline', readValue: readMap) this.discipline});
  factory _PlaceEpreuveDto.fromJson(Map<String, dynamic> json) => _$PlaceEpreuveDtoFromJson(json);

@override@JsonKey(name: 'Discipline', readValue: readMap) final  PlaceDisciplineDto? discipline;

/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceEpreuveDtoCopyWith<_PlaceEpreuveDto> get copyWith => __$PlaceEpreuveDtoCopyWithImpl<_PlaceEpreuveDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceEpreuveDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceEpreuveDto&&(identical(other.discipline, discipline) || other.discipline == discipline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,discipline);
}

@override
String toString() {
    return 'PlaceEpreuveDto(discipline: $discipline)';
}


}

/// @nodoc
abstract mixin class _$PlaceEpreuveDtoCopyWith<$Res> implements $PlaceEpreuveDtoCopyWith<$Res> {
  factory _$PlaceEpreuveDtoCopyWith(_PlaceEpreuveDto value, $Res Function(_PlaceEpreuveDto) _then) = __$PlaceEpreuveDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Discipline', readValue: readMap) PlaceDisciplineDto? discipline
});


@override $PlaceDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class __$PlaceEpreuveDtoCopyWithImpl<$Res>
    implements _$PlaceEpreuveDtoCopyWith<$Res> {
  __$PlaceEpreuveDtoCopyWithImpl(this._self, this._then);

  final _PlaceEpreuveDto _self;
  final $Res Function(_PlaceEpreuveDto) _then;

/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? discipline = freezed,}) {
  return _then(_PlaceEpreuveDto(
discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as PlaceDisciplineDto?,
  ));
}

/// Create a copy of PlaceEpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $PlaceDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// @nodoc
mixin _$PlaceDisciplineDto {

@JsonKey(name: 'isRelais') bool? get isRelay;
/// Create a copy of PlaceDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceDisciplineDtoCopyWith<PlaceDisciplineDto> get copyWith => _$PlaceDisciplineDtoCopyWithImpl<PlaceDisciplineDto>(this as PlaceDisciplineDto, _$identity);

  /// Serializes this PlaceDisciplineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceDisciplineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceDisciplineDto&&(identical(other.isRelay, _this.isRelay) || other.isRelay == _this.isRelay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceDisciplineDto;
  return Object.hash(runtimeType,_this.isRelay);
}

@override
String toString() {
  final _this = this as PlaceDisciplineDto;
  return 'PlaceDisciplineDto(isRelay: ${_this.isRelay})';
}


}

/// @nodoc
abstract mixin class $PlaceDisciplineDtoCopyWith<$Res>  {
  factory $PlaceDisciplineDtoCopyWith(PlaceDisciplineDto value, $Res Function(PlaceDisciplineDto) _then) = _$PlaceDisciplineDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'isRelais') bool? isRelay
});




}
/// @nodoc
class _$PlaceDisciplineDtoCopyWithImpl<$Res>
    implements $PlaceDisciplineDtoCopyWith<$Res> {
  _$PlaceDisciplineDtoCopyWithImpl(this._self, this._then);

  final PlaceDisciplineDto _self;
  final $Res Function(PlaceDisciplineDto) _then;

/// Create a copy of PlaceDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRelay = freezed,}) {
  return _then(PlaceDisciplineDto(
isRelay: freezed == isRelay ? _self.isRelay : isRelay // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceDisciplineDto].
extension PlaceDisciplineDtoPatterns on PlaceDisciplineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceDisciplineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceDisciplineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceDisciplineDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceDisciplineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceDisciplineDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceDisciplineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'isRelais')  bool? isRelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceDisciplineDto() when $default != null:
return $default(_that.isRelay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'isRelais')  bool? isRelay)  $default,) {final _that = this;
switch (_that) {
case _PlaceDisciplineDto():
return $default(_that.isRelay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'isRelais')  bool? isRelay)?  $default,) {final _that = this;
switch (_that) {
case _PlaceDisciplineDto() when $default != null:
return $default(_that.isRelay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceDisciplineDto implements PlaceDisciplineDto {
  const _PlaceDisciplineDto({@JsonKey(name: 'isRelais') this.isRelay});
  factory _PlaceDisciplineDto.fromJson(Map<String, dynamic> json) => _$PlaceDisciplineDtoFromJson(json);

@override@JsonKey(name: 'isRelais') final  bool? isRelay;

/// Create a copy of PlaceDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceDisciplineDtoCopyWith<_PlaceDisciplineDto> get copyWith => __$PlaceDisciplineDtoCopyWithImpl<_PlaceDisciplineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceDisciplineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceDisciplineDto&&(identical(other.isRelay, isRelay) || other.isRelay == isRelay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isRelay);
}

@override
String toString() {
    return 'PlaceDisciplineDto(isRelay: $isRelay)';
}


}

/// @nodoc
abstract mixin class _$PlaceDisciplineDtoCopyWith<$Res> implements $PlaceDisciplineDtoCopyWith<$Res> {
  factory _$PlaceDisciplineDtoCopyWith(_PlaceDisciplineDto value, $Res Function(_PlaceDisciplineDto) _then) = __$PlaceDisciplineDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'isRelais') bool? isRelay
});




}
/// @nodoc
class __$PlaceDisciplineDtoCopyWithImpl<$Res>
    implements _$PlaceDisciplineDtoCopyWith<$Res> {
  __$PlaceDisciplineDtoCopyWithImpl(this._self, this._then);

  final _PlaceDisciplineDto _self;
  final $Res Function(_PlaceDisciplineDto) _then;

/// Create a copy of PlaceDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRelay = freezed,}) {
  return _then(_PlaceDisciplineDto(
isRelay: freezed == isRelay ? _self.isRelay : isRelay // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$PlaceResultDto {

@JsonKey(name: 'tempsLabel') String? get time;@JsonKey(name: 'statutLabel') String? get statusLabel;@JsonKey(name: 'rangLabel') String? get rankLabel;@JsonKey(name: 'isDisqualifie') bool? get isDisqualified;@JsonKey(name: 'isRecord') bool? get isRecord;@JsonKey(name: 'isRecordDeFrance') bool? get isNationalRecord;
/// Create a copy of PlaceResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceResultDtoCopyWith<PlaceResultDto> get copyWith => _$PlaceResultDtoCopyWithImpl<PlaceResultDto>(this as PlaceResultDto, _$identity);

  /// Serializes this PlaceResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceResultDto&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.statusLabel, _this.statusLabel) || other.statusLabel == _this.statusLabel)&&(identical(other.rankLabel, _this.rankLabel) || other.rankLabel == _this.rankLabel)&&(identical(other.isDisqualified, _this.isDisqualified) || other.isDisqualified == _this.isDisqualified)&&(identical(other.isRecord, _this.isRecord) || other.isRecord == _this.isRecord)&&(identical(other.isNationalRecord, _this.isNationalRecord) || other.isNationalRecord == _this.isNationalRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceResultDto;
  return Object.hash(runtimeType,_this.time,_this.statusLabel,_this.rankLabel,_this.isDisqualified,_this.isRecord,_this.isNationalRecord);
}

@override
String toString() {
  final _this = this as PlaceResultDto;
  return 'PlaceResultDto(time: ${_this.time}, statusLabel: ${_this.statusLabel}, rankLabel: ${_this.rankLabel}, isDisqualified: ${_this.isDisqualified}, isRecord: ${_this.isRecord}, isNationalRecord: ${_this.isNationalRecord})';
}


}

/// @nodoc
abstract mixin class $PlaceResultDtoCopyWith<$Res>  {
  factory $PlaceResultDtoCopyWith(PlaceResultDto value, $Res Function(PlaceResultDto) _then) = _$PlaceResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'tempsLabel') String? time,@JsonKey(name: 'statutLabel') String? statusLabel,@JsonKey(name: 'rangLabel') String? rankLabel,@JsonKey(name: 'isDisqualifie') bool? isDisqualified,@JsonKey(name: 'isRecord') bool? isRecord,@JsonKey(name: 'isRecordDeFrance') bool? isNationalRecord
});




}
/// @nodoc
class _$PlaceResultDtoCopyWithImpl<$Res>
    implements $PlaceResultDtoCopyWith<$Res> {
  _$PlaceResultDtoCopyWithImpl(this._self, this._then);

  final PlaceResultDto _self;
  final $Res Function(PlaceResultDto) _then;

/// Create a copy of PlaceResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = freezed,Object? statusLabel = freezed,Object? rankLabel = freezed,Object? isDisqualified = freezed,Object? isRecord = freezed,Object? isNationalRecord = freezed,}) {
  return _then(PlaceResultDto(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,rankLabel: freezed == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String?,isDisqualified: freezed == isDisqualified ? _self.isDisqualified : isDisqualified // ignore: cast_nullable_to_non_nullable
as bool?,isRecord: freezed == isRecord ? _self.isRecord : isRecord // ignore: cast_nullable_to_non_nullable
as bool?,isNationalRecord: freezed == isNationalRecord ? _self.isNationalRecord : isNationalRecord // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceResultDto].
extension PlaceResultDtoPatterns on PlaceResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceResultDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'tempsLabel')  String? time, @JsonKey(name: 'statutLabel')  String? statusLabel, @JsonKey(name: 'rangLabel')  String? rankLabel, @JsonKey(name: 'isDisqualifie')  bool? isDisqualified, @JsonKey(name: 'isRecord')  bool? isRecord, @JsonKey(name: 'isRecordDeFrance')  bool? isNationalRecord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceResultDto() when $default != null:
return $default(_that.time,_that.statusLabel,_that.rankLabel,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'tempsLabel')  String? time, @JsonKey(name: 'statutLabel')  String? statusLabel, @JsonKey(name: 'rangLabel')  String? rankLabel, @JsonKey(name: 'isDisqualifie')  bool? isDisqualified, @JsonKey(name: 'isRecord')  bool? isRecord, @JsonKey(name: 'isRecordDeFrance')  bool? isNationalRecord)  $default,) {final _that = this;
switch (_that) {
case _PlaceResultDto():
return $default(_that.time,_that.statusLabel,_that.rankLabel,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'tempsLabel')  String? time, @JsonKey(name: 'statutLabel')  String? statusLabel, @JsonKey(name: 'rangLabel')  String? rankLabel, @JsonKey(name: 'isDisqualifie')  bool? isDisqualified, @JsonKey(name: 'isRecord')  bool? isRecord, @JsonKey(name: 'isRecordDeFrance')  bool? isNationalRecord)?  $default,) {final _that = this;
switch (_that) {
case _PlaceResultDto() when $default != null:
return $default(_that.time,_that.statusLabel,_that.rankLabel,_that.isDisqualified,_that.isRecord,_that.isNationalRecord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceResultDto implements PlaceResultDto {
  const _PlaceResultDto({@JsonKey(name: 'tempsLabel') this.time, @JsonKey(name: 'statutLabel') this.statusLabel, @JsonKey(name: 'rangLabel') this.rankLabel, @JsonKey(name: 'isDisqualifie') this.isDisqualified, @JsonKey(name: 'isRecord') this.isRecord, @JsonKey(name: 'isRecordDeFrance') this.isNationalRecord});
  factory _PlaceResultDto.fromJson(Map<String, dynamic> json) => _$PlaceResultDtoFromJson(json);

@override@JsonKey(name: 'tempsLabel') final  String? time;
@override@JsonKey(name: 'statutLabel') final  String? statusLabel;
@override@JsonKey(name: 'rangLabel') final  String? rankLabel;
@override@JsonKey(name: 'isDisqualifie') final  bool? isDisqualified;
@override@JsonKey(name: 'isRecord') final  bool? isRecord;
@override@JsonKey(name: 'isRecordDeFrance') final  bool? isNationalRecord;

/// Create a copy of PlaceResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceResultDtoCopyWith<_PlaceResultDto> get copyWith => __$PlaceResultDtoCopyWithImpl<_PlaceResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceResultDto&&(identical(other.time, time) || other.time == time)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.rankLabel, rankLabel) || other.rankLabel == rankLabel)&&(identical(other.isDisqualified, isDisqualified) || other.isDisqualified == isDisqualified)&&(identical(other.isRecord, isRecord) || other.isRecord == isRecord)&&(identical(other.isNationalRecord, isNationalRecord) || other.isNationalRecord == isNationalRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,statusLabel,rankLabel,isDisqualified,isRecord,isNationalRecord);
}

@override
String toString() {
    return 'PlaceResultDto(time: $time, statusLabel: $statusLabel, rankLabel: $rankLabel, isDisqualified: $isDisqualified, isRecord: $isRecord, isNationalRecord: $isNationalRecord)';
}


}

/// @nodoc
abstract mixin class _$PlaceResultDtoCopyWith<$Res> implements $PlaceResultDtoCopyWith<$Res> {
  factory _$PlaceResultDtoCopyWith(_PlaceResultDto value, $Res Function(_PlaceResultDto) _then) = __$PlaceResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'tempsLabel') String? time,@JsonKey(name: 'statutLabel') String? statusLabel,@JsonKey(name: 'rangLabel') String? rankLabel,@JsonKey(name: 'isDisqualifie') bool? isDisqualified,@JsonKey(name: 'isRecord') bool? isRecord,@JsonKey(name: 'isRecordDeFrance') bool? isNationalRecord
});




}
/// @nodoc
class __$PlaceResultDtoCopyWithImpl<$Res>
    implements _$PlaceResultDtoCopyWith<$Res> {
  __$PlaceResultDtoCopyWithImpl(this._self, this._then);

  final _PlaceResultDto _self;
  final $Res Function(_PlaceResultDto) _then;

/// Create a copy of PlaceResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = freezed,Object? statusLabel = freezed,Object? rankLabel = freezed,Object? isDisqualified = freezed,Object? isRecord = freezed,Object? isNationalRecord = freezed,}) {
  return _then(_PlaceResultDto(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,rankLabel: freezed == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String?,isDisqualified: freezed == isDisqualified ? _self.isDisqualified : isDisqualified // ignore: cast_nullable_to_non_nullable
as bool?,isRecord: freezed == isRecord ? _self.isRecord : isRecord // ignore: cast_nullable_to_non_nullable
as bool?,isNationalRecord: freezed == isNationalRecord ? _self.isNationalRecord : isNationalRecord // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
