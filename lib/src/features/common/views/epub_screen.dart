import 'package:epub_translator/src/features/epub_reader/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubScreen extends ConsumerStatefulWidget {
  static const routerURL = '/epub';
  static const routerName = 'epub';

  const EpubScreen({super.key});

  @override
  ConsumerState<EpubScreen> createState() => _EpubScreenState();
}

class _EpubScreenState extends ConsumerState<EpubScreen> {
  int _currChapterIdx = 0;
  int _maxChapterIdx = 1;
  late EpubBookModel _book;

  @override
  void initState() {
    super.initState();
    loadEpub();
  }

  Future<void> loadEpub() async {
    _book = await ref.read(epubControllerProvider.notifier).loadEpub();
    _maxChapterIdx = _book.chapters.length;
  }

  void _chapterChange(int addIndex) {
    int chgChapterIdx = _currChapterIdx + addIndex;

    if (chgChapterIdx < 0) return;
    if (chgChapterIdx >= _maxChapterIdx) return;

    setState(() {
      _currChapterIdx = chgChapterIdx;
    });
  }

  void _translateBook() async {
    const targetLanguage = 'ko'; // 예시로 한국어로 번역
    await ref
        .read(translationControllerProvider.notifier)
        .translateEpub(_book.chapters[_currChapterIdx], targetLanguage);
  }

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              onPressed: _translateBook,
              icon: const Icon(Icons.translate),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: EpubReaderScreen(
                    chapterIdx: _currChapterIdx,
                  ),
                ),
                const Flexible(
                  flex: 1,
                  child: EpubTranslationScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
