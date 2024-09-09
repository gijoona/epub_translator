import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:epubx/epubx.dart';
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
  int _currContentsIdx = 0;
  int _maxContentsIdx = 1;
  late EpubBookModel? _book;
  late EpubChapter? _chapter;

  @override
  void initState() {
    super.initState();
    loadEpubBook();
  }

  Future<void> loadEpubBook() async {
    _book = ref.read(epubBookProvider.notifier).state;
    if (_book != null) {
      _maxContentsIdx = _book!.contents.length;
      _chapter = _book!.chapters.first;
    }
  }

  void _changeContentsIndex(int addIndex) {
    int chgContentsIdx = _currContentsIdx + addIndex;

    if (chgContentsIdx < 0) return;
    if (chgContentsIdx >= _maxContentsIdx) return;

    _currContentsIdx = chgContentsIdx;

    loadEpubContents(_currContentsIdx);
    setState(() {});
  }

  void loadEpubContents(int index) {
    var currContentKey = _book!.contents.keys.elementAt(index);

    _chapter = _book!.chapters.firstWhere(
      (chapter) => chapter.ContentFileName == currContentKey,
      orElse: () => _chapter ?? _book!.chapters.first,
    );

    ref.read(epubContentProvider.notifier).state = EpubContentModel(
      title: _book!.title,
      author: _book!.author,
      chapter: _chapter!,
      contentKey: currContentKey,
      contentFile: _book!.contents[currContentKey]!,
    );
  }

  void _translateBook() async {
    const targetLanguage = 'ko'; // 예시로 한국어로 번역
    await ref
        .read(translationControllerProvider.notifier)
        .translateEpub(targetLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EPUB Reader'),
          actions: [
            IconButton(
              onPressed: () => _changeContentsIndex(-1),
              icon: const Icon(Icons.arrow_back),
            ),
            Text(' $_currContentsIdx'),
            const Text(
              ' / ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_maxContentsIdx - 1} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => _changeContentsIndex(1),
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: EpubReaderScreen(),
                ),
                Flexible(
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
