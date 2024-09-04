import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_file_model.dart';
import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:epub_translator/src/features/epub_reader/services/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' show parse;

class EpubController extends StateNotifier<AsyncValue<EpubBookModel>> {
  final EpubService _epubService;
  final TranslationService _translationService;
  final String filePath;

  EpubController(StateNotifierProviderRef ref)
      : _epubService = ref.read(epubServiceProvider),
        _translationService = ref.read(translationServiceProvider),
        filePath = ref.read(epubFileProvider) ?? '',
        super(const AsyncValue.loading());

  Future<void> loadEpub() async {
    state = await AsyncValue.guard(
      () async => await _epubService.loadEpub(filePath),
    );
  }

  Future<void> translateEpub(int chapterIdx, String targetLanguage) async {
    final currentState = state;
    if (currentState is AsyncData<EpubBookModel>) {
      try {
        // 로딩 상태로 설정
        state = const AsyncValue.loading();

        final book = currentState.value;
        final chapterContent = book.chapters[chapterIdx].HtmlContent;

        if (chapterContent != null) {
          // HTML 내용을 파싱하여 단락별로 나누기
          final document = parse(chapterContent);
          String documentOuterHtml = document.outerHtml;

          // 일본 소설 번역 중 후리가나를 표현하기 위해 사용하는 ruby 태그는 번역이 안되므로 별도 처리.
          final rubyElements = document.getElementsByTagName('ruby');
          if (rubyElements.isNotEmpty) {
            for (var ruby in rubyElements) {
              final rbElements = ruby.getElementsByTagName('rb');
              for (var rb in rbElements) {
                documentOuterHtml =
                    documentOuterHtml.replaceAll(ruby.outerHtml, rb.innerHtml);
              }
            }
          }

          final replaceDocument = parse(documentOuterHtml);
          final paragraphs = replaceDocument.getElementsByTagName('p');

          List<String> translatedParagraphs = [];

          // 각 단락을 번역
          for (var paragraph in paragraphs) {
            String translatedParagraph =
                await _translationService.translateText(
              paragraph.outerHtml, // HTML 태그 포함한 단락 전체를 번역
              targetLanguage,
            );
            translatedParagraphs.add(translatedParagraph);
          }

          // 번역된 단락들을 결합하여 새로운 챕터 내용 구성
          final translatedContent = translatedParagraphs.join();

          // 번역된 챕터 내용으로 업데이트
          book.chapters[chapterIdx].HtmlContent = translatedContent;

          // 상태를 번역된 책으로 업데이트
          state = AsyncValue.data(book);
        } else {
          throw Exception("Chapter content is null");
        }
      } catch (err) {
        // 에러 발생 시 에러 상태로 업데이트
        state = AsyncValue.error(err, StackTrace.fromString(err.toString()));
      }
    }
  }
}

final epubControllerProvider =
    StateNotifierProvider<EpubController, AsyncValue<EpubBookModel>>(
  (ref) => EpubController(ref),
);
