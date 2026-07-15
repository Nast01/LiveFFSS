import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/result_dto.dart';
import 'package:live_ffss/app/data/mappers/result_mapper.dart';

void main() {
  group('ResultMapper', () {
    Map<String, dynamic> baseJson({
      String? disqualificationReason,
      String? commentaireDisqualification,
    }) =>
        {
          'Id': 'r1',
          'isValid': true,
          'Statut': 1,
          'statutLabel': 'OK',
          'Rang': 2,
          'Temps': 3045,
          'tempsLabel': '0:30.45',
          if (disqualificationReason != null)
            'disqualificationReason': disqualificationReason,
          if (commentaireDisqualification != null)
            'CommentaireDisqualification': commentaireDisqualification,
        };

    test('maps result without nested heat/entry (Serie.list context)', () {
      final dto = ResultDto.fromJson(baseJson());
      final result = dto.toDomain();
      expect(result.id, 'r1');
      expect(result.rank, 2);
      expect(result.heat, isNull);
      expect(result.entry, isNull);
    });

    test('includeParents:false drops heat even when DTO carries one', () {
      final json = {
        ...baseJson(),
        'serie': {'Id': 5, 'Nom': 'S1', 'Fini': false, 'Numero': 1},
      };
      final dto = ResultDto.fromJson(json);
      final result = dto.toDomain(includeParents: false);
      expect(result.heat, isNull);
    });

    test('includeParents:true (default) maps the nested heat', () {
      final json = {
        ...baseJson(),
        'serie': {'Id': 5, 'Nom': 'S1', 'Fini': false, 'Numero': 1},
      };
      final dto = ResultDto.fromJson(json);
      final result = dto.toDomain();
      expect(result.heat, isNotNull);
      expect(result.heat!.id, 5);
    });

    test('reads disqualificationReason from new field', () {
      final dto = ResultDto.fromJson(
        baseJson(disqualificationReason: 'False start'),
      );
      expect(dto.toDomain().disqualificationReason, 'False start');
    });

    test('falls back to legacy CommentaireDisqualification', () {
      final dto = ResultDto.fromJson(
        baseJson(commentaireDisqualification: 'Legacy reason'),
      );
      expect(dto.toDomain().disqualificationReason, 'Legacy reason');
    });

    test('new field wins over legacy when both present', () {
      final dto = ResultDto.fromJson(baseJson(
        disqualificationReason: 'New',
        commentaireDisqualification: 'Legacy',
      ));
      expect(dto.toDomain().disqualificationReason, 'New');
    });
  });
}
