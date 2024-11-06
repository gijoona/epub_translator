import 'dart:async';

import 'package:epub_translator/src/db/helper/database_helper.dart';
import 'package:epub_translator/src/db/models/history_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// DatabaseHelper 인스턴스를 관리하는 프로바이더
final databaseHelperProvider = Provider((ref) => DatabaseHelper());

class HistoryNotifier extends StateNotifier<AsyncValue<HistoryModel?>> {
  final DatabaseHelper dbHelper;

  HistoryNotifier(this.dbHelper) : super(const AsyncLoading());

  // 모든 history 정보를 불러오는 메서드
  Future<List<HistoryModel>?> loadAllHistory() async {
    try {
      return await dbHelper.getAllHistory();
    } catch (e) {
      return null;
    }
  }

  // 특정 EPUB의 history 정보를 불러오는 메서드
  Future<HistoryModel?> getHistory(String epubName) async {
    try {
      final history = await dbHelper.getHistoryByEpubName(epubName);
      if (history != null) {
        state = AsyncValue.data(history);
        return history;
      } else {
        return null;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // history 정보 삽입 또는 업데이트
  Future<void> saveHistory(HistoryModel history) async {
    try {
      await dbHelper.insertOrUpdateHistory(history);
      await getHistory(history.epubName); // 업데이트 후 전체 history 정보 다시 불러오기
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // history를 삭제하는 메서드
  Future<void> deleteHistory(String epubName) async {
    try {
      await dbHelper.deleteHistory(epubName);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// history 정보를 관리하는 프로바이더
final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<HistoryModel?>>(
  (ref) {
    final dbHelper = ref.watch(databaseHelperProvider);
    return HistoryNotifier(dbHelper);
  },
);
