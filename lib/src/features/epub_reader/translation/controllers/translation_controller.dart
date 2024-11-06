import 'dart:async';
import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/translation/services/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' show parse;
// ignore: depend_on_referenced_packages
import 'package:html/dom.dart';

class TranslationController extends AsyncNotifier<String> {
  late TranslationService _translationService;

  // 번역할 텍스트 추출 및 결합
  List<String> textNodes = [];
  List<Node> textNodeReferences = [];

  @override
  FutureOr<String> build() {
    _translationService = ref.watch(translationServiceProvider);
    return '';
  }

  Future<void> translateEpub() async {
    state = const AsyncValue.loading();

    textNodes = [];
    textNodeReferences = [];

    EpubContentModel epub = ref.read(epubContentProvider.notifier).state!;
    ref.read(translatedEpubContentsProvider.notifier).state = [''];

    try {
      final epubContent = epub.content.Content;

      // HTML 내용을 파싱하여 단락별로 나누기
      final document = parse(epubContent);
      String documentOuterHtml = document.outerHtml;

      final replaceDocument =
          parse(_cleanUntranslatableTags(document, documentOuterHtml));
      refreshTranslatedEpubContentsProvider(
          replaceDocument.body!.children.map((el) => el.outerHtml).toList());

      extractTextNodes(replaceDocument.body!);

      var translationProcessIdx = 0;
      List<String> translatedParagraphs = [];

      var translatedSyntax = '';
      for (var text in textNodes) {
        var appendTranslatedSyntax = '$translatedSyntax|||$text';
        if (utf8.encode(appendTranslatedSyntax).length > 1500) {
          String translatedParagraph = await _translationService.translateText(
            translatedSyntax, // HTML 태그 포함한 단락 전체를 번역
          );

          translatedParagraphs.add(translatedParagraph);
          List<String> translatedTexts = translatedParagraph.split('|||');

          if (translationProcessIdx == 0) translatedTexts.removeAt(0);

          for (int i = 0; i < translatedTexts.length; i++) {
            textNodeReferences[translationProcessIdx].text =
                translatedTexts.elementAtOrNull(i) ?? '';
            translationProcessIdx++;
          }

          refreshTranslatedEpubContentsProvider(replaceDocument.body!.children
              .map((el) => el.outerHtml)
              .toList());
          translatedSyntax = text; // 현재 단락을 새로 시작
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
        List<String> translatedTexts = translatedParagraph.split('|||');

        if (translationProcessIdx == 0) translatedTexts.removeAt(0);

        for (int i = 0; i < translatedTexts.length; i++) {
          textNodeReferences[translationProcessIdx].text =
              translatedTexts.elementAtOrNull(i) ?? '';
          translationProcessIdx++;
        }

        refreshTranslatedEpubContentsProvider(
            replaceDocument.body!.children.map((el) => el.outerHtml).toList());
      }

      // 번역이 완료되면 최종적으로 번역된 내용으로 치환하여 화면을 갱신한다.
      List<String> translatedTexts =
          translatedParagraphs.join('|||').split('|||');

      for (int i = 0; i < textNodeReferences.length; i++) {
        textNodeReferences[i].text =
            translatedTexts.elementAtOrNull(i + 1) ?? '';
      }

      refreshTranslatedEpubContentsProvider(
          replaceDocument.body!.children.map((el) => el.outerHtml).toList());

      // 번역된 단락들을 결합하여 새로운 챕터 내용 구성
      final translatedContent = replaceDocument.outerHtml;

      // 상태를 번역된 책으로 업데이트
      state = AsyncValue.data(translatedContent);
    } catch (err) {
      // 에러 발생 시 에러 상태로 업데이트
      state = AsyncValue.error(err, StackTrace.fromString(err.toString()));
    }
  }

  /// 특정 태그 처리 (ruby, span, em)
  String _cleanUntranslatableTags(Document document, String documentOuterHtml) {
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

    // 단락내 문장에 사용되는 span의 경우 번역문 대체 시 위치를 틀어지게 하므로 별도 처리.
    final spanElements = parse(documentOuterHtml).getElementsByTagName('span');
    if (spanElements.isNotEmpty) {
      for (var span in spanElements) {
        var spanInnerHtml = span.innerHtml;
        documentOuterHtml =
            documentOuterHtml.replaceAll(span.outerHtml, spanInnerHtml);
      }
    }

    // 단락내 문장에 사용되는 em의 경우 번역문 대체 시 위치를 틀어지게 하므로 별도 처리.
    final emElements = parse(documentOuterHtml).getElementsByTagName('em');
    if (emElements.isNotEmpty) {
      for (var em in emElements) {
        var emInnerHtml = em.innerHtml;
        documentOuterHtml =
            documentOuterHtml.replaceAll(em.outerHtml, emInnerHtml);
      }
    }

    return documentOuterHtml;
  }

  void extractTextNodes(Node node) {
    if (node.nodeType == Node.TEXT_NODE &&
        node.text != null &&
        node.text!.trim().isNotEmpty) {
      textNodes.add(node.text!.trim());
      textNodeReferences.add(node);
    } else {
      node.nodes.forEach(extractTextNodes); // 자식 노드 탐색
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
