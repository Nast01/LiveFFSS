// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progression.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Stage {

 int get id; int get order; StageLevel get level;/// Le `label` FFSS, par exemple « Finale - Cadet ».
 String get name; QualificationMethod get qualification; int get heatCount; int get placesPerHeat;/// Nul quand l'API publie 0, c'est-à-dire aucune place qualificative.
 int? get qualifyingPlaces;
/// Create a copy of Stage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageCopyWith<Stage> get copyWith => _$StageCopyWithImpl<Stage>(this as Stage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Stage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Stage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.qualification, _this.qualification) || other.qualification == _this.qualification)&&(identical(other.heatCount, _this.heatCount) || other.heatCount == _this.heatCount)&&(identical(other.placesPerHeat, _this.placesPerHeat) || other.placesPerHeat == _this.placesPerHeat)&&(identical(other.qualifyingPlaces, _this.qualifyingPlaces) || other.qualifyingPlaces == _this.qualifyingPlaces));
}


@override
int get hashCode {
  final _this = this as Stage;
  return Object.hash(runtimeType,_this.id,_this.order,_this.level,_this.name,_this.qualification,_this.heatCount,_this.placesPerHeat,_this.qualifyingPlaces);
}

@override
String toString() {
  final _this = this as Stage;
  return 'Stage(id: ${_this.id}, order: ${_this.order}, level: ${_this.level}, name: ${_this.name}, qualification: ${_this.qualification}, heatCount: ${_this.heatCount}, placesPerHeat: ${_this.placesPerHeat}, qualifyingPlaces: ${_this.qualifyingPlaces})';
}


}

/// @nodoc
abstract mixin class $StageCopyWith<$Res>  {
  factory $StageCopyWith(Stage value, $Res Function(Stage) _then) = _$StageCopyWithImpl;
@useResult
$Res call({
 int id, int order, StageLevel level, String name, QualificationMethod qualification, int heatCount, int placesPerHeat, int? qualifyingPlaces
});




}
/// @nodoc
class _$StageCopyWithImpl<$Res>
    implements $StageCopyWith<$Res> {
  _$StageCopyWithImpl(this._self, this._then);

  final Stage _self;
  final $Res Function(Stage) _then;

/// Create a copy of Stage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? order = null,Object? level = null,Object? name = null,Object? qualification = null,Object? heatCount = null,Object? placesPerHeat = null,Object? qualifyingPlaces = freezed,}) {
  return _then(Stage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as StageLevel,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as QualificationMethod,heatCount: null == heatCount ? _self.heatCount : heatCount // ignore: cast_nullable_to_non_nullable
as int,placesPerHeat: null == placesPerHeat ? _self.placesPerHeat : placesPerHeat // ignore: cast_nullable_to_non_nullable
as int,qualifyingPlaces: freezed == qualifyingPlaces ? _self.qualifyingPlaces : qualifyingPlaces // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Stage].
extension StagePatterns on Stage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Stage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Stage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Stage value)  $default,){
final _that = this;
switch (_that) {
case _Stage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Stage value)?  $default,){
final _that = this;
switch (_that) {
case _Stage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int order,  StageLevel level,  String name,  QualificationMethod qualification,  int heatCount,  int placesPerHeat,  int? qualifyingPlaces)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Stage() when $default != null:
return $default(_that.id,_that.order,_that.level,_that.name,_that.qualification,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int order,  StageLevel level,  String name,  QualificationMethod qualification,  int heatCount,  int placesPerHeat,  int? qualifyingPlaces)  $default,) {final _that = this;
switch (_that) {
case _Stage():
return $default(_that.id,_that.order,_that.level,_that.name,_that.qualification,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int order,  StageLevel level,  String name,  QualificationMethod qualification,  int heatCount,  int placesPerHeat,  int? qualifyingPlaces)?  $default,) {final _that = this;
switch (_that) {
case _Stage() when $default != null:
return $default(_that.id,_that.order,_that.level,_that.name,_that.qualification,_that.heatCount,_that.placesPerHeat,_that.qualifyingPlaces);case _:
  return null;

}
}

}

/// @nodoc


class _Stage implements Stage {
  const _Stage({required this.id, required this.order, required this.level, required this.name, required this.qualification, required this.heatCount, required this.placesPerHeat, this.qualifyingPlaces});
  

@override final  int id;
@override final  int order;
@override final  StageLevel level;
/// Le `label` FFSS, par exemple « Finale - Cadet ».
@override final  String name;
@override final  QualificationMethod qualification;
@override final  int heatCount;
@override final  int placesPerHeat;
/// Nul quand l'API publie 0, c'est-à-dire aucune place qualificative.
@override final  int? qualifyingPlaces;

/// Create a copy of Stage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageCopyWith<_Stage> get copyWith => __$StageCopyWithImpl<_Stage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stage&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.level, level) || other.level == level)&&(identical(other.name, name) || other.name == name)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.heatCount, heatCount) || other.heatCount == heatCount)&&(identical(other.placesPerHeat, placesPerHeat) || other.placesPerHeat == placesPerHeat)&&(identical(other.qualifyingPlaces, qualifyingPlaces) || other.qualifyingPlaces == qualifyingPlaces));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,order,level,name,qualification,heatCount,placesPerHeat,qualifyingPlaces);
}

@override
String toString() {
    return 'Stage(id: $id, order: $order, level: $level, name: $name, qualification: $qualification, heatCount: $heatCount, placesPerHeat: $placesPerHeat, qualifyingPlaces: $qualifyingPlaces)';
}


}

/// @nodoc
abstract mixin class _$StageCopyWith<$Res> implements $StageCopyWith<$Res> {
  factory _$StageCopyWith(_Stage value, $Res Function(_Stage) _then) = __$StageCopyWithImpl;
@override @useResult
$Res call({
 int id, int order, StageLevel level, String name, QualificationMethod qualification, int heatCount, int placesPerHeat, int? qualifyingPlaces
});




}
/// @nodoc
class __$StageCopyWithImpl<$Res>
    implements _$StageCopyWith<$Res> {
  __$StageCopyWithImpl(this._self, this._then);

  final _Stage _self;
  final $Res Function(_Stage) _then;

/// Create a copy of Stage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? order = null,Object? level = null,Object? name = null,Object? qualification = null,Object? heatCount = null,Object? placesPerHeat = null,Object? qualifyingPlaces = freezed,}) {
  return _then(_Stage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as StageLevel,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as QualificationMethod,heatCount: null == heatCount ? _self.heatCount : heatCount // ignore: cast_nullable_to_non_nullable
as int,placesPerHeat: null == placesPerHeat ? _self.placesPerHeat : placesPerHeat // ignore: cast_nullable_to_non_nullable
as int,qualifyingPlaces: freezed == qualifyingPlaces ? _self.qualifyingPlaces : qualifyingPlaces // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$Progression {

 int get id; String get name; String get disciplineName; Gender? get gender; List<Stage> get stages;
/// Create a copy of Progression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressionCopyWith<Progression> get copyWith => _$ProgressionCopyWithImpl<Progression>(this as Progression, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Progression;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Progression&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.disciplineName, _this.disciplineName) || other.disciplineName == _this.disciplineName)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&const DeepCollectionEquality().equals(other.stages, _this.stages));
}


@override
int get hashCode {
  final _this = this as Progression;
  return Object.hash(runtimeType,_this.id,_this.name,_this.disciplineName,_this.gender,const DeepCollectionEquality().hash(_this.stages));
}

@override
String toString() {
  final _this = this as Progression;
  return 'Progression(id: ${_this.id}, name: ${_this.name}, disciplineName: ${_this.disciplineName}, gender: ${_this.gender}, stages: ${_this.stages})';
}


}

/// @nodoc
abstract mixin class $ProgressionCopyWith<$Res>  {
  factory $ProgressionCopyWith(Progression value, $Res Function(Progression) _then) = _$ProgressionCopyWithImpl;
@useResult
$Res call({
 int id, String name, String disciplineName, Gender? gender, List<Stage> stages
});




}
/// @nodoc
class _$ProgressionCopyWithImpl<$Res>
    implements $ProgressionCopyWith<$Res> {
  _$ProgressionCopyWithImpl(this._self, this._then);

  final Progression _self;
  final $Res Function(Progression) _then;

/// Create a copy of Progression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? disciplineName = null,Object? gender = freezed,Object? stages = null,}) {
  return _then(Progression(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,disciplineName: null == disciplineName ? _self.disciplineName : disciplineName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<Stage>,
  ));
}

}


/// Adds pattern-matching-related methods to [Progression].
extension ProgressionPatterns on Progression {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Progression value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Progression() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Progression value)  $default,){
final _that = this;
switch (_that) {
case _Progression():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Progression value)?  $default,){
final _that = this;
switch (_that) {
case _Progression() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String disciplineName,  Gender? gender,  List<Stage> stages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Progression() when $default != null:
return $default(_that.id,_that.name,_that.disciplineName,_that.gender,_that.stages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String disciplineName,  Gender? gender,  List<Stage> stages)  $default,) {final _that = this;
switch (_that) {
case _Progression():
return $default(_that.id,_that.name,_that.disciplineName,_that.gender,_that.stages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String disciplineName,  Gender? gender,  List<Stage> stages)?  $default,) {final _that = this;
switch (_that) {
case _Progression() when $default != null:
return $default(_that.id,_that.name,_that.disciplineName,_that.gender,_that.stages);case _:
  return null;

}
}

}

/// @nodoc


class _Progression extends Progression {
  const _Progression({required this.id, required this.name, this.disciplineName = '', this.gender,  List<Stage> stages = const <Stage>[]}): _stages = stages,super._();
  

@override final  int id;
@override final  String name;
@override@JsonKey() final  String disciplineName;
@override final  Gender? gender;
 final  List<Stage> _stages;
@override@JsonKey() List<Stage> get stages {
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stages);
}


/// Create a copy of Progression
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressionCopyWith<_Progression> get copyWith => __$ProgressionCopyWithImpl<_Progression>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Progression&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.disciplineName, disciplineName) || other.disciplineName == disciplineName)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.stages, _stages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,disciplineName,gender,const DeepCollectionEquality().hash(_stages));
}

@override
String toString() {
    return 'Progression(id: $id, name: $name, disciplineName: $disciplineName, gender: $gender, stages: $stages)';
}


}

/// @nodoc
abstract mixin class _$ProgressionCopyWith<$Res> implements $ProgressionCopyWith<$Res> {
  factory _$ProgressionCopyWith(_Progression value, $Res Function(_Progression) _then) = __$ProgressionCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String disciplineName, Gender? gender, List<Stage> stages
});




}
/// @nodoc
class __$ProgressionCopyWithImpl<$Res>
    implements _$ProgressionCopyWith<$Res> {
  __$ProgressionCopyWithImpl(this._self, this._then);

  final _Progression _self;
  final $Res Function(_Progression) _then;

/// Create a copy of Progression
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? disciplineName = null,Object? gender = freezed,Object? stages = null,}) {
  return _then(_Progression(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,disciplineName: null == disciplineName ? _self.disciplineName : disciplineName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<Stage>,
  ));
}


}

// dart format on
