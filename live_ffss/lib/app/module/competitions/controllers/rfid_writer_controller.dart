import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

enum RfidWriteState { idle, waiting, success, error }

class RfidWriterController extends GetxController {
  RfidWriterController(this._clubRepo, this._rfidWriter);

  final ClubRepository _clubRepo;
  final RfidWriter _rfidWriter;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<Athlete> allAthletes = <Athlete>[].obs;
  final RxList<Athlete> filteredAthletes = <Athlete>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final Rxn<Athlete> selected = Rxn<Athlete>();
  final Rx<RfidWriteState> writeState = RfidWriteState.idle.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
      loadAthletes(arg.id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadAthletes(int competitionId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final clubs = await _clubRepo.getClubs(competitionId);

      // Dedupe by id: the same athlete can surface under more than one club.
      // First occurrence wins, in repository order.
      final byId = <int, Athlete>{};
      for (final club in clubs) {
        for (final athlete in club.athletes) {
          byId.putIfAbsent(athlete.id, () => athlete);
        }
      }

      final sorted = byId.values.toList()
        ..sort((a, b) {
          final byLast =
              a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
          if (byLast != 0) return byLast;
          return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
        });

      allAthletes.value = sorted;
      _applyFilter();
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAthletes.value = List.from(allAthletes);
      return;
    }
    filteredAthletes.value = allAthletes.where((a) {
      return a.lastName.toLowerCase().contains(q) ||
          a.firstName.toLowerCase().contains(q) ||
          a.licenseeNumber.toLowerCase().contains(q) ||
          (a.club?.name.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  /// What [writeBracelet] will put on the chip. The sheet shows this so the
  /// volunteer can see the exact string before presenting a bracelet.
  String payloadFor(Athlete athlete) => braceletPayload(athlete);

  Future<void> writeBracelet(Athlete athlete) async {
    selected.value = athlete;
    writeState.value = RfidWriteState.waiting;
    message.value = null;
    try {
      await _rfidWriter.write(braceletPayload(athlete));
      if (writeState.value != RfidWriteState.waiting) return;
      writeState.value = RfidWriteState.success;
      message.value = const UiMessageSuccess('bracelet_written');
    } on AppException catch (e) {
      // A cancelled write rejects too. `cancelWrite` has already moved us out
      // of `waiting`, and the user who pressed Annuler does not want an error
      // popped at them for getting what they asked for.
      if (writeState.value != RfidWriteState.waiting) return;
      writeState.value = RfidWriteState.error;
      message.value = UiMessageError(e.message);
    }
  }

  Future<void> cancelWrite() async {
    writeState.value = RfidWriteState.idle;
    selected.value = null;
    message.value = null;
    // Releases the hardware. Without this the session stays open and the next
    // bracelet presented is silently written with the abandoned payload.
    await _rfidWriter.cancel();
  }
}
