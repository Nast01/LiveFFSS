// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_space_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MySpaceCard {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MySpaceCard);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MySpaceCard()';
}


}

/// @nodoc
class $MySpaceCardCopyWith<$Res>  {
$MySpaceCardCopyWith(MySpaceCard _, $Res Function(MySpaceCard) __);
}


/// Adds pattern-matching-related methods to [MySpaceCard].
extension MySpaceCardPatterns on MySpaceCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AthleteSpaceCard value)?  athlete,TResult Function( ClubSpaceCard value)?  club,TResult Function( OfficialSpaceCard value)?  official,TResult Function( AdminSpaceCard value)?  admin,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AthleteSpaceCard() when athlete != null:
return athlete(_that);case ClubSpaceCard() when club != null:
return club(_that);case OfficialSpaceCard() when official != null:
return official(_that);case AdminSpaceCard() when admin != null:
return admin(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AthleteSpaceCard value)  athlete,required TResult Function( ClubSpaceCard value)  club,required TResult Function( OfficialSpaceCard value)  official,required TResult Function( AdminSpaceCard value)  admin,}){
final _that = this;
switch (_that) {
case AthleteSpaceCard():
return athlete(_that);case ClubSpaceCard():
return club(_that);case OfficialSpaceCard():
return official(_that);case AdminSpaceCard():
return admin(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AthleteSpaceCard value)?  athlete,TResult? Function( ClubSpaceCard value)?  club,TResult? Function( OfficialSpaceCard value)?  official,TResult? Function( AdminSpaceCard value)?  admin,}){
final _that = this;
switch (_that) {
case AthleteSpaceCard() when athlete != null:
return athlete(_that);case ClubSpaceCard() when club != null:
return club(_that);case OfficialSpaceCard() when official != null:
return official(_that);case AdminSpaceCard() when admin != null:
return admin(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Participant participant)?  athlete,TResult Function( ClubRef club)?  club,TResult Function( OfficialRole? role)?  official,TResult Function()?  admin,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AthleteSpaceCard() when athlete != null:
return athlete(_that.participant);case ClubSpaceCard() when club != null:
return club(_that.club);case OfficialSpaceCard() when official != null:
return official(_that.role);case AdminSpaceCard() when admin != null:
return admin();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Participant participant)  athlete,required TResult Function( ClubRef club)  club,required TResult Function( OfficialRole? role)  official,required TResult Function()  admin,}) {final _that = this;
switch (_that) {
case AthleteSpaceCard():
return athlete(_that.participant);case ClubSpaceCard():
return club(_that.club);case OfficialSpaceCard():
return official(_that.role);case AdminSpaceCard():
return admin();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Participant participant)?  athlete,TResult? Function( ClubRef club)?  club,TResult? Function( OfficialRole? role)?  official,TResult? Function()?  admin,}) {final _that = this;
switch (_that) {
case AthleteSpaceCard() when athlete != null:
return athlete(_that.participant);case ClubSpaceCard() when club != null:
return club(_that.club);case OfficialSpaceCard() when official != null:
return official(_that.role);case AdminSpaceCard() when admin != null:
return admin();case _:
  return null;

}
}

}

/// @nodoc


class AthleteSpaceCard implements MySpaceCard {
  const AthleteSpaceCard(this.participant);
  

 final  Participant participant;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthleteSpaceCardCopyWith<AthleteSpaceCard> get copyWith => _$AthleteSpaceCardCopyWithImpl<AthleteSpaceCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AthleteSpaceCard&&(identical(other.participant, participant) || other.participant == participant));
}


@override
int get hashCode {
    return Object.hash(runtimeType,participant);
}

@override
String toString() {
    return 'MySpaceCard.athlete(participant: $participant)';
}


}

/// @nodoc
abstract mixin class $AthleteSpaceCardCopyWith<$Res> implements $MySpaceCardCopyWith<$Res> {
  factory $AthleteSpaceCardCopyWith(AthleteSpaceCard value, $Res Function(AthleteSpaceCard) _then) = _$AthleteSpaceCardCopyWithImpl;
@useResult
$Res call({
 Participant participant
});


$ParticipantCopyWith<$Res> get participant;

}
/// @nodoc
class _$AthleteSpaceCardCopyWithImpl<$Res>
    implements $AthleteSpaceCardCopyWith<$Res> {
  _$AthleteSpaceCardCopyWithImpl(this._self, this._then);

  final AthleteSpaceCard _self;
  final $Res Function(AthleteSpaceCard) _then;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? participant = null,}) {
  return _then(AthleteSpaceCard(
null == participant ? _self.participant : participant // ignore: cast_nullable_to_non_nullable
as Participant,
  ));
}

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantCopyWith<$Res> get participant {
  
  return $ParticipantCopyWith<$Res>(_self.participant, (value) {
    return _then(_self.copyWith(participant: value));
  });
}
}

/// @nodoc


class ClubSpaceCard implements MySpaceCard {
  const ClubSpaceCard(this.club);
  

 final  ClubRef club;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubSpaceCardCopyWith<ClubSpaceCard> get copyWith => _$ClubSpaceCardCopyWithImpl<ClubSpaceCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubSpaceCard&&(identical(other.club, club) || other.club == club));
}


@override
int get hashCode {
    return Object.hash(runtimeType,club);
}

@override
String toString() {
    return 'MySpaceCard.club(club: $club)';
}


}

/// @nodoc
abstract mixin class $ClubSpaceCardCopyWith<$Res> implements $MySpaceCardCopyWith<$Res> {
  factory $ClubSpaceCardCopyWith(ClubSpaceCard value, $Res Function(ClubSpaceCard) _then) = _$ClubSpaceCardCopyWithImpl;
@useResult
$Res call({
 ClubRef club
});


$ClubRefCopyWith<$Res> get club;

}
/// @nodoc
class _$ClubSpaceCardCopyWithImpl<$Res>
    implements $ClubSpaceCardCopyWith<$Res> {
  _$ClubSpaceCardCopyWithImpl(this._self, this._then);

  final ClubSpaceCard _self;
  final $Res Function(ClubSpaceCard) _then;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? club = null,}) {
  return _then(ClubSpaceCard(
null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as ClubRef,
  ));
}

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClubRefCopyWith<$Res> get club {
  
  return $ClubRefCopyWith<$Res>(_self.club, (value) {
    return _then(_self.copyWith(club: value));
  });
}
}

/// @nodoc


class OfficialSpaceCard implements MySpaceCard {
  const OfficialSpaceCard(this.role);
  

 final  OfficialRole? role;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfficialSpaceCardCopyWith<OfficialSpaceCard> get copyWith => _$OfficialSpaceCardCopyWithImpl<OfficialSpaceCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OfficialSpaceCard&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode {
    return Object.hash(runtimeType,role);
}

@override
String toString() {
    return 'MySpaceCard.official(role: $role)';
}


}

/// @nodoc
abstract mixin class $OfficialSpaceCardCopyWith<$Res> implements $MySpaceCardCopyWith<$Res> {
  factory $OfficialSpaceCardCopyWith(OfficialSpaceCard value, $Res Function(OfficialSpaceCard) _then) = _$OfficialSpaceCardCopyWithImpl;
@useResult
$Res call({
 OfficialRole? role
});


$OfficialRoleCopyWith<$Res>? get role;

}
/// @nodoc
class _$OfficialSpaceCardCopyWithImpl<$Res>
    implements $OfficialSpaceCardCopyWith<$Res> {
  _$OfficialSpaceCardCopyWithImpl(this._self, this._then);

  final OfficialSpaceCard _self;
  final $Res Function(OfficialSpaceCard) _then;

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? role = freezed,}) {
  return _then(OfficialSpaceCard(
freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as OfficialRole?,
  ));
}

/// Create a copy of MySpaceCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfficialRoleCopyWith<$Res>? get role {
    if (_self.role == null) {
    return null;
  }

  return $OfficialRoleCopyWith<$Res>(_self.role!, (value) {
    return _then(_self.copyWith(role: value));
  });
}
}

/// @nodoc


class AdminSpaceCard implements MySpaceCard {
  const AdminSpaceCard();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminSpaceCard);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MySpaceCard.admin()';
}


}




/// @nodoc
mixin _$MySpaceCards {

 List<MySpaceCard> get cards;/// Le compte a un licencié, mais les participants n'ont pu être lus : on
/// ne sait pas s'il est engagé. La page propose « Réessayer » pour cette
/// carte seule.
 bool get athleteUnknown;
/// Create a copy of MySpaceCards
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySpaceCardsCopyWith<MySpaceCards> get copyWith => _$MySpaceCardsCopyWithImpl<MySpaceCards>(this as MySpaceCards, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MySpaceCards;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySpaceCards&&const DeepCollectionEquality().equals(other.cards, _this.cards)&&(identical(other.athleteUnknown, _this.athleteUnknown) || other.athleteUnknown == _this.athleteUnknown));
}


@override
int get hashCode {
  final _this = this as MySpaceCards;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.cards),_this.athleteUnknown);
}

@override
String toString() {
  final _this = this as MySpaceCards;
  return 'MySpaceCards(cards: ${_this.cards}, athleteUnknown: ${_this.athleteUnknown})';
}


}

/// @nodoc
abstract mixin class $MySpaceCardsCopyWith<$Res>  {
  factory $MySpaceCardsCopyWith(MySpaceCards value, $Res Function(MySpaceCards) _then) = _$MySpaceCardsCopyWithImpl;
@useResult
$Res call({
 List<MySpaceCard> cards, bool athleteUnknown
});




}
/// @nodoc
class _$MySpaceCardsCopyWithImpl<$Res>
    implements $MySpaceCardsCopyWith<$Res> {
  _$MySpaceCardsCopyWithImpl(this._self, this._then);

  final MySpaceCards _self;
  final $Res Function(MySpaceCards) _then;

/// Create a copy of MySpaceCards
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cards = null,Object? athleteUnknown = null,}) {
  return _then(MySpaceCards(
cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<MySpaceCard>,athleteUnknown: null == athleteUnknown ? _self.athleteUnknown : athleteUnknown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MySpaceCards].
extension MySpaceCardsPatterns on MySpaceCards {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySpaceCards value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySpaceCards() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySpaceCards value)  $default,){
final _that = this;
switch (_that) {
case _MySpaceCards():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySpaceCards value)?  $default,){
final _that = this;
switch (_that) {
case _MySpaceCards() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MySpaceCard> cards,  bool athleteUnknown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySpaceCards() when $default != null:
return $default(_that.cards,_that.athleteUnknown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MySpaceCard> cards,  bool athleteUnknown)  $default,) {final _that = this;
switch (_that) {
case _MySpaceCards():
return $default(_that.cards,_that.athleteUnknown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MySpaceCard> cards,  bool athleteUnknown)?  $default,) {final _that = this;
switch (_that) {
case _MySpaceCards() when $default != null:
return $default(_that.cards,_that.athleteUnknown);case _:
  return null;

}
}

}

/// @nodoc


class _MySpaceCards implements MySpaceCards {
  const _MySpaceCards({required  List<MySpaceCard> cards, this.athleteUnknown = false}): _cards = cards;
  

 final  List<MySpaceCard> _cards;
@override List<MySpaceCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

/// Le compte a un licencié, mais les participants n'ont pu être lus : on
/// ne sait pas s'il est engagé. La page propose « Réessayer » pour cette
/// carte seule.
@override@JsonKey() final  bool athleteUnknown;

/// Create a copy of MySpaceCards
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySpaceCardsCopyWith<_MySpaceCards> get copyWith => __$MySpaceCardsCopyWithImpl<_MySpaceCards>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySpaceCards&&const DeepCollectionEquality().equals(other.cards, _cards)&&(identical(other.athleteUnknown, athleteUnknown) || other.athleteUnknown == athleteUnknown));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards),athleteUnknown);
}

@override
String toString() {
    return 'MySpaceCards(cards: $cards, athleteUnknown: $athleteUnknown)';
}


}

/// @nodoc
abstract mixin class _$MySpaceCardsCopyWith<$Res> implements $MySpaceCardsCopyWith<$Res> {
  factory _$MySpaceCardsCopyWith(_MySpaceCards value, $Res Function(_MySpaceCards) _then) = __$MySpaceCardsCopyWithImpl;
@override @useResult
$Res call({
 List<MySpaceCard> cards, bool athleteUnknown
});




}
/// @nodoc
class __$MySpaceCardsCopyWithImpl<$Res>
    implements _$MySpaceCardsCopyWith<$Res> {
  __$MySpaceCardsCopyWithImpl(this._self, this._then);

  final _MySpaceCards _self;
  final $Res Function(_MySpaceCards) _then;

/// Create a copy of MySpaceCards
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cards = null,Object? athleteUnknown = null,}) {
  return _then(_MySpaceCards(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<MySpaceCard>,athleteUnknown: null == athleteUnknown ? _self.athleteUnknown : athleteUnknown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CompetitionInfo {

 CompetitionSummary get competition; int get athletes;/// Par libellé ; chacun ouvre l'espace de son club.
 List<CompetitionClub> get clubs;/// Les épreuves eau plate.
 int get events;
/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionInfoCopyWith<CompetitionInfo> get copyWith => _$CompetitionInfoCopyWithImpl<CompetitionInfo>(this as CompetitionInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompetitionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionInfo&&(identical(other.competition, _this.competition) || other.competition == _this.competition)&&(identical(other.athletes, _this.athletes) || other.athletes == _this.athletes)&&const DeepCollectionEquality().equals(other.clubs, _this.clubs)&&(identical(other.events, _this.events) || other.events == _this.events));
}


@override
int get hashCode {
  final _this = this as CompetitionInfo;
  return Object.hash(runtimeType,_this.competition,_this.athletes,const DeepCollectionEquality().hash(_this.clubs),_this.events);
}

@override
String toString() {
  final _this = this as CompetitionInfo;
  return 'CompetitionInfo(competition: ${_this.competition}, athletes: ${_this.athletes}, clubs: ${_this.clubs}, events: ${_this.events})';
}


}

/// @nodoc
abstract mixin class $CompetitionInfoCopyWith<$Res>  {
  factory $CompetitionInfoCopyWith(CompetitionInfo value, $Res Function(CompetitionInfo) _then) = _$CompetitionInfoCopyWithImpl;
@useResult
$Res call({
 CompetitionSummary competition, int athletes, List<CompetitionClub> clubs, int events
});


$CompetitionSummaryCopyWith<$Res> get competition;

}
/// @nodoc
class _$CompetitionInfoCopyWithImpl<$Res>
    implements $CompetitionInfoCopyWith<$Res> {
  _$CompetitionInfoCopyWithImpl(this._self, this._then);

  final CompetitionInfo _self;
  final $Res Function(CompetitionInfo) _then;

/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? competition = null,Object? athletes = null,Object? clubs = null,Object? events = null,}) {
  return _then(CompetitionInfo(
competition: null == competition ? _self.competition : competition // ignore: cast_nullable_to_non_nullable
as CompetitionSummary,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as int,clubs: null == clubs ? _self.clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<CompetitionClub>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionSummaryCopyWith<$Res> get competition {
  
  return $CompetitionSummaryCopyWith<$Res>(_self.competition, (value) {
    return _then(_self.copyWith(competition: value));
  });
}
}


/// Adds pattern-matching-related methods to [CompetitionInfo].
extension CompetitionInfoPatterns on CompetitionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionInfo value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CompetitionSummary competition,  int athletes,  List<CompetitionClub> clubs,  int events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionInfo() when $default != null:
return $default(_that.competition,_that.athletes,_that.clubs,_that.events);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CompetitionSummary competition,  int athletes,  List<CompetitionClub> clubs,  int events)  $default,) {final _that = this;
switch (_that) {
case _CompetitionInfo():
return $default(_that.competition,_that.athletes,_that.clubs,_that.events);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CompetitionSummary competition,  int athletes,  List<CompetitionClub> clubs,  int events)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionInfo() when $default != null:
return $default(_that.competition,_that.athletes,_that.clubs,_that.events);case _:
  return null;

}
}

}

/// @nodoc


class _CompetitionInfo implements CompetitionInfo {
  const _CompetitionInfo({required this.competition, required this.athletes, required  List<CompetitionClub> clubs, required this.events}): _clubs = clubs;
  

@override final  CompetitionSummary competition;
@override final  int athletes;
/// Par libellé ; chacun ouvre l'espace de son club.
 final  List<CompetitionClub> _clubs;
/// Par libellé ; chacun ouvre l'espace de son club.
@override List<CompetitionClub> get clubs {
  if (_clubs is EqualUnmodifiableListView) return _clubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clubs);
}

/// Les épreuves eau plate.
@override final  int events;

/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionInfoCopyWith<_CompetitionInfo> get copyWith => __$CompetitionInfoCopyWithImpl<_CompetitionInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionInfo&&(identical(other.competition, competition) || other.competition == competition)&&(identical(other.athletes, athletes) || other.athletes == athletes)&&const DeepCollectionEquality().equals(other.clubs, _clubs)&&(identical(other.events, events) || other.events == events));
}


@override
int get hashCode {
    return Object.hash(runtimeType,competition,athletes,const DeepCollectionEquality().hash(_clubs),events);
}

@override
String toString() {
    return 'CompetitionInfo(competition: $competition, athletes: $athletes, clubs: $clubs, events: $events)';
}


}

/// @nodoc
abstract mixin class _$CompetitionInfoCopyWith<$Res> implements $CompetitionInfoCopyWith<$Res> {
  factory _$CompetitionInfoCopyWith(_CompetitionInfo value, $Res Function(_CompetitionInfo) _then) = __$CompetitionInfoCopyWithImpl;
@override @useResult
$Res call({
 CompetitionSummary competition, int athletes, List<CompetitionClub> clubs, int events
});


@override $CompetitionSummaryCopyWith<$Res> get competition;

}
/// @nodoc
class __$CompetitionInfoCopyWithImpl<$Res>
    implements _$CompetitionInfoCopyWith<$Res> {
  __$CompetitionInfoCopyWithImpl(this._self, this._then);

  final _CompetitionInfo _self;
  final $Res Function(_CompetitionInfo) _then;

/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? competition = null,Object? athletes = null,Object? clubs = null,Object? events = null,}) {
  return _then(_CompetitionInfo(
competition: null == competition ? _self.competition : competition // ignore: cast_nullable_to_non_nullable
as CompetitionSummary,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as int,clubs: null == clubs ? _self._clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<CompetitionClub>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CompetitionInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionSummaryCopyWith<$Res> get competition {
  
  return $CompetitionSummaryCopyWith<$Res>(_self.competition, (value) {
    return _then(_self.copyWith(competition: value));
  });
}
}

/// @nodoc
mixin _$ClubInfo {

 int get id;/// Celui de ses participants ; vide pour un club sans engagé.
 String get label;/// Par nom puis prénom (`clubAthletes`).
 List<Participant> get athletes;
/// Create a copy of ClubInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubInfoCopyWith<ClubInfo> get copyWith => _$ClubInfoCopyWithImpl<ClubInfo>(this as ClubInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes));
}


@override
int get hashCode {
  final _this = this as ClubInfo;
  return Object.hash(runtimeType,_this.id,_this.label,const DeepCollectionEquality().hash(_this.athletes));
}

@override
String toString() {
  final _this = this as ClubInfo;
  return 'ClubInfo(id: ${_this.id}, label: ${_this.label}, athletes: ${_this.athletes})';
}


}

/// @nodoc
abstract mixin class $ClubInfoCopyWith<$Res>  {
  factory $ClubInfoCopyWith(ClubInfo value, $Res Function(ClubInfo) _then) = _$ClubInfoCopyWithImpl;
@useResult
$Res call({
 int id, String label, List<Participant> athletes
});




}
/// @nodoc
class _$ClubInfoCopyWithImpl<$Res>
    implements $ClubInfoCopyWith<$Res> {
  _$ClubInfoCopyWithImpl(this._self, this._then);

  final ClubInfo _self;
  final $Res Function(ClubInfo) _then;

/// Create a copy of ClubInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? athletes = null,}) {
  return _then(ClubInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<Participant>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubInfo].
extension ClubInfoPatterns on ClubInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubInfo value)  $default,){
final _that = this;
switch (_that) {
case _ClubInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ClubInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label,  List<Participant> athletes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubInfo() when $default != null:
return $default(_that.id,_that.label,_that.athletes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label,  List<Participant> athletes)  $default,) {final _that = this;
switch (_that) {
case _ClubInfo():
return $default(_that.id,_that.label,_that.athletes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label,  List<Participant> athletes)?  $default,) {final _that = this;
switch (_that) {
case _ClubInfo() when $default != null:
return $default(_that.id,_that.label,_that.athletes);case _:
  return null;

}
}

}

/// @nodoc


class _ClubInfo implements ClubInfo {
  const _ClubInfo({required this.id, required this.label, required  List<Participant> athletes}): _athletes = athletes;
  

@override final  int id;
/// Celui de ses participants ; vide pour un club sans engagé.
@override final  String label;
/// Par nom puis prénom (`clubAthletes`).
 final  List<Participant> _athletes;
/// Par nom puis prénom (`clubAthletes`).
@override List<Participant> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}


/// Create a copy of ClubInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubInfoCopyWith<_ClubInfo> get copyWith => __$ClubInfoCopyWithImpl<_ClubInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.athletes, _athletes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(_athletes));
}

@override
String toString() {
    return 'ClubInfo(id: $id, label: $label, athletes: $athletes)';
}


}

/// @nodoc
abstract mixin class _$ClubInfoCopyWith<$Res> implements $ClubInfoCopyWith<$Res> {
  factory _$ClubInfoCopyWith(_ClubInfo value, $Res Function(_ClubInfo) _then) = __$ClubInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String label, List<Participant> athletes
});




}
/// @nodoc
class __$ClubInfoCopyWithImpl<$Res>
    implements _$ClubInfoCopyWith<$Res> {
  __$ClubInfoCopyWithImpl(this._self, this._then);

  final _ClubInfo _self;
  final $Res Function(_ClubInfo) _then;

/// Create a copy of ClubInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? athletes = null,}) {
  return _then(_ClubInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<Participant>,
  ));
}


}

/// @nodoc
mixin _$ClubRace {

 List<Participant> get athletes; AthleteRace get race;
/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubRaceCopyWith<ClubRace> get copyWith => _$ClubRaceCopyWithImpl<ClubRace>(this as ClubRace, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubRace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubRace&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&(identical(other.race, _this.race) || other.race == _this.race));
}


@override
int get hashCode {
  final _this = this as ClubRace;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.athletes),_this.race);
}

@override
String toString() {
  final _this = this as ClubRace;
  return 'ClubRace(athletes: ${_this.athletes}, race: ${_this.race})';
}


}

/// @nodoc
abstract mixin class $ClubRaceCopyWith<$Res>  {
  factory $ClubRaceCopyWith(ClubRace value, $Res Function(ClubRace) _then) = _$ClubRaceCopyWithImpl;
@useResult
$Res call({
 List<Participant> athletes, AthleteRace race
});


$AthleteRaceCopyWith<$Res> get race;

}
/// @nodoc
class _$ClubRaceCopyWithImpl<$Res>
    implements $ClubRaceCopyWith<$Res> {
  _$ClubRaceCopyWithImpl(this._self, this._then);

  final ClubRace _self;
  final $Res Function(ClubRace) _then;

/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? athletes = null,Object? race = null,}) {
  return _then(ClubRace(
athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<Participant>,race: null == race ? _self.race : race // ignore: cast_nullable_to_non_nullable
as AthleteRace,
  ));
}
/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AthleteRaceCopyWith<$Res> get race {
  
  return $AthleteRaceCopyWith<$Res>(_self.race, (value) {
    return _then(_self.copyWith(race: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClubRace].
extension ClubRacePatterns on ClubRace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubRace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubRace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubRace value)  $default,){
final _that = this;
switch (_that) {
case _ClubRace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubRace value)?  $default,){
final _that = this;
switch (_that) {
case _ClubRace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Participant> athletes,  AthleteRace race)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubRace() when $default != null:
return $default(_that.athletes,_that.race);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Participant> athletes,  AthleteRace race)  $default,) {final _that = this;
switch (_that) {
case _ClubRace():
return $default(_that.athletes,_that.race);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Participant> athletes,  AthleteRace race)?  $default,) {final _that = this;
switch (_that) {
case _ClubRace() when $default != null:
return $default(_that.athletes,_that.race);case _:
  return null;

}
}

}

/// @nodoc


class _ClubRace implements ClubRace {
  const _ClubRace({required  List<Participant> athletes, required this.race}): _athletes = athletes;
  

 final  List<Participant> _athletes;
@override List<Participant> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

@override final  AthleteRace race;

/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubRaceCopyWith<_ClubRace> get copyWith => __$ClubRaceCopyWithImpl<_ClubRace>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubRace&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&(identical(other.race, race) || other.race == race));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_athletes),race);
}

@override
String toString() {
    return 'ClubRace(athletes: $athletes, race: $race)';
}


}

/// @nodoc
abstract mixin class _$ClubRaceCopyWith<$Res> implements $ClubRaceCopyWith<$Res> {
  factory _$ClubRaceCopyWith(_ClubRace value, $Res Function(_ClubRace) _then) = __$ClubRaceCopyWithImpl;
@override @useResult
$Res call({
 List<Participant> athletes, AthleteRace race
});


@override $AthleteRaceCopyWith<$Res> get race;

}
/// @nodoc
class __$ClubRaceCopyWithImpl<$Res>
    implements _$ClubRaceCopyWith<$Res> {
  __$ClubRaceCopyWithImpl(this._self, this._then);

  final _ClubRace _self;
  final $Res Function(_ClubRace) _then;

/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? athletes = null,Object? race = null,}) {
  return _then(_ClubRace(
athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<Participant>,race: null == race ? _self.race : race // ignore: cast_nullable_to_non_nullable
as AthleteRace,
  ));
}

/// Create a copy of ClubRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AthleteRaceCopyWith<$Res> get race {
  
  return $AthleteRaceCopyWith<$Res>(_self.race, (value) {
    return _then(_self.copyWith(race: value));
  });
}
}

/// @nodoc
mixin _$ClubSchedule {

/// À courir d'abord, puis courues (voir [clubRaces]).
 List<ClubRace> get races;/// Athlètes dont la fiche n'a pu être lue : leurs courses manquent, ce
/// que la page dit.
 int get failedAthletes;
/// Create a copy of ClubSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubScheduleCopyWith<ClubSchedule> get copyWith => _$ClubScheduleCopyWithImpl<ClubSchedule>(this as ClubSchedule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubSchedule&&const DeepCollectionEquality().equals(other.races, _this.races)&&(identical(other.failedAthletes, _this.failedAthletes) || other.failedAthletes == _this.failedAthletes));
}


@override
int get hashCode {
  final _this = this as ClubSchedule;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.races),_this.failedAthletes);
}

@override
String toString() {
  final _this = this as ClubSchedule;
  return 'ClubSchedule(races: ${_this.races}, failedAthletes: ${_this.failedAthletes})';
}


}

/// @nodoc
abstract mixin class $ClubScheduleCopyWith<$Res>  {
  factory $ClubScheduleCopyWith(ClubSchedule value, $Res Function(ClubSchedule) _then) = _$ClubScheduleCopyWithImpl;
@useResult
$Res call({
 List<ClubRace> races, int failedAthletes
});




}
/// @nodoc
class _$ClubScheduleCopyWithImpl<$Res>
    implements $ClubScheduleCopyWith<$Res> {
  _$ClubScheduleCopyWithImpl(this._self, this._then);

  final ClubSchedule _self;
  final $Res Function(ClubSchedule) _then;

/// Create a copy of ClubSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? races = null,Object? failedAthletes = null,}) {
  return _then(ClubSchedule(
races: null == races ? _self.races : races // ignore: cast_nullable_to_non_nullable
as List<ClubRace>,failedAthletes: null == failedAthletes ? _self.failedAthletes : failedAthletes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubSchedule].
extension ClubSchedulePatterns on ClubSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubSchedule value)  $default,){
final _that = this;
switch (_that) {
case _ClubSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _ClubSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ClubRace> races,  int failedAthletes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubSchedule() when $default != null:
return $default(_that.races,_that.failedAthletes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ClubRace> races,  int failedAthletes)  $default,) {final _that = this;
switch (_that) {
case _ClubSchedule():
return $default(_that.races,_that.failedAthletes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ClubRace> races,  int failedAthletes)?  $default,) {final _that = this;
switch (_that) {
case _ClubSchedule() when $default != null:
return $default(_that.races,_that.failedAthletes);case _:
  return null;

}
}

}

/// @nodoc


class _ClubSchedule implements ClubSchedule {
  const _ClubSchedule({required  List<ClubRace> races, this.failedAthletes = 0}): _races = races;
  

/// À courir d'abord, puis courues (voir [clubRaces]).
 final  List<ClubRace> _races;
/// À courir d'abord, puis courues (voir [clubRaces]).
@override List<ClubRace> get races {
  if (_races is EqualUnmodifiableListView) return _races;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_races);
}

/// Athlètes dont la fiche n'a pu être lue : leurs courses manquent, ce
/// que la page dit.
@override@JsonKey() final  int failedAthletes;

/// Create a copy of ClubSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubScheduleCopyWith<_ClubSchedule> get copyWith => __$ClubScheduleCopyWithImpl<_ClubSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubSchedule&&const DeepCollectionEquality().equals(other.races, _races)&&(identical(other.failedAthletes, failedAthletes) || other.failedAthletes == failedAthletes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_races),failedAthletes);
}

@override
String toString() {
    return 'ClubSchedule(races: $races, failedAthletes: $failedAthletes)';
}


}

/// @nodoc
abstract mixin class _$ClubScheduleCopyWith<$Res> implements $ClubScheduleCopyWith<$Res> {
  factory _$ClubScheduleCopyWith(_ClubSchedule value, $Res Function(_ClubSchedule) _then) = __$ClubScheduleCopyWithImpl;
@override @useResult
$Res call({
 List<ClubRace> races, int failedAthletes
});




}
/// @nodoc
class __$ClubScheduleCopyWithImpl<$Res>
    implements _$ClubScheduleCopyWith<$Res> {
  __$ClubScheduleCopyWithImpl(this._self, this._then);

  final _ClubSchedule _self;
  final $Res Function(_ClubSchedule) _then;

/// Create a copy of ClubSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? races = null,Object? failedAthletes = null,}) {
  return _then(_ClubSchedule(
races: null == races ? _self._races : races // ignore: cast_nullable_to_non_nullable
as List<ClubRace>,failedAthletes: null == failedAthletes ? _self.failedAthletes : failedAthletes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
