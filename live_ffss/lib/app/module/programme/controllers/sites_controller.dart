import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';

class SitesController extends GetxController {
  SitesController(this._programme);

  final ProgrammeService _programme;

  List<ProgrammeSite> get sites =>
      _programme.current.value?.sites ?? const [];

  Future<void> addSite(String name, SiteType type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = _programme.current.value;
    if (p == null) return;
    final id = _programme.allocateId();
    // Re-read current: allocateId bumped nextLocalId in it.
    final withBump = _programme.current.value!;
    await _programme.save(withBump.copyWith(
      sites: [...withBump.sites, ProgrammeSite(id: id, name: trimmed, type: type)],
    ));
  }

  Future<void> renameSite(int id, String name, SiteType type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = _programme.current.value;
    if (p == null) return;
    await _programme.save(p.copyWith(sites: [
      for (final s in p.sites)
        s.id == id ? s.copyWith(name: trimmed, type: type) : s,
    ]));
  }

  Future<void> deleteSite(int id) async {
    final p = _programme.current.value;
    if (p == null) return;
    // Drop the site AND clear any race placed on it, so nothing dangles.
    final withoutSite =
        p.copyWith(sites: p.sites.where((s) => s.id != id).toList());
    await _programme.save(clearPlacementsForSite(withoutSite, id));
  }
}
