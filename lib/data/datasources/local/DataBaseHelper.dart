import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    print("base de datos creada correctamente");
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConst.databaseName);

    return await openDatabase(
      path,
      version: DbConst.version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    await db.execute('''
            CREATE TABLE ${DBTables.word}(
                ${WordFields.id} $idType,
                ${WordFields.word}  $textType,
                ${WordFields.definition}  $textType,
                ${WordFields.sentence} $textType,
                ${WordFields.learn} INTEGER NOT NULL DEFAULT 0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        ''');
    await db.execute('''
            CREATE TABLE ${DBTables.image}(
                ${ImageFields.id} $idType,
                ${ImageFields.wordId} INTEGER,
                ${ImageFields.name} TEXT,
                ${ImageFields.url} TEXT,
                ${ImageFields.tinyurl} TEXT,
                ${ImageFields.author} TEXT,
                ${ImageFields.source} TEXT,
                FOREIGN KEY (${ImageFields.wordId}) REFERENCES ${DBTables.word}(${WordFields.id}) ON DELETE CASCADE
            )
        ''');
    await db.execute('''
            CREATE TABLE ${DBTables.translation}(
                ${TranslationFields.id} $idType,
                ${TranslationFields.wordTranslate} TEXT,
                ${TranslationFields.wordId} INTEGER,
                ${TranslationFields.alternatives} TEXT,
                FOREIGN KEY (${TranslationFields.wordId}) REFERENCES ${DBTables.word}(${WordFields.id}) ON DELETE CASCADE
            )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {}
  }

  Future<void> close() async {
    final db = await _instance.database;
    db.close();
  }
}
