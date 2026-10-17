// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evenement_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvenementDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'Debut') String? get startDate;@JsonKey(name: 'Fin') String? get endDate;@JsonKey(name: 'Specialite', readValue: readInt) int? get speciality;@JsonKey(name: 'specialiteLabel') String? get specialityLabel;@JsonKey(name: 'Lieu') String? get location;@JsonKey(name: 'Organisme', readValue: readMap) OrganismeRefDto? get organisme;
/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvenementDtoCopyWith<EvenementDto> get copyWith => _$EvenementDtoCopyWithImpl<EvenementDto>(this as EvenementDto, _$identity);

  /// Serializes this EvenementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EvenementDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvenementDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.speciality, _this.speciality) || other.speciality == _this.speciality)&&(identical(other.specialityLabel, _this.specialityLabel) || other.specialityLabel == _this.specialityLabel)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.organisme, _this.organisme) || other.organisme == _this.organisme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EvenementDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.startDate,_this.endDate,_this.speciality,_this.specialityLabel,_this.location,_this.organisme);
}

@override
String toString() {
  final _this = this as EvenementDto;
  return 'EvenementDto(id: ${_this.id}, name: ${_this.name}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, speciality: ${_this.speciality}, specialityLabel: ${_this.specialityLabel}, location: ${_this.location}, organisme: ${_this.organisme})';
}


}

/// @nodoc
abstract mixin class $EvenementDtoCopyWith<$Res>  {
  factory $EvenementDtoCopyWith(EvenementDto value, $Res Function(EvenementDto) _then) = _$EvenementDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? startDate,@JsonKey(name: 'Fin') String? endDate,@JsonKey(name: 'Specialite', readValue: readInt) int? speciality,@JsonKey(name: 'specialiteLabel') String? specialityLabel,@JsonKey(name: 'Lieu') String? location,@JsonKey(name: 'Organisme', readValue: readMap) OrganismeRefDto? organisme
});


$OrganismeRefDtoCopyWith<$Res>? get organisme;

}
/// @nodoc
class _$EvenementDtoCopyWithImpl<$Res>
    implements $EvenementDtoCopyWith<$Res> {
  _$EvenementDtoCopyWithImpl(this._self, this._then);

  final EvenementDto _self;
  final $Res Function(EvenementDto) _then;

/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? speciality = freezed,Object? specialityLabel = freezed,Object? location = freezed,Object? organisme = freezed,}) {
  return _then(EvenementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,speciality: freezed == speciality ? _self.speciality : speciality // ignore: cast_nullable_to_non_nullable
as int?,specialityLabel: freezed == specialityLabel ? _self.specialityLabel : specialityLabel // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,organisme: freezed == organisme ? _self.organisme : organisme // ignore: cast_nullable_to_non_nullable
as OrganismeRefDto?,
  ));
}
/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganismeRefDtoCopyWith<$Res>? get organisme {
    if (_self.organisme == null) {
    return null;
  }

  return $OrganismeRefDtoCopyWith<$Res>(_self.organisme!, (value) {
    return _then(_self.copyWith(organisme: value));
  });
}
}


/// Adds pattern-matching-related methods to [EvenementDto].
extension EvenementDtoPatterns on EvenementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvenementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvenementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvenementDto value)  $default,){
final _that = this;
switch (_that) {
case _EvenementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvenementDto value)?  $default,){
final _that = this;
switch (_that) {
case _EvenementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? startDate, @JsonKey(name: 'Fin')  String? endDate, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality, @JsonKey(name: 'specialiteLabel')  String? specialityLabel, @JsonKey(name: 'Lieu')  String? location, @JsonKey(name: 'Organisme', readValue: readMap)  OrganismeRefDto? organisme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvenementDto() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.speciality,_that.specialityLabel,_that.location,_that.organisme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? startDate, @JsonKey(name: 'Fin')  String? endDate, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality, @JsonKey(name: 'specialiteLabel')  String? specialityLabel, @JsonKey(name: 'Lieu')  String? location, @JsonKey(name: 'Organisme', readValue: readMap)  OrganismeRefDto? organisme)  $default,) {final _that = this;
switch (_that) {
case _EvenementDto():
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.speciality,_that.specialityLabel,_that.location,_that.organisme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? startDate, @JsonKey(name: 'Fin')  String? endDate, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality, @JsonKey(name: 'specialiteLabel')  String? specialityLabel, @JsonKey(name: 'Lieu')  String? location, @JsonKey(name: 'Organisme', readValue: readMap)  OrganismeRefDto? organisme)?  $default,) {final _that = this;
switch (_that) {
case _EvenementDto() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.speciality,_that.specialityLabel,_that.location,_that.organisme);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EvenementDto implements EvenementDto {
  const _EvenementDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'Debut') this.startDate, @JsonKey(name: 'Fin') this.endDate, @JsonKey(name: 'Specialite', readValue: readInt) this.speciality, @JsonKey(name: 'specialiteLabel') this.specialityLabel, @JsonKey(name: 'Lieu') this.location, @JsonKey(name: 'Organisme', readValue: readMap) this.organisme});
  factory _EvenementDto.fromJson(Map<String, dynamic> json) => _$EvenementDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'Debut') final  String? startDate;
@override@JsonKey(name: 'Fin') final  String? endDate;
@override@JsonKey(name: 'Specialite', readValue: readInt) final  int? speciality;
@override@JsonKey(name: 'specialiteLabel') final  String? specialityLabel;
@override@JsonKey(name: 'Lieu') final  String? location;
@override@JsonKey(name: 'Organisme', readValue: readMap) final  OrganismeRefDto? organisme;

/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvenementDtoCopyWith<_EvenementDto> get copyWith => __$EvenementDtoCopyWithImpl<_EvenementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvenementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvenementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.speciality, speciality) || other.speciality == speciality)&&(identical(other.specialityLabel, specialityLabel) || other.specialityLabel == specialityLabel)&&(identical(other.location, location) || other.location == location)&&(identical(other.organisme, organisme) || other.organisme == organisme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,startDate,endDate,speciality,specialityLabel,location,organisme);
}

@override
String toString() {
    return 'EvenementDto(id: $id, name: $name, startDate: $startDate, endDate: $endDate, speciality: $speciality, specialityLabel: $specialityLabel, location: $location, organisme: $organisme)';
}


}

/// @nodoc
abstract mixin class _$EvenementDtoCopyWith<$Res> implements $EvenementDtoCopyWith<$Res> {
  factory _$EvenementDtoCopyWith(_EvenementDto value, $Res Function(_EvenementDto) _then) = __$EvenementDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? startDate,@JsonKey(name: 'Fin') String? endDate,@JsonKey(name: 'Specialite', readValue: readInt) int? speciality,@JsonKey(name: 'specialiteLabel') String? specialityLabel,@JsonKey(name: 'Lieu') String? location,@JsonKey(name: 'Organisme', readValue: readMap) OrganismeRefDto? organisme
});


@override $OrganismeRefDtoCopyWith<$Res>? get organisme;

}
/// @nodoc
class __$EvenementDtoCopyWithImpl<$Res>
    implements _$EvenementDtoCopyWith<$Res> {
  __$EvenementDtoCopyWithImpl(this._self, this._then);

  final _EvenementDto _self;
  final $Res Function(_EvenementDto) _then;

/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? speciality = freezed,Object? specialityLabel = freezed,Object? location = freezed,Object? organisme = freezed,}) {
  return _then(_EvenementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,speciality: freezed == speciality ? _self.speciality : speciality // ignore: cast_nullable_to_non_nullable
as int?,specialityLabel: freezed == specialityLabel ? _self.specialityLabel : specialityLabel // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,organisme: freezed == organisme ? _self.organisme : organisme // ignore: cast_nullable_to_non_nullable
as OrganismeRefDto?,
  ));
}

/// Create a copy of EvenementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganismeRefDtoCopyWith<$Res>? get organisme {
    if (_self.organisme == null) {
    return null;
  }

  return $OrganismeRefDtoCopyWith<$Res>(_self.organisme!, (value) {
    return _then(_self.copyWith(organisme: value));
  });
}
}


/// @nodoc
mixin _$OrganismeRefDto {

@JsonKey(name: 'NomOrga') String? get name;@JsonKey(name: 'label') String? get label;
/// Create a copy of OrganismeRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganismeRefDtoCopyWith<OrganismeRefDto> get copyWith => _$OrganismeRefDtoCopyWithImpl<OrganismeRefDto>(this as OrganismeRefDto, _$identity);

  /// Serializes this OrganismeRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrganismeRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganismeRefDto&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrganismeRefDto;
  return Object.hash(runtimeType,_this.name,_this.label);
}

@override
String toString() {
  final _this = this as OrganismeRefDto;
  return 'OrganismeRefDto(name: ${_this.name}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $OrganismeRefDtoCopyWith<$Res>  {
  factory $OrganismeRefDtoCopyWith(OrganismeRefDto value, $Res Function(OrganismeRefDto) _then) = _$OrganismeRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'NomOrga') String? name,@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class _$OrganismeRefDtoCopyWithImpl<$Res>
    implements $OrganismeRefDtoCopyWith<$Res> {
  _$OrganismeRefDtoCopyWithImpl(this._self, this._then);

  final OrganismeRefDto _self;
  final $Res Function(OrganismeRefDto) _then;

/// Create a copy of OrganismeRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? label = freezed,}) {
  return _then(OrganismeRefDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganismeRefDto].
extension OrganismeRefDtoPatterns on OrganismeRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganismeRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganismeRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganismeRefDto value)  $default,){
final _that = this;
switch (_that) {
case _OrganismeRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganismeRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrganismeRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'NomOrga')  String? name, @JsonKey(name: 'label')  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganismeRefDto() when $default != null:
return $default(_that.name,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'NomOrga')  String? name, @JsonKey(name: 'label')  String? label)  $default,) {final _that = this;
switch (_that) {
case _OrganismeRefDto():
return $default(_that.name,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'NomOrga')  String? name, @JsonKey(name: 'label')  String? label)?  $default,) {final _that = this;
switch (_that) {
case _OrganismeRefDto() when $default != null:
return $default(_that.name,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganismeRefDto implements OrganismeRefDto {
  const _OrganismeRefDto({@JsonKey(name: 'NomOrga') this.name, @JsonKey(name: 'label') this.label});
  factory _OrganismeRefDto.fromJson(Map<String, dynamic> json) => _$OrganismeRefDtoFromJson(json);

@override@JsonKey(name: 'NomOrga') final  String? name;
@override@JsonKey(name: 'label') final  String? label;

/// Create a copy of OrganismeRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganismeRefDtoCopyWith<_OrganismeRefDto> get copyWith => __$OrganismeRefDtoCopyWithImpl<_OrganismeRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganismeRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganismeRefDto&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,label);
}

@override
String toString() {
    return 'OrganismeRefDto(name: $name, label: $label)';
}


}

/// @nodoc
abstract mixin class _$OrganismeRefDtoCopyWith<$Res> implements $OrganismeRefDtoCopyWith<$Res> {
  factory _$OrganismeRefDtoCopyWith(_OrganismeRefDto value, $Res Function(_OrganismeRefDto) _then) = __$OrganismeRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'NomOrga') String? name,@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class __$OrganismeRefDtoCopyWithImpl<$Res>
    implements _$OrganismeRefDtoCopyWith<$Res> {
  __$OrganismeRefDtoCopyWithImpl(this._self, this._then);

  final _OrganismeRefDto _self;
  final $Res Function(_OrganismeRefDto) _then;

/// Create a copy of OrganismeRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? label = freezed,}) {
  return _then(_OrganismeRefDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
