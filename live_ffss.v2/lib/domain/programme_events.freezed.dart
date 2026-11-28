// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'programme_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventStep {

 StageLevel get level;/// Les étapes réunies dans le tour : plus d'une se dit « Finales ».
 int get stageCount; List<MeetingItem> get items;/// `none` pour un tour prévu au déroulement sans créneau au programme.
 ItemStatus get status;
/// Create a copy of EventStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventStepCopyWith<EventStep> get copyWith => _$EventStepCopyWithImpl<EventStep>(this as EventStep, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventStep;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventStep&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.stageCount, _this.stageCount) || other.stageCount == _this.stageCount)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as EventStep;
  return Object.hash(runtimeType,_this.level,_this.stageCount,const DeepCollectionEquality().hash(_this.items),_this.status);
}

@override
String toString() {
  final _this = this as EventStep;
  return 'EventStep(level: ${_this.level}, stageCount: ${_this.stageCount}, items: ${_this.items}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $EventStepCopyWith<$Res>  {
  factory $EventStepCopyWith(EventStep value, $Res Function(EventStep) _then) = _$EventStepCopyWithImpl;
@useResult
$Res call({
 StageLevel level, int stageCount, List<MeetingItem> items, ItemStatus status
});




}
/// @nodoc
class _$EventStepCopyWithImpl<$Res>
    implements $EventStepCopyWith<$Res> {
  _$EventStepCopyWithImpl(this._self, this._then);

  final EventStep _self;
  final $Res Function(EventStep) _then;

/// Create a copy of EventStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? stageCount = null,Object? items = null,Object? status = null,}) {
  return _then(EventStep(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as StageLevel,stageCount: null == stageCount ? _self.stageCount : stageCount // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [EventStep].
extension EventStepPatterns on EventStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventStep value)  $default,){
final _that = this;
switch (_that) {
case _EventStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventStep value)?  $default,){
final _that = this;
switch (_that) {
case _EventStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StageLevel level,  int stageCount,  List<MeetingItem> items,  ItemStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventStep() when $default != null:
return $default(_that.level,_that.stageCount,_that.items,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StageLevel level,  int stageCount,  List<MeetingItem> items,  ItemStatus status)  $default,) {final _that = this;
switch (_that) {
case _EventStep():
return $default(_that.level,_that.stageCount,_that.items,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StageLevel level,  int stageCount,  List<MeetingItem> items,  ItemStatus status)?  $default,) {final _that = this;
switch (_that) {
case _EventStep() when $default != null:
return $default(_that.level,_that.stageCount,_that.items,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _EventStep extends EventStep {
  const _EventStep({required this.level, this.stageCount = 1,  List<MeetingItem> items = const <MeetingItem>[], required this.status}): _items = items,super._();
  

@override final  StageLevel level;
/// Les étapes réunies dans le tour : plus d'une se dit « Finales ».
@override@JsonKey() final  int stageCount;
 final  List<MeetingItem> _items;
@override@JsonKey() List<MeetingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// `none` pour un tour prévu au déroulement sans créneau au programme.
@override final  ItemStatus status;

/// Create a copy of EventStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventStepCopyWith<_EventStep> get copyWith => __$EventStepCopyWithImpl<_EventStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventStep&&(identical(other.level, level) || other.level == level)&&(identical(other.stageCount, stageCount) || other.stageCount == stageCount)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,stageCount,const DeepCollectionEquality().hash(_items),status);
}

@override
String toString() {
    return 'EventStep(level: $level, stageCount: $stageCount, items: $items, status: $status)';
}


}

/// @nodoc
abstract mixin class _$EventStepCopyWith<$Res> implements $EventStepCopyWith<$Res> {
  factory _$EventStepCopyWith(_EventStep value, $Res Function(_EventStep) _then) = __$EventStepCopyWithImpl;
@override @useResult
$Res call({
 StageLevel level, int stageCount, List<MeetingItem> items, ItemStatus status
});




}
/// @nodoc
class __$EventStepCopyWithImpl<$Res>
    implements _$EventStepCopyWith<$Res> {
  __$EventStepCopyWithImpl(this._self, this._then);

  final _EventStep _self;
  final $Res Function(_EventStep) _then;

/// Create a copy of EventStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? stageCount = null,Object? items = null,Object? status = null,}) {
  return _then(_EventStep(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as StageLevel,stageCount: null == stageCount ? _self.stageCount : stageCount // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}


}

/// @nodoc
mixin _$ProgrammeEvent {

/// `p<id>` pour une épreuve du déroulement, `i<id>` pour un créneau de
/// course qu'aucun déroulement ne porte : de quoi la retrouver à
/// l'ouverture de la vue.
 String get key; String get name; Gender? get gender; List<String> get categories;/// Vide quand l'épreuve n'est pas au déroulement.
 List<EventStep> get steps;/// Ses créneaux dans la réunion, dans l'ordre du programme.
 List<MeetingItem> get items;/// L'état de ces créneaux-là (`stageStatus`).
 ItemStatus get status;
/// Create a copy of ProgrammeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgrammeEventCopyWith<ProgrammeEvent> get copyWith => _$ProgrammeEventCopyWithImpl<ProgrammeEvent>(this as ProgrammeEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProgrammeEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgrammeEvent&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as ProgrammeEvent;
  return Object.hash(runtimeType,_this.key,_this.name,_this.gender,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.steps),const DeepCollectionEquality().hash(_this.items),_this.status);
}

@override
String toString() {
  final _this = this as ProgrammeEvent;
  return 'ProgrammeEvent(key: ${_this.key}, name: ${_this.name}, gender: ${_this.gender}, categories: ${_this.categories}, steps: ${_this.steps}, items: ${_this.items}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ProgrammeEventCopyWith<$Res>  {
  factory $ProgrammeEventCopyWith(ProgrammeEvent value, $Res Function(ProgrammeEvent) _then) = _$ProgrammeEventCopyWithImpl;
@useResult
$Res call({
 String key, String name, Gender? gender, List<String> categories, List<EventStep> steps, List<MeetingItem> items, ItemStatus status
});




}
/// @nodoc
class _$ProgrammeEventCopyWithImpl<$Res>
    implements $ProgrammeEventCopyWith<$Res> {
  _$ProgrammeEventCopyWithImpl(this._self, this._then);

  final ProgrammeEvent _self;
  final $Res Function(ProgrammeEvent) _then;

/// Create a copy of ProgrammeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? name = null,Object? gender = freezed,Object? categories = null,Object? steps = null,Object? items = null,Object? status = null,}) {
  return _then(ProgrammeEvent(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<EventStep>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgrammeEvent].
extension ProgrammeEventPatterns on ProgrammeEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgrammeEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgrammeEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgrammeEvent value)  $default,){
final _that = this;
switch (_that) {
case _ProgrammeEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgrammeEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ProgrammeEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String name,  Gender? gender,  List<String> categories,  List<EventStep> steps,  List<MeetingItem> items,  ItemStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgrammeEvent() when $default != null:
return $default(_that.key,_that.name,_that.gender,_that.categories,_that.steps,_that.items,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String name,  Gender? gender,  List<String> categories,  List<EventStep> steps,  List<MeetingItem> items,  ItemStatus status)  $default,) {final _that = this;
switch (_that) {
case _ProgrammeEvent():
return $default(_that.key,_that.name,_that.gender,_that.categories,_that.steps,_that.items,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String name,  Gender? gender,  List<String> categories,  List<EventStep> steps,  List<MeetingItem> items,  ItemStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ProgrammeEvent() when $default != null:
return $default(_that.key,_that.name,_that.gender,_that.categories,_that.steps,_that.items,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ProgrammeEvent extends ProgrammeEvent {
  const _ProgrammeEvent({required this.key, required this.name, this.gender,  List<String> categories = const <String>[],  List<EventStep> steps = const <EventStep>[],  List<MeetingItem> items = const <MeetingItem>[], required this.status}): _categories = categories,_steps = steps,_items = items,super._();
  

/// `p<id>` pour une épreuve du déroulement, `i<id>` pour un créneau de
/// course qu'aucun déroulement ne porte : de quoi la retrouver à
/// l'ouverture de la vue.
@override final  String key;
@override final  String name;
@override final  Gender? gender;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Vide quand l'épreuve n'est pas au déroulement.
 final  List<EventStep> _steps;
/// Vide quand l'épreuve n'est pas au déroulement.
@override@JsonKey() List<EventStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

/// Ses créneaux dans la réunion, dans l'ordre du programme.
 final  List<MeetingItem> _items;
/// Ses créneaux dans la réunion, dans l'ordre du programme.
@override@JsonKey() List<MeetingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// L'état de ces créneaux-là (`stageStatus`).
@override final  ItemStatus status;

/// Create a copy of ProgrammeEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgrammeEventCopyWith<_ProgrammeEvent> get copyWith => __$ProgrammeEventCopyWithImpl<_ProgrammeEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgrammeEvent&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.steps, _steps)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,name,gender,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_items),status);
}

@override
String toString() {
    return 'ProgrammeEvent(key: $key, name: $name, gender: $gender, categories: $categories, steps: $steps, items: $items, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ProgrammeEventCopyWith<$Res> implements $ProgrammeEventCopyWith<$Res> {
  factory _$ProgrammeEventCopyWith(_ProgrammeEvent value, $Res Function(_ProgrammeEvent) _then) = __$ProgrammeEventCopyWithImpl;
@override @useResult
$Res call({
 String key, String name, Gender? gender, List<String> categories, List<EventStep> steps, List<MeetingItem> items, ItemStatus status
});




}
/// @nodoc
class __$ProgrammeEventCopyWithImpl<$Res>
    implements _$ProgrammeEventCopyWith<$Res> {
  __$ProgrammeEventCopyWithImpl(this._self, this._then);

  final _ProgrammeEvent _self;
  final $Res Function(_ProgrammeEvent) _then;

/// Create a copy of ProgrammeEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? name = null,Object? gender = freezed,Object? categories = null,Object? steps = null,Object? items = null,Object? status = null,}) {
  return _then(_ProgrammeEvent(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<EventStep>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MeetingItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}


}

/// @nodoc
mixin _$MeetingEntry {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingEntry);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MeetingEntry()';
}


}

/// @nodoc
class $MeetingEntryCopyWith<$Res>  {
$MeetingEntryCopyWith(MeetingEntry _, $Res Function(MeetingEntry) __);
}


/// Adds pattern-matching-related methods to [MeetingEntry].
extension MeetingEntryPatterns on MeetingEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EventEntry value)?  event,TResult Function( PauseEntry value)?  pause,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EventEntry() when event != null:
return event(_that);case PauseEntry() when pause != null:
return pause(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EventEntry value)  event,required TResult Function( PauseEntry value)  pause,}){
final _that = this;
switch (_that) {
case EventEntry():
return event(_that);case PauseEntry():
return pause(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EventEntry value)?  event,TResult? Function( PauseEntry value)?  pause,}){
final _that = this;
switch (_that) {
case EventEntry() when event != null:
return event(_that);case PauseEntry() when pause != null:
return pause(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ProgrammeEvent event)?  event,TResult Function( MeetingItem item)?  pause,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EventEntry() when event != null:
return event(_that.event);case PauseEntry() when pause != null:
return pause(_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ProgrammeEvent event)  event,required TResult Function( MeetingItem item)  pause,}) {final _that = this;
switch (_that) {
case EventEntry():
return event(_that.event);case PauseEntry():
return pause(_that.item);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ProgrammeEvent event)?  event,TResult? Function( MeetingItem item)?  pause,}) {final _that = this;
switch (_that) {
case EventEntry() when event != null:
return event(_that.event);case PauseEntry() when pause != null:
return pause(_that.item);case _:
  return null;

}
}

}

/// @nodoc


class EventEntry implements MeetingEntry {
  const EventEntry(this.event);
  

 final  ProgrammeEvent event;

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventEntryCopyWith<EventEntry> get copyWith => _$EventEntryCopyWithImpl<EventEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EventEntry&&(identical(other.event, event) || other.event == event));
}


@override
int get hashCode {
    return Object.hash(runtimeType,event);
}

@override
String toString() {
    return 'MeetingEntry.event(event: $event)';
}


}

/// @nodoc
abstract mixin class $EventEntryCopyWith<$Res> implements $MeetingEntryCopyWith<$Res> {
  factory $EventEntryCopyWith(EventEntry value, $Res Function(EventEntry) _then) = _$EventEntryCopyWithImpl;
@useResult
$Res call({
 ProgrammeEvent event
});


$ProgrammeEventCopyWith<$Res> get event;

}
/// @nodoc
class _$EventEntryCopyWithImpl<$Res>
    implements $EventEntryCopyWith<$Res> {
  _$EventEntryCopyWithImpl(this._self, this._then);

  final EventEntry _self;
  final $Res Function(EventEntry) _then;

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? event = null,}) {
  return _then(EventEntry(
null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as ProgrammeEvent,
  ));
}

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgrammeEventCopyWith<$Res> get event {
  
  return $ProgrammeEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}

/// @nodoc


class PauseEntry implements MeetingEntry {
  const PauseEntry(this.item);
  

 final  MeetingItem item;

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PauseEntryCopyWith<PauseEntry> get copyWith => _$PauseEntryCopyWithImpl<PauseEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PauseEntry&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode {
    return Object.hash(runtimeType,item);
}

@override
String toString() {
    return 'MeetingEntry.pause(item: $item)';
}


}

/// @nodoc
abstract mixin class $PauseEntryCopyWith<$Res> implements $MeetingEntryCopyWith<$Res> {
  factory $PauseEntryCopyWith(PauseEntry value, $Res Function(PauseEntry) _then) = _$PauseEntryCopyWithImpl;
@useResult
$Res call({
 MeetingItem item
});


$MeetingItemCopyWith<$Res> get item;

}
/// @nodoc
class _$PauseEntryCopyWithImpl<$Res>
    implements $PauseEntryCopyWith<$Res> {
  _$PauseEntryCopyWithImpl(this._self, this._then);

  final PauseEntry _self;
  final $Res Function(PauseEntry) _then;

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? item = null,}) {
  return _then(PauseEntry(
null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MeetingItem,
  ));
}

/// Create a copy of MeetingEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeetingItemCopyWith<$Res> get item {
  
  return $MeetingItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

// dart format on
