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

    return EpubContentsRender(
      contents: contents.outerHtml,
    );
  }
}
