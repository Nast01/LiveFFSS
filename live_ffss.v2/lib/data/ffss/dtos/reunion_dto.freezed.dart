// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reunion_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReunionDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'Jour') String? get day;@JsonKey(name: 'Debut') String? get start;@JsonKey(name: 'Fin') String? get end;@JsonKey(name: 'creneaus') List<CreneauDto> get creneaus;
/// Create a copy of ReunionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReunionDtoCopyWith<ReunionDto> get copyWith => _$ReunionDtoCopyWithImpl<ReunionDto>(this as ReunionDto, _$identity);

  /// Serializes this ReunionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReunionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReunionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.creneaus, _this.creneaus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReunionDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.day,_this.start,_this.end,const DeepCollectionEquality().hash(_this.creneaus));
}

@override
String toString() {
  final _this = this as ReunionDto;
  return 'ReunionDto(id: ${_this.id}, name: ${_this.name}, day: ${_this.day}, start: ${_this.start}, end: ${_this.end}, creneaus: ${_this.creneaus})';
}


}

/// @nodoc
abstract mixin class $ReunionDtoCopyWith<$Res>  {
  factory $ReunionDtoCopyWith(ReunionDto value, $Res Function(ReunionDto) _then) = _$ReunionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Jour') String? day,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'Fin') String? end,@JsonKey(name: 'creneaus') List<CreneauDto> creneaus
});




}
/// @nodoc
class _$ReunionDtoCopyWithImpl<$Res>
    implements $ReunionDtoCopyWith<$Res> {
  _$ReunionDtoCopyWithImpl(this._self, this._then);

  final ReunionDto _self;
  final $Res Function(ReunionDto) _then;

/// Create a copy of ReunionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? day = freezed,Object? start = freezed,Object? end = freezed,Object? creneaus = null,}) {
  return _then(ReunionDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,creneaus: null == creneaus ? _self.creneaus : creneaus // ignore: cast_nullable_to_non_nullable
as List<CreneauDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReunionDto].
extension ReunionDtoPatterns on ReunionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReunionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReunionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReunionDto value)  $default,){
final _that = this;
switch (_that) {
case _ReunionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReunionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReunionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Jour')  String? day, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'creneaus')  List<CreneauDto> creneaus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReunionDto() when $default != null:
return $default(_that.id,_that.name,_that.day,_that.start,_that.end,_that.creneaus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Jour')  String? day, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'creneaus')  List<CreneauDto> creneaus)  $default,) {final _that = this;
switch (_that) {
case _ReunionDto():
return $default(_that.id,_that.name,_that.day,_that.start,_that.end,_that.creneaus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Jour')  String? day, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'creneaus')  List<CreneauDto> creneaus)?  $default,) {final _that = this;
switch (_that) {
case _ReunionDto() when $default != null:
return $default(_that.id,_that.name,_that.day,_that.start,_that.end,_that.creneaus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReunionDto implements ReunionDto {
  const _ReunionDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'Jour') this.day, @JsonKey(name: 'Debut') this.start, @JsonKey(name: 'Fin') this.end, @JsonKey(name: 'creneaus')  List<CreneauDto> creneaus = const <CreneauDto>[]}): _creneaus = creneaus;
  factory _ReunionDto.fromJson(Map<String, dynamic> json) => _$ReunionDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'Jour') final  String? day;
@override@JsonKey(name: 'Debut') final  String? start;
@override@JsonKey(name: 'Fin') final  String? end;
 final  List<CreneauDto> _creneaus;
@override@JsonKey(name: 'creneaus') List<CreneauDto> get creneaus {
  if (_creneaus is EqualUnmodifiableListView) return _creneaus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_creneaus);
}


/// Create a copy of ReunionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReunionDtoCopyWith<_ReunionDto> get copyWith => __$ReunionDtoCopyWithImpl<_ReunionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReunionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReunionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.day, day) || other.day == day)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.creneaus, _creneaus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,day,start,end,const DeepCollectionEquality().hash(_creneaus));
}

@override
String toString() {
    return 'ReunionDto(id: $id, name: $name, day: $day, start: $start, end: $end, creneaus: $creneaus)';
}


}

/// @nodoc
abstract mixin class _$ReunionDtoCopyWith<$Res> implements $ReunionDtoCopyWith<$Res> {
  factory _$ReunionDtoCopyWith(_ReunionDto value, $Res Function(_ReunionDto) _then) = __$ReunionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Jour') String? day,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'Fin') String? end,@JsonKey(name: 'creneaus') List<CreneauDto> creneaus
});




}
/// @nodoc
class __$ReunionDtoCopyWithImpl<$Res>
    implements _$ReunionDtoCopyWith<$Res> {
  __$ReunionDtoCopyWithImpl(this._self, this._then);

  final _ReunionDto _self;
  final $Res Function(_ReunionDto) _then;

/// Create a copy of ReunionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? day = freezed,Object? start = freezed,Object? end = freezed,Object? creneaus = null,}) {
  return _then(_ReunionDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,creneaus: null == creneaus ? _self._creneaus : creneaus // ignore: cast_nullable_to_non_nullable
as List<CreneauDto>,
  ));
}


}


/// @nodoc
mixin _$CreneauDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'Debut') String? get start;@JsonKey(name: 'Fin') String? get end;@JsonKey(name: 'partie', readValue: readMap) PartieDto? get partie;@JsonKey(name: 'courses') List<CourseDto> get courses;
/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreneauDtoCopyWith<CreneauDto> get copyWith => _$CreneauDtoCopyWithImpl<CreneauDto>(this as CreneauDto, _$identity);

  /// Serializes this CreneauDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreneauDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreneauDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.partie, _this.partie) || other.partie == _this.partie)&&const DeepCollectionEquality().equals(other.courses, _this.courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreneauDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.start,_this.end,_this.partie,const DeepCollectionEquality().hash(_this.courses));
}

@override
String toString() {
  final _this = this as CreneauDto;
  return 'CreneauDto(id: ${_this.id}, name: ${_this.name}, start: ${_this.start}, end: ${_this.end}, partie: ${_this.partie}, courses: ${_this.courses})';
}


}

/// @nodoc
abstract mixin class $CreneauDtoCopyWith<$Res>  {
  factory $CreneauDtoCopyWith(CreneauDto value, $Res Function(CreneauDto) _then) = _$CreneauDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'Fin') String? end,@JsonKey(name: 'partie', readValue: readMap) PartieDto? partie,@JsonKey(name: 'courses') List<CourseDto> courses
});


$PartieDtoCopyWith<$Res>? get partie;

}
/// @nodoc
class _$CreneauDtoCopyWithImpl<$Res>
    implements $CreneauDtoCopyWith<$Res> {
  _$CreneauDtoCopyWithImpl(this._self, this._then);

  final CreneauDto _self;
  final $Res Function(CreneauDto) _then;

/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? start = freezed,Object? end = freezed,Object? partie = freezed,Object? courses = null,}) {
  return _then(CreneauDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,partie: freezed == partie ? _self.partie : partie // ignore: cast_nullable_to_non_nullable
as PartieDto?,courses: null == courses ? _self.courses : courses // ignore: cast_nullable_to_non_nullable
as List<CourseDto>,
  ));
}
/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartieDtoCopyWith<$Res>? get partie {
    if (_self.partie == null) {
    return null;
  }

  return $PartieDtoCopyWith<$Res>(_self.partie!, (value) {
    return _then(_self.copyWith(partie: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreneauDto].
extension CreneauDtoPatterns on CreneauDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreneauDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreneauDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreneauDto value)  $default,){
final _that = this;
switch (_that) {
case _CreneauDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreneauDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreneauDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'partie', readValue: readMap)  PartieDto? partie, @JsonKey(name: 'courses')  List<CourseDto> courses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreneauDto() when $default != null:
return $default(_that.id,_that.name,_that.start,_that.end,_that.partie,_that.courses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'partie', readValue: readMap)  PartieDto? partie, @JsonKey(name: 'courses')  List<CourseDto> courses)  $default,) {final _that = this;
switch (_that) {
case _CreneauDto():
return $default(_that.id,_that.name,_that.start,_that.end,_that.partie,_that.courses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'Fin')  String? end, @JsonKey(name: 'partie', readValue: readMap)  PartieDto? partie, @JsonKey(name: 'courses')  List<CourseDto> courses)?  $default,) {final _that = this;
switch (_that) {
case _CreneauDto() when $default != null:
return $default(_that.id,_that.name,_that.start,_that.end,_that.partie,_that.courses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreneauDto implements CreneauDto {
  const _CreneauDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'Debut') this.start, @JsonKey(name: 'Fin') this.end, @JsonKey(name: 'partie', readValue: readMap) this.partie, @JsonKey(name: 'courses')  List<CourseDto> courses = const <CourseDto>[]}): _courses = courses;
  factory _CreneauDto.fromJson(Map<String, dynamic> json) => _$CreneauDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'Debut') final  String? start;
@override@JsonKey(name: 'Fin') final  String? end;
@override@JsonKey(name: 'partie', readValue: readMap) final  PartieDto? partie;
 final  List<CourseDto> _courses;
@override@JsonKey(name: 'courses') List<CourseDto> get courses {
  if (_courses is EqualUnmodifiableListView) return _courses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courses);
}


/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreneauDtoCopyWith<_CreneauDto> get copyWith => __$CreneauDtoCopyWithImpl<_CreneauDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreneauDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreneauDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.partie, partie) || other.partie == partie)&&const DeepCollectionEquality().equals(other.courses, _courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,start,end,partie,const DeepCollectionEquality().hash(_courses));
}

@override
String toString() {
    return 'CreneauDto(id: $id, name: $name, start: $start, end: $end, partie: $partie, courses: $courses)';
}


}

/// @nodoc
abstract mixin class _$CreneauDtoCopyWith<$Res> implements $CreneauDtoCopyWith<$Res> {
  factory _$CreneauDtoCopyWith(_CreneauDto value, $Res Function(_CreneauDto) _then) = __$CreneauDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'Fin') String? end,@JsonKey(name: 'partie', readValue: readMap) PartieDto? partie,@JsonKey(name: 'courses') List<CourseDto> courses
});


@override $PartieDtoCopyWith<$Res>? get partie;

}
/// @nodoc
class __$CreneauDtoCopyWithImpl<$Res>
    implements _$CreneauDtoCopyWith<$Res> {
  __$CreneauDtoCopyWithImpl(this._self, this._then);

  final _CreneauDto _self;
  final $Res Function(_CreneauDto) _then;

/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? start = freezed,Object? end = freezed,Object? partie = freezed,Object? courses = null,}) {
  return _then(_CreneauDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,partie: freezed == partie ? _self.partie : partie // ignore: cast_nullable_to_non_nullable
as PartieDto?,courses: null == courses ? _self._courses : courses // ignore: cast_nullable_to_non_nullable
as List<CourseDto>,
  ));
}

/// Create a copy of CreneauDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PartieDtoCopyWith<$Res>? get partie {
    if (_self.partie == null) {
    return null;
  }

  return $PartieDtoCopyWith<$Res>(_self.partie!, (value) {
    return _then(_self.copyWith(partie: value));
  });
}
}


/// @nodoc
mixin _$CourseDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'statut', readValue: readInt) int? get status;@JsonKey(name: 'debut') String? get start;@JsonKey(name: 'fin') String? get end;@JsonKey(name: 'places') List<PlaceRefDto> get places;@JsonKey(name: 'serie', readValue: readMap) SerieDto? get serie;
/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseDtoCopyWith<CourseDto> get copyWith => _$CourseDtoCopyWithImpl<CourseDto>(this as CourseDto, _$identity);

  /// Serializes this CourseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CourseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourseDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.places, _this.places)&&(identical(other.serie, _this.serie) || other.serie == _this.serie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CourseDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.status,_this.start,_this.end,const DeepCollectionEquality().hash(_this.places),_this.serie);
}

@override
String toString() {
  final _this = this as CourseDto;
  return 'CourseDto(id: ${_this.id}, name: ${_this.name}, status: ${_this.status}, start: ${_this.start}, end: ${_this.end}, places: ${_this.places}, serie: ${_this.serie})';
}


}

/// @nodoc
abstract mixin class $CourseDtoCopyWith<$Res>  {
  factory $CourseDtoCopyWith(CourseDto value, $Res Function(CourseDto) _then) = _$CourseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'statut', readValue: readInt) int? status,@JsonKey(name: 'debut') String? start,@JsonKey(name: 'fin') String? end,@JsonKey(name: 'places') List<PlaceRefDto> places,@JsonKey(name: 'serie', readValue: readMap) SerieDto? serie
});


$SerieDtoCopyWith<$Res>? get serie;

}
/// @nodoc
class _$CourseDtoCopyWithImpl<$Res>
    implements $CourseDtoCopyWith<$Res> {
  _$CourseDtoCopyWithImpl(this._self, this._then);

  final CourseDto _self;
  final $Res Function(CourseDto) _then;

/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? status = freezed,Object? start = freezed,Object? end = freezed,Object? places = null,Object? serie = freezed,}) {
  return _then(CourseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceRefDto>,serie: freezed == serie ? _self.serie : serie // ignore: cast_nullable_to_non_nullable
as SerieDto?,
  ));
}
/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SerieDtoCopyWith<$Res>? get serie {
    if (_self.serie == null) {
    return null;
  }

  return $SerieDtoCopyWith<$Res>(_self.serie!, (value) {
    return _then(_self.copyWith(serie: value));
  });
}
}


/// Adds pattern-matching-related methods to [CourseDto].
extension CourseDtoPatterns on CourseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourseDto value)  $default,){
final _that = this;
switch (_that) {
case _CourseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CourseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'statut', readValue: readInt)  int? status, @JsonKey(name: 'debut')  String? start, @JsonKey(name: 'fin')  String? end, @JsonKey(name: 'places')  List<PlaceRefDto> places, @JsonKey(name: 'serie', readValue: readMap)  SerieDto? serie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourseDto() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.start,_that.end,_that.places,_that.serie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'statut', readValue: readInt)  int? status, @JsonKey(name: 'debut')  String? start, @JsonKey(name: 'fin')  String? end, @JsonKey(name: 'places')  List<PlaceRefDto> places, @JsonKey(name: 'serie', readValue: readMap)  SerieDto? serie)  $default,) {final _that = this;
switch (_that) {
case _CourseDto():
return $default(_that.id,_that.name,_that.status,_that.start,_that.end,_that.places,_that.serie);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'statut', readValue: readInt)  int? status, @JsonKey(name: 'debut')  String? start, @JsonKey(name: 'fin')  String? end, @JsonKey(name: 'places')  List<PlaceRefDto> places, @JsonKey(name: 'serie', readValue: readMap)  SerieDto? serie)?  $default,) {final _that = this;
switch (_that) {
case _CourseDto() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.start,_that.end,_that.places,_that.serie);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourseDto implements CourseDto {
  const _CourseDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'statut', readValue: readInt) this.status, @JsonKey(name: 'debut') this.start, @JsonKey(name: 'fin') this.end, @JsonKey(name: 'places')  List<PlaceRefDto> places = const <PlaceRefDto>[], @JsonKey(name: 'serie', readValue: readMap) this.serie}): _places = places;
  factory _CourseDto.fromJson(Map<String, dynamic> json) => _$CourseDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'statut', readValue: readInt) final  int? status;
@override@JsonKey(name: 'debut') final  String? start;
@override@JsonKey(name: 'fin') final  String? end;
 final  List<PlaceRefDto> _places;
@override@JsonKey(name: 'places') List<PlaceRefDto> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}

@override@JsonKey(name: 'serie', readValue: readMap) final  SerieDto? serie;

/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseDtoCopyWith<_CourseDto> get copyWith => __$CourseDtoCopyWithImpl<_CourseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.places, _places)&&(identical(other.serie, serie) || other.serie == serie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,status,start,end,const DeepCollectionEquality().hash(_places),serie);
}

@override
String toString() {
    return 'CourseDto(id: $id, name: $name, status: $status, start: $start, end: $end, places: $places, serie: $serie)';
}


}

/// @nodoc
abstract mixin class _$CourseDtoCopyWith<$Res> implements $CourseDtoCopyWith<$Res> {
  factory _$CourseDtoCopyWith(_CourseDto value, $Res Function(_CourseDto) _then) = __$CourseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'statut', readValue: readInt) int? status,@JsonKey(name: 'debut') String? start,@JsonKey(name: 'fin') String? end,@JsonKey(name: 'places') List<PlaceRefDto> places,@JsonKey(name: 'serie', readValue: readMap) SerieDto? serie
});


@override $SerieDtoCopyWith<$Res>? get serie;

}
/// @nodoc
class __$CourseDtoCopyWithImpl<$Res>
    implements _$CourseDtoCopyWith<$Res> {
  __$CourseDtoCopyWithImpl(this._self, this._then);

  final _CourseDto _self;
  final $Res Function(_CourseDto) _then;

/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? status = freezed,Object? start = freezed,Object? end = freezed,Object? places = null,Object? serie = freezed,}) {
  return _then(_CourseDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String?,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceRefDto>,serie: freezed == serie ? _self.serie : serie // ignore: cast_nullable_to_non_nullable
as SerieDto?,
  ));
}

/// Create a copy of CourseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SerieDtoCopyWith<$Res>? get serie {
    if (_self.serie == null) {
    return null;
  }

  return $SerieDtoCopyWith<$Res>(_self.serie!, (value) {
    return _then(_self.copyWith(serie: value));
  });
}
}


/// @nodoc
mixin _$PlaceRefDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'Numero', readValue: readInt) int? get number;
/// Create a copy of PlaceRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceRefDtoCopyWith<PlaceRefDto> get copyWith => _$PlaceRefDtoCopyWithImpl<PlaceRefDto>(this as PlaceRefDto, _$identity);

  /// Serializes this PlaceRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceRefDto;
  return Object.hash(runtimeType,_this.id,_this.number);
}

@override
String toString() {
  final _this = this as PlaceRefDto;
  return 'PlaceRefDto(id: ${_this.id}, number: ${_this.number})';
}


}

/// @nodoc
abstract mixin class $PlaceRefDtoCopyWith<$Res>  {
  factory $PlaceRefDtoCopyWith(PlaceRefDto value, $Res Function(PlaceRefDto) _then) = _$PlaceRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? number
});




}
/// @nodoc
class _$PlaceRefDtoCopyWithImpl<$Res>
    implements $PlaceRefDtoCopyWith<$Res> {
  _$PlaceRefDtoCopyWithImpl(this._self, this._then);

  final PlaceRefDto _self;
  final $Res Function(PlaceRefDto) _then;

/// Create a copy of PlaceRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? number = freezed,}) {
  return _then(PlaceRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceRefDto].
extension PlaceRefDtoPatterns on PlaceRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceRefDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaceRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceRefDto() when $default != null:
return $default(_that.id,_that.number);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number)  $default,) {final _that = this;
switch (_that) {
case _PlaceRefDto():
return $default(_that.id,_that.number);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number)?  $default,) {final _that = this;
switch (_that) {
case _PlaceRefDto() when $default != null:
return $default(_that.id,_that.number);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceRefDto implements PlaceRefDto {
  const _PlaceRefDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'Numero', readValue: readInt) this.number});
  factory _PlaceRefDto.fromJson(Map<String, dynamic> json) => _$PlaceRefDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Numero', readValue: readInt) final  int? number;

/// Create a copy of PlaceRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceRefDtoCopyWith<_PlaceRefDto> get copyWith => __$PlaceRefDtoCopyWithImpl<_PlaceRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number);
}

@override
String toString() {
    return 'PlaceRefDto(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class _$PlaceRefDtoCopyWith<$Res> implements $PlaceRefDtoCopyWith<$Res> {
  factory _$PlaceRefDtoCopyWith(_PlaceRefDto value, $Res Function(_PlaceRefDto) _then) = __$PlaceRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? number
});




}
/// @nodoc
class __$PlaceRefDtoCopyWithImpl<$Res>
    implements _$PlaceRefDtoCopyWith<$Res> {
  __$PlaceRefDtoCopyWithImpl(this._self, this._then);

  final _PlaceRefDto _self;
  final $Res Function(_PlaceRefDto) _then;

/// Create a copy of PlaceRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? number = freezed,}) {
  return _then(_PlaceRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SerieDto {

@JsonKey(name: 'Id', readValue: _readSerieId) int? get id;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'Numero', readValue: readInt) int? get number;@JsonKey(name: 'epreuve', readValue: readMap) EpreuveRefDto? get epreuve;@JsonKey(name: 'label') String? get label;
/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SerieDtoCopyWith<SerieDto> get copyWith => _$SerieDtoCopyWithImpl<SerieDto>(this as SerieDto, _$identity);

  /// Serializes this SerieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SerieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SerieDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.epreuve, _this.epreuve) || other.epreuve == _this.epreuve)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SerieDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.number,_this.epreuve,_this.label);
}

@override
String toString() {
  final _this = this as SerieDto;
  return 'SerieDto(id: ${_this.id}, name: ${_this.name}, number: ${_this.number}, epreuve: ${_this.epreuve}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $SerieDtoCopyWith<$Res>  {
  factory $SerieDtoCopyWith(SerieDto value, $Res Function(SerieDto) _then) = _$SerieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readSerieId) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Numero', readValue: readInt) int? number,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveRefDto? epreuve,@JsonKey(name: 'label') String? label
});


$EpreuveRefDtoCopyWith<$Res>? get epreuve;

}
/// @nodoc
class _$SerieDtoCopyWithImpl<$Res>
    implements $SerieDtoCopyWith<$Res> {
  _$SerieDtoCopyWithImpl(this._self, this._then);

  final SerieDto _self;
  final $Res Function(SerieDto) _then;

/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? number = freezed,Object? epreuve = freezed,Object? label = freezed,}) {
  return _then(SerieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,epreuve: freezed == epreuve ? _self.epreuve : epreuve // ignore: cast_nullable_to_non_nullable
as EpreuveRefDto?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveRefDtoCopyWith<$Res>? get epreuve {
    if (_self.epreuve == null) {
    return null;
  }

  return $EpreuveRefDtoCopyWith<$Res>(_self.epreuve!, (value) {
    return _then(_self.copyWith(epreuve: value));
  });
}
}


/// Adds pattern-matching-related methods to [SerieDto].
extension SerieDtoPatterns on SerieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SerieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SerieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SerieDto value)  $default,){
final _that = this;
switch (_that) {
case _SerieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SerieDto value)?  $default,){
final _that = this;
switch (_that) {
case _SerieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readSerieId)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveRefDto? epreuve, @JsonKey(name: 'label')  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SerieDto() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.epreuve,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readSerieId)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveRefDto? epreuve, @JsonKey(name: 'label')  String? label)  $default,) {final _that = this;
switch (_that) {
case _SerieDto():
return $default(_that.id,_that.name,_that.number,_that.epreuve,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: _readSerieId)  int? id, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveRefDto? epreuve, @JsonKey(name: 'label')  String? label)?  $default,) {final _that = this;
switch (_that) {
case _SerieDto() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.epreuve,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SerieDto implements SerieDto {
  const _SerieDto({@JsonKey(name: 'Id', readValue: _readSerieId) this.id, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'Numero', readValue: readInt) this.number, @JsonKey(name: 'epreuve', readValue: readMap) this.epreuve, @JsonKey(name: 'label') this.label});
  factory _SerieDto.fromJson(Map<String, dynamic> json) => _$SerieDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: _readSerieId) final  int? id;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'Numero', readValue: readInt) final  int? number;
@override@JsonKey(name: 'epreuve', readValue: readMap) final  EpreuveRefDto? epreuve;
@override@JsonKey(name: 'label') final  String? label;

/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SerieDtoCopyWith<_SerieDto> get copyWith => __$SerieDtoCopyWithImpl<_SerieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SerieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SerieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.epreuve, epreuve) || other.epreuve == epreuve)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,number,epreuve,label);
}

@override
String toString() {
    return 'SerieDto(id: $id, name: $name, number: $number, epreuve: $epreuve, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SerieDtoCopyWith<$Res> implements $SerieDtoCopyWith<$Res> {
  factory _$SerieDtoCopyWith(_SerieDto value, $Res Function(_SerieDto) _then) = __$SerieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readSerieId) int? id,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Numero', readValue: readInt) int? number,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveRefDto? epreuve,@JsonKey(name: 'label') String? label
});


@override $EpreuveRefDtoCopyWith<$Res>? get epreuve;

}
/// @nodoc
class __$SerieDtoCopyWithImpl<$Res>
    implements _$SerieDtoCopyWith<$Res> {
  __$SerieDtoCopyWithImpl(this._self, this._then);

  final _SerieDto _self;
  final $Res Function(_SerieDto) _then;

/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? number = freezed,Object? epreuve = freezed,Object? label = freezed,}) {
  return _then(_SerieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,epreuve: freezed == epreuve ? _self.epreuve : epreuve // ignore: cast_nullable_to_non_nullable
as EpreuveRefDto?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SerieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpreuveRefDtoCopyWith<$Res>? get epreuve {
    if (_self.epreuve == null) {
    return null;
  }

  return $EpreuveRefDtoCopyWith<$Res>(_self.epreuve!, (value) {
    return _then(_self.copyWith(epreuve: value));
  });
}
}


/// @nodoc
mixin _$EpreuveRefDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Genre') String? get gender;@JsonKey(name: 'discipline', readValue: readMap) DisciplineRefDto? get discipline;
/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpreuveRefDtoCopyWith<EpreuveRefDto> get copyWith => _$EpreuveRefDtoCopyWithImpl<EpreuveRefDto>(this as EpreuveRefDto, _$identity);

  /// Serializes this EpreuveRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EpreuveRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpreuveRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.discipline, _this.discipline) || other.discipline == _this.discipline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EpreuveRefDto;
  return Object.hash(runtimeType,_this.id,_this.gender,_this.discipline);
}

@override
String toString() {
  final _this = this as EpreuveRefDto;
  return 'EpreuveRefDto(id: ${_this.id}, gender: ${_this.gender}, discipline: ${_this.discipline})';
}


}

/// @nodoc
abstract mixin class $EpreuveRefDtoCopyWith<$Res>  {
  factory $EpreuveRefDtoCopyWith(EpreuveRefDto value, $Res Function(EpreuveRefDto) _then) = _$EpreuveRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'discipline', readValue: readMap) DisciplineRefDto? discipline
});


$DisciplineRefDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class _$EpreuveRefDtoCopyWithImpl<$Res>
    implements $EpreuveRefDtoCopyWith<$Res> {
  _$EpreuveRefDtoCopyWithImpl(this._self, this._then);

  final EpreuveRefDto _self;
  final $Res Function(EpreuveRefDto) _then;

/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? gender = freezed,Object? discipline = freezed,}) {
  return _then(EpreuveRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as DisciplineRefDto?,
  ));
}
/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DisciplineRefDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $DisciplineRefDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// Adds pattern-matching-related methods to [EpreuveRefDto].
extension EpreuveRefDtoPatterns on EpreuveRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpreuveRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpreuveRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpreuveRefDto value)  $default,){
final _that = this;
switch (_that) {
case _EpreuveRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpreuveRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _EpreuveRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  DisciplineRefDto? discipline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpreuveRefDto() when $default != null:
return $default(_that.id,_that.gender,_that.discipline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  DisciplineRefDto? discipline)  $default,) {final _that = this;
switch (_that) {
case _EpreuveRefDto():
return $default(_that.id,_that.gender,_that.discipline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Genre')  String? gender, @JsonKey(name: 'discipline', readValue: readMap)  DisciplineRefDto? discipline)?  $default,) {final _that = this;
switch (_that) {
case _EpreuveRefDto() when $default != null:
return $default(_that.id,_that.gender,_that.discipline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpreuveRefDto implements EpreuveRefDto {
  const _EpreuveRefDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Genre') this.gender, @JsonKey(name: 'discipline', readValue: readMap) this.discipline});
  factory _EpreuveRefDto.fromJson(Map<String, dynamic> json) => _$EpreuveRefDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Genre') final  String? gender;
@override@JsonKey(name: 'discipline', readValue: readMap) final  DisciplineRefDto? discipline;

/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpreuveRefDtoCopyWith<_EpreuveRefDto> get copyWith => __$EpreuveRefDtoCopyWithImpl<_EpreuveRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpreuveRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpreuveRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.discipline, discipline) || other.discipline == discipline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,gender,discipline);
}

@override
String toString() {
    return 'EpreuveRefDto(id: $id, gender: $gender, discipline: $discipline)';
}


}

/// @nodoc
abstract mixin class _$EpreuveRefDtoCopyWith<$Res> implements $EpreuveRefDtoCopyWith<$Res> {
  factory _$EpreuveRefDtoCopyWith(_EpreuveRefDto value, $Res Function(_EpreuveRefDto) _then) = __$EpreuveRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Genre') String? gender,@JsonKey(name: 'discipline', readValue: readMap) DisciplineRefDto? discipline
});


@override $DisciplineRefDtoCopyWith<$Res>? get discipline;

}
/// @nodoc
class __$EpreuveRefDtoCopyWithImpl<$Res>
    implements _$EpreuveRefDtoCopyWith<$Res> {
  __$EpreuveRefDtoCopyWithImpl(this._self, this._then);

  final _EpreuveRefDto _self;
  final $Res Function(_EpreuveRefDto) _then;

/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? gender = freezed,Object? discipline = freezed,}) {
  return _then(_EpreuveRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as DisciplineRefDto?,
  ));
}

/// Create a copy of EpreuveRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DisciplineRefDtoCopyWith<$Res>? get discipline {
    if (_self.discipline == null) {
    return null;
  }

  return $DisciplineRefDtoCopyWith<$Res>(_self.discipline!, (value) {
    return _then(_self.copyWith(discipline: value));
  });
}
}


/// @nodoc
mixin _$DisciplineRefDto {

@JsonKey(name: 'Nom') String? get name;
/// Create a copy of DisciplineRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisciplineRefDtoCopyWith<DisciplineRefDto> get copyWith => _$DisciplineRefDtoCopyWithImpl<DisciplineRefDto>(this as DisciplineRefDto, _$identity);

  /// Serializes this DisciplineRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DisciplineRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisciplineRefDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DisciplineRefDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as DisciplineRefDto;
  return 'DisciplineRefDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $DisciplineRefDtoCopyWith<$Res>  {
  factory $DisciplineRefDtoCopyWith(DisciplineRefDto value, $Res Function(DisciplineRefDto) _then) = _$DisciplineRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$DisciplineRefDtoCopyWithImpl<$Res>
    implements $DisciplineRefDtoCopyWith<$Res> {
  _$DisciplineRefDtoCopyWithImpl(this._self, this._then);

  final DisciplineRefDto _self;
  final $Res Function(DisciplineRefDto) _then;

/// Create a copy of DisciplineRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(DisciplineRefDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DisciplineRefDto].
extension DisciplineRefDtoPatterns on DisciplineRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisciplineRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisciplineRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisciplineRefDto value)  $default,){
final _that = this;
switch (_that) {
case _DisciplineRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisciplineRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _DisciplineRefDto() when $default != null:
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
case _DisciplineRefDto() when $default != null:
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
case _DisciplineRefDto():
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
case _DisciplineRefDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisciplineRefDto implements DisciplineRefDto {
  const _DisciplineRefDto({@JsonKey(name: 'Nom') this.name});
  factory _DisciplineRefDto.fromJson(Map<String, dynamic> json) => _$DisciplineRefDtoFromJson(json);

@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of DisciplineRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisciplineRefDtoCopyWith<_DisciplineRefDto> get copyWith => __$DisciplineRefDtoCopyWithImpl<_DisciplineRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisciplineRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisciplineRefDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'DisciplineRefDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$DisciplineRefDtoCopyWith<$Res> implements $DisciplineRefDtoCopyWith<$Res> {
  factory _$DisciplineRefDtoCopyWith(_DisciplineRefDto value, $Res Function(_DisciplineRefDto) _then) = __$DisciplineRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$DisciplineRefDtoCopyWithImpl<$Res>
    implements _$DisciplineRefDtoCopyWith<$Res> {
  __$DisciplineRefDtoCopyWithImpl(this._self, this._then);

  final _DisciplineRefDto _self;
  final $Res Function(_DisciplineRefDto) _then;

/// Create a copy of DisciplineRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_DisciplineRefDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
