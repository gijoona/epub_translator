import 'dart:async';
import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/translation/services/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:html/parser.dart' show parse;

class TranslationController extends AsyncNotifier<String> {
  late TranslationService _translationService;

  @override
  FutureOr<String> build() {
    _translationService = ref.watch(translationServiceProvider);
    return '';
  }

  Future<void> translateEpub() async {
    final currentState = state;
    EpubContentModel contentModel =
        ref.read(epubContentProvider.notifier).state!;
    ref.read(translatedEpubContentsProvider.notifier).state = [''];

    if (currentState is AsyncData<String>) {
      try {
        // final book = currentState.value;
        final chapterContent = contentModel.contentFile.Content;

        // HTML 내용을 파싱하여 단락별로 나누기
        final document = parse(chapterContent);
        String documentOuterHtml = document.outerHtml;

        // 일본 소설 번역 중 후리가나를 표현하기 위해 사용하는 ruby 태그는 번역이 안되므로 별도 처리.
        final rubyElements = document.getElementsByTagName('ruby');
        if (rubyElements.isNotEmpty) {
          for (var ruby in rubyElements) {
            final rbElements = ruby.getElementsByTagName('rb');
            var rbInnerHtml = '';
            for (var rb in rbElements) {
              rbInnerHtml += rb.innerHtml;
            }
            documentOuterHtml =
                documentOuterHtml.replaceAll(ruby.outerHtml, rbInnerHtml);
          }
        }

        final replaceDocument = parse(documentOuterHtml);
        final paragraphs = replaceDocument.getElementsByTagName('p');

        List<String> translatedParagraphs = [];

        // 각 단락을 번역
        var translatedSyntax = '';
        for (var paragraph in paragraphs) {
          var appendTranslatedSyntax = translatedSyntax + paragraph.outerHtml;
          if (utf8.encode(appendTranslatedSyntax).length > 1500) {
            String translatedParagraph =
                await _translationService.translateText(
              translatedSyntax, // HTML 태그 포함한 단락 전체를 번역
            );
            translatedParagraphs.add(translatedParagraph);
            refreshTranslatedEpubContentsProvider(translatedParagraph);
            translatedSyntax = paragraph.outerHtml; // 현재 단락을 새로 시작
          } else {
            translatedSyntax = appendTranslatedSyntax; // 단락 누적
          }
        }

        // 마지막 번역되지 않은 텍스트 처리
        if (translatedSyntax.isNotEmpty) {
          String translatedParagraph = await _translationService.translateText(
            translatedSyntax,
          );
          translatedParagraphs.add(translatedParagraph);
          refreshTranslatedEpubContentsProvider(translatedParagraph);
        }

        // 번역된 단락들을 결합하여 새로운 챕터 내용 구성
        final translatedContent = translatedParagraphs.join();

        // 상태를 번역된 책으로 업데이트
        state = AsyncValue.data(translatedContent);
      } catch (err) {
        // 에러 발생 시 에러 상태로 업데이트
        state = AsyncValue.error(err, StackTrace.fromString(err.toString()));
      }
    }
  }

  void refreshTranslatedEpubContentsProvider(String translatedContent) {
    var epubContentsList =
        ref.read(translatedEpubContentsProvider.notifier).state;
    epubContentsList.add(translatedContent);
    ref.read(translatedEpubContentsProvider.notifier).state = [
      ...epubContentsList
    ];
  }
}

final translatedEpubContentsProvider =
    StateProvider<List<String>>((ref) => ['']);

final translationControllerProvider =
    AsyncNotifierProvider<TranslationController, String>(
  () => TranslationController(),
);
