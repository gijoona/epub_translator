import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class EpubScreen extends ConsumerStatefulWidget {
  static const routeURL = '/epub';
  static const routeName = 'epub';

  const EpubScreen({super.key});

  @override
  ConsumerState<EpubScreen> createState() => _EpubScreenState();
}

class _EpubScreenState extends ConsumerState<EpubScreen> {
  int _viewMode = 0;
  int _currContentsIdx = 0;
  int _maxContentsIdx = 1;
  late EpubBookModel? _book;
  late EpubChapter? _chapter;
  final ScrollController _scrollController = ScrollController();

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

  void _changeChapterIndex(int addIndex) {
    int currChapterIdx = _book!.chapters.indexOf(_chapter!);
    int chgChapterIdx = currChapterIdx + addIndex;
    if (chgChapterIdx < 0 || _book!.chapters.length <= chgChapterIdx) return;

    EpubChapter chgChapter = _book!.chapters[chgChapterIdx];
    int searchContentsIdx = 0;
    _book!.contents.forEach((key, value) {
      if (key == chgChapter.ContentFileName) {
        _currContentsIdx = searchContentsIdx;
        loadEpubContents(searchContentsIdx);
        return;
      } else {
        searchContentsIdx++;
      }
    });
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

    _scrollPositionReset();
  }

  void _scrollPositionReset() {
    // 스크롤을 제일 위로 올리는 코드
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _translateBook() async {
    const targetLanguage = 'ko'; // 예시로 한국어로 번역
    await ref
        .read(translationControllerProvider.notifier)
        .translateEpub(targetLanguage);
  }

  void _changeView() {
    var chageViewMode = 0;
    switch (_viewMode) {
      case 0:
        chageViewMode = 1;
        break;
      case 1:
        chageViewMode = 2;
        break;
      default:
        chageViewMode = 0;
        break;
    }

    setState(() {
      _viewMode = chageViewMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bookInfo = ref.read(epubBookProvider.notifier).state;
    var caption =
        bookInfo != null ? '${bookInfo.title} (${bookInfo.author})' : '';
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(caption),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _changeView,
              icon: const FaIcon(FontAwesomeIcons.tableColumns),
            ),
            IconButton(
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_viewMode == 0 || _viewMode == 1)
                  const Flexible(
                    flex: 1,
                    child: EpubReaderScreen(),
                  ),
                if (_viewMode == 0 || _viewMode == 2)
                  const Flexible(
                    flex: 1,
                    child: EpubTranslationScreen(),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFAB(), // FAB 추가
      ),
    );
  }

  Widget _buildFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 번역 버튼
        FloatingActionButton(
          heroTag: "translate",
          onPressed: _translateBook,
          tooltip: 'Translate',
          child: const Icon(Icons.translate),
        ),
        const SizedBox(width: 10),
        // 이전 챕터로 이동
        FloatingActionButton(
          heroTag: "prevChapter",
          onPressed: () => _changeChapterIndex(-1),
          tooltip: 'Previous Chapter',
          child: const Icon(Icons.keyboard_double_arrow_left_rounded),
        ),
        const SizedBox(width: 10),
        // 이전 콘텐츠로 이동
        FloatingActionButton(
          heroTag: "prev",
          onPressed: () => _changeContentsIndex(-1),
          tooltip: 'Previous Content',
          child: const Icon(Icons.keyboard_arrow_left_rounded),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            children: [
              TextSpan(text: ' $_currContentsIdx'),
              const TextSpan(
                text: ' / ',
              ),
              TextSpan(
                text: '${_maxContentsIdx - 1} ',
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // 다음 콘텐츠로 이동
        FloatingActionButton(
          heroTag: "next",
          onPressed: () => _changeContentsIndex(1),
          tooltip: 'Next Content',
          child: const Icon(Icons.keyboard_arrow_right_rounded),
        ),
        const SizedBox(width: 10),
        // 다음 챕터로 이동
        FloatingActionButton(
          heroTag: "nextChapter",
          onPressed: () => _changeChapterIndex(1),
          tooltip: 'Next Chapter',
          child: const Icon(Icons.keyboard_double_arrow_right_rounded),
        ),
      ],
    );
  }
}
