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

/// 화면모드
/// 0 : 원본/번역 둘다 표시
/// 1 : 원본만 표시
/// 2 : 번역만 표시
enum EpubViewMode { both, original, translation }

class EpubScreen extends ConsumerStatefulWidget {
  static const routeURL = '/epub';
  static const routeName = 'epub';

  const EpubScreen({super.key});

  @override
  ConsumerState<EpubScreen> createState() => _EpubScreenState();
}

class _EpubScreenState extends ConsumerState<EpubScreen> {
  EpubViewMode _viewMode = EpubViewMode.both;
  int _currContentsIdx = 0;
  int _maxContentsIdx = 1;
  bool _isTranslating = false; // 번역 상태 플래그
  late EpubBookModel? _book;
  late EpubChapter? _chapter;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0; // 스크롤 진행 상태

  @override
  void initState() {
    super.initState();
    loadEpubBook();

    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산하여 진행 상태를 업데이트
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      setState(() {
        _scrollProgress = _scrollController.offset /
            _scrollController.position.maxScrollExtent;
      });
    }
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

    // 번역영역만 보여지는 상태에서 contents를 이동하면 자동으로 번역이 호출되도록 처리
    if (_viewMode == EpubViewMode.translation) {
      _translateBook();
    }
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
    if (_isTranslating) return; // 이미 번역 중일 경우 중복호출 방지

    _isTranslating = true;
    const targetLanguage = 'ko'; // 예시로 한국어로 번역
    setState(() {}); // 번역 시작 시 상태갱신

    try {
      await ref
          .read(translationControllerProvider.notifier)
          .translateEpub(targetLanguage);
    } finally {
      _isTranslating = false;
      setState(() {}); // 번역 완료 시 상태갱신
    }
  }

  void _changeView() {
    // Enum 순환: both -> original -> translation -> both
    setState(() {
      _viewMode = EpubViewMode
          .values[(_viewMode.index + 1) % EpubViewMode.values.length];
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
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
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60),
              controller: _scrollController,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_viewMode == EpubViewMode.both ||
                        _viewMode == EpubViewMode.original)
                      const Flexible(
                        flex: 1,
                        child: EpubReaderScreen(),
                      ),
                    if (_viewMode == EpubViewMode.both ||
                        _viewMode == EpubViewMode.translation)
                      const Flexible(
                        flex: 1,
                        child: EpubTranslationScreen(),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'changeView',
                    tooltip: 'ChangeView',
                    onPressed: _changeView,
                    child: const FaIcon(FontAwesomeIcons.tableColumns),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "translate",
                    tooltip: 'Translate',
                    onPressed: _isTranslating ? null : _translateBook,
                    child: _isTranslating
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.translate),
                  ),
                ],
              ),
            ),
            if (_isTranslating)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _scrollProgress,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          ],
        ),
        floatingActionButton: _buildFAB(), // FAB 추가
      ),
    );
  }

  Widget _buildFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
