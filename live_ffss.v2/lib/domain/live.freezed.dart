// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiveEntry {

 Meeting get meeting; MeetingItem get item; Heat get heat;
/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<LiveEntry> get copyWith => _$LiveEntryCopyWithImpl<LiveEntry>(this as LiveEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveEntry&&(identical(other.meeting, _this.meeting) || other.meeting == _this.meeting)&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.heat, _this.heat) || other.heat == _this.heat));
}


@override
int get hashCode {
  final _this = this as LiveEntry;
  return Object.hash(runtimeType,_this.meeting,_this.item,_this.heat);
}

@override
String toString() {
  final _this = this as LiveEntry;
  return 'LiveEntry(meeting: ${_this.meeting}, item: ${_this.item}, heat: ${_this.heat})';
}


}

/// @nodoc
abstract mixin class $LiveEntryCopyWith<$Res>  {
  factory $LiveEntryCopyWith(LiveEntry value, $Res Function(LiveEntry) _then) = _$LiveEntryCopyWithImpl;
@useResult
$Res call({
 Meeting meeting, MeetingItem item, Heat heat
});


$MeetingCopyWith<$Res> get meeting;$MeetingItemCopyWith<$Res> get item;$HeatCopyWith<$Res> get heat;

}
/// @nodoc
class _$LiveEntryCopyWithImpl<$Res>
    implements $LiveEntryCopyWith<$Res> {
  _$LiveEntryCopyWithImpl(this._self, this._then);

  final LiveEntry _self;
  final $Res Function(LiveEntry) _then;

/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meeting = null,Object? item = null,Object? heat = null,}) {
  return _then(LiveEntry(
meeting: null == meeting ? _self.meeting : meeting // ignore: cast_nullable_to_non_nullable
as Meeting,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MeetingItem,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,
  ));
}
/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingCopyWith<$Res> get meeting {
  
  return $MeetingCopyWith<$Res>(_self.meeting, (value) {
    return _then(_self.copyWith(meeting: value));
  });
}/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<$Res> get item {
  
  return $MeetingItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiveEntry].
extension LiveEntryPatterns on LiveEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveEntry value)  $default,){
final _that = this;
switch (_that) {
case _LiveEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LiveEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Meeting meeting,  MeetingItem item,  Heat heat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveEntry() when $default != null:
return $default(_that.meeting,_that.item,_that.heat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Meeting meeting,  MeetingItem item,  Heat heat)  $default,) {final _that = this;
switch (_that) {
case _LiveEntry():
return $default(_that.meeting,_that.item,_that.heat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Meeting meeting,  MeetingItem item,  Heat heat)?  $default,) {final _that = this;
switch (_that) {
case _LiveEntry() when $default != null:
return $default(_that.meeting,_that.item,_that.heat);case _:
  return null;

}
}

}

/// @nodoc


class _LiveEntry extends LiveEntry {
  const _LiveEntry({required this.meeting, required this.item, required this.heat}): super._();
  

@override final  Meeting meeting;
@override final  MeetingItem item;
@override final  Heat heat;

/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveEntryCopyWith<_LiveEntry> get copyWith => __$LiveEntryCopyWithImpl<_LiveEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveEntry&&(identical(other.meeting, meeting) || other.meeting == meeting)&&(identical(other.item, item) || other.item == item)&&(identical(other.heat, heat) || other.heat == heat));
}


@override
int get hashCode {
    return Object.hash(runtimeType,meeting,item,heat);
}

@override
String toString() {
    return 'LiveEntry(meeting: $meeting, item: $item, heat: $heat)';
}


}

/// @nodoc
abstract mixin class _$LiveEntryCopyWith<$Res> implements $LiveEntryCopyWith<$Res> {
  factory _$LiveEntryCopyWith(_LiveEntry value, $Res Function(_LiveEntry) _then) = __$LiveEntryCopyWithImpl;
@override @useResult
$Res call({
 Meeting meeting, MeetingItem item, Heat heat
});


@override $MeetingCopyWith<$Res> get meeting;@override $MeetingItemCopyWith<$Res> get item;@override $HeatCopyWith<$Res> get heat;

}
/// @nodoc
class __$LiveEntryCopyWithImpl<$Res>
    implements _$LiveEntryCopyWith<$Res> {
  __$LiveEntryCopyWithImpl(this._self, this._then);

  final _LiveEntry _self;
  final $Res Function(_LiveEntry) _then;

/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meeting = null,Object? item = null,Object? heat = null,}) {
  return _then(_LiveEntry(
meeting: null == meeting ? _self.meeting : meeting // ignore: cast_nullable_to_non_nullable
as Meeting,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MeetingItem,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,
  ));
}

/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingCopyWith<$Res> get meeting {
  
  return $MeetingCopyWith<$Res>(_self.meeting, (value) {
    return _then(_self.copyWith(meeting: value));
  });
}/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<$Res> get item {
  
  return $MeetingItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of LiveEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}

// dart format on
