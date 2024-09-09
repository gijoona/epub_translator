import 'package:epub_translator/src/features/common/widgets/epub_contents_render.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubReaderScreen extends ConsumerStatefulWidget {
  static const routerURL = '/epubReader';
  static const routerName = 'epubReader';

  const EpubReaderScreen({
    super.key,
  });

  @override
  ConsumerState<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends ConsumerState<EpubReaderScreen> {
  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(epubContentProvider);

    return contents == null
        ? const CircularProgressIndicator.adaptive()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Title: ${contents.title}'),
              Text('Author: ${contents.author}'),
              Text(
                'Chapter: ${contents.chapter.Title}',
              ),
              EpubContentsRender(
                contents: '${contents.contentFile.Content}',
              ),
            ],
          );
  }
}
