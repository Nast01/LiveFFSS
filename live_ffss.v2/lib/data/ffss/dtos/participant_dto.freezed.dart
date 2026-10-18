// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParticipantDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Prenom') String? get firstName;@JsonKey(name: 'Nom') String? get lastName;@JsonKey(name: 'Sexe') String? get gender;@JsonKey(name: 'clubLabel') String? get club;@JsonKey(name: 'isInvite') bool? get isGuest;@JsonKey(name: 'engagements') List<Object?> get entries;
/// Create a copy of ParticipantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantDtoCopyWith<ParticipantDto> get copyWith => _$ParticipantDtoCopyWithImpl<ParticipantDto>(this as ParticipantDto, _$identity);

  /// Serializes this ParticipantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ParticipantDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ParticipantDto;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.gender,_this.club,_this.isGuest,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as ParticipantDto;
  return 'ParticipantDto(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, gender: ${_this.gender}, club: ${_this.club}, isGuest: ${_this.isGuest}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $ParticipantDtoCopyWith<$Res>  {
  factory $ParticipantDtoCopyWith(ParticipantDto value, $Res Function(ParticipantDto) _then) = _$ParticipantDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Prenom') String? firstName,@JsonKey(name: 'Nom') String? lastName,@JsonKey(name: 'Sexe') String? gender,@JsonKey(name: 'clubLabel') String? club,@JsonKey(name: 'isInvite') bool? isGuest,@JsonKey(name: 'engagements') List<Object?> entries
});




}
/// @nodoc
class _$ParticipantDtoCopyWithImpl<$Res>
    implements $ParticipantDtoCopyWith<$Res> {
  _$ParticipantDtoCopyWithImpl(this._self, this._then);

  final ParticipantDto _self;
  final $Res Function(ParticipantDto) _then;

/// Create a copy of ParticipantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? gender = freezed,Object? club = freezed,Object? isGuest = freezed,Object? entries = null,}) {
  return _then(ParticipantDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,isGuest: freezed == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool?,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantDto].
extension ParticipantDtoPatterns on ParticipantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantDto value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'isInvite')  bool? isGuest, @JsonKey(name: 'engagements')  List<Object?> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantDto() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'isInvite')  bool? isGuest, @JsonKey(name: 'engagements')  List<Object?> entries)  $default,) {final _that = this;
switch (_that) {
case _ParticipantDto():
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'isInvite')  bool? isGuest, @JsonKey(name: 'engagements')  List<Object?> entries)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantDto() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParticipantDto implements ParticipantDto {
  const _ParticipantDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Prenom') this.firstName, @JsonKey(name: 'Nom') this.lastName, @JsonKey(name: 'Sexe') this.gender, @JsonKey(name: 'clubLabel') this.club, @JsonKey(name: 'isInvite') this.isGuest, @JsonKey(name: 'engagements')  List<Object?> entries = const <Object?>[]}): _entries = entries;
  factory _ParticipantDto.fromJson(Map<String, dynamic> json) => _$ParticipantDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Prenom') final  String? firstName;
@override@JsonKey(name: 'Nom') final  String? lastName;
@override@JsonKey(name: 'Sexe') final  String? gender;
@override@JsonKey(name: 'clubLabel') final  String? club;
@override@JsonKey(name: 'isInvite') final  bool? isGuest;
 final  List<Object?> _entries;
@override@JsonKey(name: 'engagements') List<Object?> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of ParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantDtoCopyWith<_ParticipantDto> get copyWith => __$ParticipantDtoCopyWithImpl<_ParticipantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantDto&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.club, club) || other.club == club)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,gender,club,isGuest,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'ParticipantDto(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, club: $club, isGuest: $isGuest, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$ParticipantDtoCopyWith<$Res> implements $ParticipantDtoCopyWith<$Res> {
  factory _$ParticipantDtoCopyWith(_ParticipantDto value, $Res Function(_ParticipantDto) _then) = __$ParticipantDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Prenom') String? firstName,@JsonKey(name: 'Nom') String? lastName,@JsonKey(name: 'Sexe') String? gender,@JsonKey(name: 'clubLabel') String? club,@JsonKey(name: 'isInvite') bool? isGuest,@JsonKey(name: 'engagements') List<Object?> entries
});




}
/// @nodoc
class __$ParticipantDtoCopyWithImpl<$Res>
    implements _$ParticipantDtoCopyWith<$Res> {
  __$ParticipantDtoCopyWithImpl(this._self, this._then);

  final _ParticipantDto _self;
  final $Res Function(_ParticipantDto) _then;

/// Create a copy of ParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? gender = freezed,Object? club = freezed,Object? isGuest = freezed,Object? entries = null,}) {
  return _then(_ParticipantDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,isGuest: freezed == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool?,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}


}


/// @nodoc
mixin _$ParticipantEngagementDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'categorie', readValue: readMap) ParticipantCategorieDto? get category;@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? get event;
/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantEngagementDtoCopyWith<ParticipantEngagementDto> get copyWith => _$ParticipantEngagementDtoCopyWithImpl<ParticipantEngagementDto>(this as ParticipantEngagementDto, _$identity);

  /// Serializes this ParticipantEngagementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ParticipantEngagementDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantEngagementDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.event, _this.event) || other.event == _this.event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ParticipantEngagementDto;
  return Object.hash(runtimeType,_this.id,_this.category,_this.event);
}

@override
String toString() {
  final _this = this as ParticipantEngagementDto;
  return 'ParticipantEngagementDto(id: ${_this.id}, category: ${_this.category}, event: ${_this.event})';
}


}

/// @nodoc
abstract mixin class $ParticipantEngagementDtoCopyWith<$Res>  {
  factory $ParticipantEngagementDtoCopyWith(ParticipantEngagementDto value, $Res Function(ParticipantEngagementDto) _then) = _$ParticipantEngagementDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'categorie', readValue: readMap) ParticipantCategorieDto? category,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event
});


$ParticipantCategorieDtoCopyWith<$Res>? get category;$EpreuveDtoCopyWith<$Res>? get event;

}
/// @nodoc
class _$ParticipantEngagementDtoCopyWithImpl<$Res>
    implements $ParticipantEngagementDtoCopyWith<$Res> {
  _$ParticipantEngagementDtoCopyWithImpl(this._self, this._then);

  final ParticipantEngagementDto _self;
  final $Res Function(ParticipantEngagementDto) _then;

/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? category = freezed,Object? event = freezed,}) {
  return _then(ParticipantEngagementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ParticipantCategorieDto?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as EpreuveDto?,
  ));
}
/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantCategorieDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $ParticipantCategorieDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveDtoCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $EpreuveDtoCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [ParticipantEngagementDto].
extension ParticipantEngagementDtoPatterns on ParticipantEngagementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantEngagementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantEngagementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantEngagementDto value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantEngagementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantEngagementDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantEngagementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'categorie', readValue: readMap)  ParticipantCategorieDto? category, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantEngagementDto() when $default != null:
return $default(_that.id,_that.category,_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'categorie', readValue: readMap)  ParticipantCategorieDto? category, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event)  $default,) {final _that = this;
switch (_that) {
case _ParticipantEngagementDto():
return $default(_that.id,_that.category,_that.event);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'categorie', readValue: readMap)  ParticipantCategorieDto? category, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantEngagementDto() when $default != null:
return $default(_that.id,_that.category,_that.event);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParticipantEngagementDto implements ParticipantEngagementDto {
  const _ParticipantEngagementDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'categorie', readValue: readMap) this.category, @JsonKey(name: 'epreuve', readValue: readMap) this.event});
  factory _ParticipantEngagementDto.fromJson(Map<String, dynamic> json) => _$ParticipantEngagementDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'categorie', readValue: readMap) final  ParticipantCategorieDto? category;
@override@JsonKey(name: 'epreuve', readValue: readMap) final  EpreuveDto? event;

/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantEngagementDtoCopyWith<_ParticipantEngagementDto> get copyWith => __$ParticipantEngagementDtoCopyWithImpl<_ParticipantEngagementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantEngagementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantEngagementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.event, event) || other.event == event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,category,event);
}

@override
String toString() {
    return 'ParticipantEngagementDto(id: $id, category: $category, event: $event)';
}


}

/// @nodoc
abstract mixin class _$ParticipantEngagementDtoCopyWith<$Res> implements $ParticipantEngagementDtoCopyWith<$Res> {
  factory _$ParticipantEngagementDtoCopyWith(_ParticipantEngagementDto value, $Res Function(_ParticipantEngagementDto) _then) = __$ParticipantEngagementDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'categorie', readValue: readMap) ParticipantCategorieDto? category,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event
});


@override $ParticipantCategorieDtoCopyWith<$Res>? get category;@override $EpreuveDtoCopyWith<$Res>? get event;

}
/// @nodoc
class __$ParticipantEngagementDtoCopyWithImpl<$Res>
    implements _$ParticipantEngagementDtoCopyWith<$Res> {
  __$ParticipantEngagementDtoCopyWithImpl(this._self, this._then);

  final _ParticipantEngagementDto _self;
  final $Res Function(_ParticipantEngagementDto) _then;

/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? category = freezed,Object? event = freezed,}) {
  return _then(_ParticipantEngagementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ParticipantCategorieDto?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as EpreuveDto?,
  ));
}

/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantCategorieDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $ParticipantCategorieDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ParticipantEngagementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveDtoCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $EpreuveDtoCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// @nodoc
mixin _$ParticipantCategorieDto {

@JsonKey(name: 'label') String? get label;
/// Create a copy of ParticipantCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCategorieDtoCopyWith<ParticipantCategorieDto> get copyWith => _$ParticipantCategorieDtoCopyWithImpl<ParticipantCategorieDto>(this as ParticipantCategorieDto, _$identity);

  /// Serializes this ParticipantCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ParticipantCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantCategorieDto&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ParticipantCategorieDto;
  return Object.hash(runtimeType,_this.label);
}

@override
String toString() {
  final _this = this as ParticipantCategorieDto;
  return 'ParticipantCategorieDto(label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $ParticipantCategorieDtoCopyWith<$Res>  {
  factory $ParticipantCategorieDtoCopyWith(ParticipantCategorieDto value, $Res Function(ParticipantCategorieDto) _then) = _$ParticipantCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class _$ParticipantCategorieDtoCopyWithImpl<$Res>
    implements $ParticipantCategorieDtoCopyWith<$Res> {
  _$ParticipantCategorieDtoCopyWithImpl(this._self, this._then);

  final ParticipantCategorieDto _self;
  final $Res Function(ParticipantCategorieDto) _then;

/// Create a copy of ParticipantCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,}) {
  return _then(ParticipantCategorieDto(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantCategorieDto].
extension ParticipantCategorieDtoPatterns on ParticipantCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantCategorieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantCategorieDto() when $default != null:
return $default(_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String? label)  $default,) {final _that = this;
switch (_that) {
case _ParticipantCategorieDto():
return $default(_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'label')  String? label)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantCategorieDto() when $default != null:
return $default(_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParticipantCategorieDto implements ParticipantCategorieDto {
  const _ParticipantCategorieDto({@JsonKey(name: 'label') this.label});
  factory _ParticipantCategorieDto.fromJson(Map<String, dynamic> json) => _$ParticipantCategorieDtoFromJson(json);

@override@JsonKey(name: 'label') final  String? label;

/// Create a copy of ParticipantCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCategorieDtoCopyWith<_ParticipantCategorieDto> get copyWith => __$ParticipantCategorieDtoCopyWithImpl<_ParticipantCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantCategorieDto&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label);
}

@override
String toString() {
    return 'ParticipantCategorieDto(label: $label)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCategorieDtoCopyWith<$Res> implements $ParticipantCategorieDtoCopyWith<$Res> {
  factory _$ParticipantCategorieDtoCopyWith(_ParticipantCategorieDto value, $Res Function(_ParticipantCategorieDto) _then) = __$ParticipantCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class __$ParticipantCategorieDtoCopyWithImpl<$Res>
    implements _$ParticipantCategorieDtoCopyWith<$Res> {
  __$ParticipantCategorieDtoCopyWithImpl(this._self, this._then);

  final _ParticipantCategorieDto _self;
  final $Res Function(_ParticipantCategorieDto) _then;

/// Create a copy of ParticipantCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,}) {
  return _then(_ParticipantCategorieDto(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
