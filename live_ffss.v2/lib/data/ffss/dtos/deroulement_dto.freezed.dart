// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deroulement_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeroulementDto {

@JsonKey(name: 'Id', readValue: _readId) int? get id;@JsonKey(name: 'label') String? get label;@JsonKey(name: 'IdDiscipline', readValue: readInt) int? get disciplineId;@JsonKey(name: 'Genre') String? get gender;@JsonKey(name: 'genreLabel') String? get genderLabel;@JsonKey(name: 'Discipline', readValue: _readDiscipline) DeroulementDisciplineDto? get discipline;@JsonKey(name: 'categories', readValue: readList) List<Object?> get categories;@JsonKey(name: 'parties') List<PartieDto> get parties;
/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeroulementDtoCopyWith<DeroulementDto> get copyWith => _$DeroulementDtoCopyWithImpl<DeroulementDto>(this as DeroulementDto, _$identity);

  /// Serializes this DeroulementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeroulementDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeroulementDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.disciplineId, _this.disciplineId) || other.disciplineId == _this.disciplineId)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.genderLabel, _this.genderLabel) || other.genderLabel == _this.genderLabel)&&(identical(other.discipline, _this.discipline) || other.discipline == _this.discipline)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.parties, _this.parties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeroulementDto;
  return Object.hash(runtimeType,_this.id,_this.label,_this.disciplineId,_this.gender,_this.genderLabel,_this.discipline,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.parties));
}

@override
String toString() {
  final _this = this as DeroulementDto;
  return 'DeroulementDto(id: ${_this.id}, label: ${_this.label}, disciplineId: ${_this.disciplineId}, gender: ${_this.gender}, genderLabel: ${_this.genderLabel}, discipline: ${_this.discipline}, categories: ${_this.categories}, parties: ${_this.parties})';
}


}

/// @nodoc
abstract mixin class $DeroulementDtoCopyWith<$Res>  {
  factory $DeroulementDtoCopyWith(DeroulementDto value, $Res Function(DeroulementDto) _then) = _$DeroulementDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readId) int? id,@JsonKey(name: 'label') String? label,@JsonKey(name: 'IdDiscipline', readValue: readInt) int? disciplineId,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'genreLabel') String? genderLabel,@JsonKey(name: 'Discipline', readValue: _readDiscipline) DeroulementDisciplineDto? discipline,@JsonKey(name: 'categories', readValue: readList) List<Object?> categories,@JsonKey(name: 'parties') List<PartieDto> parties
});


$DeroulementDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class _$DeroulementDtoCopyWithImpl<$Res>
    implements $DeroulementDtoCopyWith<$Res> {
  _$DeroulementDtoCopyWithImpl(this._self, this._then);

  final DeroulementDto _self;
  final $Res Function(DeroulementDto) _then;

/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,Object? disciplineId = freezed,Object? gender = freezed,Object? genderLabel = freezed,Object? discipline = freezed,Object? categories = null,Object? parties = null,}) {
  return _then(DeroulementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,disciplineId: freezed == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,genderLabel: freezed == genderLabel ? _self.genderLabel : genderLabel // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as DeroulementDisciplineDto?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Object?>,parties: null == parties ? _self.parties : parties // ignore: cast_nullable_to_non_nullable
as List<PartieDto>,
  ));
}
/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeroulementDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $DeroulementDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeroulementDto].
extension DeroulementDtoPatterns on DeroulementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeroulementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeroulementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeroulementDto value)  $default,){
final _that = this;
switch (_that) {
case _DeroulementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeroulementDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeroulementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readId)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'genreLabel')  String? genderLabel, @JsonKey(name: 'Discipline', readValue: _readDiscipline)  DeroulementDisciplineDto? discipline, @JsonKey(name: 'categories', readValue: readList)  List<Object?> categories, @JsonKey(name: 'parties')  List<PartieDto> parties)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeroulementDto() when $default != null:
return $default(_that.id,_that.label,_that.disciplineId,_that.gender,_that.genderLabel,_that.discipline,_that.categories,_that.parties);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readId)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'genreLabel')  String? genderLabel, @JsonKey(name: 'Discipline', readValue: _readDiscipline)  DeroulementDisciplineDto? discipline, @JsonKey(name: 'categories', readValue: readList)  List<Object?> categories, @JsonKey(name: 'parties')  List<PartieDto> parties)  $default,) {final _that = this;
switch (_that) {
case _DeroulementDto():
return $default(_that.id,_that.label,_that.disciplineId,_that.gender,_that.genderLabel,_that.discipline,_that.categories,_that.parties);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: _readId)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'genreLabel')  String? genderLabel, @JsonKey(name: 'Discipline', readValue: _readDiscipline)  DeroulementDisciplineDto? discipline, @JsonKey(name: 'categories', readValue: readList)  List<Object?> categories, @JsonKey(name: 'parties')  List<PartieDto> parties)?  $default,) {final _that = this;
switch (_that) {
case _DeroulementDto() when $default != null:
return $default(_that.id,_that.label,_that.disciplineId,_that.gender,_that.genderLabel,_that.discipline,_that.categories,_that.parties);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeroulementDto implements DeroulementDto {
  const _DeroulementDto({@JsonKey(name: 'Id', readValue: _readId) this.id, @JsonKey(name: 'label') this.label, @JsonKey(name: 'IdDiscipline', readValue: readInt) this.disciplineId, @JsonKey(name: 'Genre') this.gender, @JsonKey(name: 'genreLabel') this.genderLabel, @JsonKey(name: 'Discipline', readValue: _readDiscipline) this.discipline, @JsonKey(name: 'categories', readValue: readList)  List<Object?> categories = const <Object?>[], @JsonKey(name: 'parties')  List<PartieDto> parties = const <PartieDto>[]}): _categories = categories,_parties = parties;
  factory _DeroulementDto.fromJson(Map<String, dynamic> json) => _$DeroulementDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: _readId) final  int? id;
@override@JsonKey(name: 'label') final  String? label;
@override@JsonKey(name: 'IdDiscipline', readValue: readInt) final  int? disciplineId;
@override@JsonKey(name: 'Genre') final  String? gender;
@override@JsonKey(name: 'genreLabel') final  String? genderLabel;
@override@JsonKey(name: 'Discipline', readValue: _readDiscipline) final  DeroulementDisciplineDto? discipline;
 final  List<Object?> _categories;
@override@JsonKey(name: 'categories', readValue: readList) List<Object?> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<PartieDto> _parties;
@override@JsonKey(name: 'parties') List<PartieDto> get parties {
  if (_parties is EqualUnmodifiableListView) return _parties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parties);
}


/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeroulementDtoCopyWith<_DeroulementDto> get copyWith => __$DeroulementDtoCopyWithImpl<_DeroulementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeroulementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeroulementDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.disciplineId, disciplineId) || other.disciplineId == disciplineId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.genderLabel, genderLabel) || other.genderLabel == genderLabel)&&(identical(other.discipline, discipline) || other.discipline == discipline)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.parties, _parties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,disciplineId,gender,genderLabel,discipline,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_parties));
}

@override
String toString() {
    return 'DeroulementDto(id: $id, label: $label, disciplineId: $disciplineId, gender: $gender, genderLabel: $genderLabel, discipline: $discipline, categories: $categories, parties: $parties)';
}


}

/// @nodoc
abstract mixin class _$DeroulementDtoCopyWith<$Res> implements $DeroulementDtoCopyWith<$Res> {
  factory _$DeroulementDtoCopyWith(_DeroulementDto value, $Res Function(_DeroulementDto) _then) = __$DeroulementDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readId) int? id,@JsonKey(name: 'label') String? label,@JsonKey(name: 'IdDiscipline', readValue: readInt) int? disciplineId,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'genreLabel') String? genderLabel,@JsonKey(name: 'Discipline', readValue: _readDiscipline) DeroulementDisciplineDto? discipline,@JsonKey(name: 'categories', readValue: readList) List<Object?> categories,@JsonKey(name: 'parties') List<PartieDto> parties
});


@override $DeroulementDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class __$DeroulementDtoCopyWithImpl<$Res>
    implements _$DeroulementDtoCopyWith<$Res> {
  __$DeroulementDtoCopyWithImpl(this._self, this._then);

  final _DeroulementDto _self;
  final $Res Function(_DeroulementDto) _then;

/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,Object? disciplineId = freezed,Object? gender = freezed,Object? genderLabel = freezed,Object? discipline = freezed,Object? categories = null,Object? parties = null,}) {
  return _then(_DeroulementDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,disciplineId: freezed == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,genderLabel: freezed == genderLabel ? _self.genderLabel : genderLabel // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as DeroulementDisciplineDto?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Object?>,parties: null == parties ? _self._parties : parties // ignore: cast_nullable_to_non_nullable
as List<PartieDto>,
  ));
}

/// Create a copy of DeroulementDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeroulementDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $DeroulementDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// @nodoc
mixin _$DeroulementDisciplineDto {

@JsonKey(name: 'Nom') String? get name;
/// Create a copy of DeroulementDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeroulementDisciplineDtoCopyWith<DeroulementDisciplineDto> get copyWith => _$DeroulementDisciplineDtoCopyWithImpl<DeroulementDisciplineDto>(this as DeroulementDisciplineDto, _$identity);

  /// Serializes this DeroulementDisciplineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeroulementDisciplineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeroulementDisciplineDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeroulementDisciplineDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as DeroulementDisciplineDto;
  return 'DeroulementDisciplineDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $DeroulementDisciplineDtoCopyWith<$Res>  {
  factory $DeroulementDisciplineDtoCopyWith(DeroulementDisciplineDto value, $Res Function(DeroulementDisciplineDto) _then) = _$DeroulementDisciplineDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$DeroulementDisciplineDtoCopyWithImpl<$Res>
    implements $DeroulementDisciplineDtoCopyWith<$Res> {
  _$DeroulementDisciplineDtoCopyWithImpl(this._self, this._then);

  final DeroulementDisciplineDto _self;
  final $Res Function(DeroulementDisciplineDto) _then;

/// Create a copy of DeroulementDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(DeroulementDisciplineDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeroulementDisciplineDto].
extension DeroulementDisciplineDtoPatterns on DeroulementDisciplineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeroulementDisciplineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeroulementDisciplineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeroulementDisciplineDto value)  $default,){
final _that = this;
switch (_that) {
case _DeroulementDisciplineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeroulementDisciplineDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeroulementDisciplineDto() when $default != null:
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
case _DeroulementDisciplineDto() when $default != null:
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
case _DeroulementDisciplineDto():
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
case _DeroulementDisciplineDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeroulementDisciplineDto implements DeroulementDisciplineDto {
  const _DeroulementDisciplineDto({@JsonKey(name: 'Nom') this.name});
  factory _DeroulementDisciplineDto.fromJson(Map<String, dynamic> json) => _$DeroulementDisciplineDtoFromJson(json);

@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of DeroulementDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeroulementDisciplineDtoCopyWith<_DeroulementDisciplineDto> get copyWith => __$DeroulementDisciplineDtoCopyWithImpl<_DeroulementDisciplineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeroulementDisciplineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeroulementDisciplineDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'DeroulementDisciplineDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$DeroulementDisciplineDtoCopyWith<$Res> implements $DeroulementDisciplineDtoCopyWith<$Res> {
  factory _$DeroulementDisciplineDtoCopyWith(_DeroulementDisciplineDto value, $Res Function(_DeroulementDisciplineDto) _then) = __$DeroulementDisciplineDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$DeroulementDisciplineDtoCopyWithImpl<$Res>
    implements _$DeroulementDisciplineDtoCopyWith<$Res> {
  __$DeroulementDisciplineDtoCopyWithImpl(this._self, this._then);

  final _DeroulementDisciplineDto _self;
  final $Res Function(_DeroulementDisciplineDto) _then;

/// Create a copy of DeroulementDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_DeroulementDisciplineDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DeroulementCategorieDto {

@JsonKey(name: 'Nom') String? get name;
/// Create a copy of DeroulementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeroulementCategorieDtoCopyWith<DeroulementCategorieDto> get copyWith => _$DeroulementCategorieDtoCopyWithImpl<DeroulementCategorieDto>(this as DeroulementCategorieDto, _$identity);

  /// Serializes this DeroulementCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeroulementCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeroulementCategorieDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeroulementCategorieDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as DeroulementCategorieDto;
  return 'DeroulementCategorieDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $DeroulementCategorieDtoCopyWith<$Res>  {
  factory $DeroulementCategorieDtoCopyWith(DeroulementCategorieDto value, $Res Function(DeroulementCategorieDto) _then) = _$DeroulementCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$DeroulementCategorieDtoCopyWithImpl<$Res>
    implements $DeroulementCategorieDtoCopyWith<$Res> {
  _$DeroulementCategorieDtoCopyWithImpl(this._self, this._then);

  final DeroulementCategorieDto _self;
  final $Res Function(DeroulementCategorieDto) _then;

/// Create a copy of DeroulementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(DeroulementCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeroulementCategorieDto].
extension DeroulementCategorieDtoPatterns on DeroulementCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeroulementCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeroulementCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeroulementCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _DeroulementCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeroulementCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeroulementCategorieDto() when $default != null:
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
case _DeroulementCategorieDto() when $default != null:
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
case _DeroulementCategorieDto():
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
case _DeroulementCategorieDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeroulementCategorieDto implements DeroulementCategorieDto {
  const _DeroulementCategorieDto({@JsonKey(name: 'Nom') this.name});
  factory _DeroulementCategorieDto.fromJson(Map<String, dynamic> json) => _$DeroulementCategorieDtoFromJson(json);

@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of DeroulementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeroulementCategorieDtoCopyWith<_DeroulementCategorieDto> get copyWith => __$DeroulementCategorieDtoCopyWithImpl<_DeroulementCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeroulementCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeroulementCategorieDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'DeroulementCategorieDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$DeroulementCategorieDtoCopyWith<$Res> implements $DeroulementCategorieDtoCopyWith<$Res> {
  factory _$DeroulementCategorieDtoCopyWith(_DeroulementCategorieDto value, $Res Function(_DeroulementCategorieDto) _then) = __$DeroulementCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$DeroulementCategorieDtoCopyWithImpl<$Res>
    implements _$DeroulementCategorieDtoCopyWith<$Res> {
  __$DeroulementCategorieDtoCopyWithImpl(this._self, this._then);

  final _DeroulementCategorieDto _self;
  final $Res Function(_DeroulementCategorieDto) _then;

/// Create a copy of DeroulementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_DeroulementCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PartieDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'ordre', readValue: readInt) int? get order;@JsonKey(name: 'niveau') String? get level;@JsonKey(name: 'label') String? get label;@JsonKey(name: 'nbCourses', readValue: readInt) int? get heatCount;@JsonKey(name: 'nbPlaceParCourse', readValue: readInt) int? get placesPerHeat;@JsonKey(name: 'nbPlaceQualificative', readValue: readInt) int? get qualifyingPlaces;@JsonKey(name: 'logiqueQualification') String? get qualificationLogic;@JsonKey(name: 'deroulement', readValue: readMap) DeroulementDto? get deroulement;
/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartieDtoCopyWith<PartieDto> get copyWith => _$PartieDtoCopyWithImpl<PartieDto>(this as PartieDto, _$identity);

  /// Serializes this PartieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PartieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartieDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.heatCount, _this.heatCount) || other.heatCount == _this.heatCount)&&(identical(other.placesPerHeat, _this.placesPerHeat) || other.placesPerHeat == _this.placesPerHeat)&&(identical(other.qualifyingPlaces, _this.qualifyingPlaces) || other.qualifyingPlaces == _this.qualifyingPlaces)&&(identical(other.qualificationLogic, _this.qualificationLogic) || other.qualificationLogic == _this.qualificationLogic)&&(identical(other.deroulement, _this.deroulement) || other.deroulement == _this.deroulement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PartieDto;
  return Object.hash(runtimeType,_this.id,_this.order,_this.level,_this.label,_this.heatCount,_this.placesPerHeat,_this.qualifyingPlaces,_this.qualificationLogic,_this.deroulement);
}

@override
String toString() {
  final _this = this as PartieDto;
  return 'PartieDto(id: ${_this.id}, order: ${_this.order}, level: ${_this.level}, label: ${_this.label}, heatCount: ${_this.heatCount}, placesPerHeat: ${_this.placesPerHeat}, qualifyingPlaces: ${_this.qualifyingPlaces}, qualificationLogic: ${_this.qualificationLogic}, deroulement: ${_this.deroulement})';
}


}

/// @nodoc
abstract mixin class $PartieDtoCopyWith<$Res>  {
  factory $PartieDtoCopyWith(PartieDto value, $Res Function(PartieDto) _then) = _$PartieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'ordre', readValue: readInt) int? order,@JsonKey(name: 'niveau') String? level,@JsonKey(name: 'label') String? label,@JsonKey(name: 'nbCourses', readValue: readInt) int? heatCount,@JsonKey(name: 'nbPlaceParCourse', readValue: readInt) int? placesPerHeat,@JsonKey(name: 'nbPlaceQualificative', readValue: readInt) int? qualifyingPlaces,@JsonKey(name: 'logiqueQualification') String? qualificationLogic,@JsonKey(name: 'deroulement', readValue: readMap) DeroulementDto? deroulement
});


$DeroulementDtoCopyWith<$Res>? get deroulement;

}
/// @nodoc
class _$PartieDtoCopyWithImpl<$Res>
    implements $PartieDtoCopyWith<$Res> {
  _$PartieDtoCopyWithImpl(this._self, this._then);

  final PartieDto _self;
  final $Res Function(PartieDto) _then;

/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? order = freezed,Object? level = freezed,Object? label = freezed,Object? heatCount = freezed,Object? placesPerHeat = freezed,Object? qualifyingPlaces = freezed,Object? qualificationLogic = freezed,Object? deroulement = freezed,}) {
  return _then(PartieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,heatCount: freezed == heatCount ? _self.heatCount : heatCount // ignore: cast_nullable_to_non_nullable
as int?,placesPerHeat: freezed == placesPerHeat ? _self.placesPerHeat : placesPerHeat // ignore: cast_nullable_to_non_nullable
as int?,qualifyingPlaces: freezed == qualifyingPlaces ? _self.qualifyingPlaces : qualifyingPlaces // ignore: cast_nullable_to_non_nullable
as int?,qualificationLogic: freezed == qualificationLogic ? _self.qualificationLogic : qualificationLogic // ignore: cast_nullable_to_non_nullable
as String?,deroulement: freezed == deroulement ? _self.deroulement : deroulement // ignore: cast_nullable_to_non_nullable
as DeroulementDto?,
  ));
}
/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeroulementDtoCopyWith<$Res>? get deroulement {
    if (_self.deroulement == null) {
    return null;
  }

  return $DeroulementDtoCopyWith<$Res>(_self.deroulement!, (value) {
    return _then(_self.copyWith(deroulement: value));
  });
}
}


/// Adds pattern-matching-related methods to [PartieDto].
extension PartieDtoPatterns on PartieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartieDto value)  $default,){
final _that = this;
switch (_that) {
case _PartieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartieDto value)?  $default,){
final _that = this;
switch (_that) {
case _PartieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'ordre', readValue: readInt)  int? order, @JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'nbCourses', readValue: readInt)  int? heatCount, @JsonKey(name: 'nbPlaceParCourse', readValue: readInt)  int? placesPerHeat, @JsonKey(name: 'nbPlaceQualificative', readValue: readInt)  int? qualifyingPlaces, @JsonKey(name: 'logiqueQualification')  String? qualificationLogic, @JsonKey(name: 'deroulement', readValue: readMap)  DeroulementDto? deroulement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartieDto() when $default != null:
return $default(_that.id,_that.order,_that.level,_that.label,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces,_that.qualificationLogic,_that.deroulement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'ordre', readValue: readInt)  int? order, @JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'nbCourses', readValue: readInt)  int? heatCount, @JsonKey(name: 'nbPlaceParCourse', readValue: readInt)  int? placesPerHeat, @JsonKey(name: 'nbPlaceQualificative', readValue: readInt)  int? qualifyingPlaces, @JsonKey(name: 'logiqueQualification')  String? qualificationLogic, @JsonKey(name: 'deroulement', readValue: readMap)  DeroulementDto? deroulement)  $default,) {final _that = this;
switch (_that) {
case _PartieDto():
return $default(_that.id,_that.order,_that.level,_that.label,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces,_that.qualificationLogic,_that.deroulement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'ordre', readValue: readInt)  int? order, @JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'nbCourses', readValue: readInt)  int? heatCount, @JsonKey(name: 'nbPlaceParCourse', readValue: readInt)  int? placesPerHeat, @JsonKey(name: 'nbPlaceQualificative', readValue: readInt)  int? qualifyingPlaces, @JsonKey(name: 'logiqueQualification')  String? qualificationLogic, @JsonKey(name: 'deroulement', readValue: readMap)  DeroulementDto? deroulement)?  $default,) {final _that = this;
switch (_that) {
case _PartieDto() when $default != null:
return $default(_that.id,_that.order,_that.level,_that.label,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces,_that.qualificationLogic,_that.deroulement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartieDto implements PartieDto {
  const _PartieDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'ordre', readValue: readInt) this.order, @JsonKey(name: 'niveau') this.level, @JsonKey(name: 'label') this.label, @JsonKey(name: 'nbCourses', readValue: readInt) this.heatCount, @JsonKey(name: 'nbPlaceParCourse', readValue: readInt) this.placesPerHeat, @JsonKey(name: 'nbPlaceQualificative', readValue: readInt) this.qualifyingPlaces, @JsonKey(name: 'logiqueQualification') this.qualificationLogic, @JsonKey(name: 'deroulement', readValue: readMap) this.deroulement});
  factory _PartieDto.fromJson(Map<String, dynamic> json) => _$PartieDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'ordre', readValue: readInt) final  int? order;
@override@JsonKey(name: 'niveau') final  String? level;
@override@JsonKey(name: 'label') final  String? label;
@override@JsonKey(name: 'nbCourses', readValue: readInt) final  int? heatCount;
@override@JsonKey(name: 'nbPlaceParCourse', readValue: readInt) final  int? placesPerHeat;
@override@JsonKey(name: 'nbPlaceQualificative', readValue: readInt) final  int? qualifyingPlaces;
@override@JsonKey(name: 'logiqueQualification') final  String? qualificationLogic;
@override@JsonKey(name: 'deroulement', readValue: readMap) final  DeroulementDto? deroulement;

/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartieDtoCopyWith<_PartieDto> get copyWith => __$PartieDtoCopyWithImpl<_PartieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.level, level) || other.level == level)&&(identical(other.label, label) || other.label == label)&&(identical(other.heatCount, heatCount) || other.heatCount == heatCount)&&(identical(other.placesPerHeat, placesPerHeat) || other.placesPerHeat == placesPerHeat)&&(identical(other.qualifyingPlaces, qualifyingPlaces) || other.qualifyingPlaces == qualifyingPlaces)&&(identical(other.qualificationLogic, qualificationLogic) || other.qualificationLogic == qualificationLogic)&&(identical(other.deroulement, deroulement) || other.deroulement == deroulement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,order,level,label,heatCount,placesPerHeat,qualifyingPlaces,qualificationLogic,deroulement);
}

@override
String toString() {
    return 'PartieDto(id: $id, order: $order, level: $level, label: $label, heatCount: $heatCount, placesPerHeat: $placesPerHeat, qualifyingPlaces: $qualifyingPlaces, qualificationLogic: $qualificationLogic, deroulement: $deroulement)';
}


}

/// @nodoc
abstract mixin class _$PartieDtoCopyWith<$Res> implements $PartieDtoCopyWith<$Res> {
  factory _$PartieDtoCopyWith(_PartieDto value, $Res Function(_PartieDto) _then) = __$PartieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'ordre', readValue: readInt) int? order,@JsonKey(name: 'niveau') String? level,@JsonKey(name: 'label') String? label,@JsonKey(name: 'nbCourses', readValue: readInt) int? heatCount,@JsonKey(name: 'nbPlaceParCourse', readValue: readInt) int? placesPerHeat,@JsonKey(name: 'nbPlaceQualificative', readValue: readInt) int? qualifyingPlaces,@JsonKey(name: 'logiqueQualification') String? qualificationLogic,@JsonKey(name: 'deroulement', readValue: readMap) DeroulementDto? deroulement
});


@override $DeroulementDtoCopyWith<$Res>? get deroulement;

}
/// @nodoc
class __$PartieDtoCopyWithImpl<$Res>
    implements _$PartieDtoCopyWith<$Res> {
  __$PartieDtoCopyWithImpl(this._self, this._then);

  final _PartieDto _self;
  final $Res Function(_PartieDto) _then;

/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? order = freezed,Object? level = freezed,Object? label = freezed,Object? heatCount = freezed,Object? placesPerHeat = freezed,Object? qualifyingPlaces = freezed,Object? qualificationLogic = freezed,Object? deroulement = freezed,}) {
  return _then(_PartieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,heatCount: freezed == heatCount ? _self.heatCount : heatCount // ignore: cast_nullable_to_non_nullable
as int?,placesPerHeat: freezed == placesPerHeat ? _self.placesPerHeat : placesPerHeat // ignore: cast_nullable_to_non_nullable
as int?,qualifyingPlaces: freezed == qualifyingPlaces ? _self.qualifyingPlaces : qualifyingPlaces // ignore: cast_nullable_to_non_nullable
as int?,qualificationLogic: freezed == qualificationLogic ? _self.qualificationLogic : qualificationLogic // ignore: cast_nullable_to_non_nullable
as String?,deroulement: freezed == deroulement ? _self.deroulement : deroulement // ignore: cast_nullable_to_non_nullable
as DeroulementDto?,
  ));
}

/// Create a copy of PartieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeroulementDtoCopyWith<$Res>? get deroulement {
    if (_self.deroulement == null) {
    return null;
  }

  return $DeroulementDtoCopyWith<$Res>(_self.deroulement!, (value) {
    return _then(_self.copyWith(deroulement: value));
  });
}
}

// dart format on
