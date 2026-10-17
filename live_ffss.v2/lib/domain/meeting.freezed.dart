// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeetingItem {

 int get id; String get name;/// La « partie » FFSS que le créneau couvre, comme `MeetingItem.RoundId`
/// dans V3. Nulle pour un créneau sans tour.
 int? get roundId; List<Heat> get heats;
/// Create a copy of MeetingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<MeetingItem> get copyWith => _$MeetingItemCopyWithImpl<MeetingItem>(this as MeetingItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MeetingItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.roundId, _this.roundId) || other.roundId == _this.roundId)&&const DeepCollectionEquality().equals(other.heats, _this.heats));
}


@override
int get hashCode {
  final _this = this as MeetingItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.roundId,const DeepCollectionEquality().hash(_this.heats));
}

@override
String toString() {
  final _this = this as MeetingItem;
  return 'MeetingItem(id: ${_this.id}, name: ${_this.name}, roundId: ${_this.roundId}, heats: ${_this.heats})';
}


}

/// @nodoc
abstract mixin class $MeetingItemCopyWith<$Res>  {
  factory $MeetingItemCopyWith(MeetingItem value, $Res Function(MeetingItem) _then) = _$MeetingItemCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? roundId, List<Heat> heats
});




}
/// @nodoc
class _$MeetingItemCopyWithImpl<$Res>
    implements $MeetingItemCopyWith<$Res> {
  _$MeetingItemCopyWithImpl(this._self, this._then);

  final MeetingItem _self;
  final $Res Function(MeetingItem) _then;

/// Create a copy of MeetingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? roundId = freezed,Object? heats = null,}) {
  return _then(MeetingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roundId: freezed == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as int?,heats: null == heats ? _self.heats : heats // ignore: cast_nullable_to_non_nullable
as List<Heat>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingItem].
extension MeetingItemPatterns on MeetingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingItem value)  $default,){
final _that = this;
switch (_that) {
case _MeetingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingItem value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int? roundId,  List<Heat> heats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingItem() when $default != null:
return $default(_that.id,_that.name,_that.roundId,_that.heats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int? roundId,  List<Heat> heats)  $default,) {final _that = this;
switch (_that) {
case _MeetingItem():
return $default(_that.id,_that.name,_that.roundId,_that.heats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int? roundId,  List<Heat> heats)?  $default,) {final _that = this;
switch (_that) {
case _MeetingItem() when $default != null:
return $default(_that.id,_that.name,_that.roundId,_that.heats);case _:
  return null;

}
}

}

/// @nodoc


class _MeetingItem implements MeetingItem {
  const _MeetingItem({required this.id, required this.name, this.roundId,  List<Heat> heats = const <Heat>[]}): _heats = heats;
  

@override final  int id;
@override final  String name;
/// La « partie » FFSS que le créneau couvre, comme `MeetingItem.RoundId`
/// dans V3. Nulle pour un créneau sans tour.
@override final  int? roundId;
 final  List<Heat> _heats;
@override@JsonKey() List<Heat> get heats {
  if (_heats is EqualUnmodifiableListView) return _heats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_heats);
}


/// Create a copy of MeetingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingItemCopyWith<_MeetingItem> get copyWith => __$MeetingItemCopyWithImpl<_MeetingItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&const DeepCollectionEquality().equals(other.heats, _heats));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,roundId,const DeepCollectionEquality().hash(_heats));
}

@override
String toString() {
    return 'MeetingItem(id: $id, name: $name, roundId: $roundId, heats: $heats)';
}


}

/// @nodoc
abstract mixin class _$MeetingItemCopyWith<$Res> implements $MeetingItemCopyWith<$Res> {
  factory _$MeetingItemCopyWith(_MeetingItem value, $Res Function(_MeetingItem) _then) = __$MeetingItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? roundId, List<Heat> heats
});




}
/// @nodoc
class __$MeetingItemCopyWithImpl<$Res>
    implements _$MeetingItemCopyWith<$Res> {
  __$MeetingItemCopyWithImpl(this._self, this._then);

  final _MeetingItem _self;
  final $Res Function(_MeetingItem) _then;

/// Create a copy of MeetingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? roundId = freezed,Object? heats = null,}) {
  return _then(_MeetingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roundId: freezed == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as int?,heats: null == heats ? _self._heats : heats // ignore: cast_nullable_to_non_nullable
as List<Heat>,
  ));
}


}

/// @nodoc
mixin _$Meeting {

 int get id; String get name; DateTime get day; DateTime? get startTime; DateTime? get endTime; List<MeetingItem> get items;
/// Create a copy of Meeting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingCopyWith<Meeting> get copyWith => _$MeetingCopyWithImpl<Meeting>(this as Meeting, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Meeting;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Meeting&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as Meeting;
  return Object.hash(runtimeType,_this.id,_this.name,_this.day,_this.startTime,_this.endTime,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as Meeting;
  return 'Meeting(id: ${_this.id}, name: ${_this.name}, day: ${_this.day}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $MeetingCopyWith<$Res>  {
  factory $MeetingCopyWith(Meeting value, $Res Function(Meeting) _then) = _$MeetingCopyWithImpl;
@useResult
$Res call({
 int id, String name, DateTime day, DateTime? startTime, DateTime? endTime, List<MeetingItem> items
});




}
/// @nodoc
class _$MeetingCopyWithImpl<$Res>
    implements $MeetingCopyWith<$Res> {
  _$MeetingCopyWithImpl(this._self, this._then);

  final Meeting _self;
  final $Res Function(Meeting) _then;

/// Create a copy of Meeting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? day = null,Object? startTime = freezed,Object? endTime = freezed,Object? items = null,}) {
  return _then(Meeting(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Meeting].
extension MeetingPatterns on Meeting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Meeting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Meeting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Meeting value)  $default,){
final _that = this;
switch (_that) {
case _Meeting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Meeting value)?  $default,){
final _that = this;
switch (_that) {
case _Meeting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  DateTime day,  DateTime? startTime,  DateTime? endTime,  List<MeetingItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Meeting() when $default != null:
return $default(_that.id,_that.name,_that.day,_that.startTime,_that.endTime,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  DateTime day,  DateTime? startTime,  DateTime? endTime,  List<MeetingItem> items)  $default,) {final _that = this;
switch (_that) {
case _Meeting():
return $default(_that.id,_that.name,_that.day,_that.startTime,_that.endTime,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  DateTime day,  DateTime? startTime,  DateTime? endTime,  List<MeetingItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Meeting() when $default != null:
return $default(_that.id,_that.name,_that.day,_that.startTime,_that.endTime,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Meeting implements Meeting {
  const _Meeting({required this.id, required this.name, required this.day, this.startTime, this.endTime,  List<MeetingItem> items = const <MeetingItem>[]}): _items = items;
  

@override final  int id;
@override final  String name;
@override final  DateTime day;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
 final  List<MeetingItem> _items;
@override@JsonKey() List<MeetingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Meeting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingCopyWith<_Meeting> get copyWith => __$MeetingCopyWithImpl<_Meeting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Meeting&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.day, day) || other.day == day)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,day,startTime,endTime,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'Meeting(id: $id, name: $name, day: $day, startTime: $startTime, endTime: $endTime, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MeetingCopyWith<$Res> implements $MeetingCopyWith<$Res> {
  factory _$MeetingCopyWith(_Meeting value, $Res Function(_Meeting) _then) = __$MeetingCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DateTime day, DateTime? startTime, DateTime? endTime, List<MeetingItem> items
});




}
/// @nodoc
class __$MeetingCopyWithImpl<$Res>
    implements _$MeetingCopyWith<$Res> {
  __$MeetingCopyWithImpl(this._self, this._then);

  final _Meeting _self;
  final $Res Function(_Meeting) _then;

/// Create a copy of Meeting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? day = null,Object? startTime = freezed,Object? endTime = freezed,Object? items = null,}) {
  return _then(_Meeting(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,
  ));
}


}

// dart format on
