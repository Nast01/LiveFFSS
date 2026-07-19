import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

/// Scaffold controller for one scheduled course (série/quart/demi/finale) of a
/// race×category. Holds the context passed from the Séries tab; result
/// viewing/entry is deferred (future work fills this screen).
class RaceCourseController extends GetxController {
  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  int? categoryId;
  String categoryLabel = '';
  RoundType roundType = RoundType.unknown;
  int raceNumber = 0;
  int? programmeRaceId;

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is! Map) return;
    final r = arg['race'];
    if (r is Race) race.value = r;
    final c = arg['competition'];
    if (c is Competition) competition.value = c;
    final cid = arg['categoryId'];
    if (cid is int) categoryId = cid;
    final cl = arg['categoryLabel'];
    if (cl is String) categoryLabel = cl;
    final rt = arg['roundType'];
    if (rt is RoundType) roundType = rt;
    final rn = arg['raceNumber'];
    if (rn is int) raceNumber = rn;
    final pid = arg['programmeRaceId'];
    if (pid is int) programmeRaceId = pid;
  }
}
