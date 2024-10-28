import 'package:epub_translator/src/features/epub_reader/widgets/epub_contents_render_widget.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
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
    final document = parse(epub.contents[contentsNum].Content);
    // TODO :: 특정 케이스의 경우 body > div 외부에도 내용이 있음. 조치 필요
    // final elements = contents.querySelectorAll('body > *');
    final elements = document.body!.children;
    const contentSpliteByte = 3000;

    List<String> contentParagraphs = [];
    var contentSyntax = '';

    for (var paragraph in elements) {
      var appendContentsSyntax = contentSyntax + paragraph.outerHtml;
      if (utf8.encode(appendContentsSyntax).length > contentSpliteByte) {
        if (contentSyntax.trim().isNotEmpty) {
          contentParagraphs.add(contentSyntax);
        }
        contentSyntax = paragraph.outerHtml; // 현재 단락을 새로 시작
      } else {
        contentSyntax = appendContentsSyntax; // 단락 누적
      }
    }

    // 마지막 남은 텍스트 처리
    if (contentSyntax.isNotEmpty) {
      contentParagraphs.add(contentSyntax);
    }

    return contentParagraphs;
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
          return EpubContentsRenderWidget(
            contents: contentList[index],
          );
        },
      ),
    );
  }
}
