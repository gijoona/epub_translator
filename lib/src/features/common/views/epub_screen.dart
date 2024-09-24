import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/src/widgets/image.dart' as Images;

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
  bool _isVisibleFAB = false; // 기능버튼 Visible 플래그
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
      final currentScroll = _scrollController.offset;
      final totalScroll = _scrollController.position.maxScrollExtent;
      setState(() {
        _scrollProgress = (currentScroll / totalScroll)
            .clamp(0.0, 1.0); // Ensure progress is between 0 and 1
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

  void _toggleVisibleFAB() {
    setState(() {
      _isVisibleFAB = !_isVisibleFAB;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  Widget appbarBackgroundImage() {
    try {
      final base64Image = ref.read(epubServiceProvider).getImageAsBase64(
            _book!.images.keys.first,
          );

      return Images.Image.memory(
        base64Decode(base64Image.split(',').last),
        fit: BoxFit.cover,
      );
    } catch (err) {
      return const Text('Error loading image');
    }
  }

  @override
  Widget build(BuildContext context) {
    var bookInfo = ref.read(epubBookProvider.notifier).state;
    var caption =
        bookInfo != null ? '${bookInfo.title} (${bookInfo.author})' : '';
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onDoubleTap: _toggleVisibleFAB,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    snap: false,
                    floating: true,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.blurBackground,
                        StretchMode.zoomBackground,
                      ],
                      centerTitle: true,
                      title: Text(
                        caption,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          appbarBackgroundImage(),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 0.5),
                                end: Alignment.center,
                                colors: <Color>[
                                  Color(0x60000000),
                                  Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.pushNamed(SettingsScreen.routeName);
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 30,
                        right: 30,
                        bottom: 60,
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_viewMode == EpubViewMode.both ||
                              _viewMode == EpubViewMode.original)
                            const Flexible(
                              flex: 1,
                              child: EpubReaderScreen(), // EPUB 원본
                            ),
                          if (_viewMode == EpubViewMode.both ||
                              _viewMode == EpubViewMode.translation)
                            const Flexible(
                              flex: 1,
                              child: EpubTranslationScreen(), // EPUB 번역
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              // 현재 컨텐츠정보를 보여줌. (현재 Contents 번호 / 전체 Contents 번호)
              if (_isVisibleFAB)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              // 번역 중임을 나타내는 LinearProgressIndicator
              if (_isTranslating)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              // 스크롤 상태를 표시하는 LinearProgressIndicator
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
        ),
        bottomNavigationBar: _buildBottomAppBar(),
        floatingActionButton: _buildSpeedDial(), // FAB 추가
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      heroTag: 'speed-dial-hero-tag',
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 5,
      childPadding: const EdgeInsets.all(5),
      childrenButtonSize: const Size(56.0, 56.0),
      buttonSize: const Size(56.0, 56.0),
      spaceBetweenChildren: 5,
      closeManually: true,
      visible: _isVisibleFAB,
      elevation: 8.0,
      animationCurve: Curves.elasticInOut,
      children: [
        // 번역
        SpeedDialChild(
          onTap: _isTranslating ? null : _translateBook,
          label: 'Translate',
          child: _isTranslating
              ? const CircularProgressIndicator()
              : const Icon(Icons.translate),
        ),
        // 화면분할모드 변경
        SpeedDialChild(
          onTap: _changeView,
          label: 'ChangeView',
          child: const FaIcon(FontAwesomeIcons.tableColumns),
        ),
      ],
    );
  }

  // BottomAppBar로 챕터 및 콘텐츠 이동 처리
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      height: 44, // 기본 BottomAppBar는 height가 너무 커서 고정크기 부여
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            // BottomAppBar를 4등분하여 각 부분을 탭할 때마다 챕터/콘텐츠 이동
            _buildBottomAppBarButton(
              width: constraints.maxWidth / 4,
              height: constraints.maxHeight,
              icon: Icons.keyboard_double_arrow_left_rounded,
              tooltip: 'Previous Chapter',
              onTap: () => _changeChapterIndex(-1),
            ),
            _buildDivider(),
            _buildBottomAppBarButton(
              width: constraints.maxWidth / 4,
              height: constraints.maxHeight,
              icon: Icons.keyboard_arrow_left_rounded,
              tooltip: 'Previous Content',
              onTap: () => _changeContentsIndex(-1),
            ),
            _buildDivider(),
            _buildBottomAppBarButton(
              width: constraints.maxWidth / 4,
              height: constraints.maxHeight,
              icon: Icons.keyboard_arrow_right_rounded,
              tooltip: 'Next Content',
              onTap: () => _changeContentsIndex(1),
            ),
            _buildDivider(),
            _buildBottomAppBarButton(
              width: constraints.maxWidth / 4,
              height: constraints.maxHeight,
              icon: Icons.keyboard_double_arrow_right_rounded,
              tooltip: 'Next Chapter',
              onTap: () => _changeChapterIndex(1),
            ),
          ],
        ),
      ),
    );
  }

  // BottomAppBar 버튼
  Widget _buildBottomAppBarButton({
    required double width,
    required double height,
    required IconData icon,
    required String tooltip,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        width: width - 10,
        height: height,
        child: Icon(icon, size: 24),
      ),
    );
  }

  // Divider 추가
  Widget _buildDivider() {
    return VerticalDivider(
      color: Colors.grey.shade400,
      thickness: 1,
      width: 1,
    );
  }
}
