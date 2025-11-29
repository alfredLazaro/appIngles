class DbConst {
  static const String databaseName = "database.db";
  static const int version = 1;
}

class DBTables {
  static const String word = 'Word';
  static const String image = 'Image';
  static const String translation = 'Translation';
}

class WordFields {
  static const String id = 'id';
  static const String word = 'word';
  static const String definition = 'definition';
  static const String sentence = 'sentence';
  static const String learn = 'learn';
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
