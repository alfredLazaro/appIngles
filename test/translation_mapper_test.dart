import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/data/mappers/translation_mapper.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mapper = TranslationMapper();

  group('TranslationMapper.mapToTranslationEntity', () {
    test('maps a database row keyed by real column names', () {
      final row = {
        'id': 5,
        TranslationFields.wordId: 42,
        TranslationFields.wordTranslate: 'hola',
        TranslationFields.alternatives: 'saludo|hey',
        TranslationFields.createdAt: '2024-01-01T10:00:00',
      };

      final entity = mapper.mapToTranslationEntity(row);

      expect(entity.id, 5);
      expect(entity.wordId, 42);
      expect(entity.wordTranslate, 'hola');
      expect(entity.alternatives, ['saludo', 'hey']);
      expect(entity.createdAt, DateTime(2024, 1, 1, 10, 0));
    });

    test('does not crash when a row has null values', () {
      final row = {
        TranslationFields.wordId: null,
        TranslationFields.wordTranslate: null,
        TranslationFields.alternatives: null,
      };

      final entity = mapper.mapToTranslationEntity(row);

      expect(entity.wordId, 0);
      expect(entity.wordTranslate, '');
      expect(entity.alternatives, isEmpty);
      expect(entity.createdAt, isNull);
    });
  });

  group('TranslationMapper.translationEntityToMap', () {
    test('round-trips an entity into a database row', () {
      const entity = TranslationEntity(
        id: 3,
        wordId: 7,
        wordTranslate: 'adiós',
        alternatives: ['despedida', 'bye'],
      );

      final map = mapper.translationEntityToMap(entity);

      expect(map[TranslationFields.id], 3);
      expect(map[TranslationFields.wordId], 7);
      expect(map[TranslationFields.wordTranslate], 'adiós');
      expect(map[TranslationFields.alternatives], 'despedida|bye');
    });
  });
}
