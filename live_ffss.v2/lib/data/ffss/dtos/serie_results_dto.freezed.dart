// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'serie_results_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SerieResultsDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Numero', readValue: readInt) int? get number;@JsonKey(name: 'Nom') String? get name;@JsonKey(name: 'Debut') String? get start;@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? get event;@JsonKey(name: 'resultats') List<ResultatSerieDto> get results;
/// Create a copy of SerieResultsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SerieResultsDtoCopyWith<SerieResultsDto> get copyWith => _$SerieResultsDtoCopyWithImpl<SerieResultsDto>(this as SerieResultsDto, _$identity);

  /// Serializes this SerieResultsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SerieResultsDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SerieResultsDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.event, _this.event) || other.event == _this.event)&&const DeepCollectionEquality().equals(other.results, _this.results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SerieResultsDto;
  return Object.hash(runtimeType,_this.id,_this.number,_this.name,_this.start,_this.event,const DeepCollectionEquality().hash(_this.results));
}

@override
String toString() {
  final _this = this as SerieResultsDto;
  return 'SerieResultsDto(id: ${_this.id}, number: ${_this.number}, name: ${_this.name}, start: ${_this.start}, event: ${_this.event}, results: ${_this.results})';
}


}

/// @nodoc
abstract mixin class $SerieResultsDtoCopyWith<$Res>  {
  factory $SerieResultsDtoCopyWith(SerieResultsDto value, $Res Function(SerieResultsDto) _then) = _$SerieResultsDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? number,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event,@JsonKey(name: 'resultats') List<ResultatSerieDto> results
});


$EpreuveDtoCopyWith<$Res>? get event;

}
/// @nodoc
class _$SerieResultsDtoCopyWithImpl<$Res>
    implements $SerieResultsDtoCopyWith<$Res> {
  _$SerieResultsDtoCopyWithImpl(this._self, this._then);

  final SerieResultsDto _self;
  final $Res Function(SerieResultsDto) _then;

/// Create a copy of SerieResultsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? number = freezed,Object? name = freezed,Object? start = freezed,Object? event = freezed,Object? results = null,}) {
  return _then(SerieResultsDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as EpreuveDto?,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<ResultatSerieDto>,
  ));
}
/// Create a copy of SerieResultsDto
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


/// Adds pattern-matching-related methods to [SerieResultsDto].
extension SerieResultsDtoPatterns on SerieResultsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SerieResultsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SerieResultsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SerieResultsDto value)  $default,){
final _that = this;
switch (_that) {
case _SerieResultsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SerieResultsDto value)?  $default,){
final _that = this;
switch (_that) {
case _SerieResultsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event, @JsonKey(name: 'resultats')  List<ResultatSerieDto> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SerieResultsDto() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.start,_that.event,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event, @JsonKey(name: 'resultats')  List<ResultatSerieDto> results)  $default,) {final _that = this;
switch (_that) {
case _SerieResultsDto():
return $default(_that.id,_that.number,_that.name,_that.start,_that.event,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Numero', readValue: readInt)  int? number, @JsonKey(name: 'Nom')  String? name, @JsonKey(name: 'Debut')  String? start, @JsonKey(name: 'epreuve', readValue: readMap)  EpreuveDto? event, @JsonKey(name: 'resultats')  List<ResultatSerieDto> results)?  $default,) {final _that = this;
switch (_that) {
case _SerieResultsDto() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.start,_that.event,_that.results);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SerieResultsDto implements SerieResultsDto {
  const _SerieResultsDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Numero', readValue: readInt) this.number, @JsonKey(name: 'Nom') this.name, @JsonKey(name: 'Debut') this.start, @JsonKey(name: 'epreuve', readValue: readMap) this.event, @JsonKey(name: 'resultats')  List<ResultatSerieDto> results = const <ResultatSerieDto>[]}): _results = results;
  factory _SerieResultsDto.fromJson(Map<String, dynamic> json) => _$SerieResultsDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Numero', readValue: readInt) final  int? number;
@override@JsonKey(name: 'Nom') final  String? name;
@override@JsonKey(name: 'Debut') final  String? start;
@override@JsonKey(name: 'epreuve', readValue: readMap) final  EpreuveDto? event;
 final  List<ResultatSerieDto> _results;
@override@JsonKey(name: 'resultats') List<ResultatSerieDto> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of SerieResultsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SerieResultsDtoCopyWith<_SerieResultsDto> get copyWith => __$SerieResultsDtoCopyWithImpl<_SerieResultsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SerieResultsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SerieResultsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.start, start) || other.start == start)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number,name,start,event,const DeepCollectionEquality().hash(_results));
}

@override
String toString() {
    return 'SerieResultsDto(id: $id, number: $number, name: $name, start: $start, event: $event, results: $results)';
}


}

/// @nodoc
abstract mixin class _$SerieResultsDtoCopyWith<$Res> implements $SerieResultsDtoCopyWith<$Res> {
  factory _$SerieResultsDtoCopyWith(_SerieResultsDto value, $Res Function(_SerieResultsDto) _then) = __$SerieResultsDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Numero', readValue: readInt) int? number,@JsonKey(name: 'Nom') String? name,@JsonKey(name: 'Debut') String? start,@JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event,@JsonKey(name: 'resultats') List<ResultatSerieDto> results
});


@override $EpreuveDtoCopyWith<$Res>? get event;

}
/// @nodoc
class __$SerieResultsDtoCopyWithImpl<$Res>
    implements _$SerieResultsDtoCopyWith<$Res> {
  __$SerieResultsDtoCopyWithImpl(this._self, this._then);

  final _SerieResultsDto _self;
  final $Res Function(_SerieResultsDto) _then;

/// Create a copy of SerieResultsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? number = freezed,Object? name = freezed,Object? start = freezed,Object? event = freezed,Object? results = null,}) {
  return _then(_SerieResultsDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as EpreuveDto?,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<ResultatSerieDto>,
  ));
}

/// Create a copy of SerieResultsDto
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
mixin _$ResultatSerieDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Statut', readValue: readInt) int? get status;@JsonKey(name: 'Temps', readValue: readInt) int? get time;@JsonKey(name: 'complement') String? get complement;@JsonKey(name: 'Athletes') List<AthleteResultDto> get athletes;@JsonKey(name: 'engagement', readValue: readMap) EngagementResultDto? get entry;
/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultatSerieDtoCopyWith<ResultatSerieDto> get copyWith => _$ResultatSerieDtoCopyWithImpl<ResultatSerieDto>(this as ResultatSerieDto, _$identity);

  /// Serializes this ResultatSerieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResultatSerieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultatSerieDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.complement, _this.complement) || other.complement == _this.complement)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&(identical(other.entry, _this.entry) || other.entry == _this.entry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResultatSerieDto;
  return Object.hash(runtimeType,_this.id,_this.status,_this.time,_this.complement,const DeepCollectionEquality().hash(_this.athletes),_this.entry);
}

@override
String toString() {
  final _this = this as ResultatSerieDto;
  return 'ResultatSerieDto(id: ${_this.id}, status: ${_this.status}, time: ${_this.time}, complement: ${_this.complement}, athletes: ${_this.athletes}, entry: ${_this.entry})';
}


}

/// @nodoc
abstract mixin class $ResultatSerieDtoCopyWith<$Res>  {
  factory $ResultatSerieDtoCopyWith(ResultatSerieDto value, $Res Function(ResultatSerieDto) _then) = _$ResultatSerieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Statut', readValue: readInt) int? status,@JsonKey(name: 'Temps', readValue: readInt) int? time,@JsonKey(name: 'complement') String? complement,@JsonKey(name: 'Athletes') List<AthleteResultDto> athletes,@JsonKey(name: 'engagement', readValue: readMap) EngagementResultDto? entry
});


$EngagementResultDtoCopyWith<$Res>? get entry;

}
/// @nodoc
class _$ResultatSerieDtoCopyWithImpl<$Res>
    implements $ResultatSerieDtoCopyWith<$Res> {
  _$ResultatSerieDtoCopyWithImpl(this._self, this._then);

  final ResultatSerieDto _self;
  final $Res Function(ResultatSerieDto) _then;

/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = freezed,Object? time = freezed,Object? complement = freezed,Object? athletes = null,Object? entry = freezed,}) {
  return _then(ResultatSerieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<AthleteResultDto>,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as EngagementResultDto?,
  ));
}
/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementResultDtoCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $EngagementResultDtoCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResultatSerieDto].
extension ResultatSerieDtoPatterns on ResultatSerieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultatSerieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultatSerieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultatSerieDto value)  $default,){
final _that = this;
switch (_that) {
case _ResultatSerieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultatSerieDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResultatSerieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'complement')  String? complement, @JsonKey(name: 'Athletes')  List<AthleteResultDto> athletes, @JsonKey(name: 'engagement', readValue: readMap)  EngagementResultDto? entry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultatSerieDto() when $default != null:
return $default(_that.id,_that.status,_that.time,_that.complement,_that.athletes,_that.entry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'complement')  String? complement, @JsonKey(name: 'Athletes')  List<AthleteResultDto> athletes, @JsonKey(name: 'engagement', readValue: readMap)  EngagementResultDto? entry)  $default,) {final _that = this;
switch (_that) {
case _ResultatSerieDto():
return $default(_that.id,_that.status,_that.time,_that.complement,_that.athletes,_that.entry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'complement')  String? complement, @JsonKey(name: 'Athletes')  List<AthleteResultDto> athletes, @JsonKey(name: 'engagement', readValue: readMap)  EngagementResultDto? entry)?  $default,) {final _that = this;
switch (_that) {
case _ResultatSerieDto() when $default != null:
return $default(_that.id,_that.status,_that.time,_that.complement,_that.athletes,_that.entry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResultatSerieDto implements ResultatSerieDto {
  const _ResultatSerieDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Statut', readValue: readInt) this.status, @JsonKey(name: 'Temps', readValue: readInt) this.time, @JsonKey(name: 'complement') this.complement, @JsonKey(name: 'Athletes')  List<AthleteResultDto> athletes = const <AthleteResultDto>[], @JsonKey(name: 'engagement', readValue: readMap) this.entry}): _athletes = athletes;
  factory _ResultatSerieDto.fromJson(Map<String, dynamic> json) => _$ResultatSerieDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Statut', readValue: readInt) final  int? status;
@override@JsonKey(name: 'Temps', readValue: readInt) final  int? time;
@override@JsonKey(name: 'complement') final  String? complement;
 final  List<AthleteResultDto> _athletes;
@override@JsonKey(name: 'Athletes') List<AthleteResultDto> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

@override@JsonKey(name: 'engagement', readValue: readMap) final  EngagementResultDto? entry;

/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultatSerieDtoCopyWith<_ResultatSerieDto> get copyWith => __$ResultatSerieDtoCopyWithImpl<_ResultatSerieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultatSerieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultatSerieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.time, time) || other.time == time)&&(identical(other.complement, complement) || other.complement == complement)&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&(identical(other.entry, entry) || other.entry == entry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,time,complement,const DeepCollectionEquality().hash(_athletes),entry);
}

@override
String toString() {
    return 'ResultatSerieDto(id: $id, status: $status, time: $time, complement: $complement, athletes: $athletes, entry: $entry)';
}


}

/// @nodoc
abstract mixin class _$ResultatSerieDtoCopyWith<$Res> implements $ResultatSerieDtoCopyWith<$Res> {
  factory _$ResultatSerieDtoCopyWith(_ResultatSerieDto value, $Res Function(_ResultatSerieDto) _then) = __$ResultatSerieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Statut', readValue: readInt) int? status,@JsonKey(name: 'Temps', readValue: readInt) int? time,@JsonKey(name: 'complement') String? complement,@JsonKey(name: 'Athletes') List<AthleteResultDto> athletes,@JsonKey(name: 'engagement', readValue: readMap) EngagementResultDto? entry
});


@override $EngagementResultDtoCopyWith<$Res>? get entry;

}
/// @nodoc
class __$ResultatSerieDtoCopyWithImpl<$Res>
    implements _$ResultatSerieDtoCopyWith<$Res> {
  __$ResultatSerieDtoCopyWithImpl(this._self, this._then);

  final _ResultatSerieDto _self;
  final $Res Function(_ResultatSerieDto) _then;

/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = freezed,Object? time = freezed,Object? complement = freezed,Object? athletes = null,Object? entry = freezed,}) {
  return _then(_ResultatSerieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<AthleteResultDto>,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as EngagementResultDto?,
  ));
}

/// Create a copy of ResultatSerieDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementResultDtoCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $EngagementResultDtoCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// @nodoc
mixin _$AthleteResultDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'label') String? get label;@JsonKey(name: 'sexe') String? get gender;@JsonKey(name: 'clubLabel') String? get club;@JsonKey(name: 'nationaliteCode') String? get nationality;@JsonKey(name: 'isInvite') bool? get isGuest;
/// Create a copy of AthleteResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthleteResultDtoCopyWith<AthleteResultDto> get copyWith => _$AthleteResultDtoCopyWithImpl<AthleteResultDto>(this as AthleteResultDto, _$identity);

  /// Serializes this AthleteResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthleteResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthleteResultDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.nationality, _this.nationality) || other.nationality == _this.nationality)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthleteResultDto;
  return Object.hash(runtimeType,_this.id,_this.label,_this.gender,_this.club,_this.nationality,_this.isGuest);
}

@override
String toString() {
  final _this = this as AthleteResultDto;
  return 'AthleteResultDto(id: ${_this.id}, label: ${_this.label}, gender: ${_this.gender}, club: ${_this.club}, nationality: ${_this.nationality}, isGuest: ${_this.isGuest})';
}


}

/// @nodoc
abstract mixin class $AthleteResultDtoCopyWith<$Res>  {
  factory $AthleteResultDtoCopyWith(AthleteResultDto value, $Res Function(AthleteResultDto) _then) = _$AthleteResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'label') String? label,@JsonKey(name: 'sexe') String? gender,@JsonKey(name: 'clubLabel') String? club,@JsonKey(name: 'nationaliteCode') String? nationality,@JsonKey(name: 'isInvite') bool? isGuest
});




}
/// @nodoc
class _$AthleteResultDtoCopyWithImpl<$Res>
    implements $AthleteResultDtoCopyWith<$Res> {
  _$AthleteResultDtoCopyWithImpl(this._self, this._then);

  final AthleteResultDto _self;
  final $Res Function(AthleteResultDto) _then;

/// Create a copy of AthleteResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,Object? gender = freezed,Object? club = freezed,Object? nationality = freezed,Object? isGuest = freezed,}) {
  return _then(AthleteResultDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,isGuest: freezed == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [AthleteResultDto].
extension AthleteResultDtoPatterns on AthleteResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthleteResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthleteResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthleteResultDto value)  $default,){
final _that = this;
switch (_that) {
case _AthleteResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthleteResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _AthleteResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'nationaliteCode')  String? nationality, @JsonKey(name: 'isInvite')  bool? isGuest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthleteResultDto() when $default != null:
return $default(_that.id,_that.label,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'nationaliteCode')  String? nationality, @JsonKey(name: 'isInvite')  bool? isGuest)  $default,) {final _that = this;
switch (_that) {
case _AthleteResultDto():
return $default(_that.id,_that.label,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label, @JsonKey(name: 'sexe')  String? gender, @JsonKey(name: 'clubLabel')  String? club, @JsonKey(name: 'nationaliteCode')  String? nationality, @JsonKey(name: 'isInvite')  bool? isGuest)?  $default,) {final _that = this;
switch (_that) {
case _AthleteResultDto() when $default != null:
return $default(_that.id,_that.label,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthleteResultDto implements AthleteResultDto {
  const _AthleteResultDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'label') this.label, @JsonKey(name: 'sexe') this.gender, @JsonKey(name: 'clubLabel') this.club, @JsonKey(name: 'nationaliteCode') this.nationality, @JsonKey(name: 'isInvite') this.isGuest});
  factory _AthleteResultDto.fromJson(Map<String, dynamic> json) => _$AthleteResultDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'label') final  String? label;
@override@JsonKey(name: 'sexe') final  String? gender;
@override@JsonKey(name: 'clubLabel') final  String? club;
@override@JsonKey(name: 'nationaliteCode') final  String? nationality;
@override@JsonKey(name: 'isInvite') final  bool? isGuest;

/// Create a copy of AthleteResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthleteResultDtoCopyWith<_AthleteResultDto> get copyWith => __$AthleteResultDtoCopyWithImpl<_AthleteResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthleteResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthleteResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.club, club) || other.club == club)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,gender,club,nationality,isGuest);
}

@override
String toString() {
    return 'AthleteResultDto(id: $id, label: $label, gender: $gender, club: $club, nationality: $nationality, isGuest: $isGuest)';
}


}

/// @nodoc
abstract mixin class _$AthleteResultDtoCopyWith<$Res> implements $AthleteResultDtoCopyWith<$Res> {
  factory _$AthleteResultDtoCopyWith(_AthleteResultDto value, $Res Function(_AthleteResultDto) _then) = __$AthleteResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'label') String? label,@JsonKey(name: 'sexe') String? gender,@JsonKey(name: 'clubLabel') String? club,@JsonKey(name: 'nationaliteCode') String? nationality,@JsonKey(name: 'isInvite') bool? isGuest
});




}
/// @nodoc
class __$AthleteResultDtoCopyWithImpl<$Res>
    implements _$AthleteResultDtoCopyWith<$Res> {
  __$AthleteResultDtoCopyWithImpl(this._self, this._then);

  final _AthleteResultDto _self;
  final $Res Function(_AthleteResultDto) _then;

/// Create a copy of AthleteResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,Object? gender = freezed,Object? club = freezed,Object? nationality = freezed,Object? isGuest = freezed,}) {
  return _then(_AthleteResultDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,isGuest: freezed == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$EngagementResultDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'IdEpreuve', readValue: readInt) int? get eventId;@JsonKey(name: 'categorie', readValue: readMap) EngagementCategorieDto? get category;@JsonKey(name: 'clubLabel') String? get club;
/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EngagementResultDtoCopyWith<EngagementResultDto> get copyWith => _$EngagementResultDtoCopyWithImpl<EngagementResultDto>(this as EngagementResultDto, _$identity);

  /// Serializes this EngagementResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EngagementResultDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngagementResultDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.club, _this.club) || other.club == _this.club));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EngagementResultDto;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.category,_this.club);
}

@override
String toString() {
  final _this = this as EngagementResultDto;
  return 'EngagementResultDto(id: ${_this.id}, eventId: ${_this.eventId}, category: ${_this.category}, club: ${_this.club})';
}


}

/// @nodoc
abstract mixin class $EngagementResultDtoCopyWith<$Res>  {
  factory $EngagementResultDtoCopyWith(EngagementResultDto value, $Res Function(EngagementResultDto) _then) = _$EngagementResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'IdEpreuve', readValue: readInt) int? eventId,@JsonKey(name: 'categorie', readValue: readMap) EngagementCategorieDto? category,@JsonKey(name: 'clubLabel') String? club
});


$EngagementCategorieDtoCopyWith<$Res>? get category;

}
/// @nodoc
class _$EngagementResultDtoCopyWithImpl<$Res>
    implements $EngagementResultDtoCopyWith<$Res> {
  _$EngagementResultDtoCopyWithImpl(this._self, this._then);

  final EngagementResultDto _self;
  final $Res Function(EngagementResultDto) _then;

/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? eventId = freezed,Object? category = freezed,Object? club = freezed,}) {
  return _then(EngagementResultDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EngagementCategorieDto?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementCategorieDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $EngagementCategorieDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [EngagementResultDto].
extension EngagementResultDtoPatterns on EngagementResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EngagementResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EngagementResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EngagementResultDto value)  $default,){
final _that = this;
switch (_that) {
case _EngagementResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EngagementResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _EngagementResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdEpreuve', readValue: readInt)  int? eventId, @JsonKey(name: 'categorie', readValue: readMap)  EngagementCategorieDto? category, @JsonKey(name: 'clubLabel')  String? club)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EngagementResultDto() when $default != null:
return $default(_that.id,_that.eventId,_that.category,_that.club);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdEpreuve', readValue: readInt)  int? eventId, @JsonKey(name: 'categorie', readValue: readMap)  EngagementCategorieDto? category, @JsonKey(name: 'clubLabel')  String? club)  $default,) {final _that = this;
switch (_that) {
case _EngagementResultDto():
return $default(_that.id,_that.eventId,_that.category,_that.club);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'IdEpreuve', readValue: readInt)  int? eventId, @JsonKey(name: 'categorie', readValue: readMap)  EngagementCategorieDto? category, @JsonKey(name: 'clubLabel')  String? club)?  $default,) {final _that = this;
switch (_that) {
case _EngagementResultDto() when $default != null:
return $default(_that.id,_that.eventId,_that.category,_that.club);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EngagementResultDto implements EngagementResultDto {
  const _EngagementResultDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'IdEpreuve', readValue: readInt) this.eventId, @JsonKey(name: 'categorie', readValue: readMap) this.category, @JsonKey(name: 'clubLabel') this.club});
  factory _EngagementResultDto.fromJson(Map<String, dynamic> json) => _$EngagementResultDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'IdEpreuve', readValue: readInt) final  int? eventId;
@override@JsonKey(name: 'categorie', readValue: readMap) final  EngagementCategorieDto? category;
@override@JsonKey(name: 'clubLabel') final  String? club;

/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EngagementResultDtoCopyWith<_EngagementResultDto> get copyWith => __$EngagementResultDtoCopyWithImpl<_EngagementResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EngagementResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EngagementResultDto&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.category, category) || other.category == category)&&(identical(other.club, club) || other.club == club));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,category,club);
}

@override
String toString() {
    return 'EngagementResultDto(id: $id, eventId: $eventId, category: $category, club: $club)';
}


}

/// @nodoc
abstract mixin class _$EngagementResultDtoCopyWith<$Res> implements $EngagementResultDtoCopyWith<$Res> {
  factory _$EngagementResultDtoCopyWith(_EngagementResultDto value, $Res Function(_EngagementResultDto) _then) = __$EngagementResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'IdEpreuve', readValue: readInt) int? eventId,@JsonKey(name: 'categorie', readValue: readMap) EngagementCategorieDto? category,@JsonKey(name: 'clubLabel') String? club
});


@override $EngagementCategorieDtoCopyWith<$Res>? get category;

}
/// @nodoc
class __$EngagementResultDtoCopyWithImpl<$Res>
    implements _$EngagementResultDtoCopyWith<$Res> {
  __$EngagementResultDtoCopyWithImpl(this._self, this._then);

  final _EngagementResultDto _self;
  final $Res Function(_EngagementResultDto) _then;

/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? eventId = freezed,Object? category = freezed,Object? club = freezed,}) {
  return _then(_EngagementResultDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EngagementCategorieDto?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EngagementResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementCategorieDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $EngagementCategorieDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$EngagementCategorieDto {

@JsonKey(name: 'Nom') String? get name;
/// Create a copy of EngagementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EngagementCategorieDtoCopyWith<EngagementCategorieDto> get copyWith => _$EngagementCategorieDtoCopyWithImpl<EngagementCategorieDto>(this as EngagementCategorieDto, _$identity);

  /// Serializes this EngagementCategorieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EngagementCategorieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngagementCategorieDto&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EngagementCategorieDto;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as EngagementCategorieDto;
  return 'EngagementCategorieDto(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $EngagementCategorieDtoCopyWith<$Res>  {
  factory $EngagementCategorieDtoCopyWith(EngagementCategorieDto value, $Res Function(EngagementCategorieDto) _then) = _$EngagementCategorieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class _$EngagementCategorieDtoCopyWithImpl<$Res>
    implements $EngagementCategorieDtoCopyWith<$Res> {
  _$EngagementCategorieDtoCopyWithImpl(this._self, this._then);

  final EngagementCategorieDto _self;
  final $Res Function(EngagementCategorieDto) _then;

/// Create a copy of EngagementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,}) {
  return _then(EngagementCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EngagementCategorieDto].
extension EngagementCategorieDtoPatterns on EngagementCategorieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EngagementCategorieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EngagementCategorieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EngagementCategorieDto value)  $default,){
final _that = this;
switch (_that) {
case _EngagementCategorieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EngagementCategorieDto value)?  $default,){
final _that = this;
switch (_that) {
case _EngagementCategorieDto() when $default != null:
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
case _EngagementCategorieDto() when $default != null:
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
case _EngagementCategorieDto():
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
case _EngagementCategorieDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EngagementCategorieDto implements EngagementCategorieDto {
  const _EngagementCategorieDto({@JsonKey(name: 'Nom') this.name});
  factory _EngagementCategorieDto.fromJson(Map<String, dynamic> json) => _$EngagementCategorieDtoFromJson(json);

@override@JsonKey(name: 'Nom') final  String? name;

/// Create a copy of EngagementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EngagementCategorieDtoCopyWith<_EngagementCategorieDto> get copyWith => __$EngagementCategorieDtoCopyWithImpl<_EngagementCategorieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EngagementCategorieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EngagementCategorieDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'EngagementCategorieDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$EngagementCategorieDtoCopyWith<$Res> implements $EngagementCategorieDtoCopyWith<$Res> {
  factory _$EngagementCategorieDtoCopyWith(_EngagementCategorieDto value, $Res Function(_EngagementCategorieDto) _then) = __$EngagementCategorieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Nom') String? name
});




}
/// @nodoc
class __$EngagementCategorieDtoCopyWithImpl<$Res>
    implements _$EngagementCategorieDtoCopyWith<$Res> {
  __$EngagementCategorieDtoCopyWithImpl(this._self, this._then);

  final _EngagementCategorieDto _self;
  final $Res Function(_EngagementCategorieDto) _then;

/// Create a copy of EngagementCategorieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,}) {
  return _then(_EngagementCategorieDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
