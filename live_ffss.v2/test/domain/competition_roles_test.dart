import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';

void main() {
  test('isAdmin, isOfficial et isReferee se lisent dans les rôles', () {
    const roles = CompetitionRoles(
      roles: ['public', 'admin', 'officiel', 'referent_sportif'],
    );
    expect(roles.isAdmin, isTrue);
    expect(roles.isOfficial, isTrue);
    expect(roles.isReferee, isTrue);
  });

  test('un compte public n\'a aucun de ces rôles', () {
    const roles = CompetitionRoles(roles: ['public']);
    expect(roles.isAdmin, isFalse);
    expect(roles.isOfficial, isFalse);
    expect(roles.isReferee, isFalse);
    expect(roles.refereeClubs, isEmpty);
  });
}
