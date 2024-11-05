import 'package:epub_translator/src/db/helper/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// DatabaseHelper 인스턴스를 관리하는 프로바이더
final databaseHelperProvider = Provider((ref) => DatabaseHelper());

class HistoryNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final DatabaseHelper dbHelper;

  HistoryNotifier(this.dbHelper) : super(const AsyncLoading());

  // 모든 history 정보를 불러오는 메서드
  Future<void> loadAllHistory() async {
    try {
      final allHistory = await dbHelper.getAllHistory();
      state = AsyncValue.data(allHistory);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 특정 EPUB의 history 정보를 불러오는 메서드
  Future<Map<String, dynamic>?> getHistory(String epubName) async {
    try {
      return await dbHelper.getHistoryByEpubName(epubName);
    } catch (e) {
      return null;
    }
  }

  // history 정보 삽입 또는 업데이트
  Future<void> saveHistory(
      String epubName, String coverImage, String historyJson) async {
    try {
      await dbHelper.insertOrUpdateHistory(epubName, coverImage, historyJson);
      await loadAllHistory(); // 업데이트 후 전체 history 정보 다시 불러오기
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// history 정보를 관리하는 프로바이더
final historyProvider = StateNotifierProvider<HistoryNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) {
    final dbHelper = ref.watch(databaseHelperProvider);
    return HistoryNotifier(dbHelper);
  },
);
