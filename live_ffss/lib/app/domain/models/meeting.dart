import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    required int id,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    @Default(<Slot>[]) List<Slot> slots,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);
}

extension MeetingSite on Meeting {
  /// FFSS ne porte aucun site sur une réunion : la description le transporte.
  /// Toutes les courses de la réunion sont créées sur ce site.
  ///
  /// Dans le domaine et non dans une extension de présentation : c'est une
  /// relecture sémantique d'un champ, pas un formatage, et un contrôleur en a
  /// besoin pour créer ses courses.
  String get site => description;
}
