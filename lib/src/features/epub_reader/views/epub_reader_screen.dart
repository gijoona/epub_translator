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

  // 전체 내용을 한번에 그리면 버벅거리는 현상이 있으므로 ListView를 이용하여 처리하기 위해 내용을 byte단위로 짤라서 List로 처리.
  List<String> splitContentSection(EpubContentModel epub) {
    final contents = parse(epub.contents[contentsNum].Content);
    // TODO :: 특정 케이스의 경우 body > div 외부에도 내용이 있음. 조치 필요
    final elements = contents.querySelectorAll('body > div > *');
    const contentSpliteByte = 3000;

    List<String> translatedParagraphs = [];
    var translatedSyntax = '';

    for (var paragraph in elements) {
      var appendTranslatedSyntax = translatedSyntax + paragraph.outerHtml;
      if (utf8.encode(appendTranslatedSyntax).length > contentSpliteByte) {
        translatedParagraphs.add(appendTranslatedSyntax);
        translatedSyntax = paragraph.outerHtml; // 현재 단락을 새로 시작
      } else {
        translatedSyntax = appendTranslatedSyntax; // 단락 누적
      }
    }

    // 마지막 남은 텍스트 처리
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
