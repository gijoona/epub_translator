import 'dart:async';
import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/translation/services/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class TranslationController extends AsyncNotifier<String> {
  late TranslationService _translationService;

  @override
  FutureOr<String> build() {
    _translationService = ref.watch(translationServiceProvider);
    return '';
  }

  Future<void> translateEpub() async {
    state = const AsyncValue.loading();
    EpubContentModel epub = ref.read(epubContentProvider.notifier).state!;
    ref.read(translatedEpubContentsProvider.notifier).state = [''];

    try {
      // final book = currentState.value;
      final epubContent = epub.content.Content;

      var translatedParagraphs = <String>[];

      // HTML 내용을 파싱하여 단락별로 나누기
      final document = parse(epubContent);
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

      // TODO :: 하나의 태그안에 이미지와 텍스트가 둘다 포함되어있는 경우에 대한 처리방안 필요
      final ignoredEL = ['div', 'a', 'span', 'image'];
      final replaceDocument = parse(documentOuterHtml);
      final htmlHead = replaceDocument.head;
      final htmlBodyChildrens = replaceDocument.querySelectorAll('body *');
      var translatedSyntax = '';
      for (var el in htmlBodyChildrens) {
        if (!ignoredEL.contains(el.localName) && 'p' != el.parent?.localName) {
          var appendTranslatedSyntax = '$translatedSyntax ${el.outerHtml}';
          if (utf8.encode(appendTranslatedSyntax).length > 1500) {
            String translatedParagraph =
                await _translationService.translateText(
              translatedSyntax, // HTML 태그 포함한 단락 전체를 번역
            );
            translatedParagraphs.add(
                '<html>${htmlHead!.outerHtml}<body>$translatedParagraph</body></html>');

            refreshTranslatedEpubContentsProvider(translatedParagraphs);

            translatedSyntax = el.text; // 현재 단락을 새로 시작
          } else {
            translatedSyntax = appendTranslatedSyntax; // 단락 누적
          }
        }
      }

      // 마지막 번역되지 않은 텍스트 처리
      if (translatedSyntax.isNotEmpty) {
        String translatedParagraph = await _translationService.translateText(
          translatedSyntax,
        );
        translatedParagraphs.add(
            '<html>${htmlHead!.outerHtml}<body>$translatedParagraph</body></html>');

        refreshTranslatedEpubContentsProvider(translatedParagraphs);
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

  String escapeHtml(String input) {
    DocumentFragment fragment = DocumentFragment.html(input);
    return fragment.text ?? ''; // HTML 엔티티를 처리해줌
  }

  void refreshTranslatedEpubContentsProvider(List<String> epubTranslateList) {
    EpubContentModel epub = ref.read(epubContentProvider.notifier).state!;
    final currContentNum = epub.currContentNum;
    var epubTranslates = epub.translates ?? {'$currContentNum': <String>[]};
    epubTranslates['$currContentNum'] = epubTranslateList;

    ref.read(epubContentProvider.notifier).state = epub.copyWith(
      translates: epubTranslates,
    );
  }
}

final translatedEpubContentsProvider =
    StateProvider<List<String>>((ref) => ['']);

final translationControllerProvider =
    AsyncNotifierProvider<TranslationController, String>(
  () => TranslationController(),
);
