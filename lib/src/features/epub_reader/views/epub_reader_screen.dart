import 'package:epub_translator/src/features/common/widgets/epub_contents_render.dart';
import 'package:epub_translator/src/features/epub_reader/controllers/epub_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubReaderScreen extends ConsumerStatefulWidget {
  static const routerURL = '/epubReader';
  static const routerName = 'epubReader';

  final int chapterIdx;

  const EpubReaderScreen({
    super.key,
    required this.chapterIdx,
  });

  @override
  ConsumerState<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends ConsumerState<EpubReaderScreen> {
  @override
  Widget build(BuildContext context) {
    final epubState = ref.watch(epubControllerProvider);

    return Container(
      child: epubState.when(
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('$error'),
        ),
        data: (book) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Title: ${book.title}'),
              Text('Author: ${book.author}'),
              Text(
                'Chapter: ${book.chapters[widget.chapterIdx].Title}',
              ),
              EpubContentsRender(
                contents: '${book.chapters[widget.chapterIdx].HtmlContent}',
              ),
            ],
          );
        },
      ),
    );
  }
}
