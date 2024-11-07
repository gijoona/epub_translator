import 'package:epub_translator/src/db/models/history_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 싱글톤 방식으로 하나의 인스턴스만 생성
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'epub_translate.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE epub_conf (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE history (
        epub_name TEXT PRIMARY KEY,
        cover_image TEXT,
        epub_path TEXT,
        last_view_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 기본값을 현재시간으로 설정
        history_json TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE history (
          epub_name TEXT PRIMARY KEY,
          cover_image TEXT,
          epub_path TEXT,
          last_view_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 기본값을 현재시간으로 설정
          history_json TEXT
        )
      ''');
    }
  }

  // 설정 정보 삽입 또는 업데이트
  Future<int> insertOrUpdateConfig(String key, String value) async {
    final db = await database;
    return await db.insert(
      'epub_conf',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace, // key가 동일하면 업데이트
    );
  }

  // 설정 정보 가져오기
  Future<String?> getConfigValue(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'epub_conf',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    } else {
      return null; // key에 해당하는 값이 없을 경우 null 리턴
    }
  }

  // 설정 정보 삭제
  Future<int> deleteConfig(String key) async {
    final db = await database;
    return await db.delete(
      'epub_conf',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // 모든 설정 정보 가져오기 (디버깅용)
  Future<List<Map<String, dynamic>>> getAllConfigs() async {
    final db = await database;
    return await db.query('epub_conf');
  }

  // history 테이블에 정보 삽입 또는 업데이트. EPUB 파일오픈 or EPUB 컨텐츠 볼 때마다 수행.
  Future<int> insertOrUpdateHistory(HistoryModel history) async {
    final db = await database;
    return await db.insert(
      'history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // history　테이블의 모든 항목 가져오기
  Future<List<HistoryModel>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('history', orderBy: 'last_view_date DESC');
    return result.map((history) => HistoryModel.fromMap(history)).toList();
  }

  // 특정 EPUB파일의 history　항목을 가져오기.
  Future<HistoryModel?> getHistoryByEpubName(String epubName) async {
    final db = await database;
    final history = await db.query(
      'history',
      where: 'epub_name = ?',
      whereArgs: [epubName],
    );

    if (history.isNotEmpty) {
      return HistoryModel.fromMap(history.first);
    } else {
      return null;
    }
  }

  // history　항목 삭제
  Future<int> deleteHistory(String epubName) async {
    final db = await database;
    return await db.delete(
      'history',
      where: 'epub_name = ?',
      whereArgs: [epubName],
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
