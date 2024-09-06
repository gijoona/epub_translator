import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubController extends StateNotifier<AsyncValue<void>> {
  final EpubService _epubService;

  EpubController(StateNotifierProviderRef ref)
      : _epubService = ref.read(epubServiceProvider),
        super(const AsyncValue.loading());

  Future<void> loadEpub(String filePath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () async => await _epubService.loadEpub(filePath));
  }
}

final epubControllerProvider =
    StateNotifierProvider<EpubController, AsyncValue<void>>(
  (ref) => EpubController(ref),
);
