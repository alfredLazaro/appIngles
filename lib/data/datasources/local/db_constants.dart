class DbConst {
  static const String databaseName = "database.db";
  static const int version = 2;
}

class DBTables {
  static const String word = 'Word';
  static const String image = 'Image';
  static const String translation = 'Translation';
  static const String progress = 'progress';
  static const String outbox = 'outbox';
  static const String users = 'users';
}

class WordFields {
  static const String id = 'id';
  static const String word = 'word';
  static const String partOfSpeech = 'partOfSpeech';
  static const String phonetic = 'phonetic';
  static const String definition = 'definition';
  static const String sentence = 'sentence';
  static const String learn = 'learn';
  static const String synonyms = 'synonyms';
}

class ImageFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String url = 'url';
  static const String tinyurl = 'tinyurl';
  static const String author = 'author';
  static const String source = 'source';
  static const String wordId = 'wordId';
}

class TranslationFields {
  static const String id = 'id';
  static const String wordTranslate = 'wordTranslate';
  static const String alternatives = 'alternatives';
  static const String wordId = 'wordId';
}

class ProgressFields {
  static const String id = 'id';
  static const String wordId = 'word_id';
  static const String learn = 'learn';
  static const String updatedAt = 'updated_at';
  static const String userId = 'user_id';
  static const String syncedAt = 'synced_at';
}

class OutboxFields {
  static const String id = 'id';
  static const String entityType = 'entity_type';
  static const String entityId = 'entity_id';
  static const String operation = 'operation';
  static const String payload = 'payload';
  static const String status = 'status';
  static const String attempts = 'attempts';
  static const String maxAttempts = 'max_attempts';
  static const String nextRetryAt = 'next_retry_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class UserFields {
  static const String id = 'id';
  static const String email = 'email';
  static const String token = 'token';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}