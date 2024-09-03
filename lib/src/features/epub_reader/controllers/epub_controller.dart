import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_file_model.dart';
import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubController extends StateNotifier<AsyncValue<EpubBookModel>> {
  final EpubService _epubService;
  final String filePath;

  EpubController(StateNotifierProviderRef ref)
      : _epubService = ref.read(epubServiceProvider),
        filePath = ref.read(epubFileProvider) ?? '',
        super(const AsyncValue.loading());

  Future<void> loadEpub() async {
    state = await AsyncValue.guard(
      () async => await _epubService.loadEpub(filePath),
    );
  }
}

final epubControllerProvider =
    StateNotifierProvider<EpubController, AsyncValue<EpubBookModel>>(
  (ref) => EpubController(ref),
);
