// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'epreuve_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EpreuveDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'IdDiscipline', readValue: readInt) int? get disciplineId;@JsonKey(name: 'Genre') String? get gender;@JsonKey(name: 'discipline', readValue: readMap) EpreuveDisciplineDto? get discipline;@JsonKey(name: 'categories') List<EpreuveCategorieDto> get categories;
/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpreuveDtoCopyWith<EpreuveDto> get copyWith => _$EpreuveDtoCopyWithImpl<EpreuveDto>(this as EpreuveDto, _$identity);

  /// Serializes this EpreuveDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EpreuveDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpreuveDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.disciplineId, _this.disciplineId) || other.disciplineId == _this.disciplineId)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.discipline, _this.discipline) || other.discipline == _this.discipline)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EpreuveDto;
  return Object.hash(runtimeType,_this.id,_this.disciplineId,_this.gender,_this.discipline,const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as EpreuveDto;
  return 'EpreuveDto(id: ${_this.id}, disciplineId: ${_this.disciplineId}, gender: ${_this.gender}, discipline: ${_this.discipline}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $EpreuveDtoCopyWith<$Res>  {
  factory $EpreuveDtoCopyWith(EpreuveDto value, $Res Function(EpreuveDto) _then) = _$EpreuveDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'IdDiscipline', readValue: readInt) int? disciplineId,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'discipline', readValue: readMap) EpreuveDisciplineDto? discipline,@JsonKey(name: 'categories') List<EpreuveCategorieDto> categories
});


$EpreuveDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class _$EpreuveDtoCopyWithImpl<$Res>
    implements $EpreuveDtoCopyWith<$Res> {
  _$EpreuveDtoCopyWithImpl(this._self, this._then);

  final EpreuveDto _self;
  final $Res Function(EpreuveDto) _then;

/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? disciplineId = freezed,Object? gender = freezed,Object? discipline = freezed,Object? categories = null,}) {
  return _then(EpreuveDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,disciplineId: freezed == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as EpreuveDisciplineDto?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<EpreuveCategorieDto>,
  ));
}
/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $EpreuveDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// Adds pattern-matching-related methods to [EpreuveDto].
extension EpreuveDtoPatterns on EpreuveDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpreuveDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpreuveDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpreuveDto value)  $default,){
final _that = this;
switch (_that) {
case _EpreuveDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpreuveDto value)?  $default,){
final _that = this;
switch (_that) {
case _EpreuveDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  EpreuveDisciplineDto? discipline, @JsonKey(name: 'categories')  List<EpreuveCategorieDto> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpreuveDto() when $default != null:
return $default(_that.id,_that.disciplineId,_that.gender,_that.discipline,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  EpreuveDisciplineDto? discipline, @JsonKey(name: 'categories')  List<EpreuveCategorieDto> categories)  $default,) {final _that = this;
switch (_that) {
case _EpreuveDto():
return $default(_that.id,_that.disciplineId,_that.gender,_that.discipline,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdDiscipline', readValue: readInt)  int? disciplineId, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  EpreuveDisciplineDto? discipline, @JsonKey(name: 'categories')  List<EpreuveCategorieDto> categories)?  $default,) {final _that = this;
switch (_that) {
case _EpreuveDto() when $default != null:
return $default(_that.id,_that.disciplineId,_that.gender,_that.discipline,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpreuveDto implements EpreuveDto {
  const _EpreuveDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'IdDiscipline', readValue: readInt) this.disciplineId, @JsonKey(name: 'Genre') this.gender, @JsonKey(name: 'discipline', readValue: readMap) this.discipline, @JsonKey(name: 'categories')  List<EpreuveCategorieDto> categories = const <EpreuveCategorieDto>[]}): _categories = categories;
  factory _EpreuveDto.fromJson(Map<String, dynamic> json) => _$EpreuveDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'IdDiscipline', readValue: readInt) final  int? disciplineId;
@override@JsonKey(name: 'Genre') final  String? gender;
@override@JsonKey(name: 'discipline', readValue: readMap) final  EpreuveDisciplineDto? discipline;
 final  List<EpreuveCategorieDto> _categories;
@override@JsonKey(name: 'categories') List<EpreuveCategorieDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpreuveDtoCopyWith<_EpreuveDto> get copyWith => __$EpreuveDtoCopyWithImpl<_EpreuveDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpreuveDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpreuveDto&&(identical(other.id, id) || other.id == id)&&(identical(other.disciplineId, disciplineId) || other.disciplineId == disciplineId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.discipline, discipline) || other.discipline == discipline)&&const DeepCollectionEquality().equals(other.categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,disciplineId,gender,discipline,const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'EpreuveDto(id: $id, disciplineId: $disciplineId, gender: $gender, discipline: $discipline, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$EpreuveDtoCopyWith<$Res> implements $EpreuveDtoCopyWith<$Res> {
  factory _$EpreuveDtoCopyWith(_EpreuveDto value, $Res Function(_EpreuveDto) _then) = __$EpreuveDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'IdDiscipline', readValue: readInt) int? disciplineId,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'discipline', readValue: readMap) EpreuveDisciplineDto? discipline,@JsonKey(name: 'categories') List<EpreuveCategorieDto> categories
});


@override $EpreuveDisciplineDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class __$EpreuveDtoCopyWithImpl<$Res>
    implements _$EpreuveDtoCopyWith<$Res> {
  __$EpreuveDtoCopyWithImpl(this._self, this._then);

  final _EpreuveDto _self;
  final $Res Function(_EpreuveDto) _then;

/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? disciplineId = freezed,Object? gender = freezed,Object? discipline = freezed,Object? categories = null,}) {
  return _then(_EpreuveDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,disciplineId: freezed == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as EpreuveDisciplineDto?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<EpreuveCategorieDto>,
  ));
}

/// Create a copy of EpreuveDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveDisciplineDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $EpreuveDisciplineDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// @nodoc
mixin _$EpreuveDisciplineDto {

@JsonKey(name: 'label') String? get label;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) int? get teamSize;@JsonKey(name: 'Specialite', readValue: readInt) int? get speciality;
/// Create a copy of EpreuveDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpreuveDisciplineDtoCopyWith<EpreuveDisciplineDto> get copyWith => _$EpreuveDisciplineDtoCopyWithImpl<EpreuveDisciplineDto>(this as EpreuveDisciplineDto, _$identity);

  /// Serializes this EpreuveDisciplineDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EpreuveDisciplineDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpreuveDisciplineDto&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.teamSize, _this.teamSize) || other.teamSize == _this.teamSize)&&(identical(other.speciality, _this.speciality) || other.speciality == _this.speciality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EpreuveDisciplineDto;
  return Object.hash(runtimeType,_this.label,_this.name,_this.teamSize,_this.speciality);
}

@override
String toString() {
  final _this = this as EpreuveDisciplineDto;
  return 'EpreuveDisciplineDto(label: ${_this.label}, name: ${_this.name}, teamSize: ${_this.teamSize}, speciality: ${_this.speciality})';
}


}

/// @nodoc
abstract mixin class $EpreuveDisciplineDtoCopyWith<$Res>  {
  factory $EpreuveDisciplineDtoCopyWith(EpreuveDisciplineDto value, $Res Function(EpreuveDisciplineDto) _then) = _$EpreuveDisciplineDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'label') String? label,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) int? teamSize,@JsonKey(name: 'Specialite', readValue: readInt) int? speciality
});




}
/// @nodoc
class _$EpreuveDisciplineDtoCopyWithImpl<$Res>
    implements $EpreuveDisciplineDtoCopyWith<$Res> {
  _$EpreuveDisciplineDtoCopyWithImpl(this._self, this._then);

  final EpreuveDisciplineDto _self;
  final $Res Function(EpreuveDisciplineDto) _then;

/// Create a copy of EpreuveDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? name = freezed,Object? teamSize = freezed,Object? speciality = freezed,}) {
  return _then(EpreuveDisciplineDto(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,teamSize: freezed == teamSize ? _self.teamSize : teamSize // ignore: cast_nullable_to_non_nullable
as int?,speciality: freezed == speciality ? _self.speciality : speciality // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EpreuveDisciplineDto].
extension EpreuveDisciplineDtoPatterns on EpreuveDisciplineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpreuveDisciplineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpreuveDisciplineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpreuveDisciplineDto value)  $default,){
final _that = this;
switch (_that) {
case _EpreuveDisciplineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpreuveDisciplineDto value)?  $default,){
final _that = this;
switch (_that) {
case _EpreuveDisciplineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String? label, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'NbAthleteParEquipe', readValue: readInt)  int? teamSize, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpreuveDisciplineDto() when $default != null:
return $default(_that.label,_that.name,_that.teamSize,_that.speciality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String? label, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'NbAthleteParEquipe', readValue: readInt)  int? teamSize, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality)  $default,) {final _that = this;
switch (_that) {
case _EpreuveDisciplineDto():
return $default(_that.label,_that.name,_that.teamSize,_that.speciality);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'label')  String? label, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'NbAthleteParEquipe', readValue: readInt)  int? teamSize, @JsonKey(name: 'Specialite', readValue: readInt)  int? speciality)?  $default,) {final _that = this;
switch (_that) {
case _EpreuveDisciplineDto() when $default != null:
return $default(_that.label,_that.name,_that.teamSize,_that.speciality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpreuveDisciplineDto implements EpreuveDisciplineDto {
  const _EpreuveDisciplineDto({@JsonKey(name: 'label') this.label, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) this.teamSize, @JsonKey(name: 'Specialite', readValue: readInt) this.speciality});
  factory _EpreuveDisciplineDto.fromJson(Map<String, dynamic> json) => _$EpreuveDisciplineDtoFromJson(json);

@override@JsonKey(name: 'label') final  String? label;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) final  int? teamSize;
@override@JsonKey(name: 'Specialite', readValue: readInt) final  int? speciality;

/// Create a copy of EpreuveDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpreuveDisciplineDtoCopyWith<_EpreuveDisciplineDto> get copyWith => __$EpreuveDisciplineDtoCopyWithImpl<_EpreuveDisciplineDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpreuveDisciplineDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpreuveDisciplineDto&&(identical(other.label, label) || other.label == label)&&(identical(other.name, name) || other.name == name)&&(identical(other.teamSize, teamSize) || other.teamSize == teamSize)&&(identical(other.speciality, speciality) || other.speciality == speciality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,name,teamSize,speciality);
}

@override
String toString() {
    return 'EpreuveDisciplineDto(label: $label, name: $name, teamSize: $teamSize, speciality: $speciality)';
}


}

/// @nodoc
abstract mixin class _$EpreuveDisciplineDtoCopyWith<$Res> implements $EpreuveDisciplineDtoCopyWith<$Res> {
  factory _$EpreuveDisciplineDtoCopyWith(_EpreuveDisciplineDto value, $Res Function(_EpreuveDisciplineDto) _then) = __$EpreuveDisciplineDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'label') String? label,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'NbAthleteParEquipe', readValue: readInt) int? teamSize,@JsonKey(name: 'Specialite', readValue: readInt) int? speciality
});




}
/// @nodoc
class __$EpreuveDisciplineDtoCopyWithImpl<$Res>
    implements _$EpreuveDisciplineDtoCopyWith<$Res> {
  __$EpreuveDisciplineDtoCopyWithImpl(this._self, this._then);

  final _EpreuveDisciplineDto _self;
  final $Res Function(_EpreuveDisciplineDto) _then;

/// Create a copy of EpreuveDisciplineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? name = freezed,Object? teamSize = freezed,Object? speciality = freezed,}) {
  return _then(_EpreuveDisciplineDto(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,teamSize: freezed == teamSize ? _self.teamSize : teamSize // ignore: cast_nullable_to_non_nullable
as int?,speciality: freezed == speciality ? _self.speciality : speciality // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$EpreuveCategorieDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Nom') String? get name;
/// Create a copy of EpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpreuveCategorieDtoCopyWith<EpreuveCategorieDto> get copyWith => _$EpreuveCategorieDtoCopyWithImpl<EpreuveCategorieDto>(this as EpreuveCategorieDto, _$identity);

  /// Serializes this EpreuveCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EpreuveCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpreuveCategorieDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EpreuveCategorieDto;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as EpreuveCategorieDto;
  return 'EpreuveCategorieDto(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $EpreuveCategorieDtoCopyWith<$Res>  {
  factory $EpreuveCategorieDtoCopyWith(EpreuveCategorieDto value, $Res Function(EpreuveCategorieDto) _then) = _$EpreuveCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$EpreuveCategorieDtoCopyWithImpl<$Res>
    implements $EpreuveCategorieDtoCopyWith<$Res> {
  _$EpreuveCategorieDtoCopyWithImpl(this._self, this._then);

  final EpreuveCategorieDto _self;
  final $Res Function(EpreuveCategorieDto) _then;

/// Create a copy of EpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(EpreuveCategorieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EpreuveCategorieDto].
extension EpreuveCategorieDtoPatterns on EpreuveCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpreuveCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpreuveCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpreuveCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _EpreuveCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpreuveCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _EpreuveCategorieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpreuveCategorieDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name)  $default,) {final _that = this;
switch (_that) {
case _EpreuveCategorieDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name)?  $default,) {final _that = this;
switch (_that) {
case _EpreuveCategorieDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpreuveCategorieDto implements EpreuveCategorieDto {
  const _EpreuveCategorieDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Nom') this.name});
  factory _EpreuveCategorieDto.fromJson(Map<String, dynamic> json) => _$EpreuveCategorieDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of EpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpreuveCategorieDtoCopyWith<_EpreuveCategorieDto> get copyWith => __$EpreuveCategorieDtoCopyWithImpl<_EpreuveCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpreuveCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpreuveCategorieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'EpreuveCategorieDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$EpreuveCategorieDtoCopyWith<$Res> implements $EpreuveCategorieDtoCopyWith<$Res> {
  factory _$EpreuveCategorieDtoCopyWith(_EpreuveCategorieDto value, $Res Function(_EpreuveCategorieDto) _then) = __$EpreuveCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$EpreuveCategorieDtoCopyWithImpl<$Res>
    implements _$EpreuveCategorieDtoCopyWith<$Res> {
  __$EpreuveCategorieDtoCopyWithImpl(this._self, this._then);

  final _EpreuveCategorieDto _self;
  final $Res Function(_EpreuveCategorieDto) _then;

/// Create a copy of EpreuveCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_EpreuveCategorieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
