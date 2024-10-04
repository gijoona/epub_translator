import 'package:epub_translator/src/features/common/widgets/epub_contents.dart';
import 'package:epub_translator/src/features/common/widgets/epub_pagenum.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 화면모드
/// 0 : 원본/번역 둘다 표시
/// 1 : 원본만 표시
/// 2 : 번역만 표시
enum EpubViewMode { both, original, translation }

// 스크롤 진행상황을 표시
final scrollProgressProvider = StateProvider((ref) => 0.0);

final visibleFABProvider = StateProvider((ref) => false);

class EpubScreen extends ConsumerStatefulWidget {
  static const routeURL = '/epub';
  static const routeName = 'epub';

  const EpubScreen({super.key});

  @override
  ConsumerState<EpubScreen> createState() => _EpubScreenState();
}

class _EpubScreenState extends ConsumerState<EpubScreen> {
  final PageController _pageController = PageController();
  late ScrollController _contentScrollController;

  EpubViewMode _viewMode = EpubViewMode.original;
  int _maxContentsIdx = 1;
  bool _isTranslating = false; // 번역 상태 플래그
  bool _isVisibleFAB = false; // 기능버튼 Visible 플래그
  late EpubBookModel? _book;
  EpubChapter? _chapter;
  double _childMaxScrollExtent = 0.0;

  // 페이지별로 ScrollController를 관리하는 Map
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    loadEpubBook();

    _contentScrollController = _getScrollController(0);
  }

  void _onScrollUpdate(double offset, double maxScrollExtent) {
    // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산하여 진행 상태를 업데이트
    final currentScroll = offset;
    _childMaxScrollExtent = maxScrollExtent;

    var scrollProgress =
        (currentScroll / _childMaxScrollExtent).clamp(0.0, 1.0);
    ref.read(scrollProgressProvider.notifier).state = scrollProgress;
  }

  Future<void> loadEpubBook() async {
    _book = ref.read(epubBookProvider.notifier).state;
    if (_book != null) {
      _maxContentsIdx = _book!.contents.length;
    }
  }

  ScrollController _getScrollController(int pageIndex) {
    // 페이지 인덱스에 해당하는 ScrollController를 반환하거나 생성
    if (!_scrollControllers.containsKey(pageIndex)) {
      _scrollControllers[pageIndex] = ScrollController();
    }
    return _scrollControllers[pageIndex]!;
  }

  void _changeContentsIndex(String cmd) {
    switch (cmd) {
      case 'prev':
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
      case 'next':
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
    }

    ref.read(scrollProgressProvider.notifier).state = 0.0;
  }

  void _changeChapterIndex(int addIndex) {
    var epubInfo = ref.read(epubContentProvider.notifier).state!;
    int currChapterIdx = -1;
    int currContentNum;

    if (epubInfo.chapter != null) {
      currChapterIdx = epubInfo.chapters.indexOf(epubInfo.chapter!);
    }

    int chgChapterIdx =
        (currChapterIdx + addIndex).clamp(-1, epubInfo.chapters.length);

    if (chgChapterIdx == -1) {
      currContentNum = 0;
      _chapter = null;
    } else if (chgChapterIdx == epubInfo.chapters.length) {
      currContentNum = epubInfo.contents.length - 1;
      _chapter = epubInfo.chapters.last;
    } else {
      _chapter = epubInfo.chapters[chgChapterIdx];
      var targetKey = _chapter!.ContentFileName;
      currContentNum = _book!.contents.keys.toList().indexOf(targetKey!);
    }

    _pageController.animateToPage(
      currContentNum,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );

    ref.read(scrollProgressProvider.notifier).state = 0.0;
  }

  void _translateBook() async {
    if (_isTranslating) return; // 이미 번역 중일 경우 중복호출 방지

    _isTranslating = true;
    setState(() {}); // 번역 시작 시 상태갱신

    try {
      await ref.read(translationControllerProvider.notifier).translateEpub();
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
    _isVisibleFAB = !_isVisibleFAB;
    ref.read(visibleFABProvider.notifier).state = _isVisibleFAB;
  }

  // 스크롤 진행상태를 표시하는 LinearProgressIndicator에 수평 스와이프 제스처 추가 (수평 스와이프 시 스크롤 이동)
  void _handleScrollHorizontalSwipe(DragUpdateDetails details) {
    var currPositionPercent =
        (details.localPosition.dx / MediaQuery.of(context).size.width)
            .clamp(0.0, 1.0);
    var jumpScrollOffset = (_childMaxScrollExtent * currPositionPercent);
    _contentScrollController.jumpTo(jumpScrollOffset);
  }

  void _onPageChanged(int page) {
    _contentScrollController = _getScrollController(page);

    var epubContent = ref.read(epubContentProvider.notifier).state;
    ref.read(epubContentProvider.notifier).state = epubContent!.copyWith(
      currContentNum: page,
      chapter: _chapter,
      content: epubContent.contents[page],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // ScrollController를 모두 해제
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bookInfo = ref.read(epubBookProvider.notifier).state;
    var caption =
        bookInfo != null ? '${bookInfo.title} (${bookInfo.author})' : '';
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: _toggleVisibleFAB,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _maxContentsIdx,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, contentsNum) {
                  final scrollController = _getScrollController(contentsNum);

                  return EpubContents(
                    caption: caption,
                    viewMode: _viewMode,
                    contentsNum: contentsNum,
                    scrollController: scrollController,
                    onScrollUpdate: _onScrollUpdate,
                  );
                },
              ),
              // 현재 컨텐츠정보를 보여줌. (현재 Contents 번호 / 전체 Contents 번호)
              Consumer(builder: (context, ref, child) {
                var isVisible = ref.watch(visibleFABProvider);
                return !isVisible
                    ? Container()
                    : Positioned(
                        top: 70,
                        right: 10,
                        child: EpubPageNum(maxContentsIdx: _maxContentsIdx),
                      );
              }),
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
                child: GestureDetector(
                  onHorizontalDragUpdate: _handleScrollHorizontalSwipe,
                  child: Consumer(
                    builder: (context, ref, child) {
                      var scrollProgress = ref.watch(scrollProgressProvider);
                      return Container(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: LinearProgressIndicator(
                          value: scrollProgress,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAppBar(),
        floatingActionButton: _buildSpeedDial(), // FAB 추가
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Consumer(builder: (context, ref, child) {
      var isVislble = ref.watch(visibleFABProvider);
      return !isVislble
          ? const SizedBox(height: 0)
          : SpeedDial(
              heroTag: 'speed-dial-hero-tag',
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 5,
              childPadding: const EdgeInsets.all(5),
              childrenButtonSize: const Size(56.0, 56.0),
              buttonSize: const Size(56.0, 56.0),
              spaceBetweenChildren: 5,
              closeManually: true,
              // visible: ref.watch(visibleFABProvider),
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
    });
  }

  // BottomAppBar로 챕터 및 콘텐츠 이동 처리
  Widget _buildBottomAppBar() {
    return Consumer(builder: (context, ref, child) {
      var isVislble = ref.watch(visibleFABProvider);
      return !isVislble
          ? const SizedBox(height: 0)
          : BottomAppBar(
              height: 55, // 기본 BottomAppBar는 height가 너무 커서 고정크기 부여
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
                      onTap: () => _changeContentsIndex('prev'),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: constraints.maxWidth / 4,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_arrow_right_rounded,
                      tooltip: 'Next Content',
                      onTap: () => _changeContentsIndex('next'),
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
    });
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
        width: width - 3,
        height: height,
        child: Icon(icon, size: 30),
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
