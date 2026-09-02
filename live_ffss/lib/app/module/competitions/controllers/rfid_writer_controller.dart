import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/rfid/bracelet_payload.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/shared/filter_chip_bar.dart';
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

  /// Category ids ticked in the filter bar. Empty means no restriction, which
  /// is why nothing here needs an explicit "all" arm.
  final RxSet<int> selectedCategories = <int>{}.obs;
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
      _pruneCategories();
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

  bool get hasActiveFilters => selectedCategories.isNotEmpty;

  bool isCategorySelected(int id) => selectedCategories.contains(id);

  void toggleCategory(int id) {
    if (!selectedCategories.remove(id)) selectedCategories.add(id);
    _applyFilter();
  }

  void clearCategories() {
    selectedCategories.clear();
    _applyFilter();
  }

  /// The categories the loaded athletes are entered in, distinct and by name,
  /// so the sheet never offers a choice that would empty the list.
  List<FilterOption> get categoryOptions {
    final byId = <int, String>{};
    for (final athlete in allAthletes) {
      for (final category in athlete.categories) {
        byId[category.id] = category.name;
      }
    }
    final options = [
      for (final entry in byId.entries) FilterOption(entry.key, entry.value),
    ]..sort((a, b) => a.label.compareTo(b.label));
    return options;
  }

  /// Drops ticked categories that no longer exist among the loaded athletes.
  /// Without this, a reload that no longer carries one leaves the operator on
  /// an empty list with nothing left to un-tick.
  void _pruneCategories() {
    if (selectedCategories.isEmpty) return;
    final available = {for (final o in categoryOptions) o.value};
    selectedCategories.removeWhere((id) => !available.contains(id));
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    filteredAthletes.value = allAthletes
        .where((a) => _matchesQuery(a, q) && _matchesCategory(a))
        .toList();
  }

  bool _matchesQuery(Athlete athlete, String q) {
    if (q.isEmpty) return true;
    return athlete.lastName.toLowerCase().contains(q) ||
        athlete.firstName.toLowerCase().contains(q) ||
        athlete.licenseeNumber.toLowerCase().contains(q) ||
        (athlete.club?.name.toLowerCase().contains(q) ?? false);
  }

  /// An athlete races several categories at once — a junior is usually entered
  /// in Junior, Youth and Open — so one ticked category is enough to keep them.
  /// Hiding them because another of their categories was not picked would hide
  /// someone who does take the start.
  bool _matchesCategory(Athlete athlete) {
    if (selectedCategories.isEmpty) return true;
    return athlete.categories.any((c) => selectedCategories.contains(c.id));
  }

  /// What [writeBracelet] will put on the chip. The sheet shows this so the
  /// volunteer can see the exact string before presenting a bracelet.
  String payloadFor(Athlete athlete) => braceletPayload(athlete);

  Future<void> writeBracelet(Athlete athlete) async {
    // One bracelet at a time. Without this, a second call while the first is
    // in flight overwrites `selected`, and the first write's success then
    // reports itself against the second athlete — the wrong name on a green
    // check. The modal sheet makes this hard to reach by hand, but the rule
    // belongs here, not in the view that happens to enforce it today.
    if (writeState.value == RfidWriteState.waiting) return;
    selected.value = athlete;
    writeState.value = RfidWriteState.waiting;
    message.value = null;
    try {
      await _rfidWriter.write(braceletPayload(athlete));
      if (writeState.value != RfidWriteState.waiting) return;
      writeState.value = RfidWriteState.success;
      message.trigger(const UiMessageSuccess('bracelet_written'));
    } on AppException catch (e) {
      // A cancelled write rejects too. `cancelWrite` has already moved us out
      // of `waiting`, and the user who pressed Annuler does not want an error
      // popped at them for getting what they asked for.
      if (writeState.value != RfidWriteState.waiting) return;
      writeState.value = RfidWriteState.error;
      message.trigger(UiMessageError(e.message));
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
