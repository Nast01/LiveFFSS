import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/module/programme/controllers/sites_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late SitesController controller;

  setUpAll(() => registerFallbackValue(''));

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.load(42);
    controller = SitesController(service);
  });

  test('addSite appends a site with an allocated id and persists', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);

    expect(controller.sites.length, 1);
    expect(controller.sites.single.name, 'Côtier 1');
    expect(controller.sites.single.type, SiteType.cotier);
    expect(controller.sites.single.id, 1); // first allocated id
    verify(() => storage.write(
        key: 'programme_42', value: any(named: 'value'))).called(1);
  });

  test('addSite gives distinct ids', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    await controller.addSite('Sable 1', SiteType.sable);
    final ids = controller.sites.map((s) => s.id).toSet();
    expect(ids.length, 2);
  });

  test('renameSite updates name and type in place', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    final id = controller.sites.single.id;

    await controller.renameSite(id, 'Côtier A', SiteType.sable);

    expect(controller.sites.single.name, 'Côtier A');
    expect(controller.sites.single.type, SiteType.sable);
  });

  test('deleteSite removes it', () async {
    await controller.addSite('Côtier 1', SiteType.cotier);
    final id = controller.sites.single.id;

    await controller.deleteSite(id);

    expect(controller.sites, isEmpty);
  });
}
