import 'package:epub_translator/src/db/helper/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// DatabaseHelper 인스턴스를 관리하는 프로바이더
final databaseHelperProvider = Provider((ref) => DatabaseHelper());

// 설정 정보를 저장하는 StateNotifier
class ConfigNotifier extends StateNotifier<Map<String, String?>> {
  final DatabaseHelper dbHelper;

  ConfigNotifier(this.dbHelper) : super({});

  // 설정 정보를 불러오는 메서드
  Future<void> loadConfig(String key) async {
    final value = await dbHelper.getConfigValue(key);
    state = {...state, key: value};
  }

  // 설정 정보를 저장하는 메서드
  Future<void> saveConfig(String key, String value) async {
    await dbHelper.insertOrUpdateConfig(key, value);
    state = {...state, key: value}; // 상태 업데이트
  }

  // 설정 정보를 삭제하는 메서드
  Future<void> deleteConfig(String key) async {
    await dbHelper.deleteConfig(key);
    final newState = Map<String, String?>.from(state);
    newState.remove(key);
    state = newState; // 상태 업데이트
  }

  // 전체 설정 정보 불러오기 - App initialize
  Future<void> loadAllConfigs() async {
    final allConfigs = await dbHelper.getAllConfigs();
    final Map<String, String?> configsMap = {
      for (var config in allConfigs) config['key']: config['value']
    };
    state = configsMap; // 상태 업데이트
  }
}

// 설정 정보를 관리하는 프로바이더
final configProvider =
    StateNotifierProvider<ConfigNotifier, Map<String, String?>>(
  (ref) {
    final dbHelper = ref.watch(databaseHelperProvider);
    return ConfigNotifier(dbHelper);
  },
);
