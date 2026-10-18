// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resultat_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResultatDto {

@JsonKey(name: 'Id', readValue: _readAnyId) int? get id;@JsonKey(name: 'Temps', readValue: readInt) int? get time;@JsonKey(name: 'TempsLive1', readValue: readInt) int? get chrono1;@JsonKey(name: 'TempsLive2', readValue: readInt) int? get chrono2;@JsonKey(name: 'TempsLive3', readValue: readInt) int? get chrono3;@JsonKey(name: 'Rang', readValue: readInt) int? get rank;@JsonKey(name: 'Statut', readValue: readInt) int? get status;@JsonKey(name: 'complement') Object? get complement;@JsonKey(name: 'points', readValue: readInt) int? get points;@JsonKey(name: 'engagement', readValue: readMap) ResultatRefDto? get entry;@JsonKey(name: 'serie', readValue: readMap) ResultatRefDto? get series;
/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultatDtoCopyWith<ResultatDto> get copyWith => _$ResultatDtoCopyWithImpl<ResultatDto>(this as ResultatDto, _$identity);

  /// Serializes this ResultatDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResultatDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultatDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.chrono1, _this.chrono1) || other.chrono1 == _this.chrono1)&&(identical(other.chrono2, _this.chrono2) || other.chrono2 == _this.chrono2)&&(identical(other.chrono3, _this.chrono3) || other.chrono3 == _this.chrono3)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.complement, _this.complement)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.series, _this.series) || other.series == _this.series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResultatDto;
  return Object.hash(runtimeType,_this.id,_this.time,_this.chrono1,_this.chrono2,_this.chrono3,_this.rank,_this.status,const DeepCollectionEquality().hash(_this.complement),_this.points,_this.entry,_this.series);
}

@override
String toString() {
  final _this = this as ResultatDto;
  return 'ResultatDto(id: ${_this.id}, time: ${_this.time}, chrono1: ${_this.chrono1}, chrono2: ${_this.chrono2}, chrono3: ${_this.chrono3}, rank: ${_this.rank}, status: ${_this.status}, complement: ${_this.complement}, points: ${_this.points}, entry: ${_this.entry}, series: ${_this.series})';
}


}

/// @nodoc
abstract mixin class $ResultatDtoCopyWith<$Res>  {
  factory $ResultatDtoCopyWith(ResultatDto value, $Res Function(ResultatDto) _then) = _$ResultatDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readAnyId) int? id,@JsonKey(name: 'Temps', readValue: readInt) int? time,@JsonKey(name: 'TempsLive1', readValue: readInt) int? chrono1,@JsonKey(name: 'TempsLive2', readValue: readInt) int? chrono2,@JsonKey(name: 'TempsLive3', readValue: readInt) int? chrono3,@JsonKey(name: 'Rang', readValue: readInt) int? rank,@JsonKey(name: 'Statut', readValue: readInt) int? status,@JsonKey(name: 'complement') Object? complement,@JsonKey(name: 'points', readValue: readInt) int? points,@JsonKey(name: 'engagement', readValue: readMap) ResultatRefDto? entry,@JsonKey(name: 'serie', readValue: readMap) ResultatRefDto? series
});


$ResultatRefDtoCopyWith<$Res>? get entry;$ResultatRefDtoCopyWith<$Res>? get series;

}
/// @nodoc
class _$ResultatDtoCopyWithImpl<$Res>
    implements $ResultatDtoCopyWith<$Res> {
  _$ResultatDtoCopyWithImpl(this._self, this._then);

  final ResultatDto _self;
  final $Res Function(ResultatDto) _then;

/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? time = freezed,Object? chrono1 = freezed,Object? chrono2 = freezed,Object? chrono3 = freezed,Object? rank = freezed,Object? status = freezed,Object? complement = freezed,Object? points = freezed,Object? entry = freezed,Object? series = freezed,}) {
  return _then(ResultatDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,chrono1: freezed == chrono1 ? _self.chrono1 : chrono1 // ignore: cast_nullable_to_non_nullable
as int?,chrono2: freezed == chrono2 ? _self.chrono2 : chrono2 // ignore: cast_nullable_to_non_nullable
as int?,chrono3: freezed == chrono3 ? _self.chrono3 : chrono3 // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,complement: freezed == complement ? _self.complement : complement ,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as ResultatRefDto?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as ResultatRefDto?,
  ));
}
/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultatRefDtoCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $ResultatRefDtoCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultatRefDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $ResultatRefDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResultatDto].
extension ResultatDtoPatterns on ResultatDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultatDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultatDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultatDto value)  $default,){
final _that = this;
switch (_that) {
case _ResultatDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultatDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResultatDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'TempsLive1', readValue: readInt)  int? chrono1, @JsonKey(name: 'TempsLive2', readValue: readInt)  int? chrono2, @JsonKey(name: 'TempsLive3', readValue: readInt)  int? chrono3, @JsonKey(name: 'Rang', readValue: readInt)  int? rank, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'complement')  Object? complement, @JsonKey(name: 'points', readValue: readInt)  int? points, @JsonKey(name: 'engagement', readValue: readMap)  ResultatRefDto? entry, @JsonKey(name: 'serie', readValue: readMap)  ResultatRefDto? series)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultatDto() when $default != null:
return $default(_that.id,_that.time,_that.chrono1,_that.chrono2,_that.chrono3,_that.rank,_that.status,_that.complement,_that.points,_that.entry,_that.series);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'TempsLive1', readValue: readInt)  int? chrono1, @JsonKey(name: 'TempsLive2', readValue: readInt)  int? chrono2, @JsonKey(name: 'TempsLive3', readValue: readInt)  int? chrono3, @JsonKey(name: 'Rang', readValue: readInt)  int? rank, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'complement')  Object? complement, @JsonKey(name: 'points', readValue: readInt)  int? points, @JsonKey(name: 'engagement', readValue: readMap)  ResultatRefDto? entry, @JsonKey(name: 'serie', readValue: readMap)  ResultatRefDto? series)  $default,) {final _that = this;
switch (_that) {
case _ResultatDto():
return $default(_that.id,_that.time,_that.chrono1,_that.chrono2,_that.chrono3,_that.rank,_that.status,_that.complement,_that.points,_that.entry,_that.series);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id, @JsonKey(name: 'Temps', readValue: readInt)  int? time, @JsonKey(name: 'TempsLive1', readValue: readInt)  int? chrono1, @JsonKey(name: 'TempsLive2', readValue: readInt)  int? chrono2, @JsonKey(name: 'TempsLive3', readValue: readInt)  int? chrono3, @JsonKey(name: 'Rang', readValue: readInt)  int? rank, @JsonKey(name: 'Statut', readValue: readInt)  int? status, @JsonKey(name: 'complement')  Object? complement, @JsonKey(name: 'points', readValue: readInt)  int? points, @JsonKey(name: 'engagement', readValue: readMap)  ResultatRefDto? entry, @JsonKey(name: 'serie', readValue: readMap)  ResultatRefDto? series)?  $default,) {final _that = this;
switch (_that) {
case _ResultatDto() when $default != null:
return $default(_that.id,_that.time,_that.chrono1,_that.chrono2,_that.chrono3,_that.rank,_that.status,_that.complement,_that.points,_that.entry,_that.series);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResultatDto implements ResultatDto {
  const _ResultatDto({@JsonKey(name: 'Id', readValue: _readAnyId) this.id, @JsonKey(name: 'Temps', readValue: readInt) this.time, @JsonKey(name: 'TempsLive1', readValue: readInt) this.chrono1, @JsonKey(name: 'TempsLive2', readValue: readInt) this.chrono2, @JsonKey(name: 'TempsLive3', readValue: readInt) this.chrono3, @JsonKey(name: 'Rang', readValue: readInt) this.rank, @JsonKey(name: 'Statut', readValue: readInt) this.status, @JsonKey(name: 'complement') this.complement, @JsonKey(name: 'points', readValue: readInt) this.points, @JsonKey(name: 'engagement', readValue: readMap) this.entry, @JsonKey(name: 'serie', readValue: readMap) this.series});
  factory _ResultatDto.fromJson(Map<String, dynamic> json) => _$ResultatDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: _readAnyId) final  int? id;
@override@JsonKey(name: 'Temps', readValue: readInt) final  int? time;
@override@JsonKey(name: 'TempsLive1', readValue: readInt) final  int? chrono1;
@override@JsonKey(name: 'TempsLive2', readValue: readInt) final  int? chrono2;
@override@JsonKey(name: 'TempsLive3', readValue: readInt) final  int? chrono3;
@override@JsonKey(name: 'Rang', readValue: readInt) final  int? rank;
@override@JsonKey(name: 'Statut', readValue: readInt) final  int? status;
@override@JsonKey(name: 'complement') final  Object? complement;
@override@JsonKey(name: 'points', readValue: readInt) final  int? points;
@override@JsonKey(name: 'engagement', readValue: readMap) final  ResultatRefDto? entry;
@override@JsonKey(name: 'serie', readValue: readMap) final  ResultatRefDto? series;

/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultatDtoCopyWith<_ResultatDto> get copyWith => __$ResultatDtoCopyWithImpl<_ResultatDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultatDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultatDto&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.chrono1, chrono1) || other.chrono1 == chrono1)&&(identical(other.chrono2, chrono2) || other.chrono2 == chrono2)&&(identical(other.chrono3, chrono3) || other.chrono3 == chrono3)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.complement, complement)&&(identical(other.points, points) || other.points == points)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.series, series) || other.series == series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,time,chrono1,chrono2,chrono3,rank,status,const DeepCollectionEquality().hash(complement),points,entry,series);
}

@override
String toString() {
    return 'ResultatDto(id: $id, time: $time, chrono1: $chrono1, chrono2: $chrono2, chrono3: $chrono3, rank: $rank, status: $status, complement: $complement, points: $points, entry: $entry, series: $series)';
}


}

/// @nodoc
abstract mixin class _$ResultatDtoCopyWith<$Res> implements $ResultatDtoCopyWith<$Res> {
  factory _$ResultatDtoCopyWith(_ResultatDto value, $Res Function(_ResultatDto) _then) = __$ResultatDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readAnyId) int? id,@JsonKey(name: 'Temps', readValue: readInt) int? time,@JsonKey(name: 'TempsLive1', readValue: readInt) int? chrono1,@JsonKey(name: 'TempsLive2', readValue: readInt) int? chrono2,@JsonKey(name: 'TempsLive3', readValue: readInt) int? chrono3,@JsonKey(name: 'Rang', readValue: readInt) int? rank,@JsonKey(name: 'Statut', readValue: readInt) int? status,@JsonKey(name: 'complement') Object? complement,@JsonKey(name: 'points', readValue: readInt) int? points,@JsonKey(name: 'engagement', readValue: readMap) ResultatRefDto? entry,@JsonKey(name: 'serie', readValue: readMap) ResultatRefDto? series
});


@override $ResultatRefDtoCopyWith<$Res>? get entry;@override $ResultatRefDtoCopyWith<$Res>? get series;

}
/// @nodoc
class __$ResultatDtoCopyWithImpl<$Res>
    implements _$ResultatDtoCopyWith<$Res> {
  __$ResultatDtoCopyWithImpl(this._self, this._then);

  final _ResultatDto _self;
  final $Res Function(_ResultatDto) _then;

/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? time = freezed,Object? chrono1 = freezed,Object? chrono2 = freezed,Object? chrono3 = freezed,Object? rank = freezed,Object? status = freezed,Object? complement = freezed,Object? points = freezed,Object? entry = freezed,Object? series = freezed,}) {
  return _then(_ResultatDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,chrono1: freezed == chrono1 ? _self.chrono1 : chrono1 // ignore: cast_nullable_to_non_nullable
as int?,chrono2: freezed == chrono2 ? _self.chrono2 : chrono2 // ignore: cast_nullable_to_non_nullable
as int?,chrono3: freezed == chrono3 ? _self.chrono3 : chrono3 // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,complement: freezed == complement ? _self.complement : complement ,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as ResultatRefDto?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as ResultatRefDto?,
  ));
}

/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultatRefDtoCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $ResultatRefDtoCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of ResultatDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultatRefDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $ResultatRefDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// @nodoc
mixin _$ResultatRefDto {

@JsonKey(name: 'Id', readValue: _readAnyId) int? get id;
/// Create a copy of ResultatRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultatRefDtoCopyWith<ResultatRefDto> get copyWith => _$ResultatRefDtoCopyWithImpl<ResultatRefDto>(this as ResultatRefDto, _$identity);

  /// Serializes this ResultatRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResultatRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultatRefDto&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResultatRefDto;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as ResultatRefDto;
  return 'ResultatRefDto(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $ResultatRefDtoCopyWith<$Res>  {
  factory $ResultatRefDtoCopyWith(ResultatRefDto value, $Res Function(ResultatRefDto) _then) = _$ResultatRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readAnyId) int? id
});




}
/// @nodoc
class _$ResultatRefDtoCopyWithImpl<$Res>
    implements $ResultatRefDtoCopyWith<$Res> {
  _$ResultatRefDtoCopyWithImpl(this._self, this._then);

  final ResultatRefDto _self;
  final $Res Function(ResultatRefDto) _then;

/// Create a copy of ResultatRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,}) {
  return _then(ResultatRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultatRefDto].
extension ResultatRefDtoPatterns on ResultatRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultatRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultatRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultatRefDto value)  $default,){
final _that = this;
switch (_that) {
case _ResultatRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultatRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResultatRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultatRefDto() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id)  $default,) {final _that = this;
switch (_that) {
case _ResultatRefDto():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: _readAnyId)  int? id)?  $default,) {final _that = this;
switch (_that) {
case _ResultatRefDto() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResultatRefDto implements ResultatRefDto {
  const _ResultatRefDto({@JsonKey(name: 'Id', readValue: _readAnyId) this.id});
  factory _ResultatRefDto.fromJson(Map<String, dynamic> json) => _$ResultatRefDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: _readAnyId) final  int? id;

/// Create a copy of ResultatRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultatRefDtoCopyWith<_ResultatRefDto> get copyWith => __$ResultatRefDtoCopyWithImpl<_ResultatRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultatRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultatRefDto&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'ResultatRefDto(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ResultatRefDtoCopyWith<$Res> implements $ResultatRefDtoCopyWith<$Res> {
  factory _$ResultatRefDtoCopyWith(_ResultatRefDto value, $Res Function(_ResultatRefDto) _then) = __$ResultatRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: _readAnyId) int? id
});




}
/// @nodoc
class __$ResultatRefDtoCopyWithImpl<$Res>
    implements _$ResultatRefDtoCopyWith<$Res> {
  __$ResultatRefDtoCopyWithImpl(this._self, this._then);

  final _ResultatRefDto _self;
  final $Res Function(_ResultatRefDto) _then;

/// Create a copy of ResultatRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,}) {
  return _then(_ResultatRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
