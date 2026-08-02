import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/referee_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

/// The FFSS pseudo-organisme. The API uses it as a bucket for everyone who has
/// no real FFSS club — guests and foreign clubs — so its own `Id`/`label` say
/// "FFSS" and tell us nothing about the members it holds. The real club of each
/// member is carried by the member row instead. See [ClubMapper.toDomainClubs].
const int ffssBucketOrganismeId = 245;

extension ClubMapper on ClubDto {
  Club toDomain() => toDomainClubs().first;

  /// Maps this DTO to the clubs it actually represents: one for a regular
  /// organisme, one per distinct member identity for [ffssBucketOrganismeId].
  /// Never empty.
  List<Club> toDomainClubs() {
    final self = _club(
      id: id,
      name: name,
      shortName: shortName,
      logoUrl: logoUrl,
      capUrl: capUrl,
      athletes: athletes,
      referees: referees,
    );
    if (id != ffssBucketOrganismeId) return [self];

    final order = <int>[];
    final labels = <int, String>{};
    final groupedAthletes = <int, List<AthleteDto>>{};
    final groupedReferees = <int, List<RefereeDto>>{};

    void register(int clubId, String label) {
      if (labels.containsKey(clubId)) return;
      order.add(clubId);
      labels[clubId] = label;
    }

    for (final a in athletes) {
      final (clubId, label) = _resolve(a.clubId, a.clubLabel);
      register(clubId, label);
      groupedAthletes.putIfAbsent(clubId, () => []).add(a);
    }
    for (final r in referees) {
      // A guest officiel only has the competition-scoped club filled in;
      // a licensed one carries their own club in the officiel columns.
      final (clubId, label) = r.isGuest
          ? _resolve(r.clubId, r.clubLabel)
          : _resolve(r.refereeClubId, r.refereeClubLabel);
      register(clubId, label);
      groupedReferees.putIfAbsent(clubId, () => []).add(r);
    }

    if (order.isEmpty) return [self];

    final split = <Club>[];
    for (final clubId in order) {
      // Short name, logo and cap belong to the FFSS organisme itself — only
      // the leftover group (members we could not resolve) keeps them.
      final isBucket = clubId == id;
      split.add(_club(
        id: clubId,
        name: labels[clubId]!,
        shortName: isBucket ? shortName : null,
        logoUrl: isBucket ? logoUrl : null,
        capUrl: isBucket ? capUrl : null,
        // The leftover group is the FFSS organisme itself, not a guest club.
        isGuest: !isBucket,
        athletes: groupedAthletes[clubId] ?? const [],
        referees: groupedReferees[clubId] ?? const [],
      ));
    }
    return split;
  }

  /// Members whose own club is missing stay attached to the bucket rather than
  /// being dropped from the competition.
  (int, String) _resolve(int clubId, String label) =>
      clubId > 0 && label.isNotEmpty ? (clubId, label) : (id, name);
}

Club _club({
  required int id,
  required String name,
  required String? shortName,
  required String? logoUrl,
  required String? capUrl,
  required List<AthleteDto> athletes,
  required List<RefereeDto> referees,
  bool isGuest = false,
}) {
  // Lightweight back-reference used to populate athletes/referees `club`.
  // Excludes the athlete/referee lists themselves to avoid recursion.
  final clubLite = Club(
    id: id,
    name: name,
    shortName: shortName,
    logoUrl: logoUrl,
    capUrl: capUrl,
    // Carried on the back-ref too: the entries view reads it off athlete.club
    // to decide whether a logo may be fetched.
    isGuest: isGuest,
  );
  return Club(
    id: id,
    name: name,
    shortName: shortName,
    logoUrl: logoUrl,
    capUrl: capUrl,
    isGuest: isGuest,
    athletes:
        athletes.map((a) => a.toDomain().copyWith(club: clubLite)).toList(),
    referees:
        referees.map((r) => r.toDomain().copyWith(club: clubLite)).toList(),
  );
}

extension ClubX on Club {
  bool get hasLogo => logoUrl?.isNotEmpty == true;
  bool get hasCap => capUrl?.isNotEmpty == true;
}
