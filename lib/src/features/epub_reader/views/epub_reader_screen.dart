import 'package:epub_translator/src/features/common/widgets/epub_contents_render.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:html/parser.dart' show parse;
import 'dart:convert';

class EpubReaderScreen extends ConsumerWidget {
  static const routerURL = '/epubReader';
  static const routerName = 'epubReader';

  final int contentsNum;

  const EpubReaderScreen({
    super.key,
    required this.contentsNum,
  });

  List<String> splitContentSection(EpubContentModel epub) {
    final contents = parse(epub.contents[contentsNum].Content);
    final elements = contents.querySelectorAll('body > div > *');

    List<String> translatedParagraphs = [];
    var translatedSyntax = '';

    for (var paragraph in elements) {
      var appendTranslatedSyntax = translatedSyntax + paragraph.outerHtml;
      if (utf8.encode(appendTranslatedSyntax).length > 1500) {
        translatedParagraphs.add(appendTranslatedSyntax);
        translatedSyntax = paragraph.outerHtml; // 현재 단락을 새로 시작
      } else {
        translatedSyntax = appendTranslatedSyntax; // 단락 누적
      }
    }

    // 마지막 번역되지 않은 텍스트 처리
    if (translatedSyntax.isNotEmpty) {
      translatedParagraphs.add(translatedSyntax);
    }

    return translatedParagraphs;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var epub = ref.read(epubContentProvider.notifier).state;
    var contentList = splitContentSection(epub!);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true, // <==== limit height. 리스트뷰 크기 고정
        primary: false, // <====  disable scrolling. 리스트뷰 내부는 스크롤 안할거임
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          return EpubContentsRender(
            contents: contentList[index],
          );
        },
      ),
    );
  }
}
