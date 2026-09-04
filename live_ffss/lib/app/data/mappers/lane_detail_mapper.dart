import 'package:live_ffss/app/data/dtos/lane_detail_dto.dart';
import 'package:live_ffss/app/domain/models/lane.dart';

extension LaneDetailMapper on LaneDetailDto {
  /// The seat this place holds, or null for a free place — a default lane
  /// nobody was drawn into says nothing about the composition.
  LaneSeat? toSeat() {
    final seat = this.seat;
    if (seat == null || seat.entryId == 0) return null;
    return (
      laneId: id,
      number: number,
      entryId: seat.entryId,
      athleteIds: [
        for (final athlete in seat.athletes ?? const <LaneSeatAthleteDto>[])
          if (athlete.id != 0) athlete.id,
      ],
    );
  }
}
