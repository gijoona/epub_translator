import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/src/widgets/image.dart' as Images;

class EpubReaderScreen extends ConsumerStatefulWidget {
  static const routerURL = '/epubReader';
  static const routerName = 'epubReader';

  const EpubReaderScreen({super.key});

  @override
  ConsumerState<EpubReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<EpubReaderScreen> {
  int _currChapterIdx = 0;
  int _maxChapterIdx = 1;

  @override
  void initState() {
    super.initState();
    ref.read(epubControllerProvider.notifier).loadEpub();
  }

  void _chapterChange(int addIndex) {
    int chgChapterIdx = _currChapterIdx + addIndex;

    if (chgChapterIdx < 0) return;
    if (chgChapterIdx >= _maxChapterIdx) return;

    setState(() {
      _currChapterIdx = chgChapterIdx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final epubState = ref.watch(epubControllerProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EPUB Reader'),
          actions: [
            IconButton(
              onPressed: () => _chapterChange(-1),
              icon: const Icon(Icons.arrow_back),
            ),
            Text(' $_currChapterIdx'),
            const Text(
              ' / ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_maxChapterIdx - 1} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => _chapterChange(1),
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        body: epubState.when(
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('$error'),
          ),
          data: (book) {
            _maxChapterIdx = book.chapters.length;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Title: ${book.title}'),
                    Text('Author: ${book.author}'),
                    Text(
                      'Chapter: ${book.chapters[_currChapterIdx].Title}',
                    ),
                    Html(
                      data: book.chapters[_currChapterIdx].HtmlContent,
                      style: {
                        "body": Style(
                          fontSize: FontSize(18.0),
                          lineHeight: const LineHeight(1.5),
                        ),
                        "h1": Style(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize(24.0),
                        ),
                      },
                      extensions: [
                        TagExtension(
                          tagsToExtend: {'img'},
                          builder: (extensionContext) {
                            final base64Image =
                                ref.read(epubServiceProvider).getImageAsBase64(
                                      '${extensionContext.attributes['src']}',
                                    );

                            return Images.Image.memory(
                              base64Decode(base64Image.split(',').last),
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
