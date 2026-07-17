import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

class CompetitionDetailController extends GetxController {
  CompetitionDetailController(this._prefs, this._rfidWriter);

  final UserPreferencesService _prefs;
  final RfidWriter _rfidWriter;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      competition.value = arg;
    }
  }

  RxSet<int> get favoriteIds => _prefs.favoriteIds;
  Future<void> toggleFavorite(int id) => _prefs.toggleFavorite(id);

  /// Whether this device can write RFID bracelets. The header hides its NFC
  /// button when false rather than showing a disabled control that would need
  /// explaining.
  bool get canWriteBracelets => _rfidWriter.isSupported;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
