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
      version: 1,
      onCreate: _onCreate,
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

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
