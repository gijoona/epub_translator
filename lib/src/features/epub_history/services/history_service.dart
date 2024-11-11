// HistoryService 클래스 정의
import 'package:epub_translator/src/features/epub_history/models/history_model.dart';
import 'package:epub_translator/src/db/providers/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryService {
  final Ref ref;
  final HistoryNotifier historyNotifier;

  HistoryService(this.ref, this.historyNotifier);

  // history 정보 삽입 또는 업데이트
  Future<void> saveHistory(HistoryModel history) async {
    final bookHistory = await historyNotifier.getHistory(history.epubName);

    if (bookHistory != null) {
      history = history.copyWith(
        lastViewIndex: bookHistory.lastViewIndex,
      );
    }
    await historyNotifier.saveHistory(history);
  }

  // 모든 history 정보를 불러오는 메서드
  Future<List<HistoryModel>?> loadAllHistory() async {
    return await historyNotifier.loadAllHistory();
  }

  Future<List<HistoryModel>?> loadAllHistoryPaging({
    required int pageNum,
  }) async {
    return await historyNotifier.loadAllHistoryPaging(
      pageNum: pageNum,
    );
  }

  // 특정 EPUB의 history 정보를 불러오는 메서드
  Future<HistoryModel?> getHistory(String epubName) async {
    return await historyNotifier.getHistory(epubName);
  }

  // history를 삭제하는 메서드
  Future<void> deleteHistory(String epubName) async {
    await historyNotifier.deleteHistory(epubName);
  }
}

// HistoryService를 관리하는 프로바이더
final historyServiceProvider = Provider<HistoryService>((ref) {
  final historyNotifier = ref.watch(historyProvider.notifier);
  return HistoryService(ref, historyNotifier);
});
