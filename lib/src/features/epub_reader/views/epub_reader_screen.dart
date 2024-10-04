import 'package:epub_translator/src/features/common/widgets/epub_contents_render.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:html/parser.dart' show parse;

class EpubReaderScreen extends ConsumerWidget {
  static const routerURL = '/epubReader';
  static const routerName = 'epubReader';

  final int contentsNum;

  const EpubReaderScreen({
    super.key,
    required this.contentsNum,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var epub = ref.read(epubContentProvider.notifier).state;
    final contents = parse(epub!.contents[contentsNum].Content);
    final elements = contents.querySelectorAll('body > div > *');

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true, // <==== limit height. 리스트뷰 크기 고정
        primary: false, // <====  disable scrolling. 리스트뷰 내부는 스크롤 안할거임
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return EpubContentsRender(
            contents: elements[index].outerHtml,
          );
        },
      ),
    );
  }
}
