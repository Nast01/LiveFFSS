import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements ApiService {}

class _FakeMeeting extends Fake implements MeetingModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMeeting());
  });

  late _MockApi api;
  late MeetingRepository repo;

  setUp(() {
    api = _MockApi();
    repo = MeetingRepositoryImpl(api);
  });

  group('MeetingRepository', () {
    test('getMeetings forwards competitionId and returns list', () async {
      when(() => api.getMeetings(any())).thenAnswer((_) async => []);

      final list = await repo.getMeetings(42);

      expect(list, isEmpty);
      verify(() => api.getMeetings(42)).called(1);
    });

    test('createMeeting forwards meeting + competitionId', () async {
      final meeting = _FakeMeeting();
      when(() => api.createMeeting(any(), any())).thenAnswer((_) async => true);

      final result = await repo.createMeeting(meeting, 99);

      expect(result, true);
      verify(() => api.createMeeting(meeting, 99)).called(1);
    });

    test('deleteMeeting forwards meetingId', () async {
      when(() => api.deleteMeeting(any())).thenAnswer((_) async => true);

      final result = await repo.deleteMeeting(7);

      expect(result, true);
      verify(() => api.deleteMeeting(7)).called(1);
    });
  });
}
