// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntryLane {

 LaneAssignment get lane;/// Le résultat lu sur le site, avec par-dessus les saisies pas encore
/// écrites, ou écrites après la lecture.
 RaceResult get result;/// Le juge des résultats a posé un `temps` : lecture seule.
 bool get validatedByJudge;/// Faux sans engagement ou une fois validé : rien ne peut partir.
 bool get editable; EntrySendState get sendState;/// La dernière opération refusée du couloir, pour en dire la raison et
/// proposer de la réessayer ou de l'écarter.
 OutboxOperation? get rejected;
/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryLaneCopyWith<EntryLane> get copyWith => _$EntryLaneCopyWithImpl<EntryLane>(this as EntryLane, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntryLane;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryLane&&(identical(other.lane, _this.lane) || other.lane == _this.lane)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.validatedByJudge, _this.validatedByJudge) || other.validatedByJudge == _this.validatedByJudge)&&(identical(other.editable, _this.editable) || other.editable == _this.editable)&&(identical(other.sendState, _this.sendState) || other.sendState == _this.sendState)&&(identical(other.rejected, _this.rejected) || other.rejected == _this.rejected));
}


@override
int get hashCode {
  final _this = this as EntryLane;
  return Object.hash(runtimeType,_this.lane,_this.result,_this.validatedByJudge,_this.editable,_this.sendState,_this.rejected);
}

@override
String toString() {
  final _this = this as EntryLane;
  return 'EntryLane(lane: ${_this.lane}, result: ${_this.result}, validatedByJudge: ${_this.validatedByJudge}, editable: ${_this.editable}, sendState: ${_this.sendState}, rejected: ${_this.rejected})';
}


}

/// @nodoc
abstract mixin class $EntryLaneCopyWith<$Res>  {
  factory $EntryLaneCopyWith(EntryLane value, $Res Function(EntryLane) _then) = _$EntryLaneCopyWithImpl;
@useResult
$Res call({
 LaneAssignment lane, RaceResult result, bool validatedByJudge, bool editable, EntrySendState sendState, OutboxOperation? rejected
});


$LaneAssignmentCopyWith<$Res> get lane;$RaceResultCopyWith<$Res> get result;$OutboxOperationCopyWith<$Res>? get rejected;

}
/// @nodoc
class _$EntryLaneCopyWithImpl<$Res>
    implements $EntryLaneCopyWith<$Res> {
  _$EntryLaneCopyWithImpl(this._self, this._then);

  final EntryLane _self;
  final $Res Function(EntryLane) _then;

/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lane = null,Object? result = null,Object? validatedByJudge = null,Object? editable = null,Object? sendState = null,Object? rejected = freezed,}) {
  return _then(EntryLane(
lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as LaneAssignment,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RaceResult,validatedByJudge: null == validatedByJudge ? _self.validatedByJudge : validatedByJudge // ignore: cast_nullable_to_non_nullable
as bool,editable: null == editable ? _self.editable : editable // ignore: cast_nullable_to_non_nullable
as bool,sendState: null == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as EntrySendState,rejected: freezed == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as OutboxOperation?,
  ));
}
/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaneAssignmentCopyWith<$Res> get lane {
  
  return $LaneAssignmentCopyWith<$Res>(_self.lane, (value) {
    return _then(_self.copyWith(lane: value));
  });
}/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceResultCopyWith<$Res> get result {
  
  return $RaceResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxOperationCopyWith<$Res>? get rejected {
    if (_self.rejected == null) {
    return null;
  }

  return $OutboxOperationCopyWith<$Res>(_self.rejected!, (value) {
    return _then(_self.copyWith(rejected: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntryLane].
extension EntryLanePatterns on EntryLane {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryLane value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryLane() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryLane value)  $default,){
final _that = this;
switch (_that) {
case _EntryLane():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryLane value)?  $default,){
final _that = this;
switch (_that) {
case _EntryLane() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LaneAssignment lane,  RaceResult result,  bool validatedByJudge,  bool editable,  EntrySendState sendState,  OutboxOperation? rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryLane() when $default != null:
return $default(_that.lane,_that.result,_that.validatedByJudge,_that.editable,_that.sendState,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LaneAssignment lane,  RaceResult result,  bool validatedByJudge,  bool editable,  EntrySendState sendState,  OutboxOperation? rejected)  $default,) {final _that = this;
switch (_that) {
case _EntryLane():
return $default(_that.lane,_that.result,_that.validatedByJudge,_that.editable,_that.sendState,_that.rejected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LaneAssignment lane,  RaceResult result,  bool validatedByJudge,  bool editable,  EntrySendState sendState,  OutboxOperation? rejected)?  $default,) {final _that = this;
switch (_that) {
case _EntryLane() when $default != null:
return $default(_that.lane,_that.result,_that.validatedByJudge,_that.editable,_that.sendState,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc


class _EntryLane implements EntryLane {
  const _EntryLane({required this.lane, required this.result, this.validatedByJudge = false, this.editable = false, this.sendState = EntrySendState.none, this.rejected});
  

@override final  LaneAssignment lane;
/// Le résultat lu sur le site, avec par-dessus les saisies pas encore
/// écrites, ou écrites après la lecture.
@override final  RaceResult result;
/// Le juge des résultats a posé un `temps` : lecture seule.
@override@JsonKey() final  bool validatedByJudge;
/// Faux sans engagement ou une fois validé : rien ne peut partir.
@override@JsonKey() final  bool editable;
@override@JsonKey() final  EntrySendState sendState;
/// La dernière opération refusée du couloir, pour en dire la raison et
/// proposer de la réessayer ou de l'écarter.
@override final  OutboxOperation? rejected;

/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryLaneCopyWith<_EntryLane> get copyWith => __$EntryLaneCopyWithImpl<_EntryLane>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryLane&&(identical(other.lane, lane) || other.lane == lane)&&(identical(other.result, result) || other.result == result)&&(identical(other.validatedByJudge, validatedByJudge) || other.validatedByJudge == validatedByJudge)&&(identical(other.editable, editable) || other.editable == editable)&&(identical(other.sendState, sendState) || other.sendState == sendState)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lane,result,validatedByJudge,editable,sendState,rejected);
}

@override
String toString() {
    return 'EntryLane(lane: $lane, result: $result, validatedByJudge: $validatedByJudge, editable: $editable, sendState: $sendState, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$EntryLaneCopyWith<$Res> implements $EntryLaneCopyWith<$Res> {
  factory _$EntryLaneCopyWith(_EntryLane value, $Res Function(_EntryLane) _then) = __$EntryLaneCopyWithImpl;
@override @useResult
$Res call({
 LaneAssignment lane, RaceResult result, bool validatedByJudge, bool editable, EntrySendState sendState, OutboxOperation? rejected
});


@override $LaneAssignmentCopyWith<$Res> get lane;@override $RaceResultCopyWith<$Res> get result;@override $OutboxOperationCopyWith<$Res>? get rejected;

}
/// @nodoc
class __$EntryLaneCopyWithImpl<$Res>
    implements _$EntryLaneCopyWith<$Res> {
  __$EntryLaneCopyWithImpl(this._self, this._then);

  final _EntryLane _self;
  final $Res Function(_EntryLane) _then;

/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lane = null,Object? result = null,Object? validatedByJudge = null,Object? editable = null,Object? sendState = null,Object? rejected = freezed,}) {
  return _then(_EntryLane(
lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as LaneAssignment,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as RaceResult,validatedByJudge: null == validatedByJudge ? _self.validatedByJudge : validatedByJudge // ignore: cast_nullable_to_non_nullable
as bool,editable: null == editable ? _self.editable : editable // ignore: cast_nullable_to_non_nullable
as bool,sendState: null == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as EntrySendState,rejected: freezed == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as OutboxOperation?,
  ));
}

/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaneAssignmentCopyWith<$Res> get lane {
  
  return $LaneAssignmentCopyWith<$Res>(_self.lane, (value) {
    return _then(_self.copyWith(lane: value));
  });
}/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaceResultCopyWith<$Res> get result {
  
  return $RaceResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}/// Create a copy of EntryLane
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxOperationCopyWith<$Res>? get rejected {
    if (_self.rejected == null) {
    return null;
  }

  return $OutboxOperationCopyWith<$Res>(_self.rejected!, (value) {
    return _then(_self.copyWith(rejected: value));
  });
}
}

/// @nodoc
mixin _$EntryCursor {

 LiveEntry get entry; ({int position, int total,}) get position; LiveEntry? get previous; LiveEntry? get next;
/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCursorCopyWith<EntryCursor> get copyWith => _$EntryCursorCopyWithImpl<EntryCursor>(this as EntryCursor, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntryCursor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryCursor&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.previous, _this.previous) || other.previous == _this.previous)&&(identical(other.next, _this.next) || other.next == _this.next));
}


@override
int get hashCode {
  final _this = this as EntryCursor;
  return Object.hash(runtimeType,_this.entry,_this.position,_this.previous,_this.next);
}

@override
String toString() {
  final _this = this as EntryCursor;
  return 'EntryCursor(entry: ${_this.entry}, position: ${_this.position}, previous: ${_this.previous}, next: ${_this.next})';
}


}

/// @nodoc
abstract mixin class $EntryCursorCopyWith<$Res>  {
  factory $EntryCursorCopyWith(EntryCursor value, $Res Function(EntryCursor) _then) = _$EntryCursorCopyWithImpl;
@useResult
$Res call({
 LiveEntry entry, ({int position, int total,}) position, LiveEntry? previous, LiveEntry? next
});


$LiveEntryCopyWith<$Res> get entry;$LiveEntryCopyWith<$Res>? get previous;$LiveEntryCopyWith<$Res>? get next;

}
/// @nodoc
class _$EntryCursorCopyWithImpl<$Res>
    implements $EntryCursorCopyWith<$Res> {
  _$EntryCursorCopyWithImpl(this._self, this._then);

  final EntryCursor _self;
  final $Res Function(EntryCursor) _then;

/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? position = null,Object? previous = freezed,Object? next = freezed,}) {
  return _then(EntryCursor(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as LiveEntry,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as ({int position, int total,}),previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as LiveEntry?,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as LiveEntry?,
  ));
}
/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res> get entry {
  
  return $LiveEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res>? get previous {
    if (_self.previous == null) {
    return null;
  }

  return $LiveEntryCopyWith<$Res>(_self.previous!, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $LiveEntryCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntryCursor].
extension EntryCursorPatterns on EntryCursor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryCursor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryCursor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryCursor value)  $default,){
final _that = this;
switch (_that) {
case _EntryCursor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryCursor value)?  $default,){
final _that = this;
switch (_that) {
case _EntryCursor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LiveEntry entry,  ({int position, int total,}) position,  LiveEntry? previous,  LiveEntry? next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryCursor() when $default != null:
return $default(_that.entry,_that.position,_that.previous,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LiveEntry entry,  ({int position, int total,}) position,  LiveEntry? previous,  LiveEntry? next)  $default,) {final _that = this;
switch (_that) {
case _EntryCursor():
return $default(_that.entry,_that.position,_that.previous,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LiveEntry entry,  ({int position, int total,}) position,  LiveEntry? previous,  LiveEntry? next)?  $default,) {final _that = this;
switch (_that) {
case _EntryCursor() when $default != null:
return $default(_that.entry,_that.position,_that.previous,_that.next);case _:
  return null;

}
}

}

/// @nodoc


class _EntryCursor implements EntryCursor {
  const _EntryCursor({required this.entry, required this.position, this.previous, this.next});
  

@override final  LiveEntry entry;
@override final  ({int position, int total,}) position;
@override final  LiveEntry? previous;
@override final  LiveEntry? next;

/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCursorCopyWith<_EntryCursor> get copyWith => __$EntryCursorCopyWithImpl<_EntryCursor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryCursor&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.position, position) || other.position == position)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.next, next) || other.next == next));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entry,position,previous,next);
}

@override
String toString() {
    return 'EntryCursor(entry: $entry, position: $position, previous: $previous, next: $next)';
}


}

/// @nodoc
abstract mixin class _$EntryCursorCopyWith<$Res> implements $EntryCursorCopyWith<$Res> {
  factory _$EntryCursorCopyWith(_EntryCursor value, $Res Function(_EntryCursor) _then) = __$EntryCursorCopyWithImpl;
@override @useResult
$Res call({
 LiveEntry entry, ({int position, int total,}) position, LiveEntry? previous, LiveEntry? next
});


@override $LiveEntryCopyWith<$Res> get entry;@override $LiveEntryCopyWith<$Res>? get previous;@override $LiveEntryCopyWith<$Res>? get next;

}
/// @nodoc
class __$EntryCursorCopyWithImpl<$Res>
    implements _$EntryCursorCopyWith<$Res> {
  __$EntryCursorCopyWithImpl(this._self, this._then);

  final _EntryCursor _self;
  final $Res Function(_EntryCursor) _then;

/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? position = null,Object? previous = freezed,Object? next = freezed,}) {
  return _then(_EntryCursor(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as LiveEntry,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as ({int position, int total,}),previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as LiveEntry?,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as LiveEntry?,
  ));
}

/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res> get entry {
  
  return $LiveEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res>? get previous {
    if (_self.previous == null) {
    return null;
  }

  return $LiveEntryCopyWith<$Res>(_self.previous!, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of EntryCursor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveEntryCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $LiveEntryCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}

// dart format on
