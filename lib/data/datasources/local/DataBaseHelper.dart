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
                ${WordFields.partOfSpeech} TEXT,
                ${WordFields.phonetic} TEXT,
                ${WordFields.definition}  $textType,
                ${WordFields.sentence} $textType,
                ${WordFields.learn} INTEGER NOT NULL DEFAULT 0,
                ${WordFields.synonyms} TEXT,
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
    await db.execute('''
      CREATE TABLE ${DBTables.progress}(
        ${ProgressFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ProgressFields.wordId} INTEGER NOT NULL UNIQUE,
        ${WordFields.word} TEXT NOT NULL,
        ${ProgressFields.learn} INTEGER NOT NULL DEFAULT 0,
        ${ProgressFields.updatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${ProgressFields.userId} INTEGER,
        ${ProgressFields.syncedAt} TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DBTables.outbox}(
        ${OutboxFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${OutboxFields.entityType} TEXT NOT NULL,
        ${OutboxFields.entityId} INTEGER NOT NULL,
        ${OutboxFields.operation} TEXT NOT NULL DEFAULT 'upsert',
        ${OutboxFields.payload} TEXT NOT NULL,
        ${OutboxFields.status} TEXT NOT NULL DEFAULT 'pending',
        ${OutboxFields.attempts} INTEGER NOT NULL DEFAULT 0,
        ${OutboxFields.maxAttempts} INTEGER NOT NULL DEFAULT 15,
        ${OutboxFields.nextRetryAt} TEXT,
        ${OutboxFields.createdAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${OutboxFields.updatedAt} TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_outbox_pending_entity
      ON ${DBTables.outbox}(${OutboxFields.entityType}, ${OutboxFields.entityId})
      WHERE ${OutboxFields.status} = 'pending'
    ''');
    await db.execute('''
      CREATE TABLE ${DBTables.users}(
        ${UserFields.id} INTEGER PRIMARY KEY,
        ${UserFields.email} TEXT NOT NULL,
        ${UserFields.token} TEXT,
        ${UserFields.createdAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${UserFields.updatedAt} TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
    await db.execute('''
      CREATE TABLE app_preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await _instance.database;
    db.close();
  }
}